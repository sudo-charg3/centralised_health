import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:centralised_health/providers/auth_provider.dart';
import 'package:centralised_health/screens/home_screen.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _abhaIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RegisterScreen({super.key});

  Future<void> _register(BuildContext context) async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).register(
        _abhaIdController.text,
        _passwordController.text,
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error - ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _abhaIdController,
              decoration: const InputDecoration(labelText: 'ABHA ID'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _register(context),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}