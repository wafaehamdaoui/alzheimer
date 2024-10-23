import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myproject/models/authentication_response.dart';
import 'package:myproject/models/register_request.dart';
import 'package:myproject/models/user.dart';
import 'package:myproject/services/auth_service.dart';
import 'package:myproject/shared/input_text.dart';
import 'package:myproject/shared/styled_button.dart';
import 'package:myproject/shared/styled_text.dart';
import 'package:myproject/theme.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}
class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstnameController = TextEditingController(); // Firstname controller
  final TextEditingController _lastnameController = TextEditingController();  // Lastname controller
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();  // Date of Birth controller
  final AuthService _authService = AuthService();
  bool _isButtonEnabled = false;
  File? _image; // Store selected image
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  // Method to pick image
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Method to pick date of birth
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void submit() async {
  if (_formKey.currentState?.validate() ?? false) {
    final String username = '${_firstnameController.text}${_lastnameController.text}';
    final String fullName = '${_firstnameController.text} ${_lastnameController.text}';

    // Parse the date of birth to a DateTime object
    final DateTime dob = DateFormat('yyyy-MM-dd').parse(_dobController.text);

    // Calculate the age
    int age = DateTime.now().year - dob.year;
    if (DateTime.now().month < dob.month || (DateTime.now().month == dob.month && DateTime.now().day < dob.day)) {
      // Subtract one year if the birthday hasn't occurred yet this year
      age--;
    }

    // Create RegisterRequest with the calculated age and image path
    final RegisterRequest registerRequest = RegisterRequest(
      username: username,
      email: _emailController.text,
      password: _passwordController.text,
      fullName: fullName,
      profilePhotoUrl: _image?.path ?? '', 
      age: age,
    );

    User? response = await _authService.signUp(registerRequest);

    if (response != null) {
      // Navigate to login after successful signup
      Navigator.pushReplacementNamed(context, '/sign-in');
    } else {
      // Show error if signup failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: StyledErrorText('Signup failed'),
          backgroundColor: Colors.white,
        ),
      );
    }
  }
}

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _firstnameController.text.isNotEmpty &&
          _lastnameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    _firstnameController.addListener(_updateButtonState);
    _lastnameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 166, 83, 222),
              Color.fromARGB(255, 209, 151, 247),
              Color.fromARGB(255, 231, 201, 250),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 35),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StyledTitle('sign_up'.tr()),
                const SizedBox(height: 10),
                
                // Image Upload Section
                _image == null
                    ? GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      )
                    : GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: FileImage(_image!),
                        ),
                      ),
                const SizedBox(height: 8),

                // Firstname Input Field
                InputText(
                  controller: _firstnameController,
                  labelText: 'firstname'.tr(),
                  iconData: Icons.person_pin,
                  inputType: TextInputType.text,
                ),
                const SizedBox(height: 8),

                // Lastname Input Field
                InputText(
                  controller: _lastnameController,
                  labelText: 'lastname'.tr(),
                  iconData: Icons.person,
                  inputType: TextInputType.text,
                ),
                const SizedBox(height: 8),

                // Date of Birth Input Field
                TextFormField(
                  controller: _dobController,
                  readOnly: true, 
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black26, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black54, width: 2.0),
                    ),
                    labelText: 'date of birth'.tr(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context), 
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please select a date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Email Input Field
                InputText(
                  controller: _emailController,
                  labelText: 'email'.tr(),
                  iconData: Icons.email,
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),

                // Password Input Field
                InputText(
                  controller: _passwordController,
                  labelText: 'password'.tr(),
                  iconData: Icons.lock,
                  isSecret: true,
                  inputType: TextInputType.text,
                ),
                const SizedBox(height: 8),

                // Confirm Password Input Field
                InputText(
                  controller: _confirmPasswordController,
                  labelText: 'confirm_password'.tr(),
                  iconData: Icons.lock,
                  isSecret: true,
                  inputType: TextInputType.text,
                ),
                const SizedBox(height: 8),

                // Submit Button
                StyledButton(
                  onPressed: _isButtonEnabled ? submit : null,
                  enabled: _isButtonEnabled,
                  child: StyledButtonText('confirm'.tr()),
                ),
                
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.textColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: StyledText('already_have_account'.tr()),
                    ),
                    Expanded(child: Divider(color: AppTheme.textColor)),
                  ],
                ),
                const SizedBox(height: 4),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/sign-in');
                  },
                  child: Text('login'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
