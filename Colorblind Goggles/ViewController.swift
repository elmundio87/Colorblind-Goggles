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

struct FilterStruct {
    var name: String
    var shortName: String
    var shader: String
}

class ViewController: UIViewController, MultiSelectSegmentedControlDelegate  {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerButton: UIButton!
    @IBOutlet weak var colourblindLabel: UILabel!
    
    var activeFilters:[String] = ["Norm"]
    
    var filteredVideoViews:[GPUImageView] = []
    var filters:[GPUImageFilter] = []
    var videoCamera:GPUImageVideoCamera?
   
    
    @IBOutlet weak var segment: MultiSelectSegmentedControl!
    @IBOutlet weak var bottomBar: UIVisualEffectView!
    
    
    
    var filterList: [FilterStruct] = [FilterStruct(name: "Normal", shortName: "Norm", shader: "Normal"),
        FilterStruct(name:"Protanopia", shortName: "Pro", shader: "Protanopia"),
        FilterStruct(name:"Deuteranopia", shortName: "Deu", shader: "Deuteranopia"),
        FilterStruct(name:"Tritanopia", shortName:  "Tri", shader: "Tritanopia"),
        FilterStruct(name:"Monochromatic", shortName: "Mono", shader: "Mono")]
    
    var filterListIndex = 0
    var filtersOnScreen = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        cameraMagic()
        fitViewsOntoScreen()
        
    }
    
    func fitViewsOntoScreen(){
        
        switch filtersOnScreen{
        case  1:
            filteredVideoViews[0].frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
        case  2:
            filteredVideoViews[0].frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
            filteredVideoViews[1].frame = CGRectMake(0.0, view.bounds.height/2, view.bounds.width, view.bounds.height)
        case  3:
            filteredVideoViews[0].frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
            filteredVideoViews[1].frame = CGRectMake(0.0, view.bounds.height/3, view.bounds.width, view.bounds.height)
            filteredVideoViews[2].frame = CGRectMake(0.0, view.bounds.height/3 * 2, view.bounds.width, view.bounds.height)
        case 4:
            filteredVideoViews[0].frame = CGRectMake(0.0, 0.0, view.bounds.width/2, view.bounds.height/2)
            filteredVideoViews[1].frame = CGRectMake(view.bounds.width/2, 0.0, view.bounds.width/2, view.bounds.height/2)
            filteredVideoViews[2].frame = CGRectMake(0.0, view.bounds.height/2, view.bounds.width/2, view.bounds.height/2)
            filteredVideoViews[3].frame = CGRectMake(view.bounds.width/2, view.bounds.height/2, view.bounds.width/2, view.bounds.height/2)
        case 5:
            filteredVideoViews[0].frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
            filteredVideoViews[1].frame = CGRectMake(0.0, view.bounds.height/5, view.bounds.width, view.bounds.height)
            filteredVideoViews[2].frame = CGRectMake(0.0, view.bounds.height/5 * 2, view.bounds.width, view.bounds.height)
            filteredVideoViews[3].frame = CGRectMake(0.0, view.bounds.height/5 * 3, view.bounds.width, view.bounds.height)
            filteredVideoViews[4].frame = CGRectMake(0.0, view.bounds.height/5 * 4, view.bounds.width, view.bounds.height)
            
        default:
            //filteredVideoViews[0].frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
            print("should not be here...")
        }
       
        
        
    }
    
    func toggleBottomBar(sender: AnyObject){
        print(filtersOnScreen)
        bottomBar.hidden = !bottomBar.hidden
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        segment.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getShaderName(filtertype: String, filterlist: [FilterStruct]) -> String {
        
        var As = filterList
        
        let b = As.filter({ (a: FilterStruct) -> Bool in return (a.shortName == filtertype) })
        
        return b[0].shader
    
    }
    
    func cameraMagic(){
        videoCamera?.stopCameraCapture()
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .Back)
        videoCamera!.outputImageOrientation = .Portrait
        
        filters = []
        filteredVideoViews = []
        for filter in activeFilters {
            let newFilteredVideoView = GPUImageView()
            let screenTouch = UITapGestureRecognizer(target:self, action:"toggleBottomBar:")
            let shaderName = getShaderName(filter, filterlist: filterList)
            let newFilter:GPUImageFilter = GPUImageFilter(fragmentShaderFromFile: shaderName)
            filters.append(newFilter)
            filteredVideoViews.append(newFilteredVideoView)
            videoCamera?.addTarget(newFilter)
            newFilter.addTarget(newFilteredVideoView)
            newFilteredVideoView.addGestureRecognizer(screenTouch)
            view.addSubview(newFilteredVideoView)
        }
        
        view.bringSubviewToFront(bottomBar)
        view.bringSubviewToFront(segment)
        
        videoCamera?.startCameraCapture()
        
    }
    
    func multiSelect(multiSelecSegmendedControl: MultiSelectSegmentedControl!, didChangeValue value: Bool, atIndex index: UInt) {
        
        activeFilters = segment.selectedSegmentTitles as! [String]
        filtersOnScreen = activeFilters.count
        print(activeFilters)
        cameraMagic()
        fitViewsOntoScreen()
        
    }

}
