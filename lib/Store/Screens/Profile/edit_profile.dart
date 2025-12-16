import 'package:family_mart/Store/Widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/profile_controller.dart';
import '../../Extras/animated_wrapper.dart';
import '../../Extras/styles.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();

  ProfileController profileController = Get.find();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (profileController.isLoggedIn) {
      _nameController.text = profileController.user.value?.name ?? '';
      _emailController.text = profileController.user.value?.email ?? '';
      _phoneController.text = profileController.user.value?.phone ?? '';
      _locationController.text = profileController.customer.value?.place ?? '';
      _addressController.text = profileController.customer.value?.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgColor, AppColors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AnimatedWrapper(index: 0, child: _buildTopBar()),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AnimatedWrapper(index: 1, child: _buildProfilePhotoSection()),
                        const SizedBox(height: 20),
                        AnimatedWrapper(index: 2, child: _buildBasicInfoSection()),
                        const SizedBox(height: 32),
                        AnimatedWrapper(index: 3, child: _buildSaveButton()),
                        const SizedBox(height: 32),
                      ],
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Text('Edit Profile', style: AppTextStyles.heading1),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text('Profile Photo', style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Stack(
            children: [
              const CircleAvatar(radius: 50, backgroundColor: AppColors.white, child: Icon(Icons.person_outline_rounded, size: 56, color: AppColors.primary)),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showPhotoOptions,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 3),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Tap the camera icon to change photo', style: AppTextStyles.caption.copyWith(color: AppColors.grey)),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic Information', style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
              validator: (v) => v!.trim().isEmpty
                  ? 'Please enter your name'
                  : v.trim().length < 2
                  ? 'Name must be at least 2 characters long'
                  : null
          ),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              enabled: false, // Email usually shouldn't be editable

          ),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                  return 'Phone number must be 10 digits';
                }
                return null;
              }
          ),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _locationController,
              label: 'City/Location',
              icon: Icons.location_city_outlined,
              validator: (v) => v!.trim().isEmpty ? 'Please enter your location' : null
          ),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.home_outlined,
              maxLines: 3,
              validator: (v) => v!.trim().isEmpty
                  ? 'Please enter your address'
                  : v.trim().length < 5
                  ? 'Address must be at least 5 characters long'
                  : null
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: enabled ? AppColors.primary : AppColors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey.withOpacity(0.1) : null,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: profileController.isUpdatingProfile.value ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor: AppColors.grey.withOpacity(0.3),
        ),
        child: profileController.isUpdatingProfile.value
            ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SmallLoadingSpinner(),
              const SizedBox(width: 12),
              Text('Updating...', style: AppTextStyles.button),
            ]
        )
            : Text('Save Changes', style: AppTextStyles.button),
      )),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Change Profile Photo', style: AppTextStyles.heading2),
            const SizedBox(height: 20),
            ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement camera functionality
                }
            ),
            ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement gallery functionality
                }
            ),
            ListTile(
                leading: const Icon(Icons.delete_rounded, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement remove photo functionality
                }
            ),
            const SizedBox(height: 20),
          ]
      ),
    );
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if any data has changed
    if (!_hasDataChanged()) {
      Get.snackbar(
        'No Changes',
        'No changes detected in profile data',
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Call the profile controller update method
    final success = await profileController.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      place: _locationController.text.trim(),
      address: _addressController.text.trim(),
    );

    // If successful and we're still on this page, go back
    if (success && mounted) {
      // Small delay to show success message, then go back
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Get.back();
        }
      });
    }
  }

  bool _hasDataChanged() {
    final currentUser = profileController.user.value;
    final currentCustomer = profileController.customer.value;

    return _nameController.text.trim() != (currentUser?.name ?? '') ||
        _phoneController.text.trim() != (currentUser?.phone ?? '') ||
        _locationController.text.trim() != (currentCustomer?.place ?? '') ||
        _addressController.text.trim() != (currentCustomer?.address ?? '');
  }
}