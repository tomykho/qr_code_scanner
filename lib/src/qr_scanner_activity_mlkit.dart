import 'dart:async';

import 'package:flutter/services.dart';

/// Provides access to the barcode scanner.
///
/// This class is an interface between the native Android and iOS classes and a
/// Flutter project.
class QRScanner {

  /// Scan with the camera until a barcode is identified, then return.
  ///
  /// Shows a scan line with [lineColor] over a scan window. A flash icon is
  /// displayed if [isShowFlashIcon] is true. The text of the cancel button can
  /// be customized with the [cancelButtonText] string.
  static Future<String> scanBarcode() async {
    /// Get barcode scan result
    final barcodeResult = await MethodChannel('net.touchcapture.qr.flutterqr').invokeMethod('scanCodeCameraX') ?? '';
    return barcodeResult;
  }

}
