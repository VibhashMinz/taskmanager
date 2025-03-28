import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanager/core/routes.dart/app_router.dart';
import 'package:taskmanager/presentation/blocs/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
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
                TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
                TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthCubit>().loginWithEmail(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                  },
                  child: const Text("Login"),
                ),
                const SizedBox(height: 10),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.error != null) {
                      return Text(state.error!, style: TextStyle(color: Colors.red));
                    }

                    return ElevatedButton(
                      onPressed: () {
                        context.read<AuthCubit>().signInWithGoogle();
                      },
                      child: const Text('Sign in with Google'),
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.signup);
                  },
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
