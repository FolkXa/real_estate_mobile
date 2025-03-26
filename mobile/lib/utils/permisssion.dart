import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestCameraPermissions(BuildContext context) async {
    // Request camera permission
    PermissionStatus cameraStatus = await Permission.camera.request();
    
    if (cameraStatus.isDenied) {
      _showPermissionDialog(
        context, 
        'Camera permission is required to take photos',
        'Please enable camera access in your device settings to use this feature.'
      );
      return false;
    }
    
    if (cameraStatus.isPermanentlyDenied) {
      _showPermissionDialog(
        context, 
        'Camera permission is permanently denied',
        'Please enable camera access in your device settings to use this feature.',
        true
      );
      return false;
    }
    
    return cameraStatus.isGranted;
  }
  
  static Future<bool> requestStoragePermissions(BuildContext context) async {
    // For Android 13+ (API level 33+)
    if (await Permission.photos.request().isGranted) {
      return true;
    }
    
    // For older Android versions
    PermissionStatus storageStatus = await Permission.storage.request();
    
    if (storageStatus.isDenied) {
      _showPermissionDialog(
        context, 
        'Storage permission is required to select photos',
        'Please enable storage access in your device settings to use this feature.'
      );
      return false;
    }
    
    if (storageStatus.isPermanentlyDenied) {
      _showPermissionDialog(
        context, 
        'Storage permission is permanently denied',
        'Please enable storage access in your device settings to use this feature.',
        true
      );
      return false;
    }
    
    return storageStatus.isGranted;
  }
  
  static void _showPermissionDialog(
    BuildContext context, 
    String title, 
    String message, 
    [bool openSettings = false]
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            if (openSettings)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
          ],
        );
      },
    );
  }
}