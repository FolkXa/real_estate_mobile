import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:panorama/panorama.dart';

class PanoramaView extends StatefulWidget {
  final String imageUrl;

  const PanoramaView({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _PanoramaViewState createState() => _PanoramaViewState();
}

class _PanoramaViewState extends State<PanoramaView> {
  bool _isLoading = true;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    _preloadImage();
  }
  
  void _preloadImage() {
    final imageProvider = CachedNetworkImageProvider(widget.imageUrl);
    imageProvider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (_, __) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        onError: (_, __) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Panorama View',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load panorama image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    Panorama(
                      child: Image.network(widget.imageUrl),
                      sensitivity: 3.0,
                      animSpeed: 0.2,
                      sensorControl: SensorControl.Orientation,
                      onViewChanged: (longitude, latitude, tilt) {
                        // You can use these values if needed
                      },
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pan_tool,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Drag to explore | Tilt device to look around',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}