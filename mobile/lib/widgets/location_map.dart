import 'package:flutter/material.dart';

class LocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? mapboxToken;

  const LocationMap({
    Key? key,
    required this.latitude,
    required this.longitude,
    this.mapboxToken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is a placeholder. In a real app, you'd use a proper map implementation
    // like Google Maps or Mapbox
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.network(
            'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/pin-s+1f77B4($longitude,$latitude),pin-s+000(${longitude + 0.01},${latitude + 0.01})/center/$longitude,$latitude/zoom/14/600x300?access_token=${mapboxToken ?? 'YOUR_MAPBOX_TOKEN'}',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Text('Map not available'),
                ),
              );
            },
          ),
          
          // View all on map button
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'View all on map',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}