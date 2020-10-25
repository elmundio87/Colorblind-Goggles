//
//  Normal.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 24/10/2020.
//  Copyright © 2020 Edmund Dipple. All rights reserved.
//

import Metal
import BBMetalImage

public class DummyFilter: BBMetalBaseFilter {
   
    public var percent: Float
    
    public init(percent: Float = 1) {
        self.percent = percent
        super.init(kernelFunctionName: "dummy",useMainBundleKernel: true)
    }
    
    public override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
        encoder.setBytes(&percent, length: MemoryLayout<Float>.size, index: 0)
    }
}
