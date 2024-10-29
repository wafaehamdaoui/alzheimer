import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:myproject/shared/styled_text.dart';
import 'package:myproject/theme.dart';
import 'package:myproject/services/auth_service.dart';
import 'package:myproject/models/user.dart';

class EditProfileScreen extends StatefulWidget {
  final User? currentUser; // currentUser can be null

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  late TextEditingController _ageController;
  late TextEditingController _professionController;
  late TextEditingController _likesController;
  late TextEditingController _dislikesController;
  late TextEditingController _allergiesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser?.username);
    _emailController = TextEditingController(text: widget.currentUser?.email);
    _fullNameController = TextEditingController(text: widget.currentUser?.fullName);
    _ageController = TextEditingController(text: widget.currentUser?.age.toString());
    _professionController = TextEditingController(text: widget.currentUser?.profession);
    _likesController = TextEditingController(text: widget.currentUser?.likes);
    _dislikesController = TextEditingController(text: widget.currentUser?.dislikes);
    _allergiesController = TextEditingController(text: widget.currentUser?.allergies);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    _professionController.dispose();
    _likesController.dispose();
    _dislikesController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  // Method to handle form submission
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Update profile logic here (API call or local storage)
      final updatedUser = User(
        id: widget.currentUser!.id,
        username: _nameController.text,
        email: _emailController.text,
        fullName: _fullNameController.text,
        profilePhotoUrl: widget.currentUser!.profilePhotoUrl, // Preserving existing URL
        age: int.parse(_ageController.text),
        profession: _professionController.text,
        likes: _likesController.text,
        dislikes: _dislikesController.text,
        allergies: _allergiesController.text,
      );

      if (await AuthService().updateUserProfile(updatedUser) != null) {
        // Pass the updated user back when popping
        Navigator.pop(context, updatedUser);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Center(child: StyledText('profile_updated_successfully'.tr())), 
          backgroundColor: Colors.white,),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Center(child: StyledErrorText('failed_to_update_profile'.tr())), 
          backgroundColor: Colors.white,));
      } 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('edit_profile'.tr()), 
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'username'.tr()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_your_username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'email'.tr()),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_your_email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Full Name Field
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'name'.tr()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_your_full_name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Age Field
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'age'.tr()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_your_age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Profession Field
              TextFormField(
                controller: _professionController,
                decoration: InputDecoration(labelText: 'profession'.tr()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_your_profession';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Likes Field
              TextFormField(
                controller: _likesController,
                decoration: InputDecoration(labelText: 'likes'.tr()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_your_likes';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dislikes Field
              TextFormField(
                controller: _dislikesController,
                decoration: InputDecoration(labelText: 'dislikes'.tr()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_your_dislikes';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Allergies Field
              TextFormField(
                controller: _allergiesController,
                decoration: InputDecoration(labelText: 'allergies'.tr()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_your_allergies';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('save_changes'.tr(), style: TextStyle(color: Colors.white70),),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Full-width button
                  backgroundColor: AppTheme.primaryAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
