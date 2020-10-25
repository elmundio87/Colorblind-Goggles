//
//  Normal.swift
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 24/10/2020.
//  Copyright © 2020 Edmund Dipple. All rights reserved.
//

import Metal
import BBMetalImage

public class ColourBlindFilter: BBMetalBaseFilter {
   
    public var percent: Float
    public var shader: String
    
    public init(percent: Float = 100, shader: String = "Normal") {
        self.percent = percent
        self.shader = shader
        super.init(kernelFunctionName: shader.lowercased(), useMainBundleKernel: true)
    }
    
    public override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
        encoder.setBytes(&percent, length: MemoryLayout<Float>.size, index: 0)
    }
}
