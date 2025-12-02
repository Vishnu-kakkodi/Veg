
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:veegify/helper/address_utils.dart';
import 'package:veegify/model/address_model.dart';
import 'package:veegify/provider/address_provider.dart';
import 'package:veegify/views/address/location_picker.dart' show LocationPickerScreen;
// Import your LocationPickerScreen
// import 'location_picker_screen.dart';

class AddAddress extends StatefulWidget {
  final Address? address; // For editing existing address
  
  const AddAddress({super.key, this.address});
  
  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _postalCodeController;
  
  String _selectedAddressType = 'Home';
  final List<String> _addressTypes = ['Home', 'Work', 'Office', 'Other'];
  
  bool _isLoading = false;
  String _selectedLocation = 'Tap to choose location';
  LatLng? _selectedLatLng;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data if editing
    _streetController = TextEditingController(text: widget.address?.street ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _countryController = TextEditingController(text: widget.address?.country ?? '');
    _postalCodeController = TextEditingController(text: widget.address?.postalCode ?? '');
    
    if (widget.address != null) {
      _selectedAddressType = widget.address!.addressType;
      // If editing and address has coordinates, set them
      if (widget.address!.latitude != null && widget.address!.longitude != null) {
        _selectedLatLng = LatLng(widget.address!.latitude!, widget.address!.longitude!);
        _selectedLocation = widget.address!.fullAddress ?? 'Selected location';
      }
    }
  }
  
  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    // Navigate to location picker screen
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          isEditing: widget.address != null,
          userId: 'current_user_id', // Replace with actual user ID
        ),
      ),
    );

    if (result != null) {
      final LatLng location = result['location'];
      final String fullAddress = result['address'];
      
      setState(() {
        _selectedLatLng = location;
        _selectedLocation = fullAddress;
      });

      // Parse and auto-fill address fields
      _parseAndFillAddress(fullAddress);
    }
  }

  void _parseAndFillAddress(String fullAddress) {
    try {
      // Use the AddressParser utility for better parsing
      Map<String, String> addressComponents = AddressParser.parseFullAddress(fullAddress);
      
      setState(() {
        _streetController.text = addressComponents['street'] ?? '';
        _cityController.text = addressComponents['city'] ?? '';
        _stateController.text = addressComponents['state'] ?? '';
        _countryController.text = addressComponents['country'] ?? '';
        _postalCodeController.text = addressComponents['postalCode'] ?? '';
      });
    } catch (e) {
      print('Error parsing address: $e');
      // Fallback to simple parsing
      List<String> parts = fullAddress.split(', ');
      if (parts.isNotEmpty) {
        setState(() {
          _streetController.text = parts.first.trim();
          if (parts.length > 1) _cityController.text = parts[1].trim();
          if (parts.length > 2) _stateController.text = parts[2].trim();
          if (parts.length > 3) _countryController.text = parts.last.trim();
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.address != null;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Address' : 'Add Address',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Choose Location Field
              Text(
                'Choose Location',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _openLocationPicker,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: _selectedLatLng != null ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedLocation,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _selectedLatLng != null ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              // Address Type Dropdown
              Text(
                'Address Type',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedAddressType,
                    isExpanded: true,
                    dropdownColor: theme.cardColor,
                    style: theme.textTheme.bodyMedium,
                    items: _addressTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedAddressType = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Street Address Field
              _buildTextField(
                label: 'Street Address',
                controller: _streetController,
                theme: theme,
                colorScheme: colorScheme,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter street address';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // City Field
              _buildTextField(
                label: 'City',
                controller: _cityController,
                theme: theme,
                colorScheme: colorScheme,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // State and Postal Code Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'State',
                      controller: _stateController,
                      theme: theme,
                      colorScheme: colorScheme,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter state';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'Postal Code',
                      controller: _postalCodeController,
                      keyboardType: TextInputType.number,
                      theme: theme,
                      colorScheme: colorScheme,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter postal code';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Country Field
              _buildTextField(
                label: 'Country',
                controller: _countryController,
                theme: theme,
                colorScheme: colorScheme,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter country';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
                    disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                          ),
                        )
                      : Text(
                          isEditing ? 'Update Address' : 'Save Address',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required ThemeData theme,
    required ColorScheme colorScheme,
    TextInputType? keyboardType,
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
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
  
  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      
      final address = Address(
        id: widget.address?.id, // Keep existing id if editing
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        addressType: _selectedAddressType,
        latitude: _selectedLatLng?.latitude,
        longitude: _selectedLatLng?.longitude,
        fullAddress: _selectedLatLng != null ? _selectedLocation : null,
      );
      
      print('Saving address: ${address.toJson()}'); // Debug print
      
      bool success;
      if (widget.address != null) {
        print('Saving addressssssssssssssssss'); // Debug print
        // Update existing address
        success = await addressProvider.updateAddress(widget.address!.id!, address);
      } else {
        print('Saving addressssssssssssssssss1111111111'); // Debug print
        // Add new address
        success = await addressProvider.addAddress(address);
      }
      
      print('Save operation success: $success'); // Debug print
      
      if (mounted) {
        if (success) {
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(addressProvider.errorMessage.isNotEmpty 
                  ? addressProvider.errorMessage 
                  : 'Failed to save address'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Exception in _saveAddress: $e'); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving address: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}