import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(const SnackBar(content: Text('Registering...')));
    final ok = await ApiService.instance.register(name: _nameCtrl.text.trim(), email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
    scaffold.hideCurrentSnackBar();
    setState(() => _loading = false);
    if (ok) {
      scaffold.showSnackBar(const SnackBar(content: Text('Registration successful')));
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      scaffold.showSnackBar(const SnackBar(content: Text('Registration failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      appBar: const PreferredSize(preferredSize: Size.fromHeight(64), child: TopBar()),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF60A5FA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 720 : 420),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Create Account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text('Join IntelliTest today.', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 18),

                      Form(
                        key: _formKey,
                        child: Column(children: [
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(prefixIcon: Icon(Icons.person), labelText: 'Full Name'),
                            validator: requiredField(),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(prefixIcon: Icon(Icons.alternate_email), labelText: 'Email'),
                            validator: emailField(),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordCtrl,
                            decoration: const InputDecoration(prefixIcon: Icon(Icons.lock), labelText: 'Password'),
                            obscureText: true,
                            validator: passwordField(),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmCtrl,
                            decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), labelText: 'Confirm Password'),
                            obscureText: true,
                            validator: (v) => matchValidator(v, _passwordCtrl.text, message: 'Passwords do not match'),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              child: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Register'),
                            ),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('Already have an account? '),
                        GestureDetector(onTap: () => Navigator.of(context).pushReplacementNamed('/login'), child: const Text('Login', style: TextStyle(color: Color(0xFF2563EB))))
                      ])
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
