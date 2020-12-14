package net.touchcapture.qr.flutterqr

import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Camera.CameraInfo
import android.os.Bundle
import android.util.Log
import android.view.View
import com.google.zxing.BarcodeFormat
import com.google.zxing.ResultPoint
import com.journeyapps.barcodescanner.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.util.*

class QRView(messenger: BinaryMessenger, id: Any, private val context: Context) :
        PlatformView,MethodChannel.MethodCallHandler {

    companion object {
        const val CAMERA_REQUEST_ID = 513469796
    }

    var barcodeView: BarcodeView? = null
    private var isTorchOn: Boolean = false
    val channel: MethodChannel

    init {
        channel = MethodChannel(messenger, "net.touchcapture.qr.flutterqr/qrview_$id")
        channel.setMethodCallHandler(this)
        if (Shared.activity == null) {
            Log.e("qr_code_scanner", "\n\n\nERROR: Shared.activity is null!!!\n\n" +
                    "You need to upgrade your Flutter project to use the new Java Embedding API:\n\n" +
                    "- See the official wiki here: https://github.com/flutter/flutter/wiki/Upgrading-pre-1.12-Android-projects\n\n\n");
        } else {
            Shared.activity!!.application.registerActivityLifecycleCallbacks(object : Application.ActivityLifecycleCallbacks {
                override fun onActivityPaused(p0: Activity) {
                    if (p0 == Shared.activity) {
                        barcodeView?.pause()
                    }
                }

                override fun onActivityResumed(p0: Activity) {
                    if (p0 == Shared.activity) {
                        barcodeView?.resume()
                    }
                }

                override fun onActivityStarted(p0: Activity) {
                }

                override fun onActivityDestroyed(p0: Activity) {
                }

                override fun onActivitySaveInstanceState(p0: Activity, p1: Bundle) {
                }

                override fun onActivityStopped(p0: Activity) {
                }

                override fun onActivityCreated(p0: Activity, p1: Bundle?) {
                }
            })
        }
    }

    fun flipCamera() {
        barcodeView?.pause()
        var settings = barcodeView?.cameraSettings

        if(settings?.requestedCameraId == CameraInfo.CAMERA_FACING_FRONT)
            settings?.requestedCameraId = CameraInfo.CAMERA_FACING_BACK
        else
            settings?.requestedCameraId = CameraInfo.CAMERA_FACING_FRONT

        barcodeView?.cameraSettings = settings
        barcodeView?.resume()
    }

    private fun toggleFlash() {
        if (hasFlash() == true) {
            barcodeView?.setTorch(!isTorchOn)
            isTorchOn = !isTorchOn
        }

    }

    private fun pauseCamera() {
        if (barcodeView!!.isPreviewActive) {
            barcodeView?.pause()
        }
    }

    private fun resumeCamera() {
        if (!barcodeView!!.isPreviewActive) {
            barcodeView?.resume()
        }
    }

    private fun hasFlash(): Boolean? {
        return context.packageManager.hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH)
    }

    override fun getView(): View {
        return initBarCodeView()?.apply {
            resume()
        }!!
    }

    private fun initBarCodeView(): BarcodeView? {
        if (barcodeView == null) {
            barcodeView = createBarCodeView()
        }
        return barcodeView
    }

    private var lastText: String? = null

    private fun createBarCodeView(): BarcodeView? {
        val barcode = BarcodeView(Shared.activity)
        val formats: Collection<BarcodeFormat> = listOf(BarcodeFormat.QR_CODE, BarcodeFormat.CODE_39)
        barcode.decoderFactory = DefaultDecoderFactory(formats)
        barcode.decodeContinuous(
                object : BarcodeCallback {
                    override fun barcodeResult(result: BarcodeResult) {
                        if (result.text == null || result.text == lastText) {
                            return
                        }

                        lastText = result.text

                        channel.invokeMethod("onRecognizeQR", result.text)
                    }

                    override fun possibleResultPoints(resultPoints: List<ResultPoint>) {

                    }
                }
        )
        return barcode
    }

    override fun dispose() {
        barcodeView?.pause()
        barcodeView = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method){
            "flipCamera" -> {
                flipCamera()
            }
            "toggleFlash" -> {
                toggleFlash()
            }
            "pauseCamera" -> {
                pauseCamera()
            }
            "resumeCamera" -> {
                resumeCamera()
            }
        }
    }
}
