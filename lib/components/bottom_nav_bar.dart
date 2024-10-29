import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:myproject/theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor, // Navbar background color
        borderRadius: const BorderRadius.all(Radius.circular(40)),
        border: Border.all(
          color: Colors.grey.shade300, // Border color
          width: 2, // Border width
        ),
        
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent, // Set to transparent to use the Container's background color
        selectedItemColor: Colors.white, // Active icon color
        unselectedItemColor: Colors.grey[400], // Inactive icon color
        iconSize: 28,
        currentIndex: selectedIndex, // Current active item
        onTap: onItemTapped, // Handle item tap
        elevation: 0, // Remove BottomNavigationBar shadow
        items: <BottomNavigationBarItem>[
          _buildNavItem(
            icon: Icons.home_outlined, 
            label: 'home'.tr(),
            index: 0,
            selectedIndex: selectedIndex,
          ),
          _buildNavItem(
            icon: Icons.medical_services, 
            label: 'daily_routine'.tr(),
            index: 1,
            selectedIndex: selectedIndex,
          ),
          _buildNavItem(
            icon: Icons.fact_check_outlined, 
            label: 'tasks'.tr(),
            index: 2,
            selectedIndex: selectedIndex,
          ),
          _buildNavItem(
            icon: Icons.calendar_month_outlined, 
            label: 'calendar'.tr(),
            index: 3,
            selectedIndex: selectedIndex,
          ),
          
        ],
      ),
    );
  }

  // Function to build a navigation item
  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int selectedIndex,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(10), 
        decoration: BoxDecoration(
          color: selectedIndex == index
              ? AppTheme.primaryAccent
              : Colors.transparent, 
          borderRadius: BorderRadius.circular(30), 
        ),
        child: Icon(
          icon,
          size: 30,
          color: selectedIndex == index ? Colors.white : Color.fromARGB(255, 216, 216, 216), // Change icon color based on selection
        ),
      ),
      label: label, 
    );
  }
}
