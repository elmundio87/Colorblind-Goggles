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

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate  {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerButton: UIButton!
    @IBOutlet weak var filterPicker: UIPickerView!
    @IBOutlet weak var filterPickerContainer: UIVisualEffectView!
    @IBOutlet weak var filterPickerDoneButton: UIBarButtonItem!
    @IBOutlet weak var colourblindLabel: UILabel!

    
    var filteredVideoView:GPUImageView?
    var videoCamera:GPUImageVideoCamera?
    var filter:GPUImageFilter?
    
    @IBOutlet weak var bottomBar: UIVisualEffectView!
    
    var filterList = ["Normal","Protanopia","Deuteranopia","Tritanopia","Mono"]
    var filterListIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        filteredVideoView = GPUImageView(frame:CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height))
        let touch = UITapGestureRecognizer(target:self, action:"toggleBottomBar:")
        let touch2 = UITapGestureRecognizer(target:self, action:"pickerButtonTouchUpInside:")
        filteredVideoView!.addGestureRecognizer(touch)
        bottomBar.addGestureRecognizer(touch2)
        view.addSubview(filteredVideoView!)
        
        cameraMagic(filterList[filterListIndex])
        
        filterPicker.delegate = self
        filterPicker.dataSource = self
        
    }
    
    func toggleBottomBar(sender: AnyObject){
        bottomBar.hidden = !bottomBar.hidden
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        view.bringSubviewToFront(bottomBar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cameraMagic(f: String){
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .Back)
        videoCamera!.outputImageOrientation = .Portrait
        filter = GPUImageFilter(fragmentShaderFromFile: f)
        videoCamera?.addTarget(filter)
        filter?.addTarget(filteredVideoView)
        videoCamera?.startCameraCapture()
    }

    @IBAction func pickerButtonTouchUpInside(sender: AnyObject) {
        filterPickerContainer.hidden = false
        view.bringSubviewToFront(filterPickerContainer)
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title: NSString = filterList[row]
        let attString: NSAttributedString = NSAttributedString(string: title as String, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        return attString;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filterList.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        videoCamera?.stopCameraCapture()
        cameraMagic(filterList[row])
        colourblindLabel.text = filterList[row]
    }
    
    @IBAction func filterPickerDoneButtonClick(sender: AnyObject) {
        print("lol")
        filterPickerContainer.hidden = true
    }
}
