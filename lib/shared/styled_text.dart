import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StyledText extends StatelessWidget {
  const StyledText(this.text, {super.key});
  
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.kanit(
      textStyle: Theme.of(context).textTheme.bodyMedium,
    ));
  }
}
class StyledHeading extends StatelessWidget {
  const StyledHeading(this.text, {super.key});
  
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.balooBhaijaan2(
      textStyle: Theme.of(context).textTheme.headlineMedium,
    ));
  }
}
class StyledTitle extends StatelessWidget {
  const StyledTitle(this.text, {super.key});
  
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: GoogleFonts.balooBhaijaan2(
      textStyle: Theme.of(context).textTheme.titleMedium
    ));
  }
}

class StyledButtonText extends StatelessWidget {
  const StyledButtonText(this.text,{super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.balooBhaijaan2(
      textStyle: Theme.of(context).textTheme.headlineSmall,
    ));
  }
}

class StyledErrorText extends StatelessWidget {
  const StyledErrorText(this.text, {super.key});
  
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: GoogleFonts.kanit(
          textStyle: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}

class StyledSuccessText extends StatelessWidget {
  const StyledSuccessText(this.text, {super.key});
  
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: GoogleFonts.kanit(
          textStyle: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}




