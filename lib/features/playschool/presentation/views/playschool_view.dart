import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/services/storage_service.dart';

class PlayschoolView extends ConsumerStatefulWidget {
  const PlayschoolView({super.key});

  @override
  ConsumerState<PlayschoolView> createState() => _PlayschoolViewState();
}

class _PlayschoolViewState extends ConsumerState<PlayschoolView> with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0 = Tracing Canvas, 1 = Animal Sounds, 2 = Daily Tasks
  int _playschoolStars = 10;
  
  // Tracing Board State
  final List<List<Offset>> _points = [];
  Color _selectedCrayon = const Color(0xFFFF5B7F);
  double _crayonSize = 8.0;
  String _currentTraceLetter = 'A';

  // Task list
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Trace Letter A', 'completed': false, 'icon': '✏️'},
    {'title': 'Listen to Lion Sound', 'completed': false, 'icon': '🦁'},
    {'title': 'Count 1 to 5 with beads', 'completed': false, 'icon': '🧮'},
    {'title': 'Draw a circle', 'completed': false, 'icon': '🎨'},
    {'title': 'Healthy fruit snack', 'completed': false, 'icon': '🍎'},
  ];

  // Bouncing controller for tap feedback
  late final AnimationController _bounceController;
  int? _tappedAnimalIndex;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.1,
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _triggerAnimalBounce(int index) {
    setState(() {
      _tappedAnimalIndex = index;
    });
    _bounceController.forward().then((value) {
      _bounceController.reverse().then((value) {
        setState(() {
          _tappedAnimalIndex = null;
        });
      });
    });

    // Award standard star when interaction first happens for Lion
    if (index == 0 && !_tasks[1]['completed']) {
      _completeTask(1);
    }
  }

  void _completeTask(int index) {
    if (_tasks[index]['completed']) return;
    setState(() {
      _tasks[index]['completed'] = true;
      _playschoolStars += 5;
    });

    // Try to update global star count in shared preferences
    try {
      final storage = ref.read(storageServiceProvider);
      storage.setTotalStars(storage.getTotalStars() + 5);
    } catch (_) {}

    // Show success dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Text('⭐ Excellent!', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 80, color: Colors.orangeAccent),
            const SizedBox(height: 12),
            Text(
              'You earned +5 Magic Stars!\nTotal Stars: $_playschoolStars',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Yay!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF9F7FF),
      appBar: AppBar(
        title: const Text(
          '🎈 Playschool Academy',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Outfit'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_playschoolStars Stars',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Custom Segmented Play Mode Switcher ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildPlayTabButton(0, '✏️ Tracing', const Color(0xFFFF5B7F))),
                    Expanded(child: _buildPlayTabButton(1, '🦁 Animals', const Color(0xFF4CAF50))),
                    Expanded(child: _buildPlayTabButton(2, '⭐ Tasks', const Color(0xFFFF9800))),
                  ],
                ),
              ),
            ),

            // --- Main Content Area ---
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildActiveTabContent(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayTabButton(int index, String title, Color activeColor) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            color: isSelected ? activeColor : Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(bool isDark) {
    switch (_activeTab) {
      case 0:
        return _buildTracingTab(isDark);
      case 1:
        return _buildAnimalSoundsTab(isDark);
      case 2:
      default:
        return _buildDailyTasksTab(isDark);
    }
  }

  // ===========================================================================
  // TAB 1: TRACING CANVAS
  // ===========================================================================
  Widget _buildTracingTab(bool isDark) {
    final crayons = [
      const Color(0xFFFF5B7F), // Coral Pink
      const Color(0xFF4DB6AC), // Mint Teal
      const Color(0xFFFFD54F), // Bright Yellow
      const Color(0xFF42A5F5), // Sky Blue
      const Color(0xFFAB47BC), // Soft Purple
      const Color(0xFF263238), // Dark Gray
    ];

    final traceLetters = ['A', 'B', 'C', '1', '2', '3', '🍎', '⭐'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Subheader guide selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: traceLetters.map((letter) {
                final isCurrent = _currentTraceLetter == letter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentTraceLetter = letter;
                      _points.clear();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 10, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrent ? const Color(0xFFFF5B7F) : (isDark ? AppColors.darkSurface : Colors.white),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isCurrent ? const Color(0xFFFF5B7F) : Colors.grey.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      isCurrent ? 'Trace "$letter"' : letter,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? Colors.white : (isDark ? Colors.white : Colors.black87),
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Tracing Canvas Card
          Expanded(
            child: Card(
              color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Stack(
                children: [
                  // Tracer backdrop template (dotted letter guidelines)
                  Center(
                    child: Opacity(
                      opacity: 0.08,
                      child: Text(
                        _currentTraceLetter,
                        style: const TextStyle(
                          fontSize: 250,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),

                  // Dotted lines representation
                  Center(
                    child: CustomPaint(
                      painter: _DottedLetterPainter(
                        letter: _currentTraceLetter,
                        isDark: isDark,
                      ),
                      size: const Size(double.infinity, double.infinity),
                    ),
                  ),

                  // User drawing paint layer
                  GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _points.add([details.localPosition]);
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        if (_points.isNotEmpty) {
                          _points.last.add(details.localPosition);
                        }
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        // Tracing challenge completed hook
                        if (_points.length > 3 && !_tasks[0]['completed'] && _currentTraceLetter == 'A') {
                          _completeTask(0);
                        }
                      });
                    },
                    child: CustomPaint(
                      painter: _CrayonPainter(
                        pointChunks: _points,
                        crayonColor: _selectedCrayon,
                        crayonSize: _crayonSize,
                      ),
                      size: const Size(double.infinity, double.infinity),
                    ),
                  ),

                  // Bottom Toolbar: Clear, Crayons, Size
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Clear button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF5350),
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                          ),
                          onPressed: () {
                            setState(() {
                              _points.clear();
                            });
                          },
                          child: const Icon(Icons.delete_rounded, color: Colors.white),
                        ),

                        // Crayon list
                        Row(
                          children: crayons.map((color) {
                            final isSelected = _selectedCrayon == color;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCrayon = color;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isSelected ? 34 : 26,
                                height: isSelected ? 34 : 26,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? (isDark ? Colors.white : Colors.black87) : Colors.white.withOpacity(0.6),
                                    width: isSelected ? 3 : 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))]
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        // Size picker toggle
                        DropdownButton<double>(
                          value: _crayonSize,
                          icon: const Icon(Icons.brush_rounded, size: 18),
                          elevation: 16,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                          underline: Container(),
                          onChanged: (double? newValue) {
                            setState(() {
                              _crayonSize = newValue!;
                            });
                          },
                          items: const [
                            DropdownMenuItem<double>(value: 4.0, child: Text('Thin')),
                            DropdownMenuItem<double>(value: 8.0, child: Text('Medium')),
                            DropdownMenuItem<double>(value: 16.0, child: Text('Thick Crayon')),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 2: ANIMAL SOUNDS
  // ===========================================================================
  Widget _buildAnimalSoundsTab(bool isDark) {
    final animals = [
      {'emoji': '🦁', 'name': 'Lion', 'sound': 'ROAAARRR!', 'bg': const Color(0xFFFFEFE2), 'accent': Colors.orange},
      {'emoji': '🐘', 'name': 'Elephant', 'sound': 'PAWOOO!', 'bg': const Color(0xFFECEFF1), 'accent': Colors.blueGrey},
      {'emoji': '🐸', 'name': 'Frog', 'sound': 'RIBBIT RIBBIT!', 'bg': const Color(0xFFE8F5E9), 'accent': Colors.green},
      {'emoji': '🐥', 'name': 'Little Chick', 'sound': 'CHEEP CHEEP!', 'bg': const Color(0xFFFFFDE7), 'accent': Colors.amber},
      {'emoji': '🐵', 'name': 'Monkey', 'sound': 'OOO OOO AAA AAA!', 'bg': const Color(0xFFEFEBE9), 'accent': Colors.brown},
      {'emoji': '🐱', 'name': 'Kitty Cat', 'sound': 'MEOWWW!', 'bg': const Color(0xFFFCE4EC), 'accent': Colors.pinkAccent},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Tap the animals to hear their funny sounds!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              itemCount: animals.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, idx) {
                final ani = animals[idx];
                final isTapped = _tappedAnimalIndex == idx;

                return GestureDetector(
                  onTap: () => _triggerAnimalBounce(idx),
                  child: ScaleTransition(
                    scale: isTapped ? _bounceController : const AlwaysStoppedAnimation(1.0),
                    child: Card(
                      color: isDark ? const Color(0xFF1E1E2F) : ani['bg'] as Color,
                      elevation: isTapped ? 8 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: BorderSide(
                          color: (ani['accent'] as Color).withOpacity(isTapped ? 0.8 : 0.2),
                          width: 2.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ani['emoji'] as String,
                              style: const TextStyle(fontSize: 60),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ani['name'] as String,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black87,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (ani['accent'] as Color).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                ani['sound'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: ani['accent'] as Color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 3: DAILY TASKS
  // ===========================================================================
  Widget _buildDailyTasksTab(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: Colors.white, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Morning Play Checklist',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete tasks to win rewards!',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, idx) {
                final task = _tasks[idx];
                final bool isDone = task['completed'] as bool;

                return Card(
                  color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDone ? Colors.green.withOpacity(0.5) : Colors.grey.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDone ? Colors.green.withOpacity(0.12) : Colors.purple.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        task['icon'] as String,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    title: Text(
                      task['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    trailing: isDone
                        ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28)
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B1FA2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onPressed: () => _completeTask(idx),
                            child: const Text(
                              'Done',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Crayon Drawing Painter
class _CrayonPainter extends CustomPainter {
  final List<List<Offset>> pointChunks;
  final Color crayonColor;
  final double crayonSize;

  _CrayonPainter({
    required this.pointChunks,
    required this.crayonColor,
    required this.crayonSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = crayonColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = crayonSize
      ..style = PaintingStyle.stroke;

    for (final chunk in pointChunks) {
      if (chunk.isEmpty) continue;
      
      final path = Path()..moveTo(chunk[0].dx, chunk[0].dy);
      for (int i = 1; i < chunk.length; i++) {
        path.lineTo(chunk[i].dx, chunk[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CrayonPainter oldDelegate) => true;
}

// Painter representing template letters
class _DottedLetterPainter extends CustomPainter {
  final String letter;
  final bool isDark;

  _DottedLetterPainter({required this.letter, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Simple custom guideline painter for kid tracing
    final paint = Paint()
      ..color = isDark ? Colors.white24 : Colors.black12
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // We draw specific guiding segments for 'A' if selected to give that premium feel
    if (letter == 'A') {
      final double cx = size.width / 2;
      final double cy = size.height / 2 - 20;

      // Draw standard triangle outline for A
      final path = Path()
        ..moveTo(cx, cy - 80)
        ..lineTo(cx - 60, cy + 80)
        ..moveTo(cx, cy - 80)
        ..lineTo(cx + 60, cy + 80)
        ..moveTo(cx - 35, cy + 20)
        ..lineTo(cx + 35, cy + 20);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLetterPainter oldDelegate) => false;
}
