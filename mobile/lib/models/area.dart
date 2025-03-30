class Area {
  final double rai;
  final double squareWa;
  final double squareMeter;

  Area({
    this.rai = 0,
    this.squareWa = 0,
    this.squareMeter = 0,
  });

  // Create from square wa
  factory Area.fromSquareWa(double squareWa) {
    // 1 rai = 400 square wa
    final rai = (squareWa / 400).floorToDouble();
    final remainingSquareWa = (squareWa % 400).floorToDouble();
    
    // 1 square wa = 4 square meters
    final squareMeter = squareWa % 1 * 4;

    return Area(
      rai: rai,
      squareWa: remainingSquareWa,
      squareMeter: squareMeter,
    );
  }

  // Get total area in square wa
  double get totalSquareWa => (rai * 400) + squareWa + (squareMeter / 4);

  @override
  String toString() {
    if (rai > 0) {
      return '${rai.toStringAsFixed(0)} ไร่ ${squareWa.toStringAsFixed(2)} ตร.วา';
    } else if (squareWa > 0) {
      return '${squareWa.toStringAsFixed(2)} ตร.วา';
    } else {
      return '${squareMeter.toStringAsFixed(2)} ตร.ม.';
    }
  }
}