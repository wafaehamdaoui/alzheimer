import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:myproject/screens/edit_profile.dart';
import 'package:myproject/shared/styled_text.dart';
import 'package:myproject/theme.dart';
import 'package:myproject/services/auth_service.dart';
import 'package:myproject/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    User? user = await _authService.getUser(); // Fetch user info
    setState(() {
      _user = user; // Set the user object in state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _user == null
            ? const Center(child: CircularProgressIndicator()) // Show a loading indicator while fetching data
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_user!.profilePhotoUrl), // Use NetworkImage for remote images
                  ),
                  const SizedBox(height: 16),

                  // User's Full Name
                  Text(
                    _user!.fullName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),

                  // User's Email
                  Text(
                    _user!.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),

                  // User's Age
                  Text(
                    '${'age'.tr()} ${_user!.age}', // Display Age
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),

                  // User's Profession
                  Text(
                    _user?.profession??'',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),

                  // User's Likes
                  Text(
                    '${'likes'.tr()} : ${_user!.likes}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),

                  // User's Dislikes
                  Text(
                    '${'dislikes'.tr()} : ${_user!.dislikes}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),

                  // User's Allergies
                  Text(
                    '${'allergies'.tr()}: ${_user!.allergies}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // Edit Profile Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Navigate to edit profile and wait for the updated user to be returned
                      final updatedUser = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(currentUser: _user),
                        ),
                      );

                      // If an updated user is returned, update the profile
                      if (updatedUser != null && updatedUser is User) {
                        setState(() {
                          _user = updatedUser; // Update the user state with the updated profile
                        });
                      }
                    },
                    icon: const Icon(Icons.edit, color: Colors.white60,),
                    label: Text('edit_profile'.tr(),style: TextStyle(color: Colors.white70),),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reset Password Button
                  ElevatedButton.icon(
                    onPressed: () {
                      _showResetPasswordDialog(context);
                    },
                    icon: const Icon(Icons.vpn_key),
                    label: Text('reset_password'.tr()),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppTheme.focusColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _showResetPasswordDialog(BuildContext context) async {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('reset_password'.tr()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: newPasswordController,
                  obscureText: true, // Hide the password
                  decoration: InputDecoration(
                    labelText: 'new_password'.tr(), // 'New Password'
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'confirm_password'.tr(), // 'Confirm Password'
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('cancel'.tr()), // 'Cancel'
            ),
            TextButton(
              onPressed: () async {
                // Check if passwords match
                if (newPasswordController.text == confirmPasswordController.text) {
                  if (await AuthService().resetPassword(confirmPasswordController.text) != null) {
                    Navigator.pop(context);
                  }
                  Navigator.of(context).pop(); // Close dialog after saving
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Center(child: StyledText('password_reset_success'.tr())), // 'Password reset successfully'
                    backgroundColor: Colors.white,
                  ));
                } else {
                  // Show an error message if passwords do not match
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Center(child: StyledErrorText('passwords_do_not_match'.tr())), // 'Passwords do not match'
                    backgroundColor: Colors.white,
                  ));
                }
              },
              child: Text('confirm'.tr()), // 'Confirm'
            ),
          ],
        );
      },
    );
  }
}
