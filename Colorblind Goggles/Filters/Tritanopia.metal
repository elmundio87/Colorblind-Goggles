//
//  Tritanopia.metal
//  Colorblind Goggles
//
//  Created by Edmund Dipple on 19/10/2020.
//  Copyright © 2020 Edmund Dipple. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void tritanopia(texture2d<half, access::write> outputTexture [[texture(0)]],
                                 texture2d<half, access::read> inputTexture [[texture(1)]],
                                 constant float *percent [[buffer(0)]],
                                 uint2 gid [[thread_position_in_grid]]) {
    
    if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
    
    const half4 inColor = inputTexture.read(gid);

    float R;
    float G;
    float B;
    float L;
    float M;
    float S;
    
    float Smax;
    float Smin;
    float Srange;
    
    R = float(inColor.r);
    G = float(inColor.g);
    B = float(inColor.b);
    
    L = (17.8824 * (R)) + (43.5161 * (G)) + (4.11935 * (B));
    S = (0.0299566 * (R)) + (0.184309 * (G)) + (1.46709 * (B));
    
    Smax = (3.45565 * (R)) + (27.1554 * (G)) + (3.86714 * (B));
    Smin = (0.494207 * (L)) + (1.24827 * (S));
    Srange = (Smax - Smin)/100.00;
    M = Smax - (Srange * *percent);
    
    R = (0.080944 * (L)) - (0.130504 * (M)) + (0.116721 * (S));
    G = (-0.0102485 * (L)) + (0.0540194 * (M)) - (0.113615 * (S));
    B = (-0.000365294 * (L)) - (0.00412163 * (M)) + (0.693513 * (S));
    
    const half4 outColor = half4(R,G,B,1);
    outputTexture.write(outColor, gid);
}

