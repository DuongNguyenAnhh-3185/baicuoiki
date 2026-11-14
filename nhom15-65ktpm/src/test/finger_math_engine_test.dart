import 'package:flutter_test/flutter_test.dart';
import 'package:soroban_kids_app/features/1_abacus_engine/domain/entities/finger_hand_state.dart';
import 'package:soroban_kids_app/features/1_abacus_engine/presentation/controllers/finger_math_controller.dart';

void main() {
  group('Finger Math Engine Tests (Đối chiếu chuẩn Flash Card 1D RH)', () {
    test('TC_FM_01: Kiểm tra toàn bộ 10 số đếm ngón tay chuẩn Flashcard (0 đến 9)', () {
      final expectedAliases = [
        'Cái Búa ✊',
        'Cây Nến ☝️',
        'Tai Thỏ ✌️',
        'Cái Nĩa 🤟',
        'Cái Quạt ✋',
        'Anh Béo 👍',
        'Súng Nhỏ 🔫',
        'Súng Lớn 👈',
        'Cua Kẹp 🦀',
        'Bàn Tay Xòe 🖐️',
      ];

      for (int i = 0; i <= 9; i++) {
        final hand = FingerHandState.fromValue(i, handType: HandType.rightHand);
        expect(hand.digitValue, i);
        expect(hand.cartoonAlias, expectedAliases[i]);

        if (i < 5) {
          expect(hand.isThumbExtended, isFalse, reason: 'Số $i ngón cái phải gập');
          expect(hand.extendedFingersCount, i);
        } else {
          expect(hand.isThumbExtended, isTrue, reason: 'Số $i ngón cái (Anh béo 5) phải xòe');
          expect(hand.extendedFingersCount, i - 5);
        }
      }
    });

    test('TC_FM_02: Điều khiển 2 bàn tay tính toán phạm vi 0 đến 99', () {
      final controller = FingerMathController(showLeftHand: true);

      // Đặt số 37 (Tay trái = 3, Tay phải = 7)
      controller.setValue(37);
      expect(controller.leftHand.digitValue, 3);
      expect(controller.rightHand.digitValue, 7);
      expect(controller.totalValue, 37);

      // Đặt số 99 (Tay trái = 9, Tay phải = 9)
      controller.setValue(99);
      expect(controller.leftHand.digitValue, 9);
      expect(controller.rightHand.digitValue, 9);
      expect(controller.totalValue, 99);

      // Reset về 0 (Hai nắm đấm ✊ ✊)
      controller.reset();
      expect(controller.totalValue, 0);
      expect(controller.leftHand.digitValue, 0);
      expect(controller.rightHand.digitValue, 0);
    });

    test('TC_FM_03: Kiểm tra công thức Anh Bạn Nhỏ (+4 = +5 - 1 và -1 = -5 + 4)', () {
      final controller = FingerMathController(showLeftHand: false);

      // Bắt đầu từ số 1 (Cây nến ☝️)
      controller.setValue(1);
      expect(controller.rightHand.digitValue, 1);

      // Áp dụng +4 = +5 - 1: Xòe ngón cái (+5), cụp 1 ngón dài (-1)
      controller.toggleThumb(HandType.rightHand); // Xòe anh béo 5
      controller.setExtendedFingers(HandType.rightHand, 0); // Cụp 1 ngón
      expect(controller.totalValue, 5); // Kết quả = 5

      // Áp dụng -1 = -5 + 4: Cụp ngón cái (-5), xòe 4 ngón dài (+4)
      controller.toggleThumb(HandType.rightHand); // Cụp anh béo 5
      controller.setExtendedFingers(HandType.rightHand, 4); // Xòe 4 ngón dài
      expect(controller.totalValue, 4); // Kết quả = 4
    });

    test('TC_FM_04: Kiểm tra công thức Anh Bạn Lớn (+9 = +10 - 1 qua 2 bàn tay)', () {
      final controller = FingerMathController(showLeftHand: true);

      // Bắt đầu từ số 3 (Tay phải = 3)
      controller.setValue(3);
      expect(controller.totalValue, 3);

      // Áp dụng +9 = +10 - 1: Bung 1 ngón tay trái (+10), cụp 1 ngón tay phải (-1)
      controller.setExtendedFingers(HandType.leftHand, 1); // Tay trái = 10
      controller.setExtendedFingers(HandType.rightHand, 2); // 3 - 1 = 2
      expect(controller.totalValue, 12); // Kết quả = 12
    });
  });
}
