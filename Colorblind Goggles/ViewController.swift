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
    var filteredVideoView2:GPUImageView?
    var filteredVideoView3:GPUImageView?
    var filteredVideoView4:GPUImageView?
    var filteredVideoView5:GPUImageView?
    
    var videoCamera:GPUImageVideoCamera?
    var filter:GPUImageFilter?
    var filter2:GPUImageFilter?
    var filter3:GPUImageFilter?
    var filter4:GPUImageFilter?
    var filter5:GPUImageFilter?
    
    
    
    @IBOutlet weak var bottomBar: UIVisualEffectView!
    
    var filterList = ["Normal","Protanopia","Deuteranopia","Tritanopia","Mono"]
    var filterListIndex = 0
    var filtersOnScreen = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        
        filteredVideoView = GPUImageView(frame:CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height))
        filteredVideoView2 = GPUImageView(frame:CGRectMake(0.0, 0.0, 0.0, 0.0))
        filteredVideoView3 = GPUImageView(frame:CGRectMake(0.0, 0.0, 0.0, 0.0))
        filteredVideoView4 = GPUImageView(frame:CGRectMake(0.0, 0.0, 0.0, 0.0))
        filteredVideoView5 = GPUImageView(frame:CGRectMake(0.0, 0.0, 0.0, 0.0))
        
        fitViewsOntoScreen()
        cameraMagic()
        
        filterPicker.delegate = self
        filterPicker.dataSource = self
        
    }
    
    func fitViewsOntoScreen(){
        
        switch filtersOnScreen{
        case  1:
            filteredVideoView?.frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
            filteredVideoView2?.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
            filteredVideoView3?.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
            filteredVideoView4?.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
            filteredVideoView5?.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
            
        case  2:
            filteredVideoView?.frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
            filteredVideoView2?.frame = CGRectMake(0.0, view.bounds.height/2, view.bounds.width, view.bounds.height)
            filteredVideoView3?.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
            filteredVideoView4?.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
            filteredVideoView5?.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
        case  3:
            filteredVideoView?.frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
            filteredVideoView2?.frame = CGRectMake(0.0, view.bounds.height/3, view.bounds.width, view.bounds.height)
            filteredVideoView3?.frame = CGRectMake(0.0, view.bounds.height/3 * 2, view.bounds.width, view.bounds.height)
            filteredVideoView4?.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
            filteredVideoView5?.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
        case 4:
            filteredVideoView?.frame = CGRectMake(0.0, 0.0, view.bounds.width/2, view.bounds.height/2)
            filteredVideoView2?.frame = CGRectMake(view.bounds.width/2, 0.0, view.bounds.width/2, view.bounds.height/2)
            filteredVideoView3?.frame = CGRectMake(0.0, view.bounds.height/2, view.bounds.width/2, view.bounds.height/2)
            filteredVideoView4?.frame = CGRectMake(view.bounds.width/2, view.bounds.height/2, view.bounds.width/2, view.bounds.height/2)
            filteredVideoView5?.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
        case 5:
            filteredVideoView?.frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
            filteredVideoView2?.frame = CGRectMake(0.0, view.bounds.height/5, view.bounds.width, view.bounds.height)
            filteredVideoView3?.frame = CGRectMake(0.0, view.bounds.height/5 * 2, view.bounds.width, view.bounds.height)
            filteredVideoView4?.frame = CGRectMake(0.0, view.bounds.height/5 * 3, view.bounds.width, view.bounds.height)
            filteredVideoView5?.frame = CGRectMake(0.0, view.bounds.height/5 * 4, view.bounds.width, view.bounds.height)
            
        default:
            filteredVideoView?.frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
            filteredVideoView2?.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
            filteredVideoView3?.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
            filteredVideoView4?.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
            filteredVideoView5?.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
        }
       
        
        
    }
    
    func toggleBottomBar(sender: AnyObject){
        filtersOnScreen += 1
        fitViewsOntoScreen()
        print(filtersOnScreen)
        //bottomBar.hidden = !bottomBar.hidden
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        view.bringSubviewToFront(bottomBar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cameraMagic(){
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .Back)
        videoCamera!.outputImageOrientation = .Portrait
        filter = GPUImageFilter(fragmentShaderFromFile: "Normal")
        filter2 = GPUImageFilter(fragmentShaderFromFile: "Protanopia")
        filter3 = GPUImageFilter(fragmentShaderFromFile: "Deuteranopia")
        filter4 = GPUImageFilter(fragmentShaderFromFile: "Tritanopia")
        filter5 = GPUImageFilter(fragmentShaderFromFile: "Mono")
        
        
        videoCamera?.addTarget(filter)
        videoCamera?.addTarget(filter2)
        videoCamera?.addTarget(filter3)
        videoCamera?.addTarget(filter4)
        videoCamera?.addTarget(filter5)
        
        
        filter?.addTarget(filteredVideoView)
        filter2?.addTarget(filteredVideoView2)
        filter3?.addTarget(filteredVideoView3)
        filter4?.addTarget(filteredVideoView4)
        filter5?.addTarget(filteredVideoView5)
        
    
        videoCamera?.startCameraCapture()
        
        let touch = UITapGestureRecognizer(target:self, action:"toggleBottomBar:")
        let touch2 = UITapGestureRecognizer(target:self, action:"pickerButtonTouchUpInside:")
        filteredVideoView!.addGestureRecognizer(touch)
        bottomBar.addGestureRecognizer(touch2)
        
        view.addSubview(filteredVideoView!)
        view.addSubview(filteredVideoView2!)
        view.addSubview(filteredVideoView3!)
        view.addSubview(filteredVideoView4!)
        view.addSubview(filteredVideoView5!)
        
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
    
        
    @IBAction func filterPickerDoneButtonClick(sender: AnyObject) {
        print("lol")
        filterPickerContainer.hidden = true
    }
}
