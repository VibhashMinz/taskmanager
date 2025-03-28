import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanager/core/routes.dart/app_router.dart';
import 'package:taskmanager/presentation/blocs/auth_cubit.dart';
import 'package:taskmanager/presentation/blocs/task_bloc.dart';
import 'package:taskmanager/presentation/blocs/events.dart';
import 'package:taskmanager/presentation/widgets/custom_text_field.dart';
import 'package:taskmanager/presentation/widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.user != null) {
            // Load tasks after successful login
            context.read<TaskBloc>().add(LoadTasks());
            Navigator.pushReplacementNamed(context, AppRouter.taskList);
          }

          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 40),
                      CustomTextField(
                        controller: _emailController,
                        labelText: "Email",
                        prefixIcon: Icons.email_outlined,
                        type: TextFieldType.email,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        labelText: "Password",
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        obscureText: _obscurePassword,
                        onSuffixPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        type: TextFieldType.password,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: "Sign In",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().loginWithEmail(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                          }
                        },
                        isLoading: state.isLoading,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: "Sign in with Google",
                        variant: ButtonVariant.outline,
                        icon: Icons.g_mobiledata,
                        onPressed: () {
                          context.read<AuthCubit>().signInWithGoogle();
                        },
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRouter.signup);
                          },
                          child: const Text("Don't have an account? Sign up"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
