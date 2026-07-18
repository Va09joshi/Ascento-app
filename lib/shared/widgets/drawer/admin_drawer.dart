import 'package:flutter/material.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'drawer_item.dart';
import 'drawer_section.dart';

class AdminDrawer extends StatelessWidget {
  final String currentPath;
  final void Function(String) onNavigate;

  const AdminDrawer({
    super.key,
    required this.currentPath,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DrawerSection(title: 'Admin Console'),
        DrawerItem(
          icon: Icons.dashboard_rounded,
          label: 'Overview',
          active: currentPath == RoutePaths.adminDashboard,
          accent: const Color(0xFF5B67F4),
          onTap: () => onNavigate(RoutePaths.adminDashboard),
        ),
        DrawerItem(
          icon: Icons.account_tree_rounded,
          label: 'Manage Branches',
          active: currentPath == RoutePaths.manageBranches,
          accent: const Color(0xFFFF8A34),
          onTap: () => onNavigate(RoutePaths.manageBranches),
        ),
        DrawerItem(
          icon: Icons.manage_accounts_rounded,
          label: 'Users & Roles',
          active: currentPath == RoutePaths.manageUsers,
          accent: const Color(0xFF2FAE78),
          onTap: () => onNavigate(RoutePaths.manageUsers),
        ),
        DrawerItem(
          icon: Icons.category_rounded,
          label: 'Manage Domains',
          active: currentPath == RoutePaths.manageDomains,
          accent: const Color(0xFFD946EF),
          onTap: () => onNavigate(RoutePaths.manageDomains),
        ),
        DrawerItem(
          icon: Icons.school_rounded,
          label: 'Academics Config',
          active: currentPath == RoutePaths.academicsConfig,
          accent: const Color(0xFF6C4ED9),
          onTap: () => onNavigate(RoutePaths.academicsConfig),
        ),
        DrawerItem(
          icon: Icons.co_present_rounded,
          label: 'Attendance Data',
          active: currentPath == RoutePaths.attendance,
          accent: const Color(0xFFF9A826),
          onTap: () => onNavigate(RoutePaths.attendance),
        ),
        DrawerItem(
          icon: Icons.access_time_filled_rounded,
          label: 'Timetable Setup',
          active: currentPath == RoutePaths.timetable,
          accent: const Color(0xFF00B4D8),
          onTap: () => onNavigate(RoutePaths.timetable),
        ),
        DrawerItem(
          icon: Icons.assignment_rounded,
          label: 'Exams Config',
          active: currentPath == RoutePaths.exams,
          accent: const Color(0xFF9D4EDD),
          onTap: () => onNavigate(RoutePaths.exams),
        ),
        DrawerItem(
          icon: Icons.auto_stories_rounded,
          label: 'Study Materials',
          active: currentPath == RoutePaths.content,
          accent: const Color(0xFF3498DB),
          onTap: () => onNavigate(RoutePaths.content),
        ),
        DrawerItem(
          icon: Icons.video_camera_front_rounded,
          label: 'Live Meetings',
          active: currentPath == RoutePaths.meetings,
          accent: const Color(0xFFE74C3C),
          onTap: () => onNavigate(RoutePaths.meetings),
        ),
        DrawerItem(
          icon: Icons.campaign_rounded,
          label: 'Notices Board',
          active: currentPath == RoutePaths.notifications,
          accent: const Color(0xFFFF5400),
          onTap: () => onNavigate(RoutePaths.notifications),
        ),
      ],
    );
  }
}
