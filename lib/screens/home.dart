import 'package:flutter/material.dart';
import 'package:myproject/components/calendar.dart';
import 'package:myproject/components/daily_routine.dart';
import 'package:myproject/components/home_body.dart';
import 'package:myproject/components/tasks.dart';
import 'package:myproject/screens/language_selection.dart';
import 'package:myproject/screens/profile.dart';
import 'package:myproject/services/auth_service.dart';
import 'package:myproject/theme.dart';
import 'package:myproject/components/custom_app_bar.dart'; // Import the custom app bar
import 'package:myproject/components/bottom_nav_bar.dart'; // Import the custom bottom nav bar
import 'package:easy_localization/easy_localization.dart'; // Import EasyLocalization

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  // List of widgets to display when an icon in the bottom nav is tapped
  final List<Widget> _pages = const [
    Center(child: HomeBody()), 
    Center(child: DailyRoutineScreen()),
    Center(child: TasksScreen()),
    Center(child: CalendarWidget()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        logoAsset: 'assets/img/logo_color.png',
        scaffoldKey: _scaffoldKey,
      ),
      body: _pages[_selectedIndex],

      // Right-side drawer
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
              ),
              child: Text(
                'menu'.tr(), 
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            _createDrawerItem(
              icon: Icons.home_outlined,
              text: 'home'.tr(), 
              onTap: () => Navigator.pop(context),
            ),
            _createDrawerItem(
              icon: Icons.account_circle_outlined,
              text: 'profile'.tr(), 
              onTap: () => Navigator.push(
                context,  
                MaterialPageRoute(builder: (context) => const ProfileScreen()),),
            ),
            _createDrawerItem(
              icon: Icons.language_outlined,
              text: 'language'.tr(),
              onTap: () { 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
                );
              }
            ),
            _createDrawerItem(
              icon: Icons.logout,
              text: 'logout'.tr(),
              onTap: () { 
                _authService.logout();
                Navigator.popAndPushNamed(context, '/sign-in');
              }
            ),
          ],
        ),
      ),

      // Custom bottom navigation bar
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Helper method to create drawer items
  Widget _createDrawerItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}
