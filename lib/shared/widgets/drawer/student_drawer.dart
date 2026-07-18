import 'package:flutter/material.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'drawer_item.dart';
import 'drawer_section.dart';

class StudentDrawer extends StatelessWidget {
  final String currentPath;
  final void Function(String) onNavigate;

  const StudentDrawer({
    super.key,
    required this.currentPath,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DrawerSection(title: 'Student Portal'),
        DrawerItem(
          icon: Icons.grid_view_rounded,
          label: 'Overview',
          active: currentPath == RoutePaths.studentDashboard,
          accent: const Color(0xFF5B67F4),
          onTap: () => onNavigate(RoutePaths.studentDashboard),
        ),
        DrawerItem(
          icon: Icons.calendar_month_rounded,
          label: 'My Timetable',
          active: currentPath == RoutePaths.timetable,
          accent: const Color(0xFF2FA2B9),
          onTap: () => onNavigate(RoutePaths.timetable),
        ),
        DrawerItem(
          icon: Icons.assignment_rounded,
          label: 'My Exams',
          active: currentPath == RoutePaths.exams,
          accent: const Color(0xFFE85A9A),
          onTap: () => onNavigate(RoutePaths.exams),
        ),
        DrawerItem(
          icon: Icons.check_circle_rounded,
          label: 'My Attendance',
          active: currentPath == RoutePaths.attendance,
          accent: const Color(0xFF2FAE78),
          onTap: () => onNavigate(RoutePaths.attendance),
        ),
        DrawerItem(
          icon: Icons.campaign_rounded,
          label: 'Notice Board',
          active: currentPath == RoutePaths.notifications,
          accent: const Color(0xFFFF7A3A),
          onTap: () => onNavigate(RoutePaths.notifications),
        ),
        DrawerItem(
          icon: Icons.assignment_turned_in_rounded,
          label: 'My Homework',
          active: currentPath == RoutePaths.homework,
          accent: const Color(0xFF8E44AD),
          onTap: () => onNavigate(RoutePaths.homework),
        ),
        DrawerItem(
          icon: Icons.video_camera_front_rounded,
          label: 'Live Meetings',
          active: currentPath == RoutePaths.meetings,
          accent: const Color(0xFFE74C3C),
          onTap: () => onNavigate(RoutePaths.meetings),
        ),
        DrawerItem(
          icon: Icons.auto_stories_rounded,
          label: 'Study Materials',
          active: currentPath == RoutePaths.content,
          accent: const Color(0xFF3498DB),
          onTap: () => onNavigate(RoutePaths.content),
        ),
        DrawerItem(
          icon: Icons.receipt_long_rounded,
          label: 'Fee Details',
          active: currentPath == RoutePaths.fees,
          accent: const Color(0xFF1ABC9C),
          onTap: () => onNavigate(RoutePaths.fees),
        ),
      ],
    );
  }
}
