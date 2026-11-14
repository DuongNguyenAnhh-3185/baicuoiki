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
            // Thanh hiển thị giá trị số & tên hoạt hình của ngón tay
            if (widget.showLiveValue)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Số ngón tay: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '$totalVal ',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '(${rightHand.cartoonAlias})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _audioService.playBeadClick();
                        widget.controller.reset();
                      },
                      icon: const Icon(Icons.front_hand, size: 18),
                      label: const Text('Nắm tay ✊ (0)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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
                  // Tay trái: Hàng chục (nếu bật)
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
                              color: AppColors.accentYellow.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'TAY TRÁI (HÀNG CHỤC)',
                              style: TextStyle(
                                fontSize: 11,
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

                  // Tay phải: Hàng đơn vị
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'TAY PHẢI (HÀNG ĐƠN VỊ)',
                            style: TextStyle(
                              fontSize: 11,
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
