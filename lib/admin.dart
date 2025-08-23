import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

// ---------- helpers ----------
bool readBool(Map<String, dynamic> m, String key, {bool fallback = false}) {
  final v = m[key];
  return v is bool ? v : fallback;
}

String fmtTs(Timestamp? ts) {
  if (ts == null) return '—';
  final d = ts.toDate().toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}

Future<bool?> confirm(BuildContext context, String msg) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirm'),
      content: Text(msg),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Widget kv(String k, dynamic v) {
  final s = (v == null || (v is String && v.trim().isEmpty))
      ? '—'
      : v.toString();
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(s)),
      ],
    ),
  );
}

// ==================== GATE ====================
class AdminGate extends StatelessWidget {
  const AdminGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snap.data == null ? const LoginPage() : const AdminPanelPage();
      },
    );
  }
}

// ==================== LOGIN ====================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/admin');
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'invalid-credential':
          case 'wrong-password':
            _error = 'Invalid email or password.';
            break;
          case 'user-not-found':
            _error = 'No admin found with this email.';
            break;
          case 'too-many-requests':
            _error = 'Too many attempts. Please wait and try again.';
            break;
          default:
            _error = 'Auth error: ${e.code}';
        }
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 40,
                      color: BrandColors.primary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Admin Sign In',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) {
                        final x = (v ?? '').trim();
                        if (x.isEmpty) return 'Required';
                        final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(x);
                        return ok ? null : 'Invalid email';
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (v) =>
                          (v == null || v.length < 6) ? 'Min 6 chars' : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _busy ? null : _signIn,
                        child: _busy
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushReplacementNamed('/'),
                      child: const Text('← Back to site'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== PANEL ====================
class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  String _search = '';

  Stream<QuerySnapshot<Map<String, dynamic>>> _query() {
    return FirebaseFirestore.instance
        .collection('test_orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> backfillSeen() async {
    final qs = await FirebaseFirestore.instance.collection('test_orders').get();
    for (final d in qs.docs) {
      final m = d.data();
      if (!m.containsKey('seen')) {
        await d.reference.set({'seen': false}, SetOptions(merge: true));
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Backfill complete')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin • Inquiries'),
        actions: [
          IconButton(
            tooltip: 'Backfill unseen',
            onPressed: backfillSeen,
            icon: const Icon(
              Icons.build_circle_outlined,
              color: BrandColors.primary,
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          // ===== Responsive header (no overflow) =====
          Container(
            decoration: const BoxDecoration(gradient: redCardGradient),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.medical_services_outlined,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),

                // Title takes remaining space and ellipsizes
                const Expanded(
                  child: Text(
                    'Mirabella eShifa Lab — Admin',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Search box is flexible; shrinks on small widths (capped at 360)
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        hintText: 'Search name, phone, test…',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(.9),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(.18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) =>
                          setState(() => _search = v.toLowerCase()),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== List/Grid =====
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _query(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final docs = snap.data?.docs ?? [];
                final filtered = docs.where((d) {
                  final m = d.data();
                  final hay = [
                    m['name'] ?? '',
                    m['phone'] ?? '',
                    m['email'] ?? '',
                    m['test'] ?? '',
                    m['address'] ?? '',
                    m['notes'] ?? '',
                  ].join(' ').toLowerCase();
                  return hay.contains(_search);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No inquiries yet.'));
                }

                if (!isWide) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => InquiryTile(doc: filtered[i]),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 170,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) =>
                      InquiryCardWide(doc: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class InquiryTile extends StatelessWidget {
  const InquiryTile({super.key, required this.doc});
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final createdAt = (data['createdAt'] as Timestamp?);
    final preferred = (data['preferredDate'] as Timestamp?);
    final seen = readBool(data, 'seen');

    return Card(
      child: ListTile(
        leading: Icon(
          seen ? Icons.mark_email_read : Icons.mark_email_unread,
          color: seen ? Colors.green : Colors.redAccent,
        ),
        title: Text(
          '${data['name'] ?? 'Unnamed'} — ${data['test'] ?? ''}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${data['phone'] ?? ''}'
          '${(data['email'] ?? '').toString().isNotEmpty ? '  •  ${data['email']}' : ''}\n'
          'Created: ${fmtTs(createdAt)}'
          '${preferred != null ? '\nPreferred: ${fmtTs(preferred)}' : ''}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final ok = await confirm(context, 'Delete this inquiry?');
            if (ok == true) await doc.reference.delete();
          },
        ),
        onTap: () => showDetails(context, doc),
      ),
    );
  }
}

class InquiryCardWide extends StatelessWidget {
  const InquiryCardWide({super.key, required this.doc});
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final seen = readBool(data, 'seen');

    return Card(
      child: InkWell(
        onTap: () => showDetails(context, doc),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                seen ? Icons.mark_email_read : Icons.mark_email_unread,
                color: seen ? Colors.green : Colors.redAccent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? 'Unnamed',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data['test'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if ((data['phone'] ?? '').toString().isNotEmpty)
                          Chip(label: Text(data['phone'])),
                        if ((data['email'] ?? '').toString().isNotEmpty)
                          Chip(label: Text(data['email'])),
                        if ((data['address'] ?? '').toString().isNotEmpty)
                          Chip(
                            label: Text(
                              (data['address'] as String).length > 26
                                  ? '${(data['address'] as String).substring(0, 26)}…'
                                  : data['address'],
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'Created: ${fmtTs(data['createdAt'] as Timestamp?)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final ok = await confirm(context, 'Delete this inquiry?');
                  if (ok == true) await doc.reference.delete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showDetails(
  BuildContext context,
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
) async {
  final data = doc.data();
  final seen = readBool(data, 'seen');

  // mark as seen using merge to avoid overwriting existing fields
  if (!seen) await doc.reference.set({'seen': true}, SetOptions(merge: true));

  final screenW = MediaQuery.of(context).size.width;
  final maxW = screenW - 48; // margins on small screens

  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(data['name'] ?? 'Inquiry'),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, minWidth: 280),
        child: SizedBox(
          width: maxW.clamp(280.0, 560.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kv('Test', data['test']),
                kv('Phone', data['phone']),
                kv('Email', data['email']),
                kv('Address', data['address']),
                kv(
                  'Preferred Date',
                  fmtTs(data['preferredDate'] as Timestamp?),
                ),
                kv('Notes', data['notes']),
                const Divider(),
                kv('Created At', fmtTs(data['createdAt'] as Timestamp?)),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final next = !readBool(doc.data(), 'seen');
            await doc.reference.set({'seen': next}, SetOptions(merge: true));
            Navigator.pop(context);
          },
          child: Text(seen ? 'Mark Unread' : 'Mark Read'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
