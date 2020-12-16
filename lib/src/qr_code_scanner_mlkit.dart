import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Creates a Camera window with an QR scanner that continuously scans for
/// codes.
///
/// Takes [key] as reference and [onQRViewCreated] as callback for when
/// a code is scanned. [overlay] can be used to place an overlay over the
/// camera window and [overlayMargin] can be used to give a margin to that
/// overlay.
class QRViewMLKit extends StatefulWidget {
  const QRViewMLKit({
    @required Key key,
    this.overlay,
    this.overlayMargin = EdgeInsets.zero,
  })  : assert(key != null),
        super(key: key);

  final ShapeBorder overlay;
  final EdgeInsetsGeometry overlayMargin;

  @override
  State<StatefulWidget> createState() => _QRViewMLKitState();
}

class _QRViewMLKitState extends State<QRViewMLKit> {
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
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        _platformQrView = AndroidView(
          viewType: 'net.touchcapture.qr.flutterqr/qrviewmlkit',
        );
        break;
      // case TargetPlatform.iOS:
      //   _platformQrView = UiKitView(
      //     viewType: 'net.touchcapture.qr.flutterqr/qrview',
      //     onPlatformViewCreated: _onPlatformViewCreated,
      //     creationParams: _CreationParams.fromWidget(0, 0).toMap(),
      //     creationParamsCodec: StandardMessageCodec(),
      //   );
      //   break;
      default:
        throw UnsupportedError(
            "Trying to use the default webview implementation for $defaultTargetPlatform but there isn't a default one");
    }
    return _platformQrView;
  }

}

