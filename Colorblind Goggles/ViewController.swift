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
import GPUImage

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var videoCamera:GPUImageVideoCamera?
    var filter:GPUImageFilter?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Back)
        videoCamera!.outputImageOrientation = .Portrait;
        filter = GPUImageFilter(fragmentShaderFromFile: "Protanopia")
        videoCamera?.addTarget(filter)
        var filteredVideoView: GPUImageView  = GPUImageView(frame:CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height))
        view.addSubview(filteredVideoView)
        filter?.addTarget(filteredVideoView)
        videoCamera?.startCameraCapture()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //filterImage()
           }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}

