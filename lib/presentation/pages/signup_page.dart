import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanager/core/routes.dart/app_router.dart';
import 'package:taskmanager/presentation/blocs/auth_cubit.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.user != null) {
            Navigator.pushReplacementNamed(context, AppRouter.taskList);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name")),
                TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
                TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthCubit>().signUpWithEmail(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                  },
                  child: const Text("Sign Up"),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
