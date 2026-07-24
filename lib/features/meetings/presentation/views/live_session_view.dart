import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';

class LiveSessionView extends ConsumerStatefulWidget {
  final MeetingItem item;

  const LiveSessionView({super.key, required this.item});

  @override
  ConsumerState<LiveSessionView> createState() => _LiveSessionViewState();
}

class _LiveSessionViewState extends ConsumerState<LiveSessionView> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isChatOpen = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // On small screens, layout adjusts
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF111827), // Dark grey background for meetings
      body: SafeArea(
        child: Stack(
          children: [
            // Video Grid (Mock)
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2937),
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Icon(Icons.person_rounded, size: 80.r, color: Colors.white24),
                                  ),
                                  Positioned(
                                    bottom: 16.h,
                                    left: 16.w,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        'Mr. Sharma (Host)',
                                        style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          // Smaller self view
                          Container(
                            height: 120.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF374151),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Icon(_isVideoOff ? Icons.videocam_off_rounded : Icons.person_rounded, color: Colors.white24, size: 40.r),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Chat Sidebar (conditionally visible)
                  if (_isChatOpen)
                    Container(
                      width: isMobile ? MediaQuery.of(context).size.width * 0.8 : 320.w,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        border: Border(
                          left: BorderSide(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'In-call Messages',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => setState(() => _isChatOpen = false),
                                  icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Messages appear here',
                                style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12.sp),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(24.r),
                                    ),
                                    child: Text('Type a message...', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.title,
                            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Container(
                                width: 8.r,
                                height: 8.r,
                                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                              ),
                              SizedBox(width: 6.w),
                              Text('00:15:23', style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Control Bar
            Positioned(
              bottom: 32.h,
              left: 0,
              right: _isChatOpen ? (isMobile ? MediaQuery.of(context).size.width * 0.8 : 320.w) : 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(100.r),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildControlButton(
                        icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        label: _isMuted ? 'Unmute' : 'Mute',
                        isActive: _isMuted,
                        onTap: () => setState(() => _isMuted = !_isMuted),
                      ),
                      SizedBox(width: 8.w),
                      _buildControlButton(
                        icon: _isVideoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                        label: _isVideoOff ? 'Start Video' : 'Stop Video',
                        isActive: _isVideoOff,
                        onTap: () => setState(() => _isVideoOff = !_isVideoOff),
                      ),
                      SizedBox(width: 8.w),
                      _buildControlButton(
                        icon: Icons.back_hand_rounded,
                        label: 'Raise Hand',
                        isActive: false,
                        onTap: () {},
                      ),
                      SizedBox(width: 8.w),
                      _buildControlButton(
                        icon: Icons.chat_rounded,
                        label: 'Chat',
                        isActive: _isChatOpen,
                        onTap: () => setState(() => _isChatOpen = !_isChatOpen),
                      ),
                      SizedBox(width: 16.w),
                      Container(width: 1, height: 32.h, color: Colors.white24),
                      SizedBox(width: 16.w),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.r)),
                        ),
                        child: Text('Leave', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: Material(
        color: isActive ? Colors.white24 : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? Colors.transparent : Colors.white10),
            ),
            child: Icon(icon, color: Colors.white, size: 24.r),
          ),
        ),
      ),
    );
  }
}
