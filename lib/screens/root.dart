import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:myproject/shared/styled_text.dart';

class Root extends StatelessWidget {
  const Root({
    required this.title,
    required this.child ,
    super.key
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10,),
        StyledTitle(title),
        const SizedBox(height: 10,),
        Expanded(child: Container(child: child)),
        Image.asset('assets/img/bg.jpg',  
          fit: BoxFit.fitWidth,
          alignment: Alignment.bottomCenter,
        )
      ],
    );
  }
}