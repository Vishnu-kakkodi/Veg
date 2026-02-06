
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:email_validator/email_validator.dart';

// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/views/Auth/login_page.dart';
// import 'package:veegify/utils/responsive.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController referalController = TextEditingController();

//   void handleSubmit() {
//     if (_formKey.currentState?.validate() ?? false) {
//       context.read<AuthProvider>().register(
//             firstName: firstNameController.text.trim(),
//             lastName: lastNameController.text.trim(),
//             phone: phoneController.text.trim(),
//             email: emailController.text.trim(),
//             referalCode: referalController.text.trim(),
//             context: context,
//           );
//     }
//   }

//   // ---------------- Validators ----------------

//   String? _validateName(String? value, String fieldName) {
//     if (value == null || value.trim().isEmpty) {
//       return '$fieldName is required';
//     }
//     if (value.trim().length < 2) {
//       return '$fieldName must be at least 2 characters';
//     }
//     if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
//       return '$fieldName should contain only letters';
//     }
//     return null;
//   }

//   String? _validatePhone(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Phone number is required';
//     }
//     if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
//       return 'Enter a valid 10-digit phone number';
//     }
//     return null;
//   }

//   String? _validateEmail(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Email is required';
//     }
//     if (!EmailValidator.validate(value.trim())) {
//       return 'Enter a valid email address';
//     }

//     final domain = value.split('@').last.toLowerCase();
//     const blocked = {
//       'gmai.com',
//       'gmail.co',
//       'gmial.com',
//       'gmal.com',
//       'gmail.con'
//     };

//     if (blocked.contains(domain)) {
//       return 'Please check your email domain';
//     }

//     return null;
//   }

//   @override
//   void dispose() {
//     firstNameController.dispose();
//     lastNameController.dispose();
//     phoneController.dispose();
//     emailController.dispose();
//     referalController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     final isMobile = Responsive.isMobile(context);
//     final isDesktop = Responsive.isDesktop(context);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(
//               horizontal: isMobile ? 20 : 60,
//               vertical: isMobile ? 20 : 40,
//             ),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 1100),
//               child: isDesktop
//                   ? _buildDesktopLayout(theme)
//                   : _buildFormCard(theme, false),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ================= DESKTOP LAYOUT =================

//   Widget _buildDesktopLayout(ThemeData theme) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         // Left illustration
//         Expanded(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(
//                 "assets/images/signup.png",
//                 height: 320,
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'Create your new account',
//                 style: theme.textTheme.headlineMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Sign up to start using Veegify',
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   color: theme.colorScheme.onSurface.withOpacity(0.6),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(width: 60),

//         // Right form
//         Expanded(
//           child: _buildFormCard(theme, true),
//         ),
//       ],
//     );
//   }

//   // ================= FORM CARD =================

//   Widget _buildFormCard(ThemeData theme, bool isDesktop) {
//     final content = _buildFormContent(theme, isDesktop);

//     if (!isDesktop) return content;

//     return Card(
//       elevation: 8,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
//         child: content,
//       ),
//     );
//   }

//   // ================= FORM CONTENT =================

//   Widget _buildFormContent(ThemeData theme, bool isDesktop) {
//     return Form(
//       key: _formKey,
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (!isDesktop) ...[
//             Image.asset(
//               "assets/images/signup.png",
//               height: 220,
//             ),
//             const SizedBox(height: 24),
//           ],

//           Text(
//             'Create Account',
//             style: theme.textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 24),

//           Row(
//             children: [
//               Expanded(
//                 child: TextFormField(
//                   controller: firstNameController,
//                   decoration: _inputDecoration('First Name*', theme),
//                   validator: (v) => _validateName(v, 'First name'),
//                   inputFormatters: [
//                     FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
//                     LengthLimitingTextInputFormatter(30),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: TextFormField(
//                   controller: lastNameController,
//                   decoration: _inputDecoration('Last Name*', theme),
//                   validator: (v) => _validateName(v, 'Last name'),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           TextFormField(
//             controller: phoneController,
//             keyboardType: TextInputType.phone,
//             decoration: _inputDecoration('Phone*', theme),
//             validator: _validatePhone,
//             inputFormatters: [
//               FilteringTextInputFormatter.digitsOnly,
//               LengthLimitingTextInputFormatter(10),
//             ],
//           ),
//           const SizedBox(height: 16),

//           TextFormField(
//             controller: emailController,
//             keyboardType: TextInputType.emailAddress,
//             decoration: _inputDecoration('Email*', theme),
//             validator: _validateEmail,
//           ),
//           const SizedBox(height: 16),

//           TextFormField(
//             controller: referalController,
//             decoration:
//                 _inputDecoration('Referral Code (optional)', theme),
//           ),
//           const SizedBox(height: 28),

//           Consumer<AuthProvider>(
//             builder: (context, auth, _) {
//               return SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: auth.isLoading ? null : handleSubmit,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: theme.colorScheme.primary,
//                     foregroundColor: theme.colorScheme.onPrimary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: auth.isLoading
//                       ? CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             theme.colorScheme.onPrimary,
//                           ),
//                         )
//                       : const Text(
//                           'Next',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 20),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text("Already have an account? "),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => const LoginPage()),
//                   );
//                 },
//                 child: Text(
//                   "Sign in",
//                   style: TextStyle(
//                     color: theme.colorScheme.primary,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   InputDecoration _inputDecoration(String label, ThemeData theme) {
//     return InputDecoration(
//       labelText: label,
//       filled: true,
//       fillColor: theme.inputDecorationTheme.fillColor,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//     );
//   }
// }


















import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';

import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/views/Auth/login_page.dart';
import 'package:veegify/utils/responsive.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController referalController = TextEditingController();

  void handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthProvider>().register(
            firstName: firstNameController.text.trim(),
            lastName: lastNameController.text.trim(),
            phone: phoneController.text.trim(),
            email: emailController.text.trim(),
            referalCode: referalController.text.trim(),
            context: context,
          );
    }
  }

  // ---------------- Validators ----------------

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return '$fieldName should contain only letters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value.trim())) {
      return 'Enter a valid email address';
    }

    final domain = value.split('@').last.toLowerCase();
    const blocked = {
      'gmai.com',
      'gmail.co',
      'gmial.com',
      'gmal.com',
      'gmail.con'
    };

    if (blocked.contains(domain)) {
      return 'Please check your email domain';
    }

    return null;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    referalController.dispose();
    super.dispose();
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

  // ================= WEB LAYOUT (Desktop) =================

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
            borderRadius: BorderRadius.circular(0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Row(
              children: [
                // LEFT SIDE - Form Section
                Expanded(
                  flex: screenWidth > 1400 ? 4 : 5,
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
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
                              fontSize: screenWidth > 1400 ? 36 : 32,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: screenHeight > 800 ? 40 : 24),

                          // Create Account Header
                          Text(
                            'Create Account',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth > 1400 ? 32 : 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign up to start using Veegify',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: screenHeight > 800 ? 32 : 20),

                          // Form
                          Form(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // First Name & Last Name Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'First Name',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: firstNameController,
                                            decoration: _webInputDecoration(
                                              'Enter first name',
                                              theme,
                                            ),
                                            validator: (v) =>
                                                _validateName(v, 'First name'),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[a-zA-Z\s]')),
                                              LengthLimitingTextInputFormatter(30),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Last Name',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: lastNameController,
                                            decoration: _webInputDecoration(
                                              'Enter last name',
                                              theme,
                                            ),
                                            validator: (v) =>
                                                _validateName(v, 'Last name'),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[a-zA-Z\s]')),
                                              LengthLimitingTextInputFormatter(30),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Phone Number
                                Text(
                                  'Phone Number',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: _webInputDecoration(
                                    'Enter phone number',
                                    theme,
                                  ),
                                  validator: _validatePhone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Email Address
                                Text(
                                  'Email Address',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _webInputDecoration(
                                    'Enter email address',
                                    theme,
                                  ),
                                  validator: _validateEmail,
                                ),
                                const SizedBox(height: 20),

                                // Referral Code
                                Text(
                                  'Referral Code (Optional)',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: referalController,
                                  decoration: _webInputDecoration(
                                    'Enter referral code',
                                    theme,
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Next Button
                                Consumer<AuthProvider>(
                                  builder: (context, auth, _) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: auth.isLoading ? null : handleSubmit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: theme.colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: auth.isLoading
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
                                                'Create Account',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Sign In Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account? ",
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LoginPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Sign In',
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
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Fallback color if image not available
                    // color: const Color(0xFF34495E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= MOBILE LAYOUT =================

  Widget _buildMobileLayout() {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 60,
          vertical: isMobile ? 20 : 40,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: isDesktop
              ? _buildDesktopLayout(theme)
              : _buildFormCard(theme, false),
        ),
      ),
    );
  }

  // ================= DESKTOP LAYOUT (Old) =================

  Widget _buildDesktopLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left illustration
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/signup.png",
                height: 320,
              ),
              const SizedBox(height: 24),
              Text(
                'Create your new account',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up to start using Veegify',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 60),

        // Right form
        Expanded(
          child: _buildFormCard(theme, true),
        ),
      ],
    );
  }

  // ================= FORM CARD =================

  Widget _buildFormCard(ThemeData theme, bool isDesktop) {
    final content = _buildFormContent(theme, isDesktop);

    if (!isDesktop) return content;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: content,
      ),
    );
  }

  // ================= FORM CONTENT =================

  Widget _buildFormContent(ThemeData theme, bool isDesktop) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isDesktop) ...[
            Image.asset(
              "assets/images/signup.png",
              height: 220,
            ),
            const SizedBox(height: 24),
          ],

          Text(
            'Create Account',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: firstNameController,
                  decoration: _inputDecoration('First Name*', theme),
                  validator: (v) => _validateName(v, 'First name'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    LengthLimitingTextInputFormatter(30),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: lastNameController,
                  decoration: _inputDecoration('Last Name*', theme),
                  validator: (v) => _validateName(v, 'Last name'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration('Phone*', theme),
            validator: _validatePhone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('Email*', theme),
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: referalController,
            decoration: _inputDecoration('Referral Code (optional)', theme),
          ),
          const SizedBox(height: 28),

          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: auth.isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account? "),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
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

  // ================= INPUT DECORATIONS =================

  InputDecoration _inputDecoration(String label, ThemeData theme) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration _webInputDecoration(String hint, ThemeData theme) {
    return InputDecoration(
      hintText: hint,
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }
}