import 'package:flutter/material.dart';

class InputText extends StatelessWidget {
  const InputText({
    super.key,
    required this.labelText,
    required this.iconData,
    this.isSecret=false,
    required this.controller, 
    this.inputType=TextInputType.none,
    });
  
  final String labelText;
  final IconData iconData;
  final bool isSecret;
  final TextEditingController controller;
  final TextInputType inputType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: inputType,
      controller: controller,
      obscureText: isSecret,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(iconData),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}