//
//  AboutController.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 01/12/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import UIKit

class AboutController: UIViewController  {
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBAction func clickedCloseButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
}