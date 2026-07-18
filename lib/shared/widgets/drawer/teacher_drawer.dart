import 'package:flutter/material.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'drawer_item.dart';
import 'drawer_section.dart';

class TeacherDrawer extends StatelessWidget {
  final String currentPath;
  final void Function(String) onNavigate;

  const TeacherDrawer({
    super.key,
    required this.currentPath,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DrawerSection(title: 'Teacher Portal'),
        DrawerItem(
          icon: Icons.dashboard_rounded,
          label: 'My Dashboard',
          active: currentPath == RoutePaths.teacherDashboard,
          accent: const Color(0xFF5B67F4),
          onTap: () => onNavigate(RoutePaths.teacherDashboard),
        ),
        DrawerItem(
          icon: Icons.how_to_reg_rounded,
          label: 'Mark Attendance',
          active: currentPath == RoutePaths.attendance,
          accent: const Color(0xFF2FAE78),
          onTap: () => onNavigate(RoutePaths.attendance),
        ),
        DrawerItem(
          icon: Icons.access_time_rounded,
          label: 'Timetable',
          active: currentPath == RoutePaths.timetable,
          accent: const Color(0xFFE85A9A),
          onTap: () => onNavigate(RoutePaths.timetable),
        ),
        DrawerItem(
          icon: Icons.assignment_turned_in_rounded,
          label: 'Homework & Grades',
          active: currentPath == RoutePaths.homework,
          accent: const Color(0xFF8E44AD),
          onTap: () => onNavigate(RoutePaths.homework),
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
