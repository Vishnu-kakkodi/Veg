// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:email_validator/email_validator.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/views/Auth/login_page.dart';

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
//       final firstName = firstNameController.text.trim();
//       final lastName = lastNameController.text.trim();
//       final phone = phoneController.text.trim();
//       final email = emailController.text.trim();
//       final referalCode = referalController.text.trim();

//       context.read<AuthProvider>().register(
//             firstName: firstName,
//             lastName: lastName,
//             phone: phone,
//             email: email,
//             referalCode: referalCode,
//             context: context,
//           );
//     }
//   }

//   // --------- Validators ----------

//   String? _validateName(String? value, String fieldName) {
//     if (value == null || value.trim().isEmpty) {
//       return '$fieldName is required';
//     }

//     final trimmed = value.trim();

//     if (trimmed.length < 2) {
//       return '$fieldName must be at least 2 characters';
//     }

//     // Only letters and spaces
//     if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmed)) {
//       return '$fieldName should contain only letters';
//     }

//     return null;
//   }

//   String? _validatePhone(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Phone number is required';
//     }

//     final trimmed = value.trim();

//     if (!RegExp(r'^\d{10}$').hasMatch(trimmed)) {
//       return 'Enter a valid 10-digit phone number';
//     }

//     return null;
//   }

//   String? _validateEmail(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Email is required';
//     }

//     final trimmed = value.trim();

//     // 1) Basic format check
//     if (!EmailValidator.validate(trimmed)) {
//       return 'Enter a valid email address';
//     }

//     // 2) Split into local + domain
//     final parts = trimmed.split('@');
//     if (parts.length != 2) {
//       return 'Enter a valid email address';
//     }

//     final domain = parts[1].toLowerCase();

//     // 3) Block obviously wrong/typo domains
//     const blockedDomains = <String>{
//       // very common mistakes
//       'gmai.com',
//       'gmai.co',
//       'gmail.co',
//       'gmail.con',
//       'gmial.com',
//       'gmal.com',
//       'gmal.co',
//       'gmail.comm',
//       'gml.com',
//       // weird empty / partial domains that sometimes slip through
//       '.com',
//       '@.com',
//     };

//     if (blockedDomains.contains(domain)) {
//       return 'Please check your email domain — it looks incorrect';
//     }

//     // 4) If the domain contains "gmail", force exact gmail.com
//     if (domain.contains('gmail') && domain != 'gmail.com') {
//       return 'Enter a valid Gmail address (example: name@gmail.com)';
//     }

//     // 5) TLD check: last part must be 2–6 letters (e.g., .com, .in, .co.in is fine because last is "in")
//     final domainParts = domain.split('.');
//     if (domainParts.length < 2) {
//       return 'Enter a valid email domain';
//     }
//     final tld = domainParts.last;
//     if (!RegExp(r'^[a-zA-Z]{2,6}$').hasMatch(tld)) {
//       return 'Enter a valid email domain';
//     }

//     return null; // OK
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
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Form(
//             key: _formKey,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             child: Column(
//               children: [
//                 Image.asset(
//                   "assets/images/signup.png",
//                   width: 300,
//                   height: 300,
//                   color: isDark ? null : null,
//                 ),
//                 const SizedBox(height: 30),
//                 Text(
//                   'Create your new account',
//                   style: theme.textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 30),

//                 // First + Last Name
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: firstNameController,
//                         style: TextStyle(
//                           color: theme.colorScheme.onSurface,
//                         ),
//                         decoration: _inputDecoration('First Name*', theme),
//                         validator: (v) => _validateName(v, 'First name'),
//                         inputFormatters: [
//                           FilteringTextInputFormatter.allow(
//                             RegExp(r'[a-zA-Z\s]'),
//                           ),
//                           LengthLimitingTextInputFormatter(30),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: TextFormField(
//                         controller: lastNameController,
//                         style: TextStyle(
//                           color: theme.colorScheme.onSurface,
//                         ),
//                         decoration: _inputDecoration('Last Name*', theme),
//                         validator: (v) => _validateName(v, 'Last name'),
//                         inputFormatters: [
//                           FilteringTextInputFormatter.allow(
//                             RegExp(r'[a-zA-Z\s]'),
//                           ),
//                           LengthLimitingTextInputFormatter(30),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 15),

//                 // Phone
//                 TextFormField(
//                   controller: phoneController,
//                   style: TextStyle(
//                     color: theme.colorScheme.onSurface,
//                   ),
//                   keyboardType: TextInputType.phone,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                     LengthLimitingTextInputFormatter(10),
//                   ],
//                   decoration: _inputDecoration('Phone*', theme),
//                   validator: _validatePhone,
//                 ),
//                 const SizedBox(height: 15),

//                 // Email
//                 TextFormField(
//                   controller: emailController,
//                   style: TextStyle(
//                     color: theme.colorScheme.onSurface,
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: _inputDecoration('Email*', theme),
//                   validator: _validateEmail,
//                 ),
//                 const SizedBox(height: 15),

//                 // Referral (optional)
//                 TextFormField(
//                   controller: referalController,
//                   style: TextStyle(
//                     color: theme.colorScheme.onSurface,
//                   ),
//                   decoration:
//                       _inputDecoration('Referral Code (optional)', theme),
//                 ),

//                 const SizedBox(height: 25),

//                 // Submit Button
//                 Consumer<AuthProvider>(
//                   builder: (context, authProvider, child) {
//                     return SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: authProvider.isLoading ? null : handleSubmit,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: theme.colorScheme.primary,
//                           foregroundColor: theme.colorScheme.onPrimary,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: authProvider.isLoading
//                             ? CircularProgressIndicator(
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                   theme.colorScheme.onPrimary,
//                                 ),
//                               )
//                             : Text(
//                                 'Next',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: theme.colorScheme.onPrimary,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 // Sign In Link
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Already have an account? ",
//                       style: theme.textTheme.bodyMedium,
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const LoginPage(),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         "Sign in",
//                         style: TextStyle(
//                           color: theme.colorScheme.primary,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   InputDecoration _inputDecoration(String label, ThemeData theme) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: TextStyle(
//         color: theme.colorScheme.onSurface.withOpacity(0.6),
//       ),
//       hintStyle: TextStyle(
//         color: theme.colorScheme.onSurface.withOpacity(0.6),
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       filled: true,
//       fillColor: theme.inputDecorationTheme.fillColor,
//     );
//   }
// }




















import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';

import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/views/Auth/login_page.dart';
import 'package:veegify/utils/responsive.dart'; // ⬅️ add this

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
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();
      final phone = phoneController.text.trim();
      final email = emailController.text.trim();
      final referalCode = referalController.text.trim();

      context.read<AuthProvider>().register(
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            email: email,
            referalCode: referalCode,
            context: context,
          );
    }
  }

  // --------- Validators ----------

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    // Only letters and spaces
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmed)) {
      return '$fieldName should contain only letters';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final trimmed = value.trim();

    if (!RegExp(r'^\d{10}$').hasMatch(trimmed)) {
      return 'Enter a valid 10-digit phone number';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final trimmed = value.trim();

    // 1) Basic format check
    if (!EmailValidator.validate(trimmed)) {
      return 'Enter a valid email address';
    }

    // 2) Split into local + domain
    final parts = trimmed.split('@');
    if (parts.length != 2) {
      return 'Enter a valid email address';
    }

    final domain = parts[1].toLowerCase();

    // 3) Block obviously wrong/typo domains
    const blockedDomains = <String>{
      // very common mistakes
      'gmai.com',
      'gmai.co',
      'gmail.co',
      'gmail.con',
      'gmial.com',
      'gmal.com',
      'gmal.co',
      'gmail.comm',
      'gml.com',
      // weird empty / partial domains that sometimes slip through
      '.com',
      '@.com',
    };

    if (blockedDomains.contains(domain)) {
      return 'Please check your email domain — it looks incorrect';
    }

    // 4) If the domain contains "gmail", force exact gmail.com
    if (domain.contains('gmail') && domain != 'gmail.com') {
      return 'Enter a valid Gmail address (example: name@gmail.com)';
    }

    // 5) TLD check: last part must be 2–6 letters
    final domainParts = domain.split('.');
    if (domainParts.length < 2) {
      return 'Enter a valid email domain';
    }
    final tld = domainParts.last;
    if (!RegExp(r'^[a-zA-Z]{2,6}$').hasMatch(tld)) {
      return 'Enter a valid email domain';
    }

    return null; // OK
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
    final theme = Theme.of(context);

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    final screenHeight = MediaQuery.of(context).size.height;

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
                child: isDesktop
                    ? _buildDesktopLayout(
                        theme: theme,
                        verticalSpacingMedium: verticalSpacingMedium,
                        verticalSpacingSmall: verticalSpacingSmall,
                      )
                    : _buildFormCard(
                        theme: theme,
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

  /// Desktop layout → illustration on left, form on right
  Widget _buildDesktopLayout({
    required ThemeData theme,
    required double verticalSpacingMedium,
    required double verticalSpacingSmall,
  }) {
    return Row(
      children: [
        // Left: Illustration + text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/signup.png",
                  height: 260,
                ),
                const SizedBox(height: 16),
                Text(
                  'Create your new account',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to start using Veegify.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // Right: Form in card
        Expanded(
          child: _buildFormCard(
            theme: theme,
            verticalSpacingMedium: verticalSpacingMedium,
            verticalSpacingSmall: verticalSpacingSmall,
            isTabletOrDesktop: true,
          ),
        ),
      ],
    );
  }

  /// Wrap form inside a Card for tablet/desktop
  Widget _buildFormCard({
    required ThemeData theme,
    required double verticalSpacingMedium,
    required double verticalSpacingSmall,
    required bool isTabletOrDesktop,
  }) {
    final formContent = _buildFormContent(
      theme: theme,
      verticalSpacingMedium: verticalSpacingMedium,
      verticalSpacingSmall: verticalSpacingSmall,
    );

    if (!isTabletOrDesktop) {
      // Mobile: no card
      return formContent;
    }

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
    required double verticalSpacingMedium,
    required double verticalSpacingSmall,
  }) {
    final isMobile = Responsive.isMobile(context);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Illustration on top for mobile / inside card for larger
          Image.asset(
            "assets/images/signup.png",
            width: isMobile ? 260 : 220,
            height: isMobile ? 260 : 220,
          ),
          SizedBox(height: verticalSpacingMedium),
          Text(
            'Create your new account',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: verticalSpacingMedium),

          // First + Last Name
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: firstNameController,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: _inputDecoration('First Name*', theme),
                  validator: (v) => _validateName(v, 'First name'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z\s]'),
                    ),
                    LengthLimitingTextInputFormatter(30),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: lastNameController,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: _inputDecoration('Last Name*', theme),
                  validator: (v) => _validateName(v, 'Last name'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z\s]'),
                    ),
                    LengthLimitingTextInputFormatter(30),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: verticalSpacingSmall),

          // Phone
          TextFormField(
            controller: phoneController,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: _inputDecoration('Phone*', theme),
            validator: _validatePhone,
          ),
          SizedBox(height: verticalSpacingSmall),

          // Email
          TextFormField(
            controller: emailController,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('Email*', theme),
            validator: _validateEmail,
          ),
          SizedBox(height: verticalSpacingSmall),

          // Referral (optional)
          TextFormField(
            controller: referalController,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
            decoration:
                _inputDecoration('Referral Code (optional)', theme),
          ),

          SizedBox(height: verticalSpacingMedium),

          // Submit Button
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : handleSubmit,
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
                          'Next',
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

          // Sign In Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: theme.textTheme.bodyMedium,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
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

  InputDecoration _inputDecoration(String label, ThemeData theme) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor,
    );
  }
}
