import 'package:flutter/material.dart';
import 'package:myproject/screens/notifications.dart';
import 'package:myproject/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String logoAsset;
  final double appBarHeight;
  final GlobalKey<ScaffoldState> scaffoldKey; 

  const CustomAppBar({
    super.key,
    required this.logoAsset,
    required this.scaffoldKey, 
    this.appBarHeight = 45,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Image.asset(
        logoAsset,
        width: 55,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications), 
          iconSize: 22,
          color: AppTheme.primaryColor,
          onPressed: () {
            Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Notifications()),
                );
          }
        ),
        IconButton(
          icon: const Icon(Icons.menu), 
          iconSize: 32,
          color: AppTheme.primaryColor,
          onPressed: () {
            scaffoldKey.currentState?.openEndDrawer(); 
          },
        ),
      ],
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}
