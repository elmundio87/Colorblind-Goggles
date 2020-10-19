//
//  Normal.metal
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 19/10/2020.
//  Copyright © 2020 Edmund Dipple. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


kernel void normal(texture2d<half, access::write> outputTexture [[texture(0)]],
                                 texture2d<half, access::read> inputTexture [[texture(1)]],
                                 constant float *percent [[buffer(0)]],
                                 uint2 gid [[thread_position_in_grid]]) {
    
    if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
    
    outputTexture.write(inputTexture.read(gid), gid);
}
