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
    var filter: GPUImageFilter
    var view: GPUImageView
    var hidden: Bool
    
    init(name: String, shortName: String, shader: String){
        self.hidden = true
        self.name = name
        self.shortName = shortName
        self.shader = shader
        self.filter = GPUImageFilter(fragmentShaderFromFile: self.shader)
        self.view = GPUImageView()
        self.filter.addTarget(self.view)
    }
    
    mutating func setHidden(hidden: Bool){
        self.hidden = hidden
    }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        cameraMagic()
        fitViewsOntoScreen()
        
    }
    
    func fitViewsOntoScreen(){
        
        self.filterList = setHiddenOnFilterStructs(self.activeFilters)
        let videoViews = getVisibleFilterStructs(filterList)
        
        
        for var filter in filterList{
            filter.view.frame = CGRectMake(0.0, 0.0, 0.0, 0.0)
        }
        
        switch videoViews.count{
            
        case  1:
            videoViews[0].view.frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
        case  2:
            videoViews[0].view.frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
            videoViews[1].view.frame = CGRectMake(0.0, view.bounds.height/2, view.bounds.width, view.bounds.height)
        case  3:
            videoViews[0].view.frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
            videoViews[1].view.frame = CGRectMake(0.0, view.bounds.height/3, view.bounds.width, view.bounds.height)
            videoViews[2].view.frame = CGRectMake(0.0, view.bounds.height/3 * 2, view.bounds.width, view.bounds.height)
        case 4:
            videoViews[0].view.frame = CGRectMake(0.0, 0.0, view.bounds.width/2, view.bounds.height/2)
            videoViews[1].view.frame = CGRectMake(view.bounds.width/2, 0.0, view.bounds.width/2, view.bounds.height/2)
            videoViews[2].view.frame = CGRectMake(0.0, view.bounds.height/2, view.bounds.width/2, view.bounds.height/2)
            videoViews[3].view.frame = CGRectMake(view.bounds.width/2, view.bounds.height/2, view.bounds.width/2, view.bounds.height/2)
        case 5:
            videoViews[0].view.frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
            videoViews[1].view.frame = CGRectMake(0.0, view.bounds.height/5, view.bounds.width, view.bounds.height)
            videoViews[2].view.frame = CGRectMake(0.0, view.bounds.height/5 * 2, view.bounds.width, view.bounds.height)
            videoViews[3].view.frame = CGRectMake(0.0, view.bounds.height/5 * 3, view.bounds.width, view.bounds.height)
            videoViews[4].view.frame = CGRectMake(0.0, view.bounds.height/5 * 4, view.bounds.width, view.bounds.height)
            
        default:
            print("should not be here...")
        }
       
    }
    
    func toggleBottomBar(sender: AnyObject){
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
    
    func getVisibleFilterStructs(_filterList: [FilterStruct]) -> [FilterStruct]{
        return filterList.filter({ (a: FilterStruct) -> Bool in return (a.hidden == false) })
    }
    
    func setHiddenOnFilterStructs(activeFilters: [String]) -> [FilterStruct]{
        //set hidden on all filterstructs
        
        for index in 0...(filterList.count - 1){
            self.filterList[index].setHidden(true)
            if(activeFilters.contains(filterList[index].shortName)){
                self.filterList[index].setHidden(false)
            }
        }
        
        return filterList
    }
    
    func getShaderName(filtertype: String, filterlist: [FilterStruct]) -> String {
        
        let As = filterList
        
        let b = As.filter({ (a: FilterStruct) -> Bool in return (a.shortName == filtertype) })
        
        return b[0].shader
    
    }
    
    
    
    func cameraMagic(){
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .Back)
        videoCamera!.outputImageOrientation = .Portrait
        
        for filter in filterList {
            let screenTouch = UITapGestureRecognizer(target:self, action:"toggleBottomBar:")
            videoCamera?.addTarget(filter.filter)
            filter.view.addGestureRecognizer(screenTouch)
            view.addSubview(filter.view)
        }
        videoCamera?.startCameraCapture()
        view.bringSubviewToFront(bottomBar)
        view.bringSubviewToFront(segment)
    }
    
    func multiSelect(multiSelecSegmendedControl: MultiSelectSegmentedControl!, didChangeValue value: Bool, atIndex index: UInt) {
        
        activeFilters = segment.selectedSegmentTitles as! [String]
        print(activeFilters)
        fitViewsOntoScreen()
    }

}
