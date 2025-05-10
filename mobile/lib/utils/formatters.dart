import 'package:intl/intl.dart';

class Formatters {
  static final currencyFormat = NumberFormat('#,###');
  
  static String formatCurrency(int amount) {
    return currencyFormat.format(amount);
  }
  
  static String formatRating(int views) {
    // Simple rating calculation based on views
    return (views / 10).toStringAsFixed(1);
  }
}