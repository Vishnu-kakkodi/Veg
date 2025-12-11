
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/views/Auth/login_page.dart';

// class ResetPasswordScreen extends StatefulWidget {
//   final String userId;
//   const ResetPasswordScreen({super.key, required this.userId});

//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
  
//   bool _isPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;

//   @override
//   void dispose() {
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }
//     if (value.length < 8) {
//       return 'Password must be at least 8 characters long';
//     }
//     if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(value)) {
//       return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
//     }
//     return null;
//   }

//   String? _validateConfirmPassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please confirm your password';
//     }
//     if (value != _passwordController.text) {
//       return 'Passwords do not match';
//     }
//     return null;
//   }

//   void _handleResetPassword() async {
//     if (_formKey.currentState!.validate()) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
//       try {
//         await authProvider.resetPassword(
//           userId: widget.userId,
//           newPassword: _passwordController.text,
//           confirmPassword: _confirmPasswordController.text,
//           context: context,
//         );
        
//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text("Password reset successfully!"),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         );
        
//         // Navigate to login page
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const LoginPage()),
//           (route) => false,
//         );
//       } catch (error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to reset password: ${error.toString()}"),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         );
//       }
//     }
//   }

//   Widget _buildRequirement(String text, bool isValid, ThemeData theme) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         children: [
//           Icon(
//             isValid ? Icons.check_circle : Icons.cancel,
//             color: isValid ? Colors.green : Colors.red,
//             size: 16,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             text,
//             style: TextStyle(
//               color: isValid ? Colors.green : Colors.red,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
    
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SingleChildScrollView(
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   Align(
//                     alignment: Alignment.topLeft,
//                     child: IconButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       icon: Icon(
//                         Icons.arrow_back_ios,
//                         color: theme.colorScheme.onSurface,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Image.asset(
//                     "assets/images/password.png",
//                     color: isDark ? Colors.white : null,
//                   ),
//                   const SizedBox(height: 30),
//                   Text(
//                     'Reset Your Password',
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     'Enter your new password below',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurface.withOpacity(0.6),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 30),
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: !_isPasswordVisible,
//                     validator: _validatePassword,
//                     style: TextStyle(
//                       color: theme.colorScheme.onSurface,
//                     ),
//                     onChanged: (value) => setState(() {}), // Trigger rebuild for requirements
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: theme.inputDecorationTheme.fillColor,
//                       labelText: 'New Password',
//                       labelStyle: TextStyle(
//                         color: theme.colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                       hintText: 'Enter your new password',
//                       hintStyle: TextStyle(
//                         color: theme.colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                           color: theme.colorScheme.onSurface.withOpacity(0.6),
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _isPasswordVisible = !_isPasswordVisible;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _confirmPasswordController,
//                     obscureText: !_isConfirmPasswordVisible,
//                     validator: _validateConfirmPassword,
//                     style: TextStyle(
//                       color: theme.colorScheme.onSurface,
//                     ),
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: theme.inputDecorationTheme.fillColor,
//                       labelText: 'Confirm New Password',
//                       labelStyle: TextStyle(
//                         color: theme.colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                       hintText: 'Re-enter your new password',
//                       hintStyle: TextStyle(
//                         color: theme.colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                           color: theme.colorScheme.onSurface.withOpacity(0.6),
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
                  
//                   // Password requirements
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: theme.cardColor.withOpacity(0.5),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Password Requirements:',
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         _buildRequirement('At least 8 characters', _passwordController.text.length >= 8, theme),
//                         _buildRequirement('One uppercase letter', RegExp(r'[A-Z]').hasMatch(_passwordController.text), theme),
//                         _buildRequirement('One lowercase letter', RegExp(r'[a-z]').hasMatch(_passwordController.text), theme),
//                         _buildRequirement('One number', RegExp(r'\d').hasMatch(_passwordController.text), theme),
//                         _buildRequirement('One special character', RegExp(r'[@$!%*?&]').hasMatch(_passwordController.text), theme),
//                       ],
//                     ),
//                   ),
                  
//                   const SizedBox(height: 40),
//                   Consumer<AuthProvider>(
//                     builder: (context, authProvider, child) {
//                       return SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: authProvider.isLoading ? null : _handleResetPassword,
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
//                                   "Reset Password",
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
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Remember your password?',
//                         style: theme.textTheme.bodyMedium,
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pushAndRemoveUntil(
//                             context,
//                             MaterialPageRoute(builder: (context) => const LoginPage()),
//                             (route) => false,
//                           );
//                         },
//                         child: Text(
//                           'Sign in',
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
import 'package:provider/provider.dart';

import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/views/Auth/login_page.dart';
import 'package:veegify/utils/responsive.dart'; // ⬅️ add this

class ResetPasswordScreen extends StatefulWidget {
  final String userId;
  const ResetPasswordScreen({super.key, required this.userId});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
    ).hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.resetPassword(
          userId: widget.userId,
          newPassword: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          context: context,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Password reset successfully!"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Failed to reset password: ${error.toString()}"),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Widget _buildRequirement(String text, bool isValid, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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

    // For live requirement indicators
    final pw = _passwordController.text;
    final hasMinLength = pw.length >= 8;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(pw);
    final hasLower = RegExp(r'[a-z]').hasMatch(pw);
    final hasDigit = RegExp(r'\d').hasMatch(pw);
    final hasSpecial = RegExp(r'[@$!%*?&]').hasMatch(pw);

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
                  hasMinLength: hasMinLength,
                  hasUpper: hasUpper,
                  hasLower: hasLower,
                  hasDigit: hasDigit,
                  hasSpecial: hasSpecial,
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
    required bool hasMinLength,
    required bool hasUpper,
    required bool hasLower,
    required bool hasDigit,
    required bool hasSpecial,
  }) {
    final content = _buildContent(
      theme: theme,
      isMobile: isMobile,
      verticalSpacingSmall: verticalSpacingSmall,
      verticalSpacingMedium: verticalSpacingMedium,
      hasMinLength: hasMinLength,
      hasUpper: hasUpper,
      hasLower: hasLower,
      hasDigit: hasDigit,
      hasSpecial: hasSpecial,
    );

    if (!isTabletOrDesktop) {
      // Mobile → no card
      return content;
    }

    // Tablet / Desktop → card
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
    required bool hasMinLength,
    required bool hasUpper,
    required bool hasLower,
    required bool hasDigit,
    required bool hasSpecial,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),

          SizedBox(height: verticalSpacingSmall),

          Image.asset(
            "assets/images/password.png",
            height: isMobile ? 200 : 180,
            color: isDark ? Colors.white : null,
          ),

          SizedBox(height: verticalSpacingMedium),

          Text(
            'Reset Your Password',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: verticalSpacingSmall),

          Text(
            'Enter your new password below',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: verticalSpacingMedium),

          // New password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            validator: _validatePassword,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
            onChanged: (_) => setState(() {}), // update requirements
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
              labelText: 'New Password',
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              hintText: 'Enter your new password',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),

          SizedBox(height: verticalSpacingSmall),

          // Confirm password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            validator: _validateConfirmPassword,
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
              labelText: 'Confirm New Password',
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              hintText: 'Re-enter your new password',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible =
                        !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
          ),

          SizedBox(height: verticalSpacingSmall),

          // Password requirements
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password Requirements:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRequirement(
                  'At least 8 characters',
                  hasMinLength,
                  theme,
                ),
                _buildRequirement(
                  'One uppercase letter',
                  hasUpper,
                  theme,
                ),
                _buildRequirement(
                  'One lowercase letter',
                  hasLower,
                  theme,
                ),
                _buildRequirement(
                  'One number',
                  hasDigit,
                  theme,
                ),
                _buildRequirement(
                  'One special character (@\$!%*?&)',
                  hasSpecial,
                  theme,
                ),
              ],
            ),
          ),

          SizedBox(height: verticalSpacingMedium),

          // Reset button
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      authProvider.isLoading ? null : _handleResetPassword,
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
                          "Reset Password",
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

          // Back to sign in
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Remember your password?',
                style: theme.textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  'Sign in',
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
