package net.touchcapture.qr.flutterqr.mlkit

import android.content.Context
import android.view.View
import com.journeyapps.barcodescanner.BarcodeView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import net.touchcapture.qr.flutterqr.mlkit.camerax.CameraXLivePreviewActivity

class QRViewMLKit(messenger: BinaryMessenger, id: Int, private val context: Context) : CameraXLivePreviewActivity(), PlatformView {
    var cameraView: CameraXLivePreviewActivity? = null
    override fun getView(): View? {
        if (cameraView == null) {
            cameraView = CameraXLivePreviewActivity()
            return cameraView
        }

    }

    override fun dispose() {
        cameraView = null
    }
}