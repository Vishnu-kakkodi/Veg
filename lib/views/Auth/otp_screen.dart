
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/views/Auth/login_page.dart';

class ScreenOtp extends StatefulWidget {
  const ScreenOtp({super.key});

  @override
  State<ScreenOtp> createState() => _ScreenOtpState();
}

class _ScreenOtpState extends State<ScreenOtp> {
  final TextEditingController _otpController = TextEditingController();
  String _currentOtp = '';

  // Timer related
  static const int _initialSeconds = 30;
  int _remainingSeconds = _initialSeconds;
  Timer? _timer;

  bool get _isResendEnabled => _remainingSeconds == 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown({int seconds = _initialSeconds}) {
    // Cancel any existing timer first
    _timer?.cancel();
    setState(() {
      _remainingSeconds = seconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
      } else {
        setState(() {
          _remainingSeconds -= 1;
        });
      }
    });
  }

  Future<void> _handleResendOtp() async {
    if (!_isResendEnabled) return;

    final authProvider = context.read<AuthProvider>();

    // Optionally show immediate UI feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Requesting new OTP...')),
    );

    try {
      // Call provider's resend method. You should implement this to call your endpoint.
      // If your resendOtp returns a boolean or a response, adapt this handling.
     await authProvider.resendOtp();

      // restart countdown regardless (prevents spamming)
      _startCountdown();
    } catch (e) {
      // handle errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error resending OTP: $e')));
      // you might want to allow retry sooner or keep countdown — here we keep countdown behavior
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          // Ensures the scroll view resizes when the keyboard appears
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prevent infinite height
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: theme.colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 10),

                // Profile image
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 4,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 80, // reduced from 149 to be more reasonable on phones
                      backgroundColor: theme.cardColor,
                      backgroundImage: const NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPHslEuUEmK912EWkZFplnGzD1FgrhXjI1cw&s',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Enter OTP text
                Text(
                  'Enter OTP',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // OTP input field
                SizedBox(
                  width: 245,
                  child: PinCodeTextField(
                    appContext: context,
                    length: 4,
                    controller: _otpController,
                    onChanged: (value) => setState(() => _currentOtp = value),
                    onCompleted: (value) => setState(() => _currentOtp = value),
                    textStyle: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.underline,
                      activeColor: theme.colorScheme.primary,
                      selectedColor: theme.colorScheme.primary,
                      inactiveColor: theme.colorScheme.onSurface.withOpacity(0.5),
                      activeFillColor: Colors.transparent,
                      selectedFillColor: Colors.transparent,
                      inactiveFillColor: Colors.transparent,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Resend OTP button + countdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isResendEnabled ? _handleResendOtp : null,
                      child: _isResendEnabled
                          ? Text(
                              "Resend OTP",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : Text(
                              "Resend OTP ($_remainingSeconds s)",
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Next button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () {
                                if (_currentOtp.length == 4) {
                                  authProvider.verifyOtp(
                                    otp: _currentOtp,
                                    context: context,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Please enter complete OTP"),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              )
                            : Text(
                                "Next",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have account? ",
                      style: theme.textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => const LoginPage()
                          )
                        );
                      },
                      child: Text(
                        "Sign in",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}