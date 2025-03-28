import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RealEstateCard extends StatefulWidget {
  final int realEstateId;
  final String imagePath;
  final String price;
  final String name;
  final String location;
  final String sellType;
  final bool isInitiallyFavorite;
  final Future<bool> Function(int) onToggleFavorite;

  const RealEstateCard({
    required this.realEstateId,
    required this.imagePath,
    required this.price,
    required this.name,
    required this.location,
    required this.sellType,
    required this.isInitiallyFavorite,
    required this.onToggleFavorite,
    super.key,
  });

  @override
  State<RealEstateCard> createState() => _RealEstateCardState();
}

class _RealEstateCardState extends State<RealEstateCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isInitiallyFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedPrice =
        NumberFormat("#,###", "en_US").format(int.tryParse(widget.price) ?? 0);
    final displayPrice =
        "฿$formattedPrice" + (widget.sellType == "เช่า" ? " /เดือน" : "");

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      color: theme.cardColor, // 💡 รองรับทั้งธีมมืด/สว่าง
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: widget.imagePath.startsWith('http')
                      ? Image.network(widget.imagePath, fit: BoxFit.cover)
                      : Image.asset("assets/images/house1.jpg",
                          fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      final newStatus =
                          await widget.onToggleFavorite(widget.realEstateId);

                      setState(() {
                        isFavorite = newStatus;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            newStatus
                                ? 'เพิ่มเข้ารายการโปรดแล้ว'
                                : 'ลบออกจากรายการโปรดแล้ว',
                            style: const TextStyle(fontSize: 14),
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: theme.colorScheme.secondaryContainer,
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.surface.withOpacity(0.9),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayPrice,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.location,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
