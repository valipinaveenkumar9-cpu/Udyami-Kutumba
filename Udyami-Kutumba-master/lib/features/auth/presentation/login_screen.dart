import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import '../../home/presentation/main_screen.dart';
import '../view_model/auth_bloc/auth_bloc.dart';
import '../view_model/auth_bloc/auth_event.dart';
import '../view_model/auth_bloc/auth_state.dart';
import 'widgets/design/top_left_blob.dart';
import 'widgets/design/water_flow.dart';
import 'widgets/design/india_skyline.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: const _LoginScreenView(),
    );
  }
}

class _LoginScreenView extends StatefulWidget {
  const _LoginScreenView();

  @override
  State<_LoginScreenView> createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<_LoginScreenView> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mobileController.addListener(_onMobileChanged);
  }

  void _onMobileChanged() {
    final state = context.read<AuthBloc>().state;
    // If user edits number after OTP is sent, reset the auth state
    if (state is OtpSentState || state is OtpVerificationError) {
      context.read<AuthBloc>().add(ResetAuthEvent());
      _otpController.clear();
    }
  }

  void _getOtp() {
    final text = _mobileController.text.trim();
    if (text.length != 10 || int.tryParse(text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You entered an invalid phone number. Please enter 10 digits.')),
      );
      return;
    }
    context.read<AuthBloc>().add(SendOtpEvent(text));
  }

  void _verifyOtp() {
    if (_otpController.text.isEmpty) return;
    context.read<AuthBloc>().add(VerifyOtpEvent(_otpController.text));
  }

  @override
  void dispose() {
    _mobileController.removeListener(_onMobileChanged);
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Widget _buildMobileInput(ThemeData theme, bool isOtpSent, bool isLoading) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Row(
          children: [
            Container(
              width: 48,
              color: theme.colorScheme.secondary.withOpacity(0.1),
              child: Center(
                child: Icon(Icons.phone, color: theme.colorScheme.secondary, size: 20),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  hintText: 'Mobile Number',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  counterText: '',
                ),
                enabled: !isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpSection(ThemeData theme, bool isOtpSent, bool isLoading) {
    final defaultPinTheme = PinTheme(
      width: 40,
      height: 48,
      textStyle: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surface,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OTP',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Pinput(
                  length: 6,
                  controller: _otpController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: Colors.grey.shade100, width: 1.5),
                  ),
                  errorPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: Colors.grey.shade100, width: 1.5),
                  ),
                  enabled: isOtpSent && !isLoading,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : _getOtp,
                icon: Icon(Icons.refresh_outlined, size: 16, color: theme.colorScheme.secondary),
                label: Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(ThemeData theme, bool isOtpSent, bool isLoading) {
    return InkWell(
      onTap: isLoading ? null : (isOtpSent ? _verifyOtp : _getOtp),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF001F3F), Color(0xFF00509E)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            Icon(isOtpSent ? Icons.login : Icons.send, color: Theme.of(context).colorScheme.surface, size: 20),
            Container(width: 1, height: 24, color: Theme.of(context).colorScheme.surface.withOpacity(0.3), margin: EdgeInsets.symmetric(horizontal: 16)),
            Expanded(
              child: Center(
                child: isLoading
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.surface))
                    : Text(
                  isOtpSent ? 'LOGIN' : 'SEND OTP',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.surface, size: 24),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink(ThemeData theme) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SignupScreen()),
        );
      },
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(color: theme.colorScheme.onSurface),
          children: [
            TextSpan(
              text: 'Register',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Separated Background Layers (Sticky & Edge-to-Edge)
          const TopLeftBlob(),
          const IndiaSkyline(opacity: 0.50),
          const WaterFlow(),

          // Scrollable Content
          SafeArea(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is OtpVerifiedState) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                } else if (state is OtpVerificationError) {
                  _otpController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is OtpSentState && state.isTestMode) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test ID detected. Please enter test OTP.')),
                  );
                }
              },
              builder: (context, state) {
                final isOtpSent = state is OtpSentState || state is OtpVerificationError;
                final isLoading = state is AuthLoading;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 24),

                                // App Logo
                                SizedBox(
                                  height: size.height * 0.12,
                                  child: Center(
                                    child: Image.asset(
                                      'assets/logo/uk_logo_1024x1024.jpeg',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Welcome Header
                                Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        text: 'Welcome ',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Back',
                                            style: TextStyle(
                                              color: theme.colorScheme.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(width: 30, height: 1, color: theme.colorScheme.secondary),
                                        const SizedBox(width: 8),
                                        Icon(Icons.circle, size: 6, color: theme.colorScheme.secondary),
                                        const SizedBox(width: 8),
                                        Container(width: 30, height: 1, color: theme.colorScheme.secondary),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Login to your account',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 48),

                                // Mobile Input
                                _buildMobileInput(theme, isOtpSent, isLoading),

                                // OTP Section
                                if (isOtpSent) ...[
                                  const SizedBox(height: 16),
                                  _buildOtpSection(theme, isOtpSent, isLoading),
                                ],
                                const SizedBox(height: 24),

                                // Action Button
                                _buildActionButton(theme, isOtpSent, isLoading),

                                // OTP Status Message
                                if (state is OtpVerificationError) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                                  )
                                ] else if (state is OtpVerifiedState) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    'OTP Verified Successfully!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                  ),
                                ],

                                const SizedBox(height: 24),
                                // OR Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              theme.colorScheme.onSurface.withOpacity(0.0),
                                              theme.colorScheme.onSurface.withOpacity(0.5),
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              theme.colorScheme.onSurface.withOpacity(0.5),
                                              theme.colorScheme.onSurface.withOpacity(0.0),
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Create Account Link
                                _buildRegisterLink(theme),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
