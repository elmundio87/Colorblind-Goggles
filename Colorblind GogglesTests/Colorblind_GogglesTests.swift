//
//  Colorblind_GogglesTests.swift
//  Colorblind GogglesTests
//
//  Created by Edmund Dipple on 26/11/2015.
//  Copyright © 2015 Edmund Dipple. All rights reserved.
//

import XCTest
@testable import Colorblind_Goggles

class Colorblind_GogglesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRGBShouldNotOutputInvalidValues() {
        
        let filter: ColourblindFilter = ColourblindFilter()
        
        for inR in 0...255
        {
            for inG in 0...255
            {
                for inB in 0...255
                {
                    let (r,g,b) = filter.FilterColour(R: Double(inR), G: Double(inG), B: Double(inB), f: ColourblindFilter.FilterType.Monochromatic)
                    XCTAssert(r <= 255 && r >= 0)
                    XCTAssert(g <= 255 && g >= 0)
                    XCTAssert(b <= 255 && b >= 0)
                }
            }
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
