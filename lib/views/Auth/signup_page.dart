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
//     // validate before submit
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

//   // Validators
//   String? _validateName(String? value, String fieldName) {
//     if (value == null || value.trim().isEmpty) return '$fieldName is required';
//     if (value.trim().length < 2) return '$fieldName must be at least 2 characters';
//     return null;
//   }

//   String? _validatePhone(String? value) {
//     if (value == null || value.trim().isEmpty) return 'Phone number is required';
//     final trimmed = value.trim();
//     if (!RegExp(r'^\d{10}$').hasMatch(trimmed)) {
//       return 'Enter a valid 10-digit phone number';
//     }
//     return null;
//   }

// String? _validateEmail(String? value) {
//   if (value == null || value.trim().isEmpty) {
//     return 'Email is required';
//   }

//   final trimmed = value.trim();

//   // 1) Basic format check
//   if (!EmailValidator.validate(trimmed)) {
//     return 'Enter a valid email address';
//   }

//   // 2) Split into local + domain
//   final parts = trimmed.split('@');
//   if (parts.length != 2) {
//     return 'Enter a valid email address';
//   }
//   final domain = parts[1].toLowerCase();

//   // 3) Explicitly reject a list of common typo domains
//   const blockedDomains = <String>{
//     // common gmail typos
//     'gmai.com',
//     'gmai.co',
//     'gmail.co',
//     'gmail.con',
//     'gmial.com',
//     'gmal.com',
//     'gmal.co',
//     'gmail.comm',
//     // add more common typos here if you see them
//   };
//   if (blockedDomains.contains(domain)) {
//     return 'Please check your email domain — it looks incorrect';
//   }

//   // 4) If the domain contains 'gmail' ensure it's exactly 'gmail.com'
//   //    This blocks things like 'gmail.co', 'mygmail.com', 'gmailmail.com' etc.
//   if (domain.contains('gmail') && domain != 'gmail.com') {
//     return 'Enter a valid Gmail address (example: name@gmail.com)';
//   }

//   // 5) TLD check: require final label to be 2–6 letters (e.g. .com, .in, .co.uk will still pass because last label is 'uk')
//   final domainParts = domain.split('.');
//   if (domainParts.length < 2) {
//     return 'Enter a valid email domain';
//   }
//   final tld = domainParts.last;
//   if (!RegExp(r'^[a-zA-Z]{2,6}$').hasMatch(tld)) {
//     return 'Enter a valid email domain';
//   }

//   print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkggggggggggggggggggggggggggggggggggggggggggggggg");

//   return null; // OK
// }



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
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Form(
//             key: _formKey,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             child: Column(
//               children: [
//                 Image.asset("assets/images/signup.png", width: 300, height: 300),
//                 const SizedBox(height: 30),
//                 const Text(
//                   'Create your new account',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//                 ),
//                 const SizedBox(height: 30),

//                 // First and Last Name
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: firstNameController,
//                         decoration: _inputDecoration('First Name*'),
//                         validator: (v) => _validateName(v, 'First name'),
//                         onChanged: (_) => setState(() {}),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: TextFormField(
//                         controller: lastNameController,
//                         decoration: _inputDecoration('Last Name*'),
//                         validator: (v) => _validateName(v, 'Last name'),
//                         onChanged: (_) => setState(() {}),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 15),

//                 // Phone
//                 TextFormField(
//                   controller: phoneController,
//                   keyboardType: TextInputType.phone,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                     LengthLimitingTextInputFormatter(10),
//                   ],
//                   decoration: _inputDecoration('Phone*'),
//                   validator: _validatePhone,
//                   onChanged: (_) => setState(() {}),
//                 ),
//                 const SizedBox(height: 15),

//                 // Email
//                 TextFormField(
//                   controller: emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: _inputDecoration('Email*'),
//                   validator: _validateEmail,
//                   onChanged: (_) => setState(() {}),
//                 ),
//                 const SizedBox(height: 15),

//                 // Referral (optional)
//                 TextFormField(
//                   controller: referalController,
//                   decoration: _inputDecoration('Referral Code (optional)'),
//                   onChanged: (_) => setState(() {}),
//                 ),

//                 const SizedBox(height: 25),

//                 // Submit Button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: handleSubmit,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Text(
//                       'Next',
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Sign In Link
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Already have an account? "),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
//                       },
//                       child: const Text(
//                         "Sign in",
//                         style: TextStyle(
//                           color: Colors.blue,
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

//   InputDecoration _inputDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//     );
//   }
// }




















import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/views/Auth/login_page.dart';

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
    // validate before submit
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

  // Validators
  String? _validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    if (value.trim().length < 2) return '$fieldName must be at least 2 characters';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
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

    // 3) Explicitly reject a list of common typo domains
    const blockedDomains = <String>{
      // common gmail typos
      'gmai.com',
      'gmai.co',
      'gmail.co',
      'gmail.con',
      'gmial.com',
      'gmal.com',
      'gmal.co',
      'gmail.comm',
      // add more common typos here if you see them
    };
    if (blockedDomains.contains(domain)) {
      return 'Please check your email domain — it looks incorrect';
    }

    // 4) If the domain contains 'gmail' ensure it's exactly 'gmail.com'
    //    This blocks things like 'gmail.co', 'mygmail.com', 'gmailmail.com' etc.
    if (domain.contains('gmail') && domain != 'gmail.com') {
      return 'Enter a valid Gmail address (example: name@gmail.com)';
    }

    // 5) TLD check: require final label to be 2–6 letters (e.g. .com, .in, .co.uk will still pass because last label is 'uk')
    final domainParts = domain.split('.');
    if (domainParts.length < 2) {
      return 'Enter a valid email domain';
    }
    final tld = domainParts.last;
    if (!RegExp(r'^[a-zA-Z]{2,6}$').hasMatch(tld)) {
      return 'Enter a valid email domain';
    }

    print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkggggggggggggggggggggggggggggggggggggggggggggggg");

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
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                Image.asset(
                  "assets/images/signup.png", 
                  width: 300, 
                  height: 300,
                  color: isDark ? null : null,
                ),
                const SizedBox(height: 30),
                Text(
                  'Create your new account',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // First and Last Name
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
                        onChanged: (_) => setState(() {}),
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
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

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
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 15),

                // Email
                TextFormField(
                  controller: emailController,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Email*', theme),
                  validator: _validateEmail,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 15),

                // Referral (optional)
                TextFormField(
                  controller: referalController,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: _inputDecoration('Referral Code (optional)', theme),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 25),

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

                const SizedBox(height: 20),

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