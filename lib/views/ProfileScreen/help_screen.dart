// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:veegify/constants/api.dart';

// class HelpScreen extends StatefulWidget {
//   const HelpScreen({super.key});

//   @override
//   State<HelpScreen> createState() => _HelpScreenState();
// }

// class _HelpScreenState extends State<HelpScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
  
//   // Form controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
  
//   String _selectedIssueType = 'General';
//   bool _isSubmitting = false;
//   List<HelpIssue> _helpIssues = [];
//   bool _isLoading = false;

//   final List<String> _issueTypes = [
//     'General',
//     'Delivery',
//     'Product',
//     'Payment',
//     'Account',
//     'Technical',
//     'Refund',
//     'Other'
//   ];

//   final String baseUrl = ApiConstants.baseUrl;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _fetchHelpIssues();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _nameController.dispose();
//     _emailController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitHelpRequest() async {
//     if (_nameController.text.isEmpty || 
//         _emailController.text.isEmpty || 
//         _descriptionController.text.isEmpty) {
//       _showSnackBar('Please fill all fields', Colors.red);
//       return;
//     }

//     setState(() {
//       _isSubmitting = true;
//     });

//     try {
//             print("Okkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk$baseUrl");

//       final response = await http.post(
//         Uri.parse("$baseUrl/help"),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'name': _nameController.text.trim(),
//           'email': _emailController.text.trim(),
//           'issueType': _selectedIssueType,
//           'description': _descriptionController.text.trim(),
//         }),
//       );

//       print("Response Status: ${response.statusCode}");

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         _showSnackBar('Issue submitted successfully!', Colors.green);
//         _clearForm();
//         _fetchHelpIssues(); // Refresh the issues list
//         _tabController.animateTo(1); // Switch to "My Issues" tab
//       } else {
//         _showSnackBar('Failed to submit issue. Please try again.', Colors.red);
//       }
//     } catch (e) {
//       _showSnackBar('Network error. Please check your connection.', Colors.red);
//     } finally {
//       setState(() {
//         _isSubmitting = false;
//       });
//     }
//   }

//   Future<void> _fetchHelpIssues() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.get(Uri.parse("$baseUrl/help"));

      
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List<dynamic> issuesJson = data['data'];
        
//         setState(() {
//           _helpIssues = issuesJson
//               .map((json) => HelpIssue.fromJson(json))
//               .toList();
//         });
//       } else {
//         _showSnackBar('Failed to fetch issues', Colors.red);
//       }
//     } catch (e) {
//       _showSnackBar('Network error. Please check your connection.', Colors.red);
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _clearForm() {
//     _nameController.clear();
//     _emailController.clear();
//     _descriptionController.clear();
//     setState(() {
//       _selectedIssueType = 'General';
//     });
//   }

//   void _showSnackBar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: const Text(
//           'Help & Support',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: Colors.green,
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: Colors.green,
//           tabs: const [
//             Tab(
//               icon: Icon(Icons.help_outline),
//               text: 'Submit Issue',
//             ),
//             Tab(
//               icon: Icon(Icons.list_alt),
//               text: 'My Issues',
//             ),
//             Tab(
//               icon: Icon(Icons.info_outline),
//               text: 'FAQ',
//             ),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildSubmitIssueTab(),
//           _buildMyIssuesTab(),
//           _buildFAQTab(),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubmitIssueTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header Card
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.green.shade400, Colors.green.shade600],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Icon(
//                   Icons.support_agent,
//                   color: Colors.white,
//                   size: 32,
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'Need Help?',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Submit your issue and our support team will get back to you within 24 hours.',
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.9),
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Form Card
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Name Field
//                 _buildFormField(
//                   label: 'Your Name',
//                   controller: _nameController,
//                   icon: Icons.person_outline,
//                   hint: 'Enter your full name',
//                 ),

//                 const SizedBox(height: 20),

//                 // Email Field
//                 _buildFormField(
//                   label: 'Email Address',
//                   controller: _emailController,
//                   icon: Icons.email_outlined,
//                   hint: 'Enter your email address',
//                   keyboardType: TextInputType.emailAddress,
//                 ),

//                 const SizedBox(height: 20),

//                 // Issue Type Dropdown
//                 const Text(
//                   'Issue Type',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors.grey.shade50,
//                   ),
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<String>(
//                       value: _selectedIssueType,
//                       isExpanded: true,
//                       icon: const Icon(Icons.keyboard_arrow_down),
//                       items: _issueTypes.map((String type) {
//                         return DropdownMenuItem<String>(
//                           value: type,
//                           child: Row(
//                             children: [
//                               _getIssueTypeIcon(type),
//                               const SizedBox(width: 12),
//                               Text(type),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           _selectedIssueType = newValue!;
//                         });
//                       },
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Description Field
//                 const Text(
//                   'Description',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors.grey.shade50,
//                   ),
//                   child: TextField(
//                     controller: _descriptionController,
//                     maxLines: 4,
//                     decoration: const InputDecoration(
//                       hintText: 'Please describe your issue in detail...',
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.all(16),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 // Submit Button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: _isSubmitting ? null : _submitHelpRequest,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 2,
//                     ),
//                     child: _isSubmitting
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : const Text(
//                             'Submit Issue',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Contact Info Card
//           // Container(
//           //   padding: const EdgeInsets.all(20),
//           //   decoration: BoxDecoration(
//           //     color: Colors.blue.shade50,
//           //     borderRadius: BorderRadius.circular(15),
//           //     border: Border.all(color: Colors.blue.shade200),
//           //   ),
//           //   child: Column(
//           //     children: [
//           //       Icon(Icons.info_outline, color: Colors.blue.shade600, size: 28),
//           //       const SizedBox(height: 12),
//           //       Text(
//           //         'Need Immediate Help?',
//           //         style: TextStyle(
//           //           fontSize: 18,
//           //           fontWeight: FontWeight.bold,
//           //           color: Colors.blue.shade800,
//           //         ),
//           //       ),
//           //       const SizedBox(height: 8),
//           //       Text(
//           //         'Call us at 1800-XXX-XXXX (24/7)\nEmail: support@veeggify.com',
//           //         textAlign: TextAlign.center,
//           //         style: TextStyle(
//           //           fontSize: 14,
//           //           color: Colors.blue.shade700,
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMyIssuesTab() {
//     return RefreshIndicator(
//       onRefresh: _fetchHelpIssues,
//       child: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _helpIssues.isEmpty
//               ? _buildEmptyState()
//               : ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: _helpIssues.length,
//                   itemBuilder: (context, index) {
//                     final issue = _helpIssues[index];
//                     return _buildIssueCard(issue);
//                   },
//                 ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.inbox_outlined,
//             size: 64,
//             color: Colors.grey.shade400,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No Issues Found',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Your submitted issues will appear here',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade500,
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: () => _tabController.animateTo(0),
//             icon: const Icon(Icons.add),
//             label: const Text('Submit New Issue'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildIssueCard(HelpIssue issue) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 _getIssueTypeIcon(issue.issueType),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         issue.name,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       Text(
//                         issue.email,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 _buildStatusChip(issue.issueType),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               issue.description,
//               style: const TextStyle(
//                 fontSize: 14,
//                 height: 1.4,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
//                 const SizedBox(width: 6),
//                 Text(
//                   _formatDate(issue.createdAt),
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade500,
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   'ID: ${issue.id.substring(issue.id.length - 8)}',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade500,
//                     fontFamily: 'monospace',
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFAQTab() {
//     final faqs = [
//       {
//         'question': 'How long does it take to get a response?',
//         'answer': 'Our support team typically responds within 24 hours during business days.'
//       },
//       {
//         'question': 'Can I track my submitted issues?',
//         'answer': 'Yes, you can view all your submitted issues in the "My Issues" tab.'
//       },
//       {
//         'question': 'What information should I include in my issue description?',
//         'answer': 'Please provide as much detail as possible including order numbers, error messages, and steps to reproduce the issue.'
//       },
//       {
//         'question': 'How do I update my submitted issue?',
//         'answer': 'Currently, you cannot edit submitted issues. Please submit a new issue with reference to the previous one.'
//       },
//       {
//         'question': 'Is there a phone number for immediate support?',
//         'answer': 'Yes, you can call us at 1800-XXX-XXXX for urgent matters. Our phone support is available 24/7.'
//       },
//     ];

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: faqs.length,
//       itemBuilder: (context, index) {
//         final faq = faqs[index];
//         return Card(
//           margin: const EdgeInsets.only(bottom: 8),
//           child: ExpansionTile(
//             title: Text(
//               faq['question']!,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Text(
//                   faq['answer']!,
//                   style: const TextStyle(height: 1.5),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFormField({
//     required String label,
//     required TextEditingController controller,
//     required IconData icon,
//     required String hint,
//     TextInputType? keyboardType,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(12),
//             color: Colors.grey.shade50,
//           ),
//           child: TextField(
//             controller: controller,
//             keyboardType: keyboardType,
//             decoration: InputDecoration(
//               hintText: hint,
//               prefixIcon: Icon(icon, color: Colors.grey.shade600),
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.all(16),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _getIssueTypeIcon(String issueType) {
//     IconData iconData;
//     Color color;

//     switch (issueType.toLowerCase()) {
//       case 'delivery':
//         iconData = Icons.local_shipping;
//         color = Colors.orange;
//         break;
//       case 'product':
//         iconData = Icons.inventory_2;
//         color = Colors.blue;
//         break;
//       case 'payment':
//         iconData = Icons.payment;
//         color = Colors.green;
//         break;
//       case 'account':
//         iconData = Icons.account_circle;
//         color = Colors.purple;
//         break;
//       case 'technical':
//         iconData = Icons.bug_report;
//         color = Colors.red;
//         break;
//       case 'refund':
//         iconData = Icons.payment;
//         color = Colors.teal;
//         break;
//       default:
//         iconData = Icons.help_outline;
//         color = Colors.grey;
//     }

//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Icon(iconData, color: color, size: 20),
//     );
//   }

//   Widget _buildStatusChip(String issueType) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.blue.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.blue.withOpacity(0.3)),
//       ),
//       child: Text(
//         issueType,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w500,
//           color: Colors.blue.shade700,
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         return '${difference.inMinutes}m ago';
//       }
//       return '${difference.inHours}h ago';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays}d ago';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
// }

// class HelpIssue {
//   final String id;
//   final String name;
//   final String email;
//   final String issueType;
//   final String description;
//   final DateTime createdAt;

//   HelpIssue({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.issueType,
//     required this.description,
//     required this.createdAt,
//   });

//   factory HelpIssue.fromJson(Map<String, dynamic> json) {
//     return HelpIssue(
//       id: json['_id'],
//       name: json['name'],
//       email: json['email'],
//       issueType: json['issueType'],
//       description: json['description'],
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }
// }



































import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:veegify/constants/api.dart';
import 'package:veegify/helper/storage_helper.dart';


class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedIssueType = 'General';
  bool _isSubmitting = false;
  List<HelpIssue> _helpIssues = [];
  bool _isLoading = false;

  // user id
  String? _userId;

  // image picker
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  final List<String> _issueTypes = [
    'General',
    'Delivery',
    'Product',
    'Payment',
    'Account',
    'Technical',
    'Refund',
    'Other'
  ];

  final String baseUrl = ApiConstants.baseUrl;

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty;

  bool get _canSubmit => _isFormValid && !_isSubmitting;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserId();
    _fetchHelpIssues();
  }

  Future<void> _loadUserId() async {
    final user = UserPreferences.getUser();
    if (user != null && mounted) {
      setState(() {
        _userId = user.userId;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 75,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showSnackBar('Failed to pick image', Theme.of(context).colorScheme.error);
    }
  }

  void _showImageSourceSheet() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select image source',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.photo_camera, color: colorScheme.primary),
                title: Text('Camera', style: theme.textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: colorScheme.primary),
                title: Text('Gallery', style: theme.textTheme.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitHelpRequest() async {
    if (!_isFormValid) {
      _showSnackBar('Please fill all fields', Theme.of(context).colorScheme.error);
      return;
    }

    if (_userId == null || _userId!.isEmpty) {
      _showSnackBar('User not found. Please login again.', Theme.of(context).colorScheme.error);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final uri = Uri.parse("$baseUrl/help/$_userId");
      print("Submitting help to: $uri");

      final request = http.MultipartRequest('POST', uri);

      // Text fields
      request.fields['name'] = _nameController.text.trim();
      request.fields['email'] = _emailController.text.trim();
      request.fields['issueType'] = _selectedIssueType;
      request.fields['description'] = _descriptionController.text.trim();

      // Optional image file
      if (_selectedImage != null) {
        final file = await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        );
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _showSnackBar('Issue submitted successfully!', Theme.of(context).colorScheme.primary);
        _clearForm();
        _fetchHelpIssues();
        _tabController.animateTo(1);
      } else {
        _showSnackBar('Failed to submit issue. Please try again.', Theme.of(context).colorScheme.error);
      }
    } catch (e) {
      print("Submit error: $e");
      _showSnackBar('Network error. Please check your connection.', Theme.of(context).colorScheme.error);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _fetchHelpIssues() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse("$baseUrl/help/$_userId"));
      print("Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> issuesJson = data['data'];

        setState(() {
          _helpIssues =
              issuesJson.map((json) => HelpIssue.fromJson(json)).toList();
        });
      }
    } catch (e) {
      _showSnackBar('Network error. Please check your connection.', Theme.of(context).colorScheme.error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedIssueType = 'General';
      _selectedImage = null;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.cardColor,
        foregroundColor: colorScheme.onBackground,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.help_outline),
              text: 'Submit Issue',
            ),
            Tab(
              icon: Icon(Icons.list_alt),
              text: 'My Issues',
            ),
            Tab(
              icon: Icon(Icons.info_outline),
              text: 'FAQ',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubmitIssueTab(theme, colorScheme),
          _buildMyIssuesTab(theme, colorScheme),
          _buildFAQTab(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildSubmitIssueTab(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.support_agent,
                  color: colorScheme.onPrimary,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Need Help?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Submit your issue and our support team will get back to you within 24 hours.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Form Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Field
                _buildFormField(
                  label: 'Your Name',
                  controller: _nameController,
                  icon: Icons.person_outline,
                  hint: 'Enter your full name',
                  theme: theme,
                  colorScheme: colorScheme,
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 20),

                // Email Field
                _buildFormField(
                  label: 'Email Address',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  hint: 'Enter your email address',
                  keyboardType: TextInputType.emailAddress,
                  theme: theme,
                  colorScheme: colorScheme,
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 20),

                // Issue Type Dropdown
                Text(
                  'Issue Type',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surfaceVariant,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedIssueType,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface),
                      dropdownColor: theme.cardColor,
                      style: theme.textTheme.bodyMedium,
                      items: _issueTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Row(
                            children: [
                              _getIssueTypeIcon(type),
                              const SizedBox(width: 12),
                              Text(type),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedIssueType = newValue!;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Description Field
                Text(
                  'Description',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surfaceVariant,
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: theme.textTheme.bodyMedium,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Please describe your issue in detail...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Image upload section
                Text(
                  'Attachment (optional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showImageSourceSheet,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Upload image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surfaceVariant,
                        foregroundColor: colorScheme.onSurface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _selectedImage == null
                          ? Text(
                              'No file selected',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            )
                          : Row(
                              children: [
                                Icon(Icons.image, size: 18, color: colorScheme.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    File(_selectedImage!.path).path.split('/').last,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, size: 18, color: colorScheme.error),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImage = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _submitHelpRequest : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Submit Issue',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMyIssuesTab(ThemeData theme, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: _fetchHelpIssues,
      color: colorScheme.primary,
      child: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : _helpIssues.isEmpty
              ? _buildEmptyState(theme, colorScheme)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _helpIssues.length,
                  itemBuilder: (context, index) {
                    final issue = _helpIssues[index];
                    return _buildIssueCard(issue, theme, colorScheme);
                  },
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Issues Found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your submitted issues will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(0),
            icon: const Icon(Icons.add),
            label: const Text('Submit New Issue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCard(HelpIssue issue, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User + Type Section
            Row(
              children: [
                _getIssueTypeIcon(issue.issueType),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        issue.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(issue.issueType, colorScheme, theme),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              issue.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),

            // Image Section (if available)
            if (issue.imageUrl != null && issue.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  issue.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    color: colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.broken_image,
                      color: colorScheme.onSurfaceVariant,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Date + ID Section
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: colorScheme.onSurface.withOpacity(0.5)),
                const SizedBox(width: 6),
                Text(
                  _formatDate(issue.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const Spacer(),
                Text(
                  "ID: ${issue.id.substring(issue.id.length - 8)}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTab(ThemeData theme, ColorScheme colorScheme) {
    final faqs = [
      {
        'question': 'How long does it take to get a response?',
        'answer':
            'Our support team typically responds within 24 hours during business days.'
      },
      {
        'question': 'Can I track my submitted issues?',
        'answer':
            'Yes, you can view all your submitted issues in the "My Issues" tab.'
      },
      {
        'question': 'What information should I include in my issue description?',
        'answer':
            'Please provide as much detail as possible including order numbers, error messages, and steps to reproduce the issue.'
      },
      {
        'question': 'How do I update my submitted issue?',
        'answer':
            'Currently, you cannot edit submitted issues. Please submit a new issue with reference to the previous one.'
      },
      {
        'question': 'Is there a phone number for immediate support?',
        'answer':
            'Yes, you can call us at 1800-XXX-XXXX for urgent matters. Our phone support is available 24/7.'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: theme.cardColor,
          child: ExpansionTile(
            title: Text(
              faq['question']!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  faq['answer']!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required ThemeData theme,
    required ColorScheme colorScheme,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceVariant,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: theme.textTheme.bodyMedium,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              prefixIcon: Icon(icon, color: colorScheme.onSurface.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getIssueTypeIcon(String issueType) {
    IconData iconData;
    Color color;

    switch (issueType.toLowerCase()) {
      case 'delivery':
        iconData = Icons.local_shipping;
        color = Colors.orange;
        break;
      case 'product':
        iconData = Icons.inventory_2;
        color = Colors.blue;
        break;
      case 'payment':
        iconData = Icons.payment;
        color = Colors.green;
        break;
      case 'account':
        iconData = Icons.account_circle;
        color = Colors.purple;
        break;
      case 'technical':
        iconData = Icons.bug_report;
        color = Colors.red;
        break;
      case 'refund':
        iconData = Icons.payment;
        color = Colors.teal;
        break;
      default:
        iconData = Icons.help_outline;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  Widget _buildStatusChip(String issueType, ColorScheme colorScheme,  ThemeData theme,) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Text(
        issueType,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class HelpIssue {
  final String id;
  final String name;
  final String email;
  final String issueType;
  final String description;
  final DateTime createdAt;
  final String? imageUrl;

  HelpIssue({
    required this.id,
    required this.name,
    required this.email,
    required this.issueType,
    required this.description,
    required this.createdAt,
    this.imageUrl,
  });

  factory HelpIssue.fromJson(Map<String, dynamic> json) {
    return HelpIssue(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      issueType: json['issueType'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      imageUrl: json['imageUrl'],
    );
  }
}