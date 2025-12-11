// views/ProfileScreen/edit_profile_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:veegify/provider/ProfileProvider.dart/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstCtrl;
  late TextEditingController _lastCtrl;
  late TextEditingController _emailCtrl;
  File? _pickedImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final user = provider.user;
    String first = '';
    String last = '';

    if (user != null) {
      final parts = user.fullName.split(' ');
      if (parts.isNotEmpty) first = parts.first;
      if (parts.length > 1) last = parts.sublist(1).join(' ');
    }

    _firstCtrl = TextEditingController(text: first);
    _lastCtrl = TextEditingController(text: last);
    _emailCtrl = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    
    final file = File(picked.path);
    setState(() {
      _pickedImage = file;
    });

    // Upload immediately after picking
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final success = await provider.uploadProfileImage(file);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Profile photo updated'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        // Clear picked image after successful upload
        setState(() {
          _pickedImage = null;
        });
      } else {
        final err = provider.error ?? "Image upload failed.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        // Clear picked image on error too
        setState(() {
          _pickedImage = null;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final provider = Provider.of<ProfileProvider>(context, listen: false);

    // Image is already uploaded in _pickImage, just update profile data
    final success = await provider.editProfile(
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );

    setState(() => _saving = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Profile updated successfully'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.of(context).pop();
      } else {
        final err = provider.error ?? "Update failed.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Profile Image with Consumer
                  Consumer<ProfileProvider>(
                    builder: (context, provider, child) {
                      final currentImg = provider.imageUrl;
                      
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: colorScheme.onPrimary, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: colorScheme.surfaceVariant,
                              backgroundImage: _pickedImage != null
                                  ? FileImage(_pickedImage!)
                                  : (currentImg != null && currentImg.isNotEmpty
                                      ? NetworkImage(currentImg) as ImageProvider
                                      : const AssetImage('assets/images/default_avatar.png')),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colorScheme.onPrimary, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: colorScheme.onSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          // Show loading indicator when uploading
                          if (provider.loading)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: colorScheme.onPrimary,
                                    strokeWidth: 3,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.edit, size: 18, color: colorScheme.onPrimary),
                    label: Text(
                      'Change Photo',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Form section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // First Name
                    _buildTextField(
                      controller: _firstCtrl,
                      label: 'First Name',
                      icon: Icons.person_outline,
                      theme: theme,
                      colorScheme: colorScheme,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'First name required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Last Name
                    _buildTextField(
                      controller: _lastCtrl,
                      label: 'Last Name',
                      icon: Icons.person_outline,
                      theme: theme,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      theme: theme,
                      colorScheme: colorScheme,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email required';
                        final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                        if (!emailRegex.hasMatch(v.trim())) return 'Enter valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone (read-only)
                    Consumer<ProfileProvider>(
                      builder: (context, provider, child) {
                        final phone = provider.user?.phoneNumber ?? '';
                        return _buildTextField(
                          initialValue: phone,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          enabled: false,
                          // helperText: 'Phone number cannot be changed',
                          theme: theme,
                          colorScheme: colorScheme,
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: _saving
                          ? Center(
                              child: CircularProgressIndicator(
                                color: colorScheme.primary,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Save Changes',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required ColorScheme colorScheme,
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
    String? helperText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: enabled ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.6),
        ),
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          helperStyle: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            icon,
            color: enabled ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.4),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.error, width: 2),
          ),
          filled: true,
          fillColor: enabled ? theme.cardColor : colorScheme.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}