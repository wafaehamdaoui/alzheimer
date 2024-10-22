import 'package:flutter/material.dart';
import 'package:myproject/theme.dart';

class StyledButton extends StatelessWidget {
  const StyledButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.enabled = true, // Default to true
  });

  final Function()? onPressed; // Change to nullable
  final Widget child;  
  final bool enabled; // Add enabled parameter

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null, // Disable button if not enabled
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          gradient: enabled // Change appearance based on enabled state
              ? LinearGradient(
                  colors: [AppTheme.primaryAccent, AppTheme.primaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null, // No gradient if disabled
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: enabled ? null : Color.fromARGB(255, 203, 135, 243), // Change background color if disabled
        ),
        child: child,
      ),
    );
  }
}
