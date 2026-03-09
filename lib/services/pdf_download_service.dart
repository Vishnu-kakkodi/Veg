// lib/services/pdf_download_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class PdfDownloadService {
  static Future<void> downloadInvoice({
    required BuildContext context,
    required String? invoiceUrl,
    required String orderId,
  }) async {
    // Check if invoice URL exists
    print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkk$invoiceUrl");
    if (invoiceUrl == null || invoiceUrl.isEmpty) {
      _showErrorSnackBar(context, 'Invoice not available for this order');
      return;
    }

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Downloading invoice...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Download the PDF
      final response = await http.get(
        Uri.parse(invoiceUrl),
        headers: {
          'Accept': 'application/pdf',
        },
      ).timeout(const Duration(seconds: 30));

      // Check if download was successful
      if (response.statusCode != 200) {
        throw Exception('Failed to download invoice: ${response.statusCode}');
      }

      // Check if content is PDF by checking magic number
      if (!_isPdfContent(response.bodyBytes)) {
        throw Exception('Invalid PDF file received');
      }

      // Handle different platforms
      if (kIsWeb) {
        // For web - trigger download via blob
        await _downloadOnWeb(response.bodyBytes, 'invoice_$orderId.pdf');
      } else {
        // For mobile - save and open
        await _saveAndOpenFile(response.bodyBytes, orderId);
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice downloaded successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on http.ClientException catch (e) {
      _handleError(context, 'Network error: Could not connect to server. ${e.message}');
    } catch (e) {
      _handleError(context, 'Failed to download invoice: ${e.toString()}');
    }
  }

  // Helper method to check if bytes represent a PDF file
  static bool _isPdfContent(Uint8List bytes) {
    if (bytes.length < 4) return false;
    
    // PDF magic number: %PDF (hex: 25 50 44 46)
    return bytes[0] == 0x25 && // %
           bytes[1] == 0x50 && // P
           bytes[2] == 0x44 && // D
           bytes[3] == 0x46;   // F
  }

  static Future<void> _saveAndOpenFile(Uint8List bytes, String orderId) async {
    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/invoice_$orderId.pdf';
      final file = File(filePath);

      // Write bytes to file
      await file.writeAsBytes(bytes);

      // Open the file
      await OpenFilex.open(filePath);
    } catch (e) {
      throw Exception('Failed to save file: ${e.toString()}');
    }
  }

  static Future<void> _downloadOnWeb(Uint8List bytes, String fileName) async {
    try {
      // Check if we're in a browser environment
      if (kIsWeb) {
        // For web, we need to use dart:html
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = '_blank'
          ..download = fileName;

        anchor.click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      throw Exception('Failed to download on web: ${e.toString()}');
    }
  }

  static void _handleError(BuildContext context, String message) {
    if (context.mounted) {
      _showErrorSnackBar(context, message);
    }
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

// Required for web - make sure to import conditionally
