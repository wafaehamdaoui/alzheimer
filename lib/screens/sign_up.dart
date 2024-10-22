import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:myproject/models/authentication_response.dart';
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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isButtonEnabled = false;

  void submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      AuthenticationResponse? response = await _authService.signUp(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (response != null) {
        // Navigate to login after successful signup
        Navigator.pushReplacementNamed(context, '/sign-in');
      } else {
        // Show error if signup failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: StyledErrorText('Signup failed'), backgroundColor: Colors.white),
        );
      }
    }
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _usernameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
              Color.fromARGB(255, 231, 201, 250),  // Light purple color
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/img/logo.png", 
                  height: 200, 
                  fit: BoxFit.fitHeight,
                ),
                StyledTitle('sign_up'.tr()),
                const SizedBox(height: 10),
                InputText(
                  controller: _usernameController,
                  labelText: 'username'.tr(),
                  iconData: Icons.person,
                  inputType: TextInputType.text,
                ),
                const SizedBox(height: 10),
                InputText(
                  controller: _emailController,
                  labelText: 'email'.tr(),
                  iconData: Icons.email,
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                InputText(
                  controller: _passwordController,
                  labelText: 'password'.tr(),
                  iconData: Icons.lock,
                  isSecret: true,
                ),
                const SizedBox(height: 10),
                InputText(
                  controller: _confirmPasswordController,
                  labelText: 'confirm_password'.tr(),
                  iconData: Icons.lock,
                  isSecret: true,
                ),
                const SizedBox(height: 10),
                StyledButton(
                  onPressed: _isButtonEnabled ? submit : null,
                  enabled: _isButtonEnabled,
                  child: StyledButtonText('confirm'.tr()),
                ),
                const SizedBox(height: 20),
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
