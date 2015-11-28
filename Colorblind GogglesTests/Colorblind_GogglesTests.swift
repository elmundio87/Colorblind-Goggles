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
    
    func testGetShaderName() {
        let filterList: [FilterStruct] = [FilterStruct(name: "Normal", shortName: "Norm", shader: "Normal"),
            FilterStruct(name:"Protanopia", shortName: "Pro", shader: "Protanopia"),
            FilterStruct(name:"Deuteranopia", shortName: "Deu", shader: "Deuteranopia"),
            FilterStruct(name:"Tritanopia", shortName:  "Tri", shader: "Tritanopia"),
            FilterStruct(name:"Monochromatic", shortName: "Mono", shader: "Mono")]
        
        let shaderName = ViewController().getShaderName("Pro",filterlist: filterList)
        XCTAssert( shaderName == "Protanopia", shaderName)
        
              
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
