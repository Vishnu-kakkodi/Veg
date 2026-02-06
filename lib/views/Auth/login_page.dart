
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/utils/responsive.dart';
// import 'package:veegify/views/Auth/signup_page.dart';
// import 'package:veegify/views/ForgotPassword/forgot_password_screen.dart';

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
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Responsive.builder(
//           context: context,
//           mobile: _buildMobileLayout(),
//           tablet: _buildTabletLayout(),
//           desktop: _buildDesktopLayout(),
//         ),
//       ),
//     );
//   }

//   // Mobile Layout (< 600px)
//   Widget _buildMobileLayout() {
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         child: _buildFormContent(
//           imageHeight: 160,
//           titleFontSize: 24,
//           bodyFontSize: 14,
//           spacing: 16,
//           smallSpacing: 8,
//           buttonHeight: 50,
//           showCard: false,
//         ),
//       ),
//     );
//   }

//   // Tablet Layout (600px - 1024px)
//   Widget _buildTabletLayout() {
//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 500),
//           child: _buildFormContent(
//             imageHeight: 180,
//             titleFontSize: 26,
//             bodyFontSize: 15,
//             spacing: 20,
//             smallSpacing: 10,
//             buttonHeight: 52,
//             showCard: true,
//           ),
//         ),
//       ),
//     );
//   }

//   // Desktop Layout (> 1024px)
//   Widget _buildDesktopLayout() {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 1200),
//           child: Card(
//             elevation: 8,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(24),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(48.0),
//               child: Row(
//                 children: [
//                   // Left side - Illustration
//                   Expanded(
//                     flex: 5,
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 48.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Image.asset(
//                             "assets/images/login.png",
//                             height: 280,
//                             fit: BoxFit.contain,
//                           ),
//                           const SizedBox(height: 24),
//                           Text(
//                             'Welcome back!',
//                             style: theme.textTheme.headlineMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 32,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             'Login to continue using Veegify and enjoy\ndelicious food delivered to your doorstep.',
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               color:
//                                   theme.colorScheme.onSurface.withOpacity(0.6),
//                               fontSize: 16,
//                               height: 1.5,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // Vertical divider
//                   Container(
//                     width: 1,
//                     height: 400,
//                     color: theme.colorScheme.onSurface.withOpacity(0.1),
//                   ),

//                   // Right side - Form
//                   Expanded(
//                     flex: 5,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 48.0),
//                       child: _buildFormContent(
//                         imageHeight: 0, // Don't show image on right side
//                         titleFontSize: 28,
//                         bodyFontSize: 15,
//                         spacing: 24,
//                         smallSpacing: 12,
//                         buttonHeight: 54,
//                         showCard: false,
//                         showWelcomeImage: false,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }



//   Widget _buildFormContent({
//     required double imageHeight,
//     required double titleFontSize,
//     required double bodyFontSize,
//     required double spacing,
//     required double smallSpacing,
//     required double buttonHeight,
//     required bool showCard,
//     bool showWelcomeImage = true,
//   }) {
//     final theme = Theme.of(context);
//     final content = Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Welcome Image
//           if (showWelcomeImage && imageHeight > 0)
//             Center(
//               child: Image.asset(
//                 "assets/images/login.png",
//                 height: imageHeight,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           if (showWelcomeImage && imageHeight > 0) SizedBox(height: spacing),

//           // Welcome Title
//           Text(
//             'Welcome back,\nGlad to see you 👋',
//             textAlign: TextAlign.center,
//             style: theme.textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//               fontSize: titleFontSize,
//               height: 1.3,
//             ),
//           ),
//           SizedBox(height: spacing),

//           // Phone Number Label
//           RichText(
//             text: TextSpan(
//               text: 'Phone Number',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 fontSize: bodyFontSize,
//               ),
//               children: const [
//                 TextSpan(
//                   text: ' *',
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: smallSpacing),

//           // Phone Number Field
//           TextFormField(
//             controller: _phoneController,
//             keyboardType: TextInputType.phone,
//             validator: _validatePhoneNumber,
//             style: TextStyle(
//               color: theme.colorScheme.onSurface,
//               fontSize: bodyFontSize,
//             ),
//             inputFormatters: [
//               LengthLimitingTextInputFormatter(10),
//               FilteringTextInputFormatter.digitsOnly,
//             ],
//             decoration: InputDecoration(
//               hintText: 'Enter your phone number',
//               hintStyle: TextStyle(
//                 color: theme.colorScheme.onSurface.withOpacity(0.5),
//                 fontSize: bodyFontSize,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(
//                   color: theme.colorScheme.onSurface.withOpacity(0.1),
//                   width: 1,
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(
//                   color: theme.colorScheme.primary,
//                   width: 2,
//                 ),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: const BorderSide(
//                   color: Colors.red,
//                   width: 1,
//                 ),
//               ),
//               filled: true,
//               fillColor: theme.inputDecorationTheme.fillColor,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 16,
//               ),
//               prefixIcon: Icon(
//                 Icons.phone,
//                 color: theme.colorScheme.onSurface.withOpacity(0.6),
//                 size: 22,
//               ),
//             ),
//           ),

//           SizedBox(height: spacing),

//           // Password Label
//           RichText(
//             text: TextSpan(
//               text: 'Password',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 fontSize: bodyFontSize,
//               ),
//               children: const [
//                 TextSpan(
//                   text: ' *',
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: smallSpacing),

//           // Password Field
//           TextFormField(
//             controller: _passwordController,
//             obscureText: !_isPasswordVisible,
//             validator: _validatePassword,
//             style: TextStyle(
//               color: theme.colorScheme.onSurface,
//               fontSize: bodyFontSize,
//             ),
//             decoration: InputDecoration(
//               hintText: 'Enter your password',
//               hintStyle: TextStyle(
//                 color: theme.colorScheme.onSurface.withOpacity(0.5),
//                 fontSize: bodyFontSize,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(
//                   color: theme.colorScheme.onSurface.withOpacity(0.1),
//                   width: 1,
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(
//                   color: theme.colorScheme.primary,
//                   width: 2,
//                 ),
//               ),
//               errorBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: const BorderSide(
//                   color: Colors.red,
//                   width: 1,
//                 ),
//               ),
//               filled: true,
//               fillColor: theme.inputDecorationTheme.fillColor,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 16,
//               ),
//               prefixIcon: Icon(
//                 Icons.lock,
//                 color: theme.colorScheme.onSurface.withOpacity(0.6),
//                 size: 22,
//               ),
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   _isPasswordVisible
//                       ? Icons.visibility
//                       : Icons.visibility_off,
//                   color: theme.colorScheme.onSurface.withOpacity(0.6),
//                   size: 22,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     _isPasswordVisible = !_isPasswordVisible;
//                   });
//                 },
//               ),
//             ),
//           ),

//           SizedBox(height: spacing),

//           // Login Button
//           Consumer<AuthProvider>(
//             builder: (context, authProvider, child) {
//               return SizedBox(
//                 width: double.infinity,
//                 height: buttonHeight,
//                 child: ElevatedButton(
//                   onPressed: authProvider.isLoading ? null : _handleLogin,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: theme.colorScheme.primary,
//                     foregroundColor: theme.colorScheme.onPrimary,
//                     elevation: authProvider.isLoading ? 0 : 3,
//                     shadowColor: theme.colorScheme.primary.withOpacity(0.4),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     textStyle: TextStyle(
//                       fontSize: bodyFontSize + 1,
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                   child: authProvider.isLoading
//                       ? SizedBox(
//                           height: 24,
//                           width: 24,
//                           child: CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               theme.colorScheme.onPrimary,
//                             ),
//                             strokeWidth: 2.5,
//                           ),
//                         )
//                       : const Text('Log In'),
//                 ),
//               );
//             },
//           ),

//           SizedBox(height: smallSpacing),

//           // Forgot Password
//           Align(
//             alignment: Alignment.centerRight,
//             child: TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const ForgotPasswordScreen(),
//                   ),
//                 );
//               },
//               style: TextButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 8,
//                   vertical: 4,
//                 ),
//               ),
//               child: Text(
//                 'Forgot Your Password?',
//                 style: TextStyle(
//                   color: theme.colorScheme.primary,
//                   fontSize: bodyFontSize,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(height: smallSpacing),

//           // Register Link
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 "Don't have an account? ",
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   fontSize: bodyFontSize,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const SignupPage(),
//                     ),
//                   );
//                 },
//                 child: Text(
//                   'Register',
//                   style: TextStyle(
//                     color: theme.colorScheme.primary,
//                     fontWeight: FontWeight.bold,
//                     fontSize: bodyFontSize,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),

//       //               Row(
//       //       mainAxisAlignment: MainAxisAlignment.center,
//       //       children: [
//       //         GestureDetector(
//       //       onTap: () async {
//       //   final uri = Uri.parse("https://pixelmindsolutions.com");
//       //   if (await canLaunchUrl(uri)) {
//       //     await launchUrl(uri, mode: LaunchMode.externalApplication);
//       //   }
//       // },
//       //           child:RichText(
//       //     text: TextSpan(
//       //       style: const TextStyle(fontSize: 12),
//       //       children: [
//       //         TextSpan(
//       //           text: "Powered by ",
//       //           style: TextStyle(
//       //             color: Theme.of(context)
//       //                 .colorScheme
//       //                 .onSurface
//       //                 .withOpacity(0.6),
//       //             fontWeight: FontWeight.w500,
//       //           ),
//       //         ),
//       //         TextSpan(
//       //           text: "Pixelmindsolutions Pvt Ltd",
//       //           style: TextStyle(
//       //             color: Theme.of(context).colorScheme.primary,
//       //             fontWeight: FontWeight.bold,
//       //           ),
//       //         ),
//       //       ],
//       //     ),
//       //   ),
      
//       //         ),
//       //       ],
//       //     ),
//         ],
//       ),
//     );

//     // Wrap in card if needed
//     if (showCard) {
//       return Card(
//         elevation: 6,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(spacing + 8),
//           child: content,
//         ),
//       );
//     }

//     return content;
//   }
// }






















import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/utils/responsive.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    
return Scaffold(
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  body: SafeArea(
    child: (kIsWeb && screenWidth > 1024)
        ? Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: _buildWebLayout(), // card / content on top
          )
        : _buildMobileLayout(),
  ),
);

  }

  // WEB LAYOUT - Completely different design with image
  Widget _buildWebLayout() {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust padding based on screen width
    final horizontalPadding = screenWidth > 1400 ? 60.0 : 40.0;
    final verticalPadding = screenHeight > 800 ? 40.0 : 24.0;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: screenWidth > 1600 ? 1400 : 1200,
          maxHeight: screenHeight * 0.95,
        ),
        margin: const EdgeInsets.all(20),
        child: Card(
          elevation: 16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(00),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                // LEFT SIDE - Form Section
                Expanded(
                  flex: screenWidth > 1400 ? 4 : 5,
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Text(
                            'Veegiffy',
                            style: TextStyle(
                                                      fontFamily: 'Cursive',

                              fontSize: screenWidth > 1400 ? 36 : 32,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: screenHeight > 800 ? 50 : 30),

                          // Welcome Back
                          Text(
                            'Welcome Back',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth > 1400 ? 32 : 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in with your mobile and Password',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: screenHeight > 800 ? 40 : 24),

                          // Form
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email Address Label
                                Text(
                                  'Mobile',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Phone Number Field
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  validator: _validatePhoneNumber,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(10),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter your mobile',
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                      ),
                                    ),
                                    suffixIcon: Icon(
                                      Icons.check_circle,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Password Label
                                Text(
                                  'Password',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  validator: _validatePassword,
                                  decoration: InputDecoration(
                                    hintText: '••••••••••',
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Remember Me & Forgot Password Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        // SizedBox(
                                        //   height: 20,
                                        //   width: 20,
                                        //   child: Checkbox(
                                        //     value: _rememberMe,
                                        //     onChanged: (value) {
                                        //       setState(() {
                                        //         _rememberMe = value ?? false;
                                        //       });
                                        //     },
                                        //     shape: RoundedRectangleBorder(
                                        //       borderRadius: BorderRadius.circular(4),
                                        //     ),
                                        //     materialTapTargetSize:
                                        //         MaterialTapTargetSize.shrinkWrap,
                                        //   ),
                                        // ),
                                        // const SizedBox(width: 8),
                                        // Text(
                                        //   'Remember me',
                                        //   style: theme.textTheme.bodySmall?.copyWith(
                                        //     fontSize: 13,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Sign In Button
                                Consumer<AuthProvider>(
                                  builder: (context, authProvider, child) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed:
                                            authProvider.isLoading ? null : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: theme.colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: authProvider.isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation(
                                                    Colors.white,
                                                  ),
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : const Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Sign Up Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                      ),
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
                                        'Sign Up',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // RIGHT SIDE - Image Section
                Expanded(
                  flex: screenWidth > 1400 ? 6 : 5,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/login_bg.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    // If you want to use a placeholder colored background instead
                    // color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MOBILE LAYOUT - Keep existing design unchanged
  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: _buildFormContent(
          imageHeight: 160,
          titleFontSize: 24,
          bodyFontSize: 14,
          spacing: 16,
          smallSpacing: 8,
          buttonHeight: 50,
          showCard: false,
        ),
      ),
    );
  }

  Widget _buildFormContent({
    required double imageHeight,
    required double titleFontSize,
    required double bodyFontSize,
    required double spacing,
    required double smallSpacing,
    required double buttonHeight,
    required bool showCard,
    bool showWelcomeImage = true,
  }) {
    final theme = Theme.of(context);
    final content = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Welcome Image
          if (showWelcomeImage && imageHeight > 0)
            Center(
              child: Image.asset(
                "assets/images/login.png",
                height: imageHeight,
                fit: BoxFit.contain,
              ),
            ),
          if (showWelcomeImage && imageHeight > 0) SizedBox(height: spacing),

          // Welcome Title
          Text(
            'Welcome back,\nGlad to see you 👋',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
              height: 1.3,
            ),
          ),
          SizedBox(height: spacing),

          // Phone Number Label
          RichText(
            text: TextSpan(
              text: 'Phone Number',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: bodyFontSize,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          SizedBox(height: smallSpacing),

          // Phone Number Field
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: _validatePhoneNumber,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: bodyFontSize,
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: 'Enter your phone number',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: bodyFontSize,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(
                Icons.phone,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                size: 22,
              ),
            ),
          ),
          SizedBox(height: spacing),

          // Password Label
          RichText(
            text: TextSpan(
              text: 'Password',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: bodyFontSize,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          SizedBox(height: smallSpacing),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            validator: _validatePassword,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: bodyFontSize,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: bodyFontSize,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(
                Icons.lock,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                size: 22,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: spacing),

          // Login Button
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: authProvider.isLoading ? 0 : 3,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(
                      fontSize: bodyFontSize + 1,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  child: authProvider.isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              theme.colorScheme.onPrimary,
                            ),
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Log In'),
                ),
              );
            },
          ),
          SizedBox(height: smallSpacing),

          // Forgot Password
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
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
              ),
              child: Text(
                'Forgot Your Password?',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: bodyFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: smallSpacing),

          // Register Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: bodyFontSize,
                ),
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
                    fontSize: bodyFontSize,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (showCard) {
      return Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(spacing + 8),
          child: content,
        ),
      );
    }
    return content;
  }
}