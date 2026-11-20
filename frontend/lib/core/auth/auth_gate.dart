import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api/api_client.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _needsLogin = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final client = context.read<ApiClient>();
      final status = await client.getAuthStatus();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _needsLogin = status['enabled'] == true && !client.isAuthenticated;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _needsLogin = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _login(String username, String password) async {
    setState(() => _error = '');
    try {
      final client = context.read<ApiClient>();
      final result = await client.login(username: username, password: password);
      if (result['authenticated'] == true) {
        client.setToken(result['access_token']?.toString() ?? '');
        if (!mounted) return;
        setState(() => _needsLogin = false);
      } else {
        if (!mounted) return;
        setState(() => _error = 'Authentication is disabled.');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    if (_needsLogin) {
      return MaterialApp(
        home: _LoginPage(onLogin: _login, error: _error),
      );
    }
    if (_error.isNotEmpty) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              _error,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}

class _LoginPage extends StatefulWidget {
  const _LoginPage({required this.onLogin, required this.error});

  final Future<void> Function(String username, String password) onLogin;
  final String error;

  @override
  State<_LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_username.text.trim().isEmpty || _password.text.isEmpty) return;
    setState(() => _loading = true);
    await widget.onLogin(_username.text.trim(), _password.text);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 380,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Keitaro Wrapper',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _username,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  if (widget.error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.error,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
