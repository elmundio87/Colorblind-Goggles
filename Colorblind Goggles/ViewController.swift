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
        self.view.backgroundColor = UIColor.blackColor()
        self.filter.addTarget(self.view)
        self.label = UILabel(frame: CGRect(x:20.0,y:0.0,width:200.0,height:50.0))
        self.setLabelTitle(self.name)
        self.view.addSubview(label)
        self.view.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
    }
    
    mutating func setHidden(hidden: Bool){
        self.hidden = hidden
        self.view.hidden = hidden
    }
    
    mutating func setLabelTitle(title: String){
        let shadow : NSShadow = NSShadow()
        shadow.shadowOffset = CGSizeMake(1.0, 1.0)
        shadow.shadowColor = UIColor.blackColor()
        let attributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSShadowAttributeName : shadow]
        let title = NSAttributedString(string: title , attributes: attributes)
        label.attributedText = title
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged", name: UIDeviceOrientationDidChangeNotification, object: nil)
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

        self.fitViewsOntoScreen()
        
    }
    
    func fitViewsOntoScreen(){
        let frame:CGSize = view.bounds.size
        self.fitViewsOntoScreen(frame)
    }
    
    func fitViewsOntoScreen(frame:CGSize){
        let currentOrientation = UIApplication.sharedApplication().statusBarOrientation
        self.filterList = setHiddenOnFilterStructs(self.activeFilters)
        let videoViews = getVisibleFilterStructs(filterList)
        
        
        filterList[0].view.frame = CGRectMake(0.0, 0.0, frame.width, frame.height)
        filterList[1].view.frame = CGRectMake(0.0, frame.height/5, frame.width, frame.height)
        filterList[2].view.frame = CGRectMake(0.0, frame.height/5 * 2, frame.width, frame.height)
        filterList[3].view.frame = CGRectMake(0.0, frame.height/5 * 3, frame.width, frame.height)
        filterList[4].view.frame = CGRectMake(0.0, frame.height/5 * 4, frame.width, frame.height)

        
        
        if(currentOrientation == .Portrait){
        switch videoViews.count{
            
        case  1:
            videoViews[0].view.frame = CGRectMake(0.0, 0.0, frame.width, frame.height)
        case  2:
            videoViews[0].view.frame = CGRectMake(0.0, 0.0, frame.width, frame.height)
            videoViews[1].view.frame = CGRectMake(0.0, frame.height/2, frame.width, frame.height)
        case  3:
            videoViews[0].view.frame = CGRectMake(0.0, 0.0, frame.width, frame.height)
            videoViews[1].view.frame = CGRectMake(0.0, frame.height/3, frame.width, frame.height)
            videoViews[2].view.frame = CGRectMake(0.0, frame.height/3 * 2, frame.width, frame.height)
        case 4:
            videoViews[0].view.frame = CGRectMake(0.0, 0.0, frame.width/2, frame.height/2)
            videoViews[1].view.frame = CGRectMake(frame.width/2, 0.0, frame.width/2, frame.height/2)
            videoViews[2].view.frame = CGRectMake(0.0, frame.height/2, frame.width/2, frame.height/2)
            videoViews[3].view.frame = CGRectMake(frame.width/2, frame.height/2, frame.width/2, frame.height/2)
        case 5:
            videoViews[0].view.frame = CGRectMake(0.0, 0.0, frame.width, frame.height)
            videoViews[1].view.frame = CGRectMake(0.0, frame.height/5, frame.width, frame.height)
            videoViews[2].view.frame = CGRectMake(0.0, frame.height/5 * 2, frame.width, frame.height)
            videoViews[3].view.frame = CGRectMake(0.0, frame.height/5 * 3, frame.width, frame.height)
            videoViews[4].view.frame = CGRectMake(0.0, frame.height/5 * 4, frame.width, frame.height)
            
        default:
            print("should not be here...")
            }
        }else{
            switch videoViews.count{
                
            case  1:
                videoViews[0].view.frame = CGRectMake(0.0, 0.0, frame.width, frame.height)
            case  2:
                videoViews[0].view.frame = CGRectMake(0.0, 0.0, frame.width, frame.height)
                videoViews[1].view.frame = CGRectMake(frame.width * 1/2, 0.0, frame.width, frame.height)
            case  3:
                videoViews[0].view.frame = CGRectMake(0.0, 0.0, frame.width, frame.height)
                videoViews[1].view.frame = CGRectMake(frame.width * 1/3, 0.0, frame.width, frame.height)
                videoViews[2].view.frame = CGRectMake(frame.width * 2/3, 0.0, frame.width, frame.height)
            case 4:
                videoViews[0].view.frame = CGRectMake(0.0, 0.0, frame.width/2, frame.height/2)
                videoViews[1].view.frame = CGRectMake(frame.width/2, 0.0, frame.width/2, frame.height/2)
                videoViews[2].view.frame = CGRectMake(0.0, frame.height/2, frame.width/2, frame.height/2)
                videoViews[3].view.frame = CGRectMake(frame.width/2, frame.height/2, frame.width/2, frame.height/2)
            case 5:
                videoViews[0].view.frame = CGRectMake(0.0, 0.0, frame.width, frame.height)
                videoViews[1].view.frame = CGRectMake(frame.width * 1/5, 0.0, frame.width, frame.height)
                videoViews[2].view.frame = CGRectMake(frame.width * 2/5, 0.0, frame.width, frame.height)
                videoViews[3].view.frame = CGRectMake(frame.width * 3/5, 0.0, frame.width, frame.height)
                videoViews[4].view.frame = CGRectMake(frame.width * 4/5, 0.0, frame.width, frame.height)
                
            default:
                print("should not be here...")
            }
        }
       
    }
    
    func toggleBottomBar(sender: AnyObject){
        bottomBar.hidden = !bottomBar.hidden
    }
    
    func permissionDenied(){
        let alertVC = UIAlertController(title: "Permission to access camera was denied", message: "You need to allow Colorblind Goggles to use the camera in Settings to use it", preferredStyle: .ActionSheet)
        alertVC.addAction(UIAlertAction(title: "Open Settings", style: .Default) {
            value in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .Cancel) {
            value in
            UIControl().sendAction(Selector("suspend"), to: UIApplication.sharedApplication(), forEvent: nil)
            })
        
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        segment.delegate = self
        
        let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if(status == AVAuthorizationStatus.Authorized) {
            cameraMagic(cameraPosition)
        } else if(status == AVAuthorizationStatus.Denied){
            permissionDenied()
        } else if(status == AVAuthorizationStatus.Restricted){
            // restricted
        } else if(status == AVAuthorizationStatus.NotDetermined){
            // not determined
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {
                granted in
                if(granted){
                    self.cameraMagic(self.cameraPosition)
                } else {
                    print("Not granted access")
                }
            })
        }
        
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
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        self.cameraMagic(position, orientation: orientation)
    }
    
    
    func cameraMagic(position: AVCaptureDevicePosition, orientation: UIInterfaceOrientation){
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: position)
        
        if(videoCamera != nil){
            videoCamera!.outputImageOrientation = orientation
        
            videoCamera?.startCameraCapture()

            for index in 0...(filterList.count - 1){
                videoCamera?.addTarget(self.filterList[index].filter)
                self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            }
        }else{
            var alert = UIAlertController(title: "Error", message: "No camera found", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
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
        
        UIView.animateWithDuration(1.0, delay: 1.0, options: .CurveEaseOut, animations: {
            self.percentLabel.alpha = 0
            }, completion: nil)
           
        for index in 0...(filterList.count - 1){
            
            self.filterList[index].filter.setFloat(Float(percent), forUniformName: "factor")
            if(percent < 100){
                self.filterList[index].setLabelTitle(self.filterList[index].name + " (" + String(percent) + "%)")
            }else{
                self.filterList[index].setLabelTitle(self.filterList[index].name)
            }
        }
    }
    
    func orientationChanged(){
        fitViewsOntoScreen()
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        videoCamera?.outputImageOrientation = orientation
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
