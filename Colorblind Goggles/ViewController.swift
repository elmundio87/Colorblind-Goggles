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
    var label: UILabel
    
    init(name: String, shortName: String, shader: String){
        self.hidden = true
        self.name = name
        self.shortName = shortName
        self.shader = shader
        self.filter = GPUImageFilter(fragmentShaderFromFile: self.shader)
        self.view = GPUImageView()
        self.filter.addTarget(self.view)
        self.label = UILabel(frame: CGRect(x:20.0,y:0.0,width:200.0,height:50.0))
        
        let shadow : NSShadow = NSShadow()
        shadow.shadowOffset = CGSizeMake(1.0, 1.0)
        shadow.shadowColor = UIColor.blackColor()
        
        let attributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSShadowAttributeName : shadow]
        
        let title = NSAttributedString(string: self.name, attributes: attributes)
        label.attributedText = title
        self.view.addSubview(label)
    }
    
    mutating func setHidden(hidden: Bool){
        self.hidden = hidden
        self.view.hidden = hidden
    }
}

class ViewController: UIViewController, MultiSelectSegmentedControlDelegate  {
    
    var activeFilters:[String] = ["Norm"]
    var videoCamera:GPUImageVideoCamera?
    var library:ALAssetsLibrary =  ALAssetsLibrary()
    var cameraPosition: AVCaptureDevicePosition = .Back
    var percent = 100
    var lastLocation:CGPoint = CGPointMake(0, 0)
   
    
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
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
        segment.selectedSegmentIndexes = NSIndexSet(index: 0)
        
        var panRecognizer = UIPanGestureRecognizer(target:self, action:"detectPan:")
        self.view.gestureRecognizers = [panRecognizer]

        
        for filter in filterList {
            let screenTouch = UITapGestureRecognizer(target:self, action:"toggleBottomBar:")
            filter.view.addGestureRecognizer(screenTouch)
            containerView.addSubview(filter.view)
        }
        
        view.bringSubviewToFront(containerView)
        view.bringSubviewToFront(bottomBar)
        
        cameraMagic(cameraPosition)
        fitViewsOntoScreen()
        
    }
    
    func fitViewsOntoScreen(){
        
        self.filterList = setHiddenOnFilterStructs(self.activeFilters)
        let videoViews = getVisibleFilterStructs(filterList)
        
        
        filterList[0].view.frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
        filterList[1].view.frame = CGRectMake(0.0, view.bounds.height/5, view.bounds.width, view.bounds.height)
        filterList[2].view.frame = CGRectMake(0.0, view.bounds.height/5 * 2, view.bounds.width, view.bounds.height)
        filterList[3].view.frame = CGRectMake(0.0, view.bounds.height/5 * 3, view.bounds.width, view.bounds.height)
        filterList[4].view.frame = CGRectMake(0.0, view.bounds.height/5 * 4, view.bounds.width, view.bounds.height)

        
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
    

    
    func cameraMagic(position: AVCaptureDevicePosition){
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: position)
        videoCamera!.outputImageOrientation = .Portrait
        
        videoCamera?.startCameraCapture()

        for index in 0...(filterList.count - 1){
            videoCamera?.addTarget(self.filterList[index].filter)
            self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
        }
        
        
        
    }
    
    func multiSelect(multiSelecSegmendedControl: MultiSelectSegmentedControl!, didChangeValue value: Bool, atIndex index: UInt) {
        
        if(segment.selectedSegmentIndexes.count == 0){
            segment.selectedSegmentIndexes = NSIndexSet(index: Int(index))
        }
        
        activeFilters = segment.selectedSegmentTitles as! [String]
        print(activeFilters)
        fitViewsOntoScreen()
    }

    @IBAction func snapButtonTouchUpInside(sender: AnyObject) {
        let view = containerView
        let viewImage:UIImage = view.pb_takeSnapshot()
        saveImageToAlbum(viewImage)
        
        let tempView:UIImageView = UIImageView(image: viewImage)
        self.view.addSubview(tempView)
        tempView.frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height)
        self.view.bringSubviewToFront(tempView)

        let endRect:CGRect = CGRectMake(view.bounds.width-40, view.bounds.height, 40.0, 10.0 );
        tempView.genieInTransitionWithDuration(0.7, destinationRect: endRect, destinationEdge: BCRectEdge.Top, completion: {
            tempView.removeFromSuperview()
        })
        
    }
    
    @IBAction func flipButtonTouchUpInside(sender: AnyObject) {
        toggleCameraPosition()
        videoCamera?.stopCameraCapture()
        cameraMagic(cameraPosition)
    }
    
    func saveImageToAlbum(image:UIImage) {
        library.writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation(rawValue: image.imageOrientation.rawValue)!, completionBlock:saveDone)
    }


    func saveDone(assetURL:NSURL!, error:NSError!){
        print("saveDone")
        library.assetForURL(assetURL, resultBlock: self.saveToAlbum, failureBlock: nil)
    }
    
    func toggleCameraPosition(){
        if(cameraPosition == AVCaptureDevicePosition.Back){
            cameraPosition = AVCaptureDevicePosition.Front
        }else{
            cameraPosition = AVCaptureDevicePosition.Back
        }
    }
    
    func saveToAlbum(asset:ALAsset!){
        
        library.enumerateGroupsWithTypes(ALAssetsGroupAlbum, usingBlock: { group, stop in
            stop.memory = false
            if(group != nil){
                let str = group.valueForProperty(ALAssetsGroupPropertyName) as! String
                if(str == "MY_ALBUM_NAME"){
                    group!.addAsset(asset!)
                    let assetRep:ALAssetRepresentation = asset.defaultRepresentation()
                    let iref = assetRep.fullResolutionImage().takeUnretainedValue()
                    let image:UIImage =  UIImage(CGImage:iref)
                    
                }
                
            }
            
            },
            failureBlock: { error in
                print("NOOOOOOO")
        })
        
    }
    
    @IBAction func detectPan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        let midpoint = containerView.bounds.height / 2
        let current = recognizer.locationInView(containerView).y
        if let view = recognizer.view {
            percent =  (Int)((midpoint - current) * 0.3) + 50
            
        }
        
        if(percent < 0)
        {
            percent = 0
        }

        if(percent > 100)
        {
            percent = 100
        }

        percentLabel.alpha = 1
        
        view.bringSubviewToFront(percentLabel)
        percentLabel.text = String(percent) + "%"
        
        UIView.animateWithDuration(1.0) {
            self.percentLabel.alpha = 0
        }
           
        for index in 0...(filterList.count - 1){
            
            self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            
        }
    }
    
}

extension UIView {
    
    func pb_takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        
        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        
        // old style: layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
