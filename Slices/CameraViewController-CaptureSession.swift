import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON

// AVCapture Extension
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func grabCam(){
        var newCaptureDevice: AVCaptureDevice?
        
        // Get devices and check for correct camera.
        let devices = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: currentCameraPosition).devices
        
        if devices == nil {
            logger.message(type: .error, message: "Grabbing camera: No devices found.")
            return
        }
        
        newCaptureDevice = devices!.first
        
        if newCaptureDevice != nil {
            captureDevice = newCaptureDevice!
            logger.message(type: .information, message: "Capture device set: \(currentCameraPosition)")
        }
        else {
            logger.message(type: .error, message: "Grabbing camera: No devices matching desired position.")
            return
        }
    }
    
    func changeCameraPosition() {
        captureSession?.stopRunning()
        captureSession = nil
        grabCam()
        startCaptureSession()
    }
    
    func startCaptureSession() {
        if captureSession == nil {
            captureSession = AVCaptureSession()
            initCaptureSession()
        }
        else if captureSession?.isRunning == false {
            captureSession!.startRunning()
        }
        else {
            logger.message(type: .debug, message: "Tried to start capture session when one was already running.")
        }
    }
    
    func initCaptureSession() {
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        var err: NSError?
        do {
            currentInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            err = error
            currentInput = nil
        }
        
        
        if err == nil && captureSession!.canAddInput(currentInput){
            captureSession!.addInput(currentInput)
            logger.message(type: .information, message: "Input added to capture session.")
            
            // Setup video output
            videoOutput = AVCaptureMovieFileOutput()
            if captureSession!.canAddOutput(videoOutput){
                logger.message(type: .information, message: "Video output added to capture session.")
                captureSession!.addOutput(videoOutput)
                tempVideoURL = URL(fileURLWithPath: NSTemporaryDirectory() + "temp.mov")
                
                let connection: AVCaptureConnection! = videoOutput!.connection(withMediaType: AVMediaTypeVideo)!
                connection.isVideoMirrored = true
            }
            else{
                logger.message(type: .error, message: "In capture session: Could not add video output to capture session.")
            }
            
            // Setup photo output
            photoOutput = AVCapturePhotoOutput()
            if captureSession!.canAddOutput(photoOutput){
                captureSession!.addOutput(photoOutput)
                logger.message(type: .information, message: "Photo output added to capture session.")
                
                // Setup Live Preview
                logger.message(type: .information, message: "Setting up live preview.")
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                viewPreview.layer.addSublayer(previewLayer!)
                previewLayer!.frame = CGRect(x: 0, y: 0, width: viewPreview.frame.size.width, height: viewPreview.frame.size.height)
                viewPreview.isHidden = false
                
            }
            else {
                logger.message(type: .error, message: "In capture session: Could not add photo output to capture session.")
            }
            
            captureSession!.startRunning()
            logger.message(type: .information, message: "Initial capture session started.")
        }
        else{
            logger.message(type: .error, message: "Getting device: \(err?.localizedDescription).")
            return
        }
    }
    
    func capturePhotoTap(gestureRecognizer: UITapGestureRecognizer) {
        photoOutput.capturePhoto(with: getPhotoCaptureSettings(), delegate: self)
    }
    
    func getPhotoCaptureSettings() -> AVCapturePhotoSettings{
        let capturePhotoSettings = AVCapturePhotoSettings()
        capturePhotoSettings.flashMode = currentFlashMode
        capturePhotoSettings.isAutoStillImageStabilizationEnabled = true
        
        let previewPixelType = capturePhotoSettings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: imgMain.frame.width,
                             kCVPixelBufferHeightKey as String: imgMain.frame.height] as [String : Any]
        
        capturePhotoSettings.previewPhotoFormat = previewFormat
        
        return capturePhotoSettings
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?){
        
        if error != nil {
            logger.message(type: .error, message: "While capturing photo: \(error!.localizedDescription).")
            return
        }

        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            let capturedImage = UIImage(data: dataImage)?.cgImage!
            if (currentCameraPosition == .front) {
                sliceTimeline?.addTimelineBlock(image: UIImage(cgImage: capturedImage!, scale: 1.0, orientation: .leftMirrored).fixImageFromCamera())
            }
            else {
                sliceTimeline?.addTimelineBlock(image: UIImage(cgImage: capturedImage!, scale: 1.0, orientation: .right).fixImageFromCamera())
            }
            logger.message(type: .information, message: "Captured photo.")
        } else {
            logger.message(type: .error, message: "In photo capture sample buffer: Nil was found.")
        }
    }
    
    func changeFlashMode(){
        if (currentFlashMode == .on) {
            currentFlashMode = .off
            flashButton.setImage(UIImage(named: "FlashOff"), for: .normal)
        }
        else {
            currentFlashMode = .on
            flashButton.setImage(UIImage(named: "FlashOn"), for: .normal)
        }
        
        flashButton.fadeInAndOut(duration: 2.0)
    }
}
