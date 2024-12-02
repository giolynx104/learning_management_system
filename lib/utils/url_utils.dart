import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openFileUrl(BuildContext context, String? fileUrl) async {
  debugPrint('Attempting to open file link: $fileUrl');
  if (fileUrl == null || fileUrl.isEmpty) {
    debugPrint('File link is null or empty');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No file link available'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  // Parse the URL and ensure it's encoded properly
  var uri = Uri.parse(fileUrl);
  
  // Special handling for Google Drive/Docs URLs
  if (uri.host.contains('google.com')) {
    debugPrint('Detected Google Docs/Drive URL');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
      debugPrint('URL launch result: $launched');
      
      if (!launched) {
        // If external app launch fails, try browser
        final browserLaunched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        debugPrint('Browser launch result: $browserLaunched');
        
        if (!browserLaunched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open file. Please check if you have a compatible app installed.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching Google URL: $e');
      // Try fallback to browser if app launch fails
      try {
        final browserLaunched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        debugPrint('Fallback browser launch result: $browserLaunched');
        
        if (!browserLaunched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open file. Please check if you have a compatible app installed.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error launching in browser: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening file: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  } else {
    // For non-Google URLs, use the standard approach
    try {
      final canLaunch = await canLaunchUrl(uri);
      debugPrint('Can launch URL: $canLaunch');
      if (canLaunch) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('URL launch result: $launched');
      } else {
        debugPrint('Cannot launch URL');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

String getFileNameFromUrl(String url) {
  // For Google Drive URLs, extract the document name
  if (url.contains('docs.google.com')) {
    final docId = url.split('/')[5];
    return 'Google Doc: ${docId.substring(0, 8)}...';
  }
  return 'View Attachment';
} 