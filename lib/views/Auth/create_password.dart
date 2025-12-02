// import 'package:flutter/material.dart';
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

//   void _handleCreatePassword() {
//     if (_formKey.currentState!.validate()) {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       print("lldsfjlfdj;dfjkdfj;dfjd;fjd;kfjdskfjds;fjds;f");
//       authProvider.setPassword(
//         userId: widget.userId,
//         password: _passwordController.text,
//         context: context,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
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
//                       icon: const Icon(Icons.arrow_back_ios),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Image.asset("assets/images/password.png"),
//                   const SizedBox(height: 30),
//                   const Text(
//                     'Create Your New Password',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 22,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: !_isPasswordVisible,
//                     validator: _validatePassword,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       labelText: 'Password',
//                       hintText: 'Enter your password',
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       labelText: 'Confirm Password',
//                       hintText: 'Re-enter your password',
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
//                   // Container(
//                   //   padding: const EdgeInsets.all(16),
//                   //   decoration: BoxDecoration(
//                   //     color: Colors.grey.shade100,
//                   //     borderRadius: BorderRadius.circular(12),
//                   //   ),
//                   //   child: Column(
//                   //     crossAxisAlignment: CrossAxisAlignment.start,
//                   //     children: [
//                   //       const Text(
//                   //         'Password Requirements:',
//                   //         style: TextStyle(
//                   //           fontWeight: FontWeight.bold,
//                   //           fontSize: 14,
//                   //         ),
//                   //       ),
//                   //       const SizedBox(height: 8),
//                   //       _buildRequirement('At least 8 characters', _passwordController.text.length >= 8),
//                   //       _buildRequirement('One uppercase letter', RegExp(r'[A-Z]').hasMatch(_passwordController.text)),
//                   //       _buildRequirement('One lowercase letter', RegExp(r'[a-z]').hasMatch(_passwordController.text)),
//                   //       _buildRequirement('One number', RegExp(r'\d').hasMatch(_passwordController.text)),
//                   //       _buildRequirement('One special character', RegExp(r'[@$!%*?&]').hasMatch(_passwordController.text)),
//                   //     ],
//                   //   ),
//                   // ),
//                   const SizedBox(height: 40),
//                   Consumer<AuthProvider>(
//                     builder: (context, authProvider, child) {
//                       return SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: authProvider.isLoading ? null : _handleCreatePassword,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           child: authProvider.isLoading
//                               ? const CircularProgressIndicator(
//                                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                 )
//                               : const Text(
//                                   "Create Password",
//                                   style: TextStyle(fontSize: 16, color: Colors.white),
//                                 ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text('Already have account?'),
//                       TextButton(
//                         onPressed: () {
//                                                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));

//                         },
//                         child: const Text(
//                           'Sign in',
//                           style: TextStyle(color: Colors.blue),
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

//   Widget _buildRequirement(String text, bool isValid) {
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
import 'package:provider/provider.dart';
import 'package:veegify/provider/AuthProvider/auth_provider.dart';
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
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(value)) {
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

  void _handleCreatePassword() {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print("lldsfjlfdj;dfjkdfj;dfjd;fjd;kfjdskfjds;fjds;f");
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
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    "assets/images/password.png",
                    color: isDark ? Colors.white : null,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Create Your New Password',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    validator: _validatePassword,
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
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                  const SizedBox(height: 20),
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
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                  const SizedBox(height: 20),
                  // Password requirements
                  // Container(
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: theme.cardColor.withOpacity(0.5),
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         'Password Requirements:',
                  //         style: theme.textTheme.bodyMedium?.copyWith(
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 8),
                  //       _buildRequirement('At least 8 characters', _passwordController.text.length >= 8, theme),
                  //       _buildRequirement('One uppercase letter', RegExp(r'[A-Z]').hasMatch(_passwordController.text), theme),
                  //       _buildRequirement('One lowercase letter', RegExp(r'[a-z]').hasMatch(_passwordController.text), theme),
                  //       _buildRequirement('One number', RegExp(r'\d').hasMatch(_passwordController.text), theme),
                  //       _buildRequirement('One special character', RegExp(r'[@$!%*?&]').hasMatch(_passwordController.text), theme),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 40),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _handleCreatePassword,
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
                  const SizedBox(height: 20),
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
                              builder: (context) => const LoginPage()
                            )
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
            ),
          ),
        ),
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