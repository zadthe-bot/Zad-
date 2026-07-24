import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _submit() async {
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'Password needs at least 6 characters.');
      return;
    }
    setState(() { _error = null; _loading = true; });
    try {
      await ref.read(authServiceProvider).signup(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.code == 'email-already-in-use' ? 'That email is already registered.' : 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Create account', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              const Text('Takes a minute.', style: TextStyle(color: AppColors.blackSoft)),
              const SizedBox(height: 28),
              TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Full name')),
              const SizedBox(height: 12),
              TextField(controller: _emailCtrl, decoration: const InputDecoration(hintText: 'Email'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              TextField(controller: _passCtrl, decoration: const InputDecoration(hintText: 'Password'), obscureText: true),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: AppColors.orangeDark, fontSize: 13)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: Text(_loading ? 'Creating…' : 'Sign up'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text.rich(TextSpan(
                    children: [
                      TextSpan(text: 'Have an account? ', style: TextStyle(color: AppColors.blackSoft)),
                      TextSpan(text: 'Log in', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w600)),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
