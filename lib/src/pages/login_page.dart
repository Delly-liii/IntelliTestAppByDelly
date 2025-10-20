import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(const SnackBar(content: Text('Signing in...')));
    final ok = await ApiService.instance.login(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
    scaffold.hideCurrentSnackBar();
    setState(() => _loading = false);
    if (ok) {
      scaffold.showSnackBar(const SnackBar(content: Text('Login successful')));
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      scaffold.showSnackBar(const SnackBar(content: Text('Invalid credentials')));
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
              constraints: BoxConstraints(maxWidth: isWide ? 640 : 420),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text('Welcome back. Sign in to continue.', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 18),

                      Form(
                        key: _formKey,
                        child: Column(children: [
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
                            validator: requiredField(),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              child: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Login'),
                            ),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('Don\'t have an account? '),
                        GestureDetector(onTap: () => Navigator.of(context).pushReplacementNamed('/register'), child: const Text('Create Account', style: TextStyle(color: Color(0xFF2563EB))))
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
