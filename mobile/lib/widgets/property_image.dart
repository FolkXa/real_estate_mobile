import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:panorama/panorama.dart';
import '../services/firebase_service.dart';
import 'property_image_gallery.dart';

class PropertyImage extends StatefulWidget {
  final int realEstateId;
  final double height;
  final BorderRadius? borderRadius;
  final bool isClickable;

  const PropertyImage({
    Key? key,
    required this.realEstateId,
    this.height = 200,
    this.borderRadius,
    this.isClickable = true,
  }) : super(key: key);

  @override
  _PropertyImageState createState() => _PropertyImageState();
}

class _PropertyImageState extends State<PropertyImage> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<String>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _imagesFuture =
        _firebaseService.getImagesForRealEstate(widget.realEstateId);
  }

  void _openGallery(List<String> images, int initialIndex) {
    if (!widget.isClickable) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyImageGallery(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: widget.borderRadius,
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: widget.borderRadius,
            ),
            child: const Center(
              child:
                  Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            ),
          );
        }

        final images = snapshot.data!;

        return SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              // Main image with single tap and double tap
              GestureDetector(
                onTap: () => _openGallery(images, 0),
                child: Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(images[0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: widget.isClickable
                      ? Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  // SizedBox(width: 4),
                                  // Text(
                                  //   'Double tap for panorama',
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //     fontSize: 10,
                                  //     fontWeight: FontWeight.bold,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
              ),

              // Image counter
              if (images.length > 1)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Small thumbnails preview
              if (images.length > 1)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      for (int i = 1; i < images.length && i < 4; i++)
                        GestureDetector(
                          onTap: () => _openGallery(images, i),
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 2),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(images[i]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      if (images.length > 4)
                        GestureDetector(
                          onTap: () => _openGallery(images, 4),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '+${images.length - 4}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
