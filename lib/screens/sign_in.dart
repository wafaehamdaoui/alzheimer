import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:myproject/models/authentication_response.dart';
import 'package:myproject/services/auth_service.dart';
import 'package:myproject/shared/input_text.dart';
import 'package:myproject/shared/styled_button.dart';
import 'package:myproject/shared/styled_text.dart';
import 'package:myproject/theme.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isButtonEnabled = false;

  void submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      AuthenticationResponse? response = await _authService.login(
        _usernameController.text, // Use username here
        _passwordController.text,
      );

      if (response != null) {
        // Navigate to home after successful login
        Navigator.pushReplacementNamed(context, '/home');
        Navigator.pop(context);
      } else {
        // Show error if login failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: StyledErrorText('Login failed'), backgroundColor: Colors.white),
        );
      }
    }
  }

  void goToSignUp() {
    Navigator.pushNamed(context, '/sign-up');
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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
               // Dark purple color
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
                StyledTitle('login'.tr()),
                const SizedBox(height: 20),
                InputText(
                  controller: _usernameController,
                  labelText: 'username'.tr(),
                  iconData: Icons.person,
                  inputType: TextInputType.text,
                ),
                const SizedBox(height: 20),
                InputText(
                  controller: _passwordController,
                  labelText: 'password'.tr(),
                  iconData: Icons.lock,
                  isSecret: true,
                  inputType: TextInputType.text,
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
                    Expanded(child: Divider(color:AppTheme.textColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: StyledText('dont_have_account'.tr()),
                    ),
                    Expanded(child: Divider(color:AppTheme.textColor)),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: goToSignUp,
                  child: Text('create_an_account'.tr()),
                ),
                //const Expanded(child: SizedBox(height: 4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
