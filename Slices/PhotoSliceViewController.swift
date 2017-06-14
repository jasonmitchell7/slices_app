import UIKit
import AVFoundation

// TODO: Remove this.
class PhotoSliceViewController: UIViewController{
    
    var slice: Slice!
    //var toppings = [Slice]()
    
    var captureDevice: AVCaptureDevice?
    var audioDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var currentReaction: UIImage?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var videoOutput: AVCaptureMovieFileOutput?
    var tempVideoURL: URL?
    var currentInput: AVCaptureDeviceInput?
    
    @IBOutlet weak var imgCaptured: UIImageView!
    @IBOutlet weak var viewPreview: UIView!
    @IBOutlet weak var imgLarge: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add tap gesture to preview view preview.
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoSliceViewController.sendToReviewPhoto))
        imgCaptured.addGestureRecognizer(tapRecognizer)
    }
    
    func sendToReviewPhoto(){
        if currentReaction != nil{
            self.performSegue(withIdentifier: "photoSliceViewToPhotoReview", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "photoSliceViewToPhotoReview"){
            let reviewPhotoVC = segue.destination as! ReviewPhotoViewController
            
            reviewPhotoVC.currentImage = currentReaction
            reviewPhotoVC.parentID = slice.sliceID
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show the slice.
        if let photo = slice.photoImg{
            imgLarge.image = photo
        }
        
        //slice.requestTopping(nil)
        
        grabFaceCam()
        
        if captureDevice != nil {
            beginPhotoSession()
        }
        else{
            print("Could not grab device.", terminator: "")
        }
        
        addBorders()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        previewLayer!.frame = viewPreview.bounds
    }

    func addBorders(){
        imgCaptured.layer.borderWidth = 2.0
        imgCaptured.layer.borderColor = styleMgr.colorOffWhite.cgColor
        imgCaptured.layer.cornerRadius = 8.0
        imgCaptured.layer.masksToBounds = true
        
        viewPreview.layer.borderWidth = 2.0
        viewPreview.layer.borderColor = styleMgr.colorOffWhite.cgColor
        viewPreview.layer.masksToBounds = true
    }
}

// AVCapture Extension
extension PhotoSliceViewController: AVCaptureFileOutputRecordingDelegate{
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [AnyObject]!, error: Error!){
        
        if error != nil {
            print("Error recording video:")
            print("\(error.localizedDescription)")
        }
        
        //self.performSegueWithIdentifier("segueToReviewVideo", sender: self)
    }
    
    func takePhoto(){
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo){
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(imageSampleBuffer: CMSampleBuffer?, error: Error?) in
                if (imageSampleBuffer != nil){
                    // TODO: Update StillImage to Photo
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData!)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    
                    let image: UIImage! = UIImage(cgImage:cgImageRef!, scale: 1.0, orientation: .leftMirrored)
                    
                    self.currentReaction = image.fixImageFromCamera()
                    
                    self.imgCaptured.image = self.currentReaction?.cropImageToSquare()
                }
            })
        }
    }
    
    
    
    func grabFaceCam(){
        
        // Get devices and check for correct camera.
        let devices = AVCaptureDevice.devices()
        
        for device in devices!{
            if (device.position == AVCaptureDevicePosition.front)
            {
                captureDevice = device as? AVCaptureDevice
            }
        }
        
        if captureDevice == nil{
            print("Could not grab front camera.")
            print("\(devices)")
        }

    }
    
    func beginPhotoSession() {
        print("begin sesh")
        
        // Create capture session if we haven't done so yet.
        if captureSession == nil{
            captureSession = AVCaptureSession()
        }
        else if captureSession!.isRunning {
            return
        }
        
        captureSession!.sessionPreset = AVCaptureSessionPresetMedium
        
        var err: NSError?
        do {
            currentInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            err = error
            currentInput = nil
        }
        
        
        if err == nil && captureSession!.canAddInput(currentInput){
            captureSession!.addInput(currentInput)
            
            // Setup video output
            videoOutput = AVCaptureMovieFileOutput()
            if captureSession!.canAddOutput(videoOutput){
                captureSession!.addOutput(videoOutput)
                tempVideoURL = URL(fileURLWithPath: NSTemporaryDirectory() + "temp.mov")
                
                let connection: AVCaptureConnection! = videoOutput!.connection(withMediaType: AVMediaTypeVideo)!
                connection.isVideoMirrored = true
            }
            else{
                print("Could not add video output to capture session.", terminator: "")
            }
            
            // Setup photo output
            stillImageOutput = AVCaptureStillImageOutput()
            if captureSession!.canAddOutput(videoOutput){
                stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            }
            
            if captureSession!.canAddOutput(stillImageOutput){
                captureSession!.addOutput(stillImageOutput)
                
                // Setup Live Preview
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                viewPreview.layer.addSublayer(previewLayer!)
                
                // Add tap gesture to preview view preview.
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoSliceViewController.takePhoto))
                viewPreview.addGestureRecognizer(tapRecognizer)
            }
            
            captureSession!.startRunning()
            
        }
        else{
            print("Error getting device: \(err?.localizedDescription)", terminator: "")
            return
        }
        
    }
}



