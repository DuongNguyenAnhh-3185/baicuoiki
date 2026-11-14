import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../injection_container.dart';
import '../../../../shared/entities/attempt_log.dart';
import '../../../../shared/entities/soroban_question.dart';
import '../../../../shared/widgets/mascot_bubble.dart';
import 'package:soroban_kids_app/features/1_abacus_engine/presentation/controllers/finger_math_controller.dart';
import 'package:soroban_kids_app/features/1_abacus_engine/presentation/widgets/finger_math_board_widget.dart';
import 'package:soroban_kids_app/features/4_ai_voice_tutor/domain/engine/adaptive_tutor_engine.dart';
import 'package:soroban_kids_app/features/4_ai_voice_tutor/presentation/widgets/voice_answer_mic_button.dart';
import 'package:soroban_kids_app/features/3_lessons_flash_anzan/domain/question_generator.dart';

class LessonPlayScreen extends StatefulWidget {
  final int level;

  const LessonPlayScreen({super.key, required this.level});

  @override
  State<LessonPlayScreen> createState() => _LessonPlayScreenState();
}

class _LessonPlayScreenState extends State<LessonPlayScreen> {
  final AudioService _audioService = sl<AudioService>();
  final StorageService _storageService = sl<StorageService>();
  late FingerMathController _fingerController;

  late SorobanQuestion _currentQuestion;
  int _questionIndex = 1;
  String _mascotSpeech = 'Bé hãy nhìn phép tính và gảy ngón tay Finger Math nhé!';
  String _formulaHint = '';
  DateTime _questionStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Cấp 1 & 2 dùng 1 bàn tay phải (hàng đơn vị) hoặc 2 bàn tay nếu kết quả > 9
    _fingerController = FingerMathController(showLeftHand: widget.level >= 2);
    _loadNextQuestion();
  }

  @override
  void dispose() {
    _fingerController.dispose();
    super.dispose();
  }

  void _loadNextQuestion() {
    setState(() {
      _currentQuestion = QuestionGenerator.generate(widget.level);
      _fingerController.reset();
      _questionStartTime = DateTime.now();

      // Tạo gợi ý công thức Finger Math (Anh bạn nhỏ / Anh bạn lớn)
      _formulaHint = _getFingerMathFormulaHint(_currentQuestion);
      _mascotSpeech = 'Phép tính: ${_currentQuestion.formulaExpression} = ?\n$_formulaHint';
    });
    _audioService.speak(
      'Bé ơi, hãy tính: ${_currentQuestion.formulaExpression}. $_formulaHint',
    );
  }

  String _getFingerMathFormulaHint(SorobanQuestion q) {
    if (q.level == 1) {
      return 'Bung các ngón tay trên Tay Phải (đơn vị: 0-9) theo từng số nhé!';
    }
    // Cấp độ 2 & 3: Công thức Anh Bạn Nhỏ & Anh Bạn Lớn
    for (final op in q.operands) {
      if (op == 9) return 'Anh Bạn Lớn (+9 = +10 - 1): Bung 1 ngón Tay Trái (+10), gập 1 ngón Tay Phải (-1)';
      if (op == 8) return 'Anh Bạn Lớn (+8 = +10 - 2): Bung 1 ngón Tay Trái (+10), gập 2 ngón Tay Phải (-2)';
      if (op == 7) return 'Anh Bạn Lớn (+7 = +10 - 3): Bung 1 ngón Tay Trái (+10), gập 3 ngón Tay Phải (-3)';
      if (op == 6) return 'Anh Bạn Lớn (+6 = +10 - 4): Bung 1 ngón Tay Trái (+10), gập 4 ngón Tay Phải (-4)';
      if (op == 4) return 'Anh Bạn Nhỏ (+4 = +5 - 1): Tay Phải xòe ngón cái (5), gập 1 ngón dài';
      if (op == 3) return 'Anh Bạn Nhỏ (+3 = +5 - 2): Tay Phải xòe ngón cái (5), gập 2 ngón dài';
      if (op == 2) return 'Anh Bạn Nhỏ (+2 = +5 - 3): Tay Phải xòe ngón cái (5), gập 3 ngón dài';
      if (op == 1) return 'Anh Bạn Nhỏ (+1 = +5 - 4): Tay Phải xòe ngón cái (5), gập 4 ngón dài';
      if (op == -1) return 'Anh Bạn Nhỏ (-1 = -5 + 4): Tay Phải gập ngón cái (5), bung 4 ngón dài';
      if (op == -2) return 'Anh Bạn Nhỏ (-2 = -5 + 3): Tay Phải gập ngón cái (5), bung 3 ngón dài';
      if (op == -3) return 'Anh Bạn Nhỏ (-3 = -5 + 2): Tay Phải gập ngón cái (5), bung 2 ngón dài';
      if (op == -4) return 'Anh Bạn Nhỏ (-4 = -5 + 1): Tay Phải gập ngón cái (5), bung 1 ngón dài';
      if (op == -9) return 'Anh Bạn Lớn (-9 = -10 + 1): Gập 1 ngón Tay Trái (-10), bung 1 ngón Tay Phải (+1)';
    }
    return 'Áp dụng công thức ngón tay Tay Trái và Tay Phải để tính nhanh nhé!';
  }

  Future<void> _checkAnswer(int answer, String answeredVia) async {
    final elapsed = DateTime.now().difference(_questionStartTime).inMilliseconds;
    final isCorrect = answer == _currentQuestion.expectedAnswer;

    final log = AttemptLog(
      questionId: _currentQuestion.id,
      userAnswer: answer,
      isCorrect: isCorrect,
      responseTimeMs: elapsed,
      answeredVia: answeredVia,
      timestamp: DateTime.now().toIso8601String(),
    );
    await _storageService.saveAttemptLog(log);

    // Cập nhật streak nếu đúng
    if (isCorrect) {
      final profile = await _storageService.getChildProfile();
      await _storageService.saveChildProfile(
        profile.copyWith(streakCount: profile.streakCount + 1),
      );
      await _audioService.playSuccessFeedback();
    } else {
      await _audioService.playEncouragementFeedback();
    }

    // Đánh giá Adaptive Tutor
    final recentLogs = await _storageService.getRecentLogs();
    final decision = AdaptiveTutorEngine.evaluatePerformance(
      recentAttempts: recentLogs,
    );

    _showResultDialog(isCorrect: isCorrect, answer: answer, decision: decision);
  }

  void _showResultDialog({
    required bool isCorrect,
    required int answer,
    required AdaptiveDecision decision,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor:
              isCorrect ? const Color(0xFFF0FFF4) : const Color(0xFFFFF5F5),
          title: Text(
            isCorrect ? 'CHÍNH XÁC! ⭐' : 'BÉ CỐ LÊN NHÉ! 💖',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isCorrect ? AppColors.success : AppColors.error,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isCorrect
                    ? 'Bé tính đúng rồi! Kết quả là $answer'
                    : 'Bé ra $answer, đáp án đúng là ${_currentQuestion.expectedAnswer}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  decision.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _questionIndex++);
                _loadNextQuestion();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCorrect ? AppColors.success : AppColors.secondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: const Text('Câu tiếp theo ➡️',
                  style: TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.level == 1
              ? 'Finger Math: Đếm Ngón Cơ Bản'
              : 'Finger Math: Anh Bạn Nhỏ & Lớn',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cardBg,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  'Câu $_questionIndex',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mascot Bubble trên cùng
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: MascotBubbleWidget(
                speechText: _mascotSpeech,
                onMascotTap: () {
                  _audioService.speak(_mascotSpeech);
                },
              ),
            ),

            // Khung hiển thị phép tính to rõ
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _currentQuestion.formulaExpression,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            // Bàn tay Finger Math tương tác
            Expanded(
              child: Center(
                child: FingerMathBoardWidget(
                  controller: _fingerController,
                  height: 220,
                  showLiveValue: true,
                ),
              ),
            ),

            // Nút trả lời (Gửi kết quả bàn tay hoặc Bấm nói giọng nói)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _checkAnswer(
                        _fingerController.totalValue,
                        'finger_touch',
                      );
                    },
                    icon: const Icon(Icons.front_hand, size: 26),
                    label: const Text('GỬI NGÓN TAY ✋'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                  VoiceAnswerMicButton(
                    onAnswerDetected: (answer, raw) {
                      _checkAnswer(answer, 'voice');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
