import 'dart:async';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

typedef QRViewCreatedCallback = void Function(QRViewController);

class QRView extends StatefulWidget {
  const QRView({
    @required Key key,
    @required this.onQRViewCreated,
    this.overlay,
    this.overlayMargin = EdgeInsets.zero,
  })  : assert(key != null),
        assert(onQRViewCreated != null),
        super(key: key);

  final QRViewCreatedCallback onQRViewCreated;

  final ShapeBorder overlay;
  final EdgeInsetsGeometry overlayMargin;

  @override
  State<StatefulWidget> createState() => _QRViewState();
}

class _QRViewState extends State<QRView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _getPlatformQrView(),
        if (widget.overlay != null)
          Container(
            padding: widget.overlayMargin,
            decoration: ShapeDecoration(
              shape: widget.overlay,
            ),
          )
        else
          Container(),
      ],
    );
  }

  Widget _getPlatformQrView() {
    Widget _platformQrView;
    // This is used in the platform side to register the view.
    const viewType = 'net.touchcapture.qr.flutterqr/qrview';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        _platformQrView = PlatformViewLink(
            viewType: viewType,
            surfaceFactory: (context, controller) {
              return AndroidViewSurface(
                  controller: controller,
                  hitTestBehavior: PlatformViewHitTestBehavior.opaque,
                  gestureRecognizers: const <
                      Factory<OneSequenceGestureRecognizer>>{});
            },
            onCreatePlatformView: (params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: viewType,
                layoutDirection: TextDirection.ltr,
                // creationParams: creationParams,
              )
                ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
                ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
                ..create();
            });
        break;
      case TargetPlatform.iOS:
        _platformQrView = UiKitView(
          viewType: viewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: _CreationParams.fromWidget(0, 0).toMap(),
          creationParamsCodec: StandardMessageCodec(),
        );
        break;
      default:
        throw UnsupportedError(
            "Trying to use the default webview implementation for $defaultTargetPlatform but there isn't a default one");
    }
    return _platformQrView;
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onQRViewCreated == null) {
      return;
    }
    widget.onQRViewCreated(QRViewController._(id, widget.key));
  }
}

class _CreationParams {
  _CreationParams({this.width, this.height});

  static _CreationParams fromWidget(double width, double height) {
    return _CreationParams(
      width: width,
      height: height,
    );
  }

  final double width;
  final double height;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'width': width,
      'height': height,
    };
  }
}

class QRViewController {
  QRViewController._(int id, GlobalKey qrKey)
      : _channel = MethodChannel('net.touchcapture.qr.flutterqr/qrview_$id') {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final RenderBox renderBox = qrKey.currentContext.findRenderObject();
      _channel.invokeMethod('setDimensions',
          {'width': renderBox.size.width, 'height': renderBox.size.height});
    }
    _channel.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case scanMethodCall:
            if (call.arguments != null) {
              _scanUpdateController.sink.add(call.arguments.toString());
            }
        }
      },
    );
  }

  static const scanMethodCall = 'onRecognizeQR';

  final MethodChannel _channel;

  final StreamController<String> _scanUpdateController =
      StreamController<String>();

  Stream<String> get scannedDataStream => _scanUpdateController.stream;

  void flipCamera() {
    _channel.invokeMethod('flipCamera');
  }

  void toggleFlash() {
    _channel.invokeMethod('toggleFlash');
  }

  void pauseCamera() {
    _channel.invokeMethod('pauseCamera');
  }

  void resumeCamera() {
    _channel.invokeMethod('resumeCamera');
  }

  void dispose() {
    _scanUpdateController.close();
  }
}
