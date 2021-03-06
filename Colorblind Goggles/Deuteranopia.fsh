precision highp float;
varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform highp float factor;

float minMaxRGB(float val){
    if(val < 0.0)
    {
        return 0.0;
    }
    if(val > 255.0)
    {
        return 255.0;
    }
    return val;
}

void main(){
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    lowp vec4 outputColor;
    
    highp float R;
    highp float G;
    highp float B;
    highp float L;
    highp float M;
    highp float S;
    
    highp float Mmin;
    highp float Mmax;
    highp float Mrange;
    
    R = float(textureColor.r);
    G = float(textureColor.g);
    B = float(textureColor.b);
    
    L = (17.8824 * (R)) + (43.5161 * (G)) + (4.11935 * (B));
    S = (0.0299566 * (R)) + (0.184309 * (G)) + (1.46709 * (B));
    
    Mmax = (3.45565 * (R)) + (27.1554 * (G)) + (3.86714 * (B));
    Mmin = (0.494207 * (L)) + (1.24827 * (S));
    Mrange = (Mmax - Mmin)/100.00;
    M = Mmax - (Mrange * factor);
    
    R = (0.080944 * (L)) - (0.130504 * (M)) + (0.116721 * (S));
    G = (-0.0102485 * (L)) + (0.0540194 * (M)) - (0.113615 * (S));
    B = (-0.000365294 * (L)) - (0.00412163 * (M)) + (0.693513 * (S));
    
    outputColor.r = minMaxRGB(R);
    outputColor.g = minMaxRGB(G);
    outputColor.b = minMaxRGB(B);
    outputColor.a = 1.0;
    
    gl_FragColor = outputColor;
}

