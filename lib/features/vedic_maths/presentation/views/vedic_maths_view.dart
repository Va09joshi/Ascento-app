import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/services/storage_service.dart';

class VedicMathsView extends ConsumerStatefulWidget {
  const VedicMathsView({super.key});

  @override
  ConsumerState<VedicMathsView> createState() => _VedicMathsViewState();
}

class _VedicMathsViewState extends ConsumerState<VedicMathsView> {
  int _activeSection = 0; // 0 = Trick Cards, 1 = Live Solver, 2 = Timer Quiz
  int _vedicStars = 15;

  // --- TRICKS STATE ---
  final List<Map<String, dynamic>> _tricks = [
    {
      'title': 'Squaring Numbers Ending in 5',
      'sutra': 'Ekadhikena Purvena',
      'desc': 'Square any number ending in 5 in under 2 seconds!',
      'steps': [
        'Multiply the first digit (N) by the next higher number (N + 1).',
        'Append "25" to the end of the result.',
      ],
      'example': '45² = (4 × 5) | 25 = 2025',
      'testNum': 65,
    },
    {
      'title': 'Multiply by 11 Shortcut',
      'sutra': 'Antyayordashakepi',
      'desc': 'Instantly multiply any 2-digit number by 11!',
      'steps': [
        'Add the two digits together (A + B).',
        'Place this sum in between the original digits. If sum >= 10, carry over 1 to the first digit.',
      ],
      'example': '43 × 11 = 4 | (4+3) | 3 = 473',
      'testNum': 53,
    },
    {
      'title': 'Numbers Near Base 100',
      'sutra': 'Nikhilam Navatashcaramam Dashatah',
      'desc': 'Multiply numbers like 96 × 98 in your head!',
      'steps': [
        'Find the difference from 100 for both numbers. (-4 and -2)',
        'Subtract the difference of one from the other diagonally. (96 - 2 = 94)',
        'Multiply the differences for the right part. (-4 × -2 = 08). Append it!',
      ],
      'example': '96 × 98 = (96-2) | (-4 × -2) = 9408',
      'testNum': 95,
    }
  ];

  int _selectedTrickIdx = 0;

  // --- SOLVER STATE ---
  final TextEditingController _solverNum1Controller = TextEditingController(text: '75');
  String _solverStepsHtml = '';
  
  // --- TIMER QUIZ STATE ---
  bool _quizRunning = false;
  int _secondsLeft = 30;
  int _quizScore = 0;
  String _quizQuestion = '';
  int _correctAnswer = 0;
  final TextEditingController _quizInputController = TextEditingController();
  Timer? _quizTimer;
  final List<String> _quizLogs = [];

  @override
  void initState() {
    super.initState();
    _calculateSolverSteps();
  }

  @override
  void dispose() {
    _solverNum1Controller.dispose();
    _quizInputController.dispose();
    _quizTimer?.cancel();
    super.dispose();
  }

  // --- SOLVER LOGIC ---
  void _calculateSolverSteps() {
    final inputVal = int.tryParse(_solverNum1Controller.text) ?? 5;
    
    // Default trick logic is Squaring Ending in 5
    if (inputVal % 10 == 5) {
      final int n = inputVal ~/ 10;
      final int n1 = n + 1;
      final int leftSide = n * n1;
      final int finalResult = inputVal * inputVal;

      setState(() {
        _solverStepsHtml = '💡 Formula: (N × (N + 1)) | 25\n\n'
            'Step 1: Separate the digits. N = $n, and 5.\n'
            'Step 2: Multiply first part: $n × ($n + 1) = $n × $n1 = $leftSide\n'
            'Step 3: Place 25 at the end.\n'
            'Result: $leftSide | 25 = $finalResult\n\n'
            'Wow! Mental maths works wonders! 🎉';
      });
    } else {
      // General multiplying by 11 fallback solver
      final int a = inputVal ~/ 10;
      final int b = inputVal % 10;
      final int sum = a + b;
      final int finalResult = inputVal * 11;

      setState(() {
        _solverStepsHtml = '💡 Formula for $inputVal × 11:\n\n'
            'Step 1: First digit is $a, Last digit is $b.\n'
            'Step 2: Add digits: $a + $b = $sum\n'
            'Step 3: Put sum in middle: ${sum >= 10 ? '${a + 1} | ${sum - 10} | $b' : '$a | $sum | $b'}\n'
            'Result: $finalResult\n\n'
            'Extremely fast! ⚡';
      });
    }
  }

  // --- QUIZ LOGIC ---
  void _startQuiz() {
    setState(() {
      _quizRunning = true;
      _secondsLeft = 30;
      _quizScore = 0;
      _quizLogs.clear();
      _generateQuizQuestion();
    });

    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _endQuiz();
      }
    });
  }

  void _generateQuizQuestion() {
    final rand = Random();
    final type = rand.nextInt(3);

    if (type == 0) {
      // Squaring ending in 5
      final base = (rand.nextInt(9) + 1) * 10 + 5;
      _quizQuestion = 'What is $base² ?';
      _correctAnswer = base * base;
    } else if (type == 1) {
      // Multiply by 11
      final num = rand.nextInt(89) + 10;
      _quizQuestion = 'What is $num × 11 ?';
      _correctAnswer = num * 11;
    } else {
      // Near base 100 subtraction practice
      final val1 = rand.nextInt(6) + 93; // 93 to 98
      final val2 = rand.nextInt(6) + 93; // 93 to 98
      _quizQuestion = 'What is $val1 × $val2 ?';
      _correctAnswer = val1 * val2;
    }
    _quizInputController.clear();
  }

  void _checkQuizAnswer() {
    final ans = int.tryParse(_quizInputController.text);
    if (ans == null) return;

    final isCorrect = ans == _correctAnswer;
    setState(() {
      if (isCorrect) {
        _quizScore++;
        _quizLogs.insert(0, '✅ Correct! $_quizQuestion = $_correctAnswer');
      } else {
        _quizLogs.insert(0, '❌ Incorrect! $_quizQuestion was $_correctAnswer, you put $ans');
      }
    });

    _generateQuizQuestion();
  }

  void _endQuiz() {
    _quizTimer?.cancel();
    setState(() {
      _quizRunning = false;
      _vedicStars += _quizScore * 2;
    });

    try {
      final storage = ref.read(storageServiceProvider);
      storage.setTotalStars(storage.getTotalStars() + (_quizScore * 2));
    } catch (_) {}

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🏆 Quiz Complete!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 72),
            const SizedBox(height: 12),
            Text(
              'You solved $_quizScore questions correctly!\n\nEarned: +${_quizScore * 2} Stars!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFFFF9F5),
      appBar: AppBar(
        title: const Text(
          '⚡ Vedic Maths Sutras',
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
                colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_vedicStars Stars',
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
            // --- Custom Top Segment Bar ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildPlayTabButton(0, '📚 Sutra Cards', Colors.deepOrange)),
                    Expanded(child: _buildPlayTabButton(1, '⚡ Trick Solver', Colors.orange)),
                    Expanded(child: _buildPlayTabButton(2, '⏱️ Timed Quiz', Colors.orangeAccent)),
                  ],
                ),
              ),
            ),

            // --- Tab Content View ---
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
    final isSelected = _activeSection == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeSection = index;
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
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(bool isDark) {
    switch (_activeSection) {
      case 0:
        return _buildSutraCardsTab(isDark);
      case 1:
        return _buildLiveSolverTab(isDark);
      case 2:
      default:
        return _buildTimedQuizTab(isDark);
    }
  }

  // ===========================================================================
  // TAB 1: SUTRA CARDS
  // ===========================================================================
  Widget _buildSutraCardsTab(bool isDark) {
    final trick = _tricks[_selectedTrickIdx];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row of selection circles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_tricks.length, (idx) {
              final isCurrent = _selectedTrickIdx == idx;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTrickIdx = idx;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: isCurrent ? 24 : 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isCurrent ? Colors.deepOrange : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Core trick details card
          Expanded(
            child: Card(
              color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Sutra: "${trick['sutra']}"',
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        trick['title'] as String,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        trick['desc'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Divider(height: 32),
                      const Text(
                        '🔑 How to solve mental math steps:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(
                        (trick['steps'] as List).length,
                        (stepIdx) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.orange.withOpacity(0.2),
                                child: Text(
                                  '${stepIdx + 1}',
                                  style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  trick['steps'][stepIdx] as String,
                                  style: const TextStyle(fontSize: 13, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 32),
                      const Text(
                        '📝 Real-world Example:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.orange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange.withOpacity(0.2)),
                        ),
                        child: Text(
                          trick['example'] as String,
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 2: LIVE SOLVER
  // ===========================================================================
  Widget _buildLiveSolverTab(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User input area
          Card(
            color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.calculate_rounded, color: Colors.orange, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Try any number ending in 5 or multiplier near 11:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        TextField(
                          controller: _solverNum1Controller,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          decoration: const InputDecoration(
                            hintText: 'Enter e.g. 45 or 85',
                            border: InputBorder.none,
                          ),
                          onChanged: (val) => _calculateSolverSteps(),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: Colors.orange),
                    onPressed: _calculateSolverSteps,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Live Math Steps Showcase
          Expanded(
            child: Card(
              color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚡ Mental Breakdown Solver',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.orangeAccent),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black38 : const Color(0xFFFFFCFA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.withOpacity(0.1)),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _solverStepsHtml,
                            style: const TextStyle(
                              fontSize: 15,
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w600,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 3: TIMED QUIZ
  // ===========================================================================
  Widget _buildTimedQuizTab(bool isDark) {
    if (!_quizRunning) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_rounded, size: 90, color: Colors.deepOrangeAccent),
            const SizedBox(height: 16),
            const Text(
              'Timed Mental Calculator Challenge',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Solve as many Vedic equations as possible in 30 seconds! Every correct answer yields +2 Stars.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 4,
              ),
              onPressed: _startQuiz,
              child: const Text(
                '🚀 Start Timed Quiz!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Timer and score bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '$_secondsLeft seconds',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.redAccent, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: Colors.green, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Score: $_quizScore',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Question Card
          Card(
            color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    'Solve Diagonally or using Sutra:',
                    style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _quizQuestion,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Outfit',
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _quizInputController,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Type answer',
                            hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                            filled: true,
                            fillColor: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          onSubmitted: (val) => _checkQuizAnswer(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        onPressed: _checkQuizAnswer,
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quiz logs list
          Expanded(
            child: ListView.builder(
              itemCount: _quizLogs.length,
              itemBuilder: (context, idx) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    _quizLogs[idx],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
