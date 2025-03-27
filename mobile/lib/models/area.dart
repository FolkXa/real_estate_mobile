class Area {
  final double value;
  final AreaUnit unit;

  // Constants for conversion
  static const double SQUARE_WA_TO_SQUARE_METER = 4.0;
  static const double SQUARE_METER_TO_SQUARE_WA = 0.25;

  Area({
    required this.value,
    required this.unit,
  });

  // Create from square meters
  factory Area.fromSquareMeters(double squareMeters) {
    return Area(
      value: squareMeters,
      unit: AreaUnit.squareMeter,
    );
  }

  // Create from square wa
  factory Area.fromSquareWa(double squareWa) {
    return Area(
      value: squareWa,
      unit: AreaUnit.squareWa,
    );
  }

  // Create from database value with specified unit
  factory Area.fromDatabase(dynamic areaValue, AreaUnit unit) {
    if (areaValue == null) {
      return Area(value: 0, unit: unit);
    }
    
    double parsedValue;
    if (areaValue is int) {
      parsedValue = areaValue.toDouble();
    } else if (areaValue is double) {
      parsedValue = areaValue;
    } else if (areaValue is String) {
      parsedValue = double.tryParse(areaValue) ?? 0.0;
    } else {
      parsedValue = 0.0;
    }
    
    return Area(value: parsedValue, unit: unit);
  }

  // Convert to square meters
  double get inSquareMeters {
    if (unit == AreaUnit.squareMeter) {
      return value;
    } else {
      return value * SQUARE_WA_TO_SQUARE_METER;
    }
  }

  // Convert to square wa
  double get inSquareWa {
    if (unit == AreaUnit.squareWa) {
      return value;
    } else {
      return value * SQUARE_METER_TO_SQUARE_WA;
    }
  }

  // Convert to the other unit
  Area convertTo(AreaUnit targetUnit) {
    if (unit == targetUnit) {
      return this;
    }
    
    if (targetUnit == AreaUnit.squareMeter) {
      return Area(value: inSquareMeters, unit: AreaUnit.squareMeter);
    } else {
      return Area(value: inSquareWa, unit: AreaUnit.squareWa);
    }
  }

  // Format for display with unit symbol
  String format({int decimalPlaces = 0}) {
    String formattedValue = value.toStringAsFixed(decimalPlaces);
    
    if (unit == AreaUnit.squareMeter) {
      return '$formattedValue ตร.ม.';
    } else {
      return '$formattedValue ตร.ว.';
    }
  }

  // Format for display with full unit name
  String formatWithFullUnit({int decimalPlaces = 0}) {
    String formattedValue = value.toStringAsFixed(decimalPlaces);
    
    if (unit == AreaUnit.squareMeter) {
      return '$formattedValue ตารางเมตร';
    } else {
      return '$formattedValue ตารางวา';
    }
  }

  // For comparison and equality checks
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Area && 
           other.inSquareMeters == inSquareMeters;
  }

  @override
  int get hashCode => value.hashCode ^ unit.hashCode;

  @override
  String toString() => format();
}

enum AreaUnit {
  squareMeter, // ตารางเมตร (ตร.ม.)
  squareWa,    // ตารางวา (ตร.ว.)
}