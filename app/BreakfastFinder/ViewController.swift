/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Contains the view controller for the Breakfast Finder.
*/

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    // Hide the status bar.
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    // Let system decide to hide home indicator.
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    var bufferSize: CGSize = .zero
    var rootLayer: CALayer! = nil
    
    @IBOutlet weak private var previewView: UIView!
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var videoDevice: AVCaptureDevice! = nil
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    // Configure device framerate
    func configureDevice(desiredFPS: Int32, desiredWidth: Int32, desiredHeight: Int32) {
        if let device = self.videoDevice {
            
            for vFormat in self.videoDevice!.formats {

                let ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
                let frameRates = ranges[0]
                let resolution = CMVideoFormatDescriptionGetDimensions(vFormat.formatDescription)
                let width = resolution.width
                let height = resolution.height

                if Int32(frameRates.maxFrameRate) == desiredFPS && width == desiredWidth && height == desiredHeight {
                    do {
                        try device.lockForConfiguration()
                        device.activeFormat = vFormat as AVCaptureDevice.Format
                        device.activeVideoMinFrameDuration = frameRates.minFrameDuration
                        device.activeVideoMaxFrameDuration = frameRates.maxFrameDuration
                        device.unlockForConfiguration()
                    } catch {
                        print(error)
                    }
                }
            }
        }

    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // to be implemented in the subclass
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVCapture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input
        var isUltraWide = true
        self.videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera], mediaType: .video, position: .back).devices.first
//        self.videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front).devices.first
//        self.videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first

        do {
            deviceInput = try AVCaptureDeviceInput(device: self.videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            isUltraWide = false
        }
        
        if(!isUltraWide) {
            do {
                self.videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
                deviceInput = try AVCaptureDeviceInput(device: self.videoDevice!)
            } catch {
                print("Could not create video device input: \(error)")
                return
            }

        }
        
        // Set 1920x1080 240
        configureDevice(desiredFPS: 60,desiredWidth: 1920,desiredHeight: 1080)
        
        session.beginConfiguration()
//        session.sessionPreset = .hd1280x720 // Model image size is smaller.
//        session.sessionPreset = .hd1920x1080 // Model image size is smaller.

        session.sessionPreset = AVCaptureSession.Preset.inputPriority

        // Add a video input
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        let captureConnection = videoDataOutput.connection(with: .video)
        // Always process the frames
        captureConnection?.isEnabled = true

        // Apply the changes to the session.
        session.commitConfiguration()
        
        do {
            try  self.videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((self.videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            self.videoDevice!.unlockForConfiguration()

        } catch {
            print(error)
        }
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer = previewView.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
    }
    
    func startCaptureSession() {
        session.startRunning()
    }
    
    // Clean up capture setup
    func teardownAVCapture() {
        previewLayer.removeFromSuperlayer()
        previewLayer = nil
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // print("frame dropped")
    }
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
//            exifOrientation = .upMirrored
            exifOrientation = .up
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
//            exifOrientation = .down
            exifOrientation = .up
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
}

