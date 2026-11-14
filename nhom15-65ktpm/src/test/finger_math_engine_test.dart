import 'package:flutter_test/flutter_test.dart';
import 'package:soroban_kids_app/features/1_abacus_engine/domain/entities/finger_hand_state.dart';
import 'package:soroban_kids_app/features/1_abacus_engine/presentation/controllers/finger_math_controller.dart';

void main() {
  group('Finger Math Engine Tests (Quy ước chuẩn 2 bàn tay: Tay Phải 0-9, Tay Trái 10-90)', () {
    test('TC_FM_01: Kiểm tra quy ước 10 số đếm Tay Phải (Hàng đơn vị 0 đến 9)', () {
      final expectedDescriptions = [
        'Tay Phải: Nắm tay (0)',
        'Tay Phải: 1 ngón trỏ (1)',
        'Tay Phải: 2 ngón trỏ + giữa (2)',
        'Tay Phải: 3 ngón trỏ + giữa + áp út (3)',
        'Tay Phải: 4 ngón dài (4)',
        'Tay Phải: Ngón cái (5)',
        'Tay Phải: Ngón cái (5) + 1 ngón trỏ (1) = 6',
        'Tay Phải: Ngón cái (5) + 2 ngón (2) = 7',
        'Tay Phải: Ngón cái (5) + 3 ngón (3) = 8',
        'Tay Phải: Cả 5 ngón xòe = 9',
      ];

      for (int i = 0; i <= 9; i++) {
        final hand = FingerHandState.fromValue(i, handType: HandType.rightHand);
        expect(hand.digitValue, i);
        expect(hand.fingerDescription, expectedDescriptions[i]);

        if (i < 5) {
          expect(hand.isThumbExtended, isFalse, reason: 'Số $i ngón cái phải gập');
          expect(hand.extendedFingersCount, i);
        } else {
          expect(hand.isThumbExtended, isTrue, reason: 'Số $i ngón cái (5) phải xòe');
          expect(hand.extendedFingersCount, i - 5);
        }
      }
    });

    test('TC_FM_02: Kiểm tra quy ước Tay Trái (Hàng chục 10 đến 90)', () {
      final expectedTens = [
        'Tay Trái: Nắm tay (0)',
        'Tay Trái: 1 ngón trỏ (10)',
        'Tay Trái: 2 ngón trỏ + giữa (20)',
        'Tay Trái: 3 ngón trỏ + giữa + áp út (30)',
        'Tay Trái: 4 ngón dài (40)',
        'Tay Trái: Ngón cái (50)',
        'Tay Trái: Ngón cái (50) + 1 ngón trỏ (10) = 60',
        'Tay Trái: Ngón cái (50) + 2 ngón (20) = 70',
        'Tay Trái: Ngón cái (50) + 3 ngón (30) = 80',
        'Tay Trái: Cả 5 ngón xòe = 90',
      ];

      for (int i = 0; i <= 9; i++) {
        final hand = FingerHandState.fromValue(i, handType: HandType.leftHand);
        expect(hand.digitValue, i);
        expect(hand.actualValue, i * 10);
        expect(hand.fingerDescription, expectedTens[i]);
      }
    });

    test('TC_FM_03: Điều khiển phối hợp 2 bàn tay tính toán phạm vi 0 đến 99', () {
      final controller = FingerMathController(showLeftHand: true);

      // Đặt số 37 (Tay trái = 3 chục, Tay phải = 7 đơn vị)
      controller.setValue(37);
      expect(controller.leftHand.digitValue, 3);
      expect(controller.rightHand.digitValue, 7);
      expect(controller.totalValue, 37);

      // Đặt số 68 (Tay trái = 6 chục, Tay phải = 8 đơn vị)
      controller.setValue(68);
      expect(controller.leftHand.digitValue, 6);
      expect(controller.leftHand.isThumbExtended, isTrue);
      expect(controller.leftHand.extendedFingersCount, 1);
      expect(controller.rightHand.digitValue, 8);
      expect(controller.rightHand.isThumbExtended, isTrue);
      expect(controller.rightHand.extendedFingersCount, 3);
      expect(controller.totalValue, 68);

      // Reset về 0 (Hai nắm tay)
      controller.reset();
      expect(controller.totalValue, 0);
      expect(controller.leftHand.digitValue, 0);
      expect(controller.rightHand.digitValue, 0);
    });

    test('TC_FM_04: Kiểm tra công thức Anh Bạn Nhỏ (Cặp bạn nhỏ tổng = 5)', () {
      expect(FingerMathFormulaHelper.getSmallFriend(1), 4);
      expect(FingerMathFormulaHelper.getSmallFriend(4), 1);
      expect(FingerMathFormulaHelper.getSmallFriend(2), 3);
      expect(FingerMathFormulaHelper.getSmallFriend(3), 2);

      final controller = FingerMathController(showLeftHand: false);

      // Phép tính 1 + 4 = 5: Bắt đầu từ 1 ngón trỏ
      controller.setValue(1);
      expect(controller.rightHand.digitValue, 1);

      // Áp dụng +4 = +5 - 1: Xòe ngón cái (+5), cụp 1 ngón dài (-1)
      controller.toggleThumb(HandType.rightHand);
      controller.setExtendedFingers(HandType.rightHand, 0);
      expect(controller.totalValue, 5);

      // Phép tính 5 - 1 = 4: Cụp ngón cái (-5), xòe 4 ngón dài (+4)
      controller.toggleThumb(HandType.rightHand);
      controller.setExtendedFingers(HandType.rightHand, 4);
      expect(controller.totalValue, 4);
    });

    test('TC_FM_05: Kiểm tra công thức Anh Bạn Lớn (Cặp bạn lớn tổng = 10, phối hợp 2 tay)', () {
      expect(FingerMathFormulaHelper.getBigFriend(9), 1);
      expect(FingerMathFormulaHelper.getBigFriend(8), 2);
      expect(FingerMathFormulaHelper.getBigFriend(7), 3);
      expect(FingerMathFormulaHelper.getBigFriend(6), 4);
      expect(FingerMathFormulaHelper.getBigFriend(5), 5);

      final controller = FingerMathController(showLeftHand: true);

      // Bắt đầu từ số 6 (Tay phải: ngón cái 5 + 1 ngón trỏ = 6)
      controller.setValue(6);
      expect(controller.totalValue, 6);

      // Phép tính 6 + 7 = 13:
      // Bạn lớn của 7 là 3 -> Bung 1 ngón Tay Trái (+10), gập 3 ngón ở Tay Phải (-3)
      // Tay phải đang là 6 (5 + 1), gập 3 -> còn 3 ngón dài (trỏ, giữa, áp út) không ngón cái
      controller.setExtendedFingers(HandType.leftHand, 1); // +10 ở Tay Trái
      controller.toggleThumb(HandType.rightHand); // gập ngón cái 5
      controller.setExtendedFingers(HandType.rightHand, 3); // 3 ngón dài
      expect(controller.totalValue, 13);
    });
  });
}
