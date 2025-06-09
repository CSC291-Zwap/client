import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/services/auth_api_service.dart';
import 'package:client/data/models/user.dart';
import 'package:go_router/go_router.dart';

// Providers for form fields
final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final confirmPasswordProvider = StateProvider<String>((ref) => '');

final authApiServiceProvider = Provider<AuthApiService>(
  (ref) => AuthApiService(),
);

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(emailProvider);
    final password = ref.watch(passwordProvider);
    final confirmPassword = ref.watch(confirmPasswordProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                _buildLogo(),
                const SizedBox(height: 16),
                _buildTitle(),
                const SizedBox(height: 16),
                _buildTagline(),
                const SizedBox(height: 40),
                _buildFormFields(ref),
                const SizedBox(height: 32),
                _buildRegisterButton(
                  context,
                  ref,
                  email,
                  password,
                  confirmPassword,
                ),
                const SizedBox(height: 18),
                _buildFooter(context),
                // const Spacer(),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'By signing up, agree to terms and conditions',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return const Icon(Icons.all_inclusive, size: 80, color: Color(0xFF43A047));
  }

  Widget _buildTitle() {
    return const Text(
      'Zwap',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF43A047),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 1.2),
        borderRadius: BorderRadius.circular(25),
        color: Colors.green[50]?.withOpacity(0.7),
      ),
      child: const Text(
        'Finding amazing deals and\nSelling your gently used items',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF388E3C),
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFormFields(WidgetRef ref) {
    return Column(
      children: [
        TextField(
          onChanged: (value) => ref.read(emailProvider.notifier).state = value,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
            labelText: 'Email',
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          onChanged:
              (value) => ref.read(passwordProvider.notifier).state = value,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
            labelText: 'Password',
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          onChanged:
              (value) =>
                  ref.read(confirmPasswordProvider.notifier).state = value,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
            labelText: 'Confirm Password',
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(
    BuildContext context,
    WidgetRef ref,
    String email,
    String password,
    String confirmPassword,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill all fields')),
            );
            return;
          }
          if (password != confirmPassword) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Passwords do not match')),
            );
            return;
          }

          try {
            final authApi = ref.read(authApiServiceProvider);
            final response = await authApi.signup({
              'email': email,
              'password': password,
            });
            // Check for backend error (success: false)
            if (response.data['success'] == false) {
              final msg =
                  response.data['msg'] ?? 'Signup failed. Please try again.';
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(msg)));
              return;
            }

            // Proceed if success
            final data = response.data['data'];
            final userJson = data['newUser'];
            final token = data['token'];

            final user = User.fromJson(userJson);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Registered as ${user.email}')),
            );
            await Future.delayed(const Duration(milliseconds: 500));
            if (context.mounted) {
              context.push('/login');
            }
          } on DioException catch (e) {
            String errorMessage = 'Signup failed. Please try again.';
            if (e.response != null && e.response?.data != null) {
              final data = e.response?.data;
              if (data is Map && data['msg'] != null) {
                errorMessage = data['msg'].toString();
              } else if (data is Map && data['message'] != null) {
                errorMessage = data['message'].toString();
              }
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey,
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          'Register',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account? '),
        GestureDetector(
          onTap: () {
            context.push('/login');
          },
          child: const Text(
            'Login Here!',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
