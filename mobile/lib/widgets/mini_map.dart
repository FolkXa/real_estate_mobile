import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MiniMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MiniMap({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LatLng position = LatLng(latitude, longitude);

    return Container(
      height: 180,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: position,
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: MarkerId('property_location'),
              position: position,
            ),
          },
          zoomControlsEnabled: false,
          liteModeEnabled: true, // ✅ Mini map style
          myLocationEnabled: false,
          onMapCreated: (controller) {},
        ),
      ),
    );
  }
}
