import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:client/services/auth_api_service.dart';
import 'package:client/data/models/user.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Providers for form fields
final loginEmailProvider = StateProvider<String>((ref) => '');
final loginPasswordProvider = StateProvider<String>((ref) => '');
final authApiServiceProvider = Provider<AuthApiService>(
  (ref) => AuthApiService(),
);

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  Future<void> _saveToken(String token) async {
    final box = Hive.box('authBox');
    await box.put('auth_token', token);
  }

  Future<void> _saveInfo(String id, String email) async {
    final box = Hive.box('authBox');
    await box.put('user_id', id);
    await box.put('user_email', email);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(loginEmailProvider);
    final password = ref.watch(loginPasswordProvider);

    return Scaffold(
      body: SafeArea(
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
              _buildLoginButton(context, ref, email, password),
              const SizedBox(height: 18),
              _buildFooter(context),
              const Spacer(),
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
          onChanged:
              (value) => ref.read(loginEmailProvider.notifier).state = value,
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
              (value) => ref.read(loginPasswordProvider.notifier).state = value,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
            labelText: 'Password',
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(
    BuildContext context,
    WidgetRef ref,
    String email,
    String password,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (email.isEmpty || password.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill all fields')),
            );
            return;
          }
          try {
            final authApi = ref.read(authApiServiceProvider);
            final response = await authApi.login({
              'email': email,
              'password': password,
            });

            final data = response.data['data'];
            final user = User(
              id: data['id'],
              name: null,
              email: data['email'],
              password: '',
              createdAt: '',
              updatedAt: '',
            );
            final token = data['token'];

            await _saveToken(token);
            await _saveInfo(user.id, user.email);

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Welcome, ${user.email}!')));
            await Future.delayed(const Duration(milliseconds: 500));
            if (context.mounted) {
              context.go('/');
            }
          } on DioException catch (e) {
            // DioException is the new name for DioError in recent dio versions
            String errorMessage = 'Login failed. Please try again.';
            if (e.response != null && e.response?.data != null) {
              // Try to extract a message from backend response
              final data = e.response?.data;
              if (data is Map && data['message'] != null) {
                errorMessage = data['message'].toString();
              }
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
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
          'Login',
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
        const Text("Don't have an Account? "),
        GestureDetector(
          onTap: () {
            context.push('/signup');
          },
          child: const Text(
            'Sign Up!',
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
