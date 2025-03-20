import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

class PropertyImage extends StatelessWidget {
  final int realEstateId;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final bool showLoading;

  const PropertyImage({
    Key? key,
    required this.realEstateId,
    this.width = double.infinity,
    this.height = 300,
    this.borderRadius,
    this.showLoading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();
    
    return StreamBuilder<QuerySnapshot>(
      stream: firebaseService.getPropertyImages(realEstateId),
      builder: (context, imageSnapshot) {
        if (imageSnapshot.connectionState == ConnectionState.waiting && showLoading) {
          return SizedBox(
            width: width,
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        String imagePath = AppAssets.defaultPropertyImage;

        if (imageSnapshot.hasData && imageSnapshot.data!.docs.isNotEmpty) {
          var imageData = imageSnapshot.data!.docs.first.data() as Map<String, dynamic>;
          imagePath = imageData["image_path"] ?? AppAssets.defaultPropertyImage;
        }

        // Check if it's a network image or asset image
        Widget imageWidget;
        if (imagePath.startsWith('http')) {
          imageWidget = Image.network(
            imagePath,
            fit: BoxFit.cover,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                AppAssets.defaultPropertyImage,
                fit: BoxFit.cover,
                width: width,
                height: height,
              );
            },
          );
        } else {
          imageWidget = Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: width,
            height: height,
          );
        }

        if (borderRadius != null) {
          return ClipRRect(
            borderRadius: borderRadius!,
            child: imageWidget,
          );
        }
        
        return imageWidget;
      },
    );
  }
}