import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:myproject/theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: TextStyle(color: AppTheme.primaryColor),),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); 
          },
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
          },
          child: Text('confirm'.tr()),
        ),
      ],
    );
  }
}
