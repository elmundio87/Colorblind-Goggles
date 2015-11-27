//
//  ViewController.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 26/11/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var stillImageOutput: AVCaptureStillImageOutput?
    let cbf = ColourblindFilter()
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureCamera()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        filterImage()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1/30, target: self, selector: "takePict:", userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func filterImage(){
        let image:UIImage = UIImage(named: "test_image.jpg")!
        let cbf = ColourblindFilter()
        
        //imageView.image = image
        //imageView.image = image.getGrayScale()

        
        imageView.image = image.applyOnPixels({ (point, redColor, greenColor, blueColor, alphaValue) -> (newRedColor: UInt8, newgreenColor: UInt8, newblueColor: UInt8, newalphaValue: UInt8) in
            let (r,g,b,a) = cbf.FilterColour(R: Double(redColor), G: Double(greenColor), B: Double(blueColor), A: Double(alphaValue), f: ColourblindFilter.FilterType.Deuteranopia)
            return (UInt8(r),UInt8(g),UInt8(b),255)
            
        })
    }
    
    func configureCamera(){
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        
        var input: AnyObject!
        do{
            try input = AVCaptureDeviceInput(device: captureDevice)
        }catch let error as NSError {
            // If any error occurs, simply log the description of it and don't continue any more.
            print("\(error.localizedDescription)")
            return
        }
        
        self.stillImageOutput = AVCaptureStillImageOutput()
        
        // Initialize the captureSession object.
        captureSession = AVCaptureSession()
        // Set the input device on the capture session.
        captureSession?.addInput(input as! AVCaptureInput)
        captureSession?.addOutput(self.stillImageOutput)
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        view.bringSubviewToFront(imageView)
        
        
        captureSession?.startRunning()
      
    }
    
    func takePict(timer: NSTimer){
        
        var layer : AVCaptureVideoPreviewLayer = videoPreviewLayer! as AVCaptureVideoPreviewLayer
        
        self.stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = layer.connection.videoOrientation
        
        self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(self.stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo), completionHandler: {
            (imageDataSampleBuffer,error) -> Void in
            if ((imageDataSampleBuffer) != nil) {
                var imageData : NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                var image : UIImage = UIImage(data: imageData)!
                self.imageView.image = image.applyOnPixels({ (point, redColor, greenColor, blueColor, alphaValue) -> (newRedColor: UInt8, newgreenColor: UInt8, newblueColor: UInt8, newalphaValue: UInt8) in
                    let (r,g,b,a) = self.cbf.FilterColour(R: Double(redColor), G: Double(greenColor), B: Double(blueColor), A: Double(alphaValue), f: ColourblindFilter.FilterType.Deuteranopia)
                    return (UInt8(r),UInt8(g),UInt8(b),255)
                    
                })
            }
        })
        
    }
    
    private func createARGBBitmapContext(inImage: CGImageRef) -> CGContext {
        //Get image width, height
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        // Declare the number of bytes per row. Each pixel in the bitmap in this example is represented by 4 bytes; 8 bits each of red, green, blue, and alpha.
        let bitmapBytesPerRow = Int(pixelsWide) * 4
        let bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        // Use the generic RGB color space.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // Allocate memory for image data. This is the destination in memory where any drawing to the bitmap context will be rendered.
        let bitmapData = malloc(Int(bitmapByteCount))
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits per component. Regardless of what the source image format is (CMYK, Grayscale, and so on) it will be converted over to the format  specified here by CGBitmapContextCreate.
        let context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
        return context!
    }

}

