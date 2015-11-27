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
    
    var filteredVideoView:GPUImageView?
    var videoCamera:GPUImageVideoCamera?
    var filter:GPUImageFilter?
    
    var filterList = ["Normal","Protanopia","Deuteranopia","Tritanopia","Mono"]
    var filterListIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        filteredVideoView = GPUImageView(frame:CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height))
        let touch = UITapGestureRecognizer(target:self, action:"action:")
        filteredVideoView!.addGestureRecognizer(touch)
        view.addSubview(filteredVideoView!)
        
        cameraMagic(filterList[filterListIndex])
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //filterImage()
           }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func action(sender:UITapGestureRecognizer) {
        videoCamera?.stopCameraCapture()
        cameraMagic(filterList[++filterListIndex])
    }
    
    func cameraMagic(f: String){
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .Back)
        videoCamera!.outputImageOrientation = .Portrait
        filter = GPUImageFilter(fragmentShaderFromFile: f)
        //filter = GPUImageFilter(fragmentShaderFromFile: "Protanopia")
        //filter = GPUImageFilter(fragmentShaderFromFile: "Deuteranopia")
        //filter = GPUImageFilter(fragmentShaderFromFile: "Tritanopia")
        //filter = GPUImageFilter(fragmentShaderFromFile: "Mono")
        
        
        videoCamera?.addTarget(filter)
        
        
        filter?.addTarget(filteredVideoView)
        videoCamera?.startCameraCapture()
    }

    

}

