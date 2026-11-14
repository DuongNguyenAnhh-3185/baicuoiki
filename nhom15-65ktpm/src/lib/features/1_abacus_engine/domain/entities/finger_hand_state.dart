import 'package:equatable/equatable.dart';

enum HandType { rightHand, leftHand }

class FingerHandState extends Equatable {
  final HandType handType; // rightHand: Hàng đơn vị, leftHand: Hàng chục
  final bool isThumbExtended; // Ngón cái xòe (Anh béo = 5)
  final int extendedFingersCount; // Số ngón dài xòe (0..4: trỏ, giữa, áp út, út)

  const FingerHandState({
    required this.handType,
    this.isThumbExtended = false,
    this.extendedFingersCount = 0,
  });

  /// Giá trị số hiển thị trên 1 bàn tay (từ 0 đến 9)
  int get digitValue => (isThumbExtended ? 5 : 0) + extendedFingersCount;

  /// Tên gọi hoạt hình biểu tượng thân thiện cho trẻ 4-6 tuổi theo chuẩn Finger Math
  String get cartoonAlias {
    switch (digitValue) {
      case 0:
        return 'Cái Búa ✊';
      case 1:
        return 'Cây Nến ☝️';
      case 2:
        return 'Tai Thỏ ✌️';
      case 3:
        return 'Cái Nĩa 🤟';
      case 4:
        return 'Cái Quạt ✋';
      case 5:
        return 'Anh Béo 👍';
      case 6:
        return 'Súng Nhỏ 🔫';
      case 7:
        return 'Súng Lớn 👈';
      case 8:
        return 'Cua Kẹp 🦀';
      case 9:
        return 'Bàn Tay Xòe 🖐️';
      default:
        return '';
    }
  }

  FingerHandState copyWith({
    HandType? handType,
    bool? isThumbExtended,
    int? extendedFingersCount,
  }) {
    return FingerHandState(
      handType: handType ?? this.handType,
      isThumbExtended: isThumbExtended ?? this.isThumbExtended,
      extendedFingersCount: extendedFingersCount ?? this.extendedFingersCount,
    );
  }

  /// Khởi tạo trạng thái bàn tay từ giá trị số (0 đến 9)
  factory FingerHandState.fromValue(int value, {HandType handType = HandType.rightHand}) {
    final clamped = value.clamp(0, 9);
    final thumb = clamped >= 5;
    final fingers = clamped % 5;
    return FingerHandState(
      handType: handType,
      isThumbExtended: thumb,
      extendedFingersCount: fingers,
    );
  }

  @override
  List<Object?> get props => [handType, isThumbExtended, extendedFingersCount];
}
