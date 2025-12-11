
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/views/Auth/login_page.dart';

// class CreatePassword extends StatefulWidget {
//   final String userId;

//   const CreatePassword({super.key, required this.userId});

//   @override
//   State<CreatePassword> createState() => _CreatePasswordState();
// }

// class _CreatePasswordState extends State<CreatePassword> {
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

//     // No spaces allowed
//     if (value.contains(' ')) {
//       return 'Password must not contain spaces';
//     }

//     if (value.length < 8) {
//       return 'Password must be at least 8 characters long';
//     }

//     final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
//     final hasLower = RegExp(r'[a-z]').hasMatch(value);
//     final hasDigit = RegExp(r'\d').hasMatch(value);
//     final hasSpecial = RegExp(r'[@$!%*?&]').hasMatch(value);

//     if (!hasUpper || !hasLower || !hasDigit || !hasSpecial) {
//       return 'Use upper, lower, number & special character (@\$!%*?&)';
//     }

//     // Full strong pattern check (optional but keeps it strict)
//     final strongPattern = RegExp(
//       r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
//     );
//     if (!strongPattern.hasMatch(value)) {
//       return 'Password is not strong enough';
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

//   void _handleCreatePassword() {
//     if (_formKey.currentState!.validate()) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       authProvider.setPassword(
//         userId: widget.userId,
//         password: _passwordController.text,
//         context: context,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     final passwordText = _passwordController.text;
//     final hasMinLength = passwordText.length >= 8;
//     final hasUpper = RegExp(r'[A-Z]').hasMatch(passwordText);
//     final hasLower = RegExp(r'[a-z]').hasMatch(passwordText);
//     final hasDigit = RegExp(r'\d').hasMatch(passwordText);
//     final hasSpecial = RegExp(r'[@$!%*?&]').hasMatch(passwordText);
//     final hasNoSpaces = !passwordText.contains(' ');

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SingleChildScrollView(
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Form(
//               key: _formKey,
//               autovalidateMode: AutovalidateMode.onUserInteraction,
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
//                     'Create Your New Password',
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Password field
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: !_isPasswordVisible,
//                     validator: _validatePassword,
//                     style: TextStyle(
//                       color: theme.colorScheme.onSurface,
//                     ),
//                     inputFormatters: [
//                       // prevent spaces
//                       FilteringTextInputFormatter.deny(RegExp(r'\s')),
//                     ],
//                     onChanged: (_) => setState(() {}),
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: theme.inputDecorationTheme.fillColor,
//                       labelText: 'Password',
//                       labelStyle: TextStyle(
//                         color: theme.colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                       hintText: 'Enter your password',
//                       hintStyle: TextStyle(
//                         color: theme.colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _isPasswordVisible
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                           color:
//                               theme.colorScheme.onSurface.withOpacity(0.6),
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

//                   // Confirm password
//                   TextFormField(
//                     controller: _confirmPasswordController,
//                     obscureText: !_isConfirmPasswordVisible,
//                     validator: _validateConfirmPassword,
//                     style: TextStyle(
//                       color: theme.colorScheme.onSurface,
//                     ),
//                     inputFormatters: [
//                       FilteringTextInputFormatter.deny(RegExp(r'\s')),
//                     ],
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: theme.inputDecorationTheme.fillColor,
//                       labelText: 'Confirm Password',
//                       labelStyle: TextStyle(
//                         color: theme.colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                       hintText: 'Re-enter your password',
//                       hintStyle: TextStyle(
//                         color: theme.colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _isConfirmPasswordVisible
//                               ? Icons.visibility
//                               : Icons.visibility_off,
//                           color:
//                               theme.colorScheme.onSurface.withOpacity(0.6),
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _isConfirmPasswordVisible =
//                                 !_isConfirmPasswordVisible;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Password requirements box
//                   Container(
//                     width: double.infinity,
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
//                         _buildRequirement(
//                           'At least 8 characters',
//                           hasMinLength,
//                           theme,
//                         ),
//                         _buildRequirement(
//                           'One uppercase letter (A-Z)',
//                           hasUpper,
//                           theme,
//                         ),
//                         _buildRequirement(
//                           'One lowercase letter (a-z)',
//                           hasLower,
//                           theme,
//                         ),
//                         _buildRequirement(
//                           'One number (0-9)',
//                           hasDigit,
//                           theme,
//                         ),
//                         _buildRequirement(
//                           'One special character (@\$!%*?&)',
//                           hasSpecial,
//                           theme,
//                         ),
//                         _buildRequirement(
//                           'No spaces',
//                           hasNoSpaces,
//                           theme,
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 40),

//                   // Submit
//                   Consumer<AuthProvider>(
//                     builder: (context, authProvider, child) {
//                       return SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: authProvider.isLoading
//                               ? null
//                               : _handleCreatePassword,
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
//                                   "Create Password",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: theme.colorScheme.onPrimary,
//                                   ),
//                                 ),
//                         ),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 20),

//                   // Already have account
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Already have account?',
//                         style: theme.textTheme.bodyMedium,
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const LoginPage(),
//                             ),
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
// }













import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/utils/responsive.dart'; // ⬅️ add this
import 'package:veegify/views/Auth/login_page.dart';

class CreatePassword extends StatefulWidget {
  final String userId;

  const CreatePassword({super.key, required this.userId});

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
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

    // No spaces allowed
    if (value.contains(' ')) {
      return 'Password must not contain spaces';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasLower = RegExp(r'[a-z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    final hasSpecial = RegExp(r'[@$!%*?&]').hasMatch(value);

    if (!hasUpper || !hasLower || !hasDigit || !hasSpecial) {
      return 'Use upper, lower, number & special character (@\$!%*?&)';
    }

    final strongPattern = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    if (!strongPattern.hasMatch(value)) {
      return 'Password is not strong enough';
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

  void _handleCreatePassword() {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.setPassword(
        userId: widget.userId,
        password: _passwordController.text,
        context: context,
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

    final passwordText = _passwordController.text;
    final hasMinLength = passwordText.length >= 8;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(passwordText);
    final hasLower = RegExp(r'[a-z]').hasMatch(passwordText);
    final hasDigit = RegExp(r'\d').hasMatch(passwordText);
    final hasSpecial = RegExp(r'[@$!%*?&]').hasMatch(passwordText);
    final hasNoSpaces = !passwordText.contains(' ');

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
                  verticalSpacingMedium: verticalSpacingMedium,
                  verticalSpacingSmall: verticalSpacingSmall,
                  hasMinLength: hasMinLength,
                  hasUpper: hasUpper,
                  hasLower: hasLower,
                  hasDigit: hasDigit,
                  hasSpecial: hasSpecial,
                  hasNoSpaces: hasNoSpaces,
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
    required double verticalSpacingMedium,
    required double verticalSpacingSmall,
    required bool hasMinLength,
    required bool hasUpper,
    required bool hasLower,
    required bool hasDigit,
    required bool hasSpecial,
    required bool hasNoSpaces,
  }) {
    final content = _buildContent(
      theme: theme,
      isMobile: isMobile,
      verticalSpacingMedium: verticalSpacingMedium,
      verticalSpacingSmall: verticalSpacingSmall,
      hasMinLength: hasMinLength,
      hasUpper: hasUpper,
      hasLower: hasLower,
      hasDigit: hasDigit,
      hasSpecial: hasSpecial,
      hasNoSpaces: hasNoSpaces,
    );

    if (!isTabletOrDesktop) {
      // Mobile → no card
      return content;
    }

    // Tablet / Desktop → form in card
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
    required double verticalSpacingMedium,
    required double verticalSpacingSmall,
    required bool hasMinLength,
    required bool hasUpper,
    required bool hasLower,
    required bool hasDigit,
    required bool hasSpecial,
    required bool hasNoSpaces,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
            'Create Your New Password',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: verticalSpacingMedium),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            validator: _validatePassword,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
              labelText: 'Password',
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              hintText: 'Enter your password',
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
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
              labelText: 'Confirm Password',
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              hintText: 'Re-enter your password',
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
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
          ),

          SizedBox(height: verticalSpacingSmall),

          // Password requirements box
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
                  'One uppercase letter (A-Z)',
                  hasUpper,
                  theme,
                ),
                _buildRequirement(
                  'One lowercase letter (a-z)',
                  hasLower,
                  theme,
                ),
                _buildRequirement(
                  'One number (0-9)',
                  hasDigit,
                  theme,
                ),
                _buildRequirement(
                  'One special character (@\$!%*?&)',
                  hasSpecial,
                  theme,
                ),
                _buildRequirement(
                  'No spaces',
                  hasNoSpaces,
                  theme,
                ),
              ],
            ),
          ),

          SizedBox(height: verticalSpacingMedium),

          // Submit
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      authProvider.isLoading ? null : _handleCreatePassword,
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
                          "Create Password",
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                ),
              );
            },
          ),

          SizedBox(height: verticalSpacingSmall),

          // Already have account
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have account?',
                style: theme.textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
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
}
