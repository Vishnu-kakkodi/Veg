
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/views/Auth/signup_page.dart';
// import 'package:veegify/views/ForgotPassword/forgot_password_screen.dart';
// import 'package:flutter/services.dart';


// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
  
//   bool _isPasswordVisible = false;
//   bool _rememberMe = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedCredentials();
//   }

//   void _loadSavedCredentials() {
//     if (UserPreferences.getRememberMe()) {
//       _phoneController.text = UserPreferences.getSavedPhoneNumber();
//       _passwordController.text = UserPreferences.getSavedPassword();
//       _rememberMe = true;
//     }
//   }

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   String? _validatePhoneNumber(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Phone number is required';
//     }
//     if (value.length < 10) {
//       return 'Phone number must be at least 10 digits';
//     }
//     if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//       return 'Phone number must contain only digits';
//     }
//     return null;
//   }

//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Password is required';
//     }
//     if (value.length < 6) {
//       return 'Password must be at least 6 characters';
//     }
//     return null;
//   }

//   void _handleLogin() {
//     if (_formKey.currentState!.validate()) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       authProvider.login(
//         phoneNumber: _phoneController.text.trim(),
//         password: _passwordController.text,
//         rememberMe: _rememberMe,
//         context: context,
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
//           padding: const EdgeInsets.all(20),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 30),
//                 Image.asset(
//                   "assets/images/login.png",
//                   color: isDark ? null : null,
//                 ),
//                 const SizedBox(height: 30),
//                 Text(
//                   'Welcome back glad to see you',
//                   style: theme.textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: RichText(
//                     text: TextSpan(
//                       text: 'Phone Number',
//                       style: theme.textTheme.bodyLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                       children: const [
//                         TextSpan(
//                           text: '*',
//                           style: TextStyle(color: Colors.red),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 5),
// TextFormField(
//   controller: _phoneController,
//   keyboardType: TextInputType.phone,
//   validator: _validatePhoneNumber,
//   style: TextStyle(
//     color: theme.colorScheme.onSurface,
//   ),
//   inputFormatters: [
//     LengthLimitingTextInputFormatter(10), // ⬅️ limits to 10 digits
//     FilteringTextInputFormatter.digitsOnly, // ⬅️ allows only numbers
//   ],
//   decoration: InputDecoration(
//     hintText: 'Enter your phone number',
//     hintStyle: TextStyle(
//       color: theme.colorScheme.onSurface.withOpacity(0.6),
//     ),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(12),
//       borderSide: BorderSide.none,
//     ),
//     filled: true,
//     fillColor: theme.inputDecorationTheme.fillColor,
//     prefixIcon: Icon(
//       Icons.phone,
//       color: theme.colorScheme.onSurface.withOpacity(0.6),
//     ),
//   ),
// ),

//                 const SizedBox(height: 15),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: RichText(
//                     text: TextSpan(
//                       text: 'Password',
//                       style: theme.textTheme.bodyLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                       children: const [
//                         TextSpan(
//                           text: '*',
//                           style: TextStyle(color: Colors.red),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: !_isPasswordVisible,
//                   validator: _validatePassword,
//                   style: TextStyle(
//                     color: theme.colorScheme.onSurface,
//                   ),
//                   decoration: InputDecoration(
//                     hintText: 'Enter your password',
//                     hintStyle: TextStyle(
//                       color: theme.colorScheme.onSurface.withOpacity(0.6),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     fillColor: theme.inputDecorationTheme.fillColor,
//                     prefixIcon: Icon(
//                       Icons.lock,
//                       color: theme.colorScheme.onSurface.withOpacity(0.6),
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                         color: theme.colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isPasswordVisible = !_isPasswordVisible;
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//                 // const SizedBox(height: 10),
//                 // Row(
//                 //   children: [
//                 //     Checkbox(
//                 //       value: _rememberMe,
//                 //       onChanged: (value) {
//                 //         setState(() {
//                 //           _rememberMe = value ?? false;
//                 //         });
//                 //       },
//                 //     ),
//                 //     Text(
//                 //       'Remember me',
//                 //       style: theme.textTheme.bodyMedium,
//                 //     ),
//                 //   ],
//                 // ),
//                 const SizedBox(height: 30),
//                 Consumer<AuthProvider>(
//                   builder: (context, authProvider, child) {
//                     return SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: authProvider.isLoading ? null : _handleLogin,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: theme.colorScheme.primary,
//                           foregroundColor: theme.colorScheme.onPrimary,
//                           elevation: 5,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           textStyle: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         child: authProvider.isLoading
//                             ? CircularProgressIndicator(
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                   theme.colorScheme.onPrimary,
//                                 ),
//                               )
//                             : const Text('Log In'),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 5),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context, 
//                         MaterialPageRoute(
//                           builder: (context) => const ForgotPasswordScreen()
//                         )
//                       );
//                     },
//                     child: Text(
//                       'Forgot Your Password?',
//                       style: TextStyle(
//                         color: theme.colorScheme.primary,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Don't have account? ",
//                       style: theme.textTheme.bodyMedium,
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const SignupPage()
//                           ),
//                         );
//                       },
//                       child: Text(
//                         'Register',
//                         style: TextStyle(
//                           color: theme.colorScheme.primary,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


















import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/utils/responsive.dart'; // ⬅️ add this
import 'package:veegify/views/Auth/signup_page.dart';
import 'package:veegify/views/ForgotPassword/forgot_password_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    if (UserPreferences.getRememberMe()) {
      _phoneController.text = UserPreferences.getSavedPhoneNumber();
      _passwordController.text = UserPreferences.getSavedPassword();
      _rememberMe = true;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.login(
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    // Common paddings by device
    final horizontalPadding = isMobile ? 20.0 : (isTablet ? 40.0 : 80.0);
    final verticalSpacingSmall = screenHeight * 0.015; // ~1.5%
    final verticalSpacingMedium = screenHeight * 0.03; // ~3%

    // Max width for form card on large screens
    const double maxFormWidth = 420;

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
                child: isDesktop
                    ? _buildDesktopLayout(
                        theme: theme,
                        isDark: isDark,
                        verticalSpacingMedium: verticalSpacingMedium,
                        verticalSpacingSmall: verticalSpacingSmall,
                      )
                    : _buildFormCard(
                        theme: theme,
                        isDark: isDark,
                        verticalSpacingMedium: verticalSpacingMedium,
                        verticalSpacingSmall: verticalSpacingSmall,
                        isTabletOrDesktop: isTablet || isDesktop,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// For desktop we can show a side illustration + form nicely.
  Widget _buildDesktopLayout({
    required ThemeData theme,
    required bool isDark,
    required double verticalSpacingMedium,
    required double verticalSpacingSmall,
  }) {
    return Row(
      children: [
        // Left side illustration (expanded)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/login.png",
                  height: 260,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome back!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to continue using Veegify.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // Right side form card
        Expanded(
          child: _buildFormCard(
            theme: theme,
            isDark: isDark,
            verticalSpacingMedium: verticalSpacingMedium,
            verticalSpacingSmall: verticalSpacingSmall,
            isTabletOrDesktop: true,
          ),
        ),
      ],
    );
  }

  /// Form wrapped in a Card (for tablet/desktop) or plain (for mobile)
  Widget _buildFormCard({
    required ThemeData theme,
    required bool isDark,
    required double verticalSpacingMedium,
    required double verticalSpacingSmall,
    required bool isTabletOrDesktop,
  }) {
    final formContent = _buildFormContent(
      theme: theme,
      isDark: isDark,
      verticalSpacingMedium: verticalSpacingMedium,
      verticalSpacingSmall: verticalSpacingSmall,
    );

    if (!isTabletOrDesktop) {
      // Mobile: no card, full width
      return formContent;
    }

    // Tablet / Desktop: show card
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: formContent,
      ),
    );
  }

  Widget _buildFormContent({
    required ThemeData theme,
    required bool isDark,
    required double verticalSpacingMedium,
    required double verticalSpacingSmall,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // On mobile show the image here, on tablet/desktop card maybe smaller
          Image.asset(
            "assets/images/login.png",
            height: Responsive.isMobile(context) ? 180 : 140,
          ),
          SizedBox(height: verticalSpacingMedium),
          Text(
            'Welcome back,\nGlad to see you 👋',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: verticalSpacingMedium),

          // Phone label
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: 'Phone Number',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                children: const [
                  TextSpan(
                    text: '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: verticalSpacingSmall),

          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: _validatePhoneNumber,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
            inputFormatters:  [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: 'Enter your phone number',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
              prefixIcon: Icon(
                Icons.phone,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),

          SizedBox(height: verticalSpacingMedium),

          // Password label
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: 'Password',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                children: const [
                  TextSpan(
                    text: '*',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: verticalSpacingSmall),

          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            validator: _validatePassword,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
              prefixIcon: Icon(
                Icons.lock,
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

          SizedBox(height: verticalSpacingMedium),

          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: authProvider.isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Text('Log In'),
                ),
              );
            },
          ),

          SizedBox(height: verticalSpacingSmall),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: Text(
                'Forgot Your Password?',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),

          SizedBox(height: verticalSpacingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have account? ",
                style: theme.textTheme.bodyMedium,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupPage(),
                    ),
                  );
                },
                child: Text(
                  'Register',
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
