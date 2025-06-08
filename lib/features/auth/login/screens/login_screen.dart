import 'package:client/features/profile/providers/profile_provider.dart';
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
final loginLoadingProvider = StateProvider<bool>((ref) => false);

// Safe auth service provider
final authApiServiceProvider = Provider<AuthApiService?>((ref) {
  try {
    return AuthApiService();
  } catch (e) {
    print('AuthApiService initialization failed: $e');
    return null;
  }
});

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
    final isLoading = ref.watch(loginLoadingProvider);
    final authService = ref.watch(authApiServiceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
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
                _buildLoginButton(
                  context,
                  ref,
                  email,
                  password,
                  authService,
                  isLoading,
                ),
                const SizedBox(height: 18),
                _buildFooter(context),
                const SizedBox(height: 16),
                if (authService == null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Text(
                      'Warning: API service unavailable.',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'By signing up, agree to terms and conditions',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
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
    AuthApiService? authService,
    bool isLoading,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            (authService == null || isLoading)
                ? null
                : () =>
                    _handleLogin(context, ref, email, password, authService),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              authService == null ? Colors.grey : const Color(0xFF43A047),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child:
            isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  authService == null ? 'Service Unavailable' : 'Login',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
      ),
    );
  }

  Future<void> _handleLogin(
    BuildContext context,
    WidgetRef ref,
    String email,
    String password,
    AuthApiService authService,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    ref.read(loginLoadingProvider.notifier).state = true;

    try {
      final response = await authService.login({
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
      ref.invalidate(profileProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Welcome, ${user.email}!')));
        await Future.delayed(const Duration(milliseconds: 500));
        if (context.mounted) {
          context.go('/');
        }
      }
    } on DioException catch (e) {
      if (context.mounted) {
        String errorMessage = 'Login failed. Please try again.';
        if (e.response != null && e.response?.data != null) {
          final data = e.response?.data;
          if (data is Map && data['message'] != null) {
            errorMessage = data['message'].toString();
          }
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    } finally {
      ref.read(loginLoadingProvider.notifier).state = false;
    }
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an Account? "),
        GestureDetector(
          onTap: () => context.push('/signup'),
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
