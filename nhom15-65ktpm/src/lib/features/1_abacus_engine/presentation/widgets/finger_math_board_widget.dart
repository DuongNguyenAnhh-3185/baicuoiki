import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/finger_hand_state.dart';
import '../controllers/finger_math_controller.dart';
import 'finger_hand_painter.dart';

class FingerMathBoardWidget extends StatefulWidget {
  final FingerMathController controller;
  final double height;
  final bool showLiveValue;

  const FingerMathBoardWidget({
    super.key,
    required this.controller,
    this.height = 230.0,
    this.showLiveValue = true,
  });

  @override
  State<FingerMathBoardWidget> createState() => _FingerMathBoardWidgetState();
}

class _FingerMathBoardWidgetState extends State<FingerMathBoardWidget> {
  final AudioService _audioService = sl<AudioService>();

  void _handleHandTap(TapUpDetails details, Size size, HandType handType) {
    final pos = details.localPosition;
    _audioService.playBeadClick();

    final isRight = handType == HandType.rightHand;
    final thumbZoneX = isRight ? size.width * 0.35 : size.width * 0.65;

    // Chạm vào vùng ngón cái
    if (isRight ? (pos.dx < thumbZoneX) : (pos.dx > thumbZoneX)) {
      widget.controller.toggleThumb(handType);
    } else {
      // Chạm vào vùng 4 ngón dài
      final fingerZoneWidth = size.width * 0.55;
      final startX = isRight ? size.width * 0.35 : size.width * 0.1;
      final relativeX = (pos.dx - startX).clamp(0.0, fingerZoneWidth);
      final fraction = relativeX / fingerZoneWidth;

      int selectedCount = ((fraction * 4).floor() + 1).clamp(1, 4);
      if (!isRight) {
        selectedCount = 5 - selectedCount;
      }
      widget.controller.setExtendedFingers(handType, selectedCount);
    }
  }

  void _showFormulaGuideModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Text(
                    '📖 Quy Ước 2 Bàn Tay & Bảng Công Thức',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Quy ước 2 bàn tay (0 đến 99):',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildRuleCard(
                    title: '👉 Tay Phải: HÀNG ĐƠN VỊ (0 - 9)',
                    content: '• Ngón cái = 5 (giá trị 5)\n'
                        '• 4 ngón dài (trỏ, giữa, áp út, út) = mỗi ngón giá trị 1\n'
                        '• Số 6: Ngón cái (5) + 1 ngón trỏ (1)\n'
                        '• Số 7: Ngón cái (5) + 2 ngón (2)\n'
                        '• Số 8: Ngón cái (5) + 3 ngón (3)\n'
                        '• Số 9: Cả 5 ngón xòe (5 + 4 = 9)',
                    color: AppColors.secondary.withOpacity(0.1),
                  ),
                  const SizedBox(height: 8),
                  _buildRuleCard(
                    title: '👈 Tay Trái: HÀNG CHỤC (10 - 90)',
                    content: '• Ngón cái = 50 (giá trị 50)\n'
                        '• 4 ngón dài = mỗi ngón giá trị 10\n'
                        '• Số 10: Tay trái giơ 1 ngón trỏ (10), tay phải nắm (0)\n'
                        '• Số 60: Ngón cái (50) + 1 ngón dài (10)\n'
                        '• Kết hợp 2 tay: Biểu diễn từ 00 đến 99 linh hoạt',
                    color: AppColors.accentYellow.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '2. Công thức Anh Bạn Nhỏ (Tổng = 5):',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildRuleCard(
                    title: '🤝 Cặp bạn nhỏ: (4-1), (3-2), (2-3), (1-4)',
                    content: 'Dùng khi cộng/trừ trong phạm vi 5 trên cùng 1 bàn tay:\n'
                        '• +4 = +5 - 1 | +3 = +5 - 2 | +2 = +5 - 3 | +1 = +5 - 4\n'
                        '• -4 = -5 + 1 | -3 = -5 + 2 | -2 = -5 + 3 | -1 = -5 + 4\n'
                        'Thao tác: Thêm ngón cái 5, gập bớt ngón bạn nhỏ tương ứng.',
                    color: Colors.green.shade50,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '3. Công thức Anh Bạn Lớn (Tổng = 10 - Phối hợp 2 tay):',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildRuleCard(
                    title: '🌟 Cặp bạn lớn: (9-1), (8-2), (7-3), (6-4), (5-5)',
                    content: 'Dùng khi cộng qua 10 hoặc trừ qua 10 (phối hợp 2 tay):\n'
                        '• Phép cộng (+): Bung 1 ngón Tay Trái (+10), gập bạn lớn ở Tay Phải (- bạn lớn)\n'
                        '  Ví dụ: +9 = +10 (Tay Trái) - 1 (Tay Phải)\n'
                        '  Ví dụ: +8 = +10 (Tay Trái) - 2 (Tay Phải)\n'
                        '• Phép trừ (-): Gập 1 ngón Tay Trái (-10), bung bạn lớn ở Tay Phải (+ bạn lớn)\n'
                        '  Ví dụ: -9 = -10 (Tay Trái) + 1 (Tay Phải)',
                    color: Colors.orange.shade50,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRuleCard({
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final totalVal = widget.controller.totalValue;
        final rightHand = widget.controller.rightHand;
        final leftHand = widget.controller.leftHand;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thanh hiển thị giá trị số & quy ước ngón tay
            if (widget.showLiveValue)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Số: ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '$totalVal',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${rightHand.shortNotation})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Xem quy ước & công thức',
                          onPressed: () => _showFormulaGuideModal(context),
                          icon: const Icon(
                            Icons.help_outline_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            _audioService.playBeadClick();
                            widget.controller.reset();
                          },
                          icon: const Icon(Icons.front_hand, size: 16),
                          label: const Text('Nắm tay (0)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Khu vực hiển thị 2 bàn tay tương tác
            Container(
              height: widget.height,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Tay trái: Hàng chục (10..90)
                  if (widget.controller.showLeftHand)
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentYellow.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'TAY TRÁI (HÀNG CHỤC: ${leftHand.actualValue})',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final size = Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                );
                                return GestureDetector(
                                  onTapUp: (details) => _handleHandTap(
                                    details,
                                    size,
                                    HandType.leftHand,
                                  ),
                                  child: CustomPaint(
                                    size: size,
                                    painter: FingerHandPainter(
                                      handState: leftHand,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (widget.controller.showLeftHand)
                    Container(
                      width: 2,
                      height: widget.height * 0.7,
                      color: Colors.grey.shade200,
                    ),

                  // Tay phải: Hàng đơn vị (0..9)
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'TAY PHẢI (HÀNG ĐƠN VỊ: ${rightHand.actualValue})',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final size = Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              );
                              return GestureDetector(
                                onTapUp: (details) => _handleHandTap(
                                  details,
                                  size,
                                  HandType.rightHand,
                                ),
                                child: CustomPaint(
                                  size: size,
                                  painter: FingerHandPainter(
                                    handState: rightHand,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
