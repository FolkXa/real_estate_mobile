class Area {
  final double rai;
  final double ngan;
  final double wa;

  Area({
    this.rai = 0,
    this.ngan = 0,
    this.wa = 0,
  });

  // Create from square wa
  factory Area.fromSquareWa(double squareWa) {
    // 1 rai = 4 ngan = 400 square wa
    final rai = (squareWa / 400).floorToDouble();
    final remainingSquareWa = squareWa % 400;
    
    // 1 ngan = 100 square wa
    final ngan = (remainingSquareWa / 100).floorToDouble();
    final wa = remainingSquareWa % 100;

    return Area(
      rai: rai,
      ngan: ngan,
      wa: wa,
    );
  }

  // Get total area in square wa
  double get totalSquareWa => (rai * 400) + (ngan * 100) + wa;

  @override
  String toString() {
    if (rai > 0) {
      return '${rai.toStringAsFixed(0)} ไร่ ${ngan.toStringAsFixed(0)} งาน ${wa.toStringAsFixed(0)} ตรว.';
    } else if (ngan > 0) {
      return '${ngan.toStringAsFixed(0)} งาน ${wa.toStringAsFixed(0)} ตรว.';
    } else {
      return '${wa.toStringAsFixed(0)} ตรว.';
    }
  }
}
