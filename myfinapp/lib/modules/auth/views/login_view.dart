import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../models/login_request.dart';
import '../../../app/routes/app_routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showForm = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    ever(Get.find<AuthController>().status, _onAuthStatusChanged);
  }

  void _onAuthStatusChanged(AuthStatus status) {
    if (status == AuthStatus.authenticated) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/login_finance_man.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: _showForm ? _buildLoginPanel() : _buildWelcomeContent(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeContent() {
    return Column(
      key: const ValueKey('welcome'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 60),
        Text(
          'MYFIN',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: 28,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Personal Finance',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: () => setState(() => _showForm = true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF4793A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Powered by MDM SOLUTIONS',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
                letterSpacing: 0.5,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLoginPanel() {
    return Column(
      key: const ValueKey('login'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                Text(
                  'MYFIN',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF3D2C2C),
                        letterSpacing: 1,
                        fontSize: 22,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  'Personal Finance',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8C7B7B),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3D2C2C),
                        fontSize: 16,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  'Sign in to manage your finances',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C7B7B),
                        fontSize: 12,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                _buildUsernameField(),
                const SizedBox(height: 12),
                _buildPasswordField(),
                const SizedBox(height: 18),
                _buildLoginButton(),
                const SizedBox(height: 16),
                Obx(() {
                  final authFailed = Get.find<AuthController>().status.value == AuthStatus.authenticationFailed;
                  final errorMessage = Get.find<AuthController>().errorMessage.value;
                  if (authFailed && errorMessage.isNotEmpty) {
                    return _buildErrorCard(errorMessage);
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 14),
                _buildOrSeparator(),
                const SizedBox(height: 14),
                _buildSocialLoginSection(),
                const SizedBox(height: 16),
              ],
                ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Powered by MDM SOLUTIONS',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8C7B7B),
                fontSize: 11,
                letterSpacing: 0.5,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF68727D),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _usernameController,
          textInputAction: TextInputAction.next,
          enabled: !_isSubmitting,
          style: const TextStyle(color: Color(0xFF222222), fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF68727D), size: 18),
            hintText: 'Enter username',
            hintStyle: TextStyle(color: const Color(0xFF68727D).withValues(alpha: 0.7), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFFFF7EF),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Username is required';
            }
            if (value.trim().length > 50) {
              return 'Username must be 50 characters or less';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF68727D),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
        ),
        const SizedBox(height: 4),
        Obx(() {
          final isPasswordVisible = Get.find<AuthController>().passwordVisible.value;
          return TextFormField(
            controller: _passwordController,
            obscureText: !isPasswordVisible,
            textInputAction: TextInputAction.done,
            enabled: !_isSubmitting,
            style: const TextStyle(color: Color(0xFF222222), fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF68727D), size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: const Color(0xFF68727D),
                  size: 18,
                ),
                onPressed: () {
                  if (!_isSubmitting) {
                    Get.find<AuthController>().togglePasswordVisibility();
                  }
                },
              ),
              hintText: 'Enter password',
              hintStyle: TextStyle(color: const Color(0xFF68727D).withValues(alpha: 0.7), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFFFF7EF),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (value.length > 128) {
                return 'Password must be 128 characters or less';
              }
              return null;
            },
          );
        }),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(() {
      final isLoading = Get.find<AuthController>().status.value == AuthStatus.authenticating;
      return ElevatedButton(
        onPressed: (_isSubmitting || isLoading) ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF4793A),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFF4793A).withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Login',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
      );
    });
  }

  Widget _buildOrSeparator() {
    return Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFFE8DDD6), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: const Color(0xFF8C7B7B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(child: Divider(color: const Color(0xFFE8DDD6), thickness: 1)),
      ],
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        _SocialLoginButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata_rounded,
          backgroundColor: const Color(0xFFF5EBE0),
          foregroundColor: const Color(0xFF3D2C2C),
          iconColor: const Color(0xFFEA4335),
          onPressed: null,
        ),
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    final lower = message.toLowerCase();
    final isNetworkError = lower.contains('unable to connect') ||
        lower.contains('connection refused') ||
        lower.contains('connection timed out') ||
        lower.contains('host unreachable') ||
        lower.contains('connection failed');

    final icon = isNetworkError ? Icons.wifi_off_rounded : Icons.error_outline_rounded;
    final title = isNetworkError ? 'Connection problem' : 'Login unsuccessful';
    final body = isNetworkError
        ? "We couldn't connect to MYFIN right now. Please check your network connection and try again."
        : 'Invalid username or password. Please check your details and try again.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF8C4CE),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE04057), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFE04057),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFFB83A4A),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _submit,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE04057),
                side: const BorderSide(color: Color(0xFFE04057)),
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Try Again',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_isSubmitting) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final validationError = _validate(username, password);
    if (validationError != null) {
      Get.find<AuthController>().errorMessage.value = validationError;
      Get.find<AuthController>().status.value = AuthStatus.authenticationFailed;
      return;
    }

    setState(() => _isSubmitting = true);
    Get.find<AuthController>().login(LoginRequest(username: username, password: password));
    ever(Get.find<AuthController>().status, (AuthStatus status) {
      if (status == AuthStatus.authenticated || status == AuthStatus.authenticationFailed) {
        setState(() => _isSubmitting = false);
      }
    });
  }

  String? _validate(String username, String password) {
    if (username.isEmpty) {
      return 'Username is required';
    }
    if (username.length > 50) {
      return 'Username must be 50 characters or less';
    }
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (password.length > 128) {
      return 'Password must be 128 characters or less';
    }
    return null;
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color iconColor;
  final VoidCallback? onPressed;

  const _SocialLoginButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.iconColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
