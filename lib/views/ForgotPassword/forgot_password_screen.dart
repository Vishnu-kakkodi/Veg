
// import 'package:flutter/material.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/views/ForgotPassword/reset_password_screen.dart';
// import 'package:veegify/views/Auth/login_page.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
  
//   String _currentOtp = '';
//   bool _isOtpSent = false;
//   String? _userId;

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }

//   String? _validatePhoneNumber(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Phone number is required';
//     }
//     if (value.length != 10) {
//       return 'Phone number must be 10 digits';
//     }
//     if (!RegExp(r'^\d+$').hasMatch(value)) {
//       return 'Phone number must contain only digits';
//     }
//     return null;
//   }

//   void _sendOtp() async {
//     if (_formKey.currentState!.validate()) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
//       try {
//         print("jjjjjjjjjjjjjjjjjjok");
//         await authProvider.sendForgotPasswordOtp(
//           phoneNumber: _phoneController.text,
//           context: context,
//         );
        
//         setState(() {
//           _isOtpSent = true;
//         });
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text("OTP sent successfully"),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         );
//       } catch (error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to send OTP: ${error.toString()}"),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         );
//       }
//     }
//   }

//   void _verifyOtp() async {
//     print("uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu$_currentOtp");
//     if (_currentOtp.length == 4) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
//       try {
//         final response = await authProvider.verifyForgotPasswordOtp(
//           otp: _currentOtp,
//           context: context,
//         );
        
//         if (response != null && response['userId'] != null) {
//           _userId = response['userId'];
          
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ResetPasswordScreen(userId: _userId!),
//             ),
//           );
//         }
//       } catch (error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("OTP verification failed: ${error.toString()}"),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text("Please enter complete OTP"),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       );
//     }
//   }

//   void _resendOtp() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
//     try {
//       await authProvider.sendForgotPasswordOtp(
//         phoneNumber: _phoneController.text,
//         context: context,
//       );
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text("OTP resent successfully"),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       );
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to resend OTP: ${error.toString()}"),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
    
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Back button
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: IconButton(
//                       icon: Icon(
//                         Icons.arrow_back_ios,
//                         color: theme.colorScheme.onSurface,
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   // Profile image
//                   Center(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.5),
//                             spreadRadius: 4,
//                             blurRadius: 10,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ),
//                       child: CircleAvatar(
//                         radius: 80,
//                         backgroundColor: theme.cardColor,
//                         backgroundImage: const NetworkImage(
//                           'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPHslEuUEmK912EWkZFplnGzD1FgrhXjI1cw&s',
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   // Title
//                   Text(
//                     _isOtpSent ? 'Enter OTP' : 'Forgot Password',
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   // Subtitle
//                   Text(
//                     _isOtpSent 
//                         ? 'Enter the 4-digit code sent to ${_phoneController.text}'
//                         : 'Enter your phone number to receive OTP',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurface.withOpacity(0.6),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),

//                   const SizedBox(height: 30),

//                   // Phone number input (only show if OTP not sent)
//                   if (!_isOtpSent) ...[
//                     TextFormField(
//                       controller: _phoneController,
//                       keyboardType: TextInputType.phone,
//                       validator: _validatePhoneNumber,
//                       style: TextStyle(
//                         color: theme.colorScheme.onSurface,
//                       ),
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: theme.inputDecorationTheme.fillColor,
//                         labelText: 'Phone Number',
//                         labelStyle: TextStyle(
//                           color: theme.colorScheme.onSurface.withOpacity(0.6),
//                         ),
//                         hintText: 'Enter your phone number',
//                         hintStyle: TextStyle(
//                           color: theme.colorScheme.onSurface.withOpacity(0.6),
//                         ),
//                         prefixText: '+91 ',
//                         prefixStyle: TextStyle(
//                           color: theme.colorScheme.onSurface,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                   ],

//                   // OTP input field (only show if OTP sent)
//                   if (_isOtpSent) ...[
//                     SizedBox(
//                       width: 245,
//                       child: PinCodeTextField(
//                         appContext: context,
//                         length: 4,
//                         controller: _otpController,
//                         onChanged: (value) => _currentOtp = value,
//                         textStyle: TextStyle(
//                           color: theme.colorScheme.onSurface,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         pinTheme: PinTheme(
//                           shape: PinCodeFieldShape.underline,
//                           activeColor: theme.colorScheme.primary,
//                           selectedColor: theme.colorScheme.primary,
//                           inactiveColor: theme.colorScheme.onSurface.withOpacity(0.5),
//                           activeFillColor: Colors.transparent,
//                           selectedFillColor: Colors.transparent,
//                           inactiveFillColor: Colors.transparent,
//                         ),
//                       ),
//                     ),

//                     // Resend OTP button
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: _resendOtp,
//                         child: Text(
//                           "Resend OTP",
//                           style: TextStyle(
//                             color: theme.colorScheme.primary,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 10),
//                   ],

//                   // Action button
//                   Consumer<AuthProvider>(
//                     builder: (context, authProvider, child) {
//                       return SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: authProvider.isLoading
//                               ? null
//                               : _isOtpSent ? _verifyOtp : _sendOtp,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: theme.colorScheme.primary,
//                             foregroundColor: theme.colorScheme.onPrimary,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: authProvider.isLoading
//                               ? CircularProgressIndicator(
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                     theme.colorScheme.onPrimary,
//                                   ),
//                                 )
//                               : Text(
//                                   _isOtpSent ? "Verify OTP" : "Send OTP",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: theme.colorScheme.onPrimary,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                         ),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 20),

//                   // Back to sign in link
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Remember your password? ",
//                         style: theme.textTheme.bodyMedium,
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const LoginPage()
//                             ),
//                           );
//                         },
//                         child: Text(
//                           "Sign in",
//                           style: TextStyle(
//                             color: theme.colorScheme.primary,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




















import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/views/ForgotPassword/reset_password_screen.dart';
import 'package:veegify/views/Auth/login_page.dart';
import 'package:veegify/utils/responsive.dart'; // ⬅️ add this

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _currentOtp = '';
  bool _isOtpSent = false;
  String? _userId;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  void _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.sendForgotPasswordOtp(
          phoneNumber: _phoneController.text,
          context: context,
        );

        setState(() {
          _isOtpSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("OTP sent successfully"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send OTP: ${error.toString()}"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _verifyOtp() async {
    if (_currentOtp.length == 4) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final response = await authProvider.verifyForgotPasswordOtp(
          otp: _currentOtp,
          context: context,
        );

        if (response != null && response['userId'] != null) {
          _userId = response['userId'];

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(userId: _userId!),
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("OTP verification failed: ${error.toString()}"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
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
  }

  void _resendOtp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.sendForgotPasswordOtp(
        phoneNumber: _phoneController.text,
        context: context,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("OTP resent successfully"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to resend OTP: ${error.toString()}"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;

    final horizontalPadding = isMobile ? 20.0 : (isTablet ? 40.0 : 80.0);
    final verticalSpacingSmall = screenHeight * 0.015;
    final verticalSpacingMedium = screenHeight * 0.03;

    const double maxFormWidth = 460;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isMobile ? 10 : 24,
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : maxFormWidth,
                ),
                child: _buildFormCard(
                  theme: theme,
                  isMobile: isMobile,
                  isTabletOrDesktop: isTablet || isDesktop,
                  verticalSpacingSmall: verticalSpacingSmall,
                  verticalSpacingMedium: verticalSpacingMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard({
    required ThemeData theme,
    required bool isMobile,
    required bool isTabletOrDesktop,
    required double verticalSpacingSmall,
    required double verticalSpacingMedium,
  }) {
    final content = _buildContent(
      theme: theme,
      isMobile: isMobile,
      verticalSpacingSmall: verticalSpacingSmall,
      verticalSpacingMedium: verticalSpacingMedium,
    );

    if (!isTabletOrDesktop) {
      // Mobile → no card
      return content;
    }

    // Tablet / Desktop → nice card
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: content,
      ),
    );
  }

  Widget _buildContent({
    required ThemeData theme,
    required bool isMobile,
    required double verticalSpacingSmall,
    required double verticalSpacingMedium,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          SizedBox(height: verticalSpacingSmall),

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
                radius: isMobile ? 70 : 80,
                backgroundColor: theme.cardColor,
                backgroundImage: const NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPHslEuUEmK912EWkZFplnGzD1FgrhXjI1cw&s',
                ),
              ),
            ),
          ),

          SizedBox(height: verticalSpacingMedium),

          // Title
          Text(
            _isOtpSent ? 'Enter OTP' : 'Forgot Password',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: verticalSpacingSmall),

          // Subtitle
          Text(
            _isOtpSent
                ? 'Enter the 4-digit code sent to ${_phoneController.text}'
                : 'Enter your phone number to receive OTP',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: verticalSpacingMedium),

          // Phone number input (only when OTP not sent)
          if (!_isOtpSent) ...[
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: _validatePhoneNumber,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor,
                labelText: 'Phone Number',
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                hintText: 'Enter your phone number',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixText: '+91 ',
                prefixStyle: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            SizedBox(height: verticalSpacingMedium),
          ],

          // OTP input (only when OTP sent)
          if (_isOtpSent) ...[
            SizedBox(
              width: 245,
              child: PinCodeTextField(
                appContext: context,
                length: 4,
                controller: _otpController,
                onChanged: (value) => _currentOtp = value,
                keyboardType: TextInputType.number,
                textStyle: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  activeColor: theme.colorScheme.primary,
                  selectedColor: theme.colorScheme.primary,
                  inactiveColor:
                      theme.colorScheme.onSurface.withOpacity(0.5),
                  activeFillColor: Colors.transparent,
                  selectedFillColor: Colors.transparent,
                  inactiveFillColor: Colors.transparent,
                ),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resendOtp,
                child: Text(
                  "Resend OTP",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),

            SizedBox(height: verticalSpacingSmall),
          ],

          // Action button
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : _isOtpSent
                          ? _verifyOtp
                          : _sendOtp,
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
                          _isOtpSent ? "Verify OTP" : "Send OTP",
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

          SizedBox(height: verticalSpacingSmall),

          // Back to sign-in link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Remember your password? ",
                style: theme.textTheme.bodyMedium,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
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
    );
  }
}
