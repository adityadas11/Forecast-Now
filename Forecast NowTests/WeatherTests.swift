//
//  WeatherTests.swift
//  Forecast NowTests
//
//  Created by Adi on 3/17/20.
//  Copyright © 2020 Adi. All rights reserved.
//

import Foundation
import XCTest
@testable import Forecast_Now

class WeatherTests : XCTestCase{
    
    func testDateFormat(){
        let dummyVC = ViewController()
        //true case
        XCTAssertEqual(dummyVC.getDate(epoch:1584434362 ), "Tuesday, March 17")
       //false case
        XCTAssertNotEqual(dummyVC.getDate(epoch:1584434362 ), "Tuesday, March 16")
        XCTAssertNotEqual(dummyVC.getDate(epoch:1584434362 ), "Tuesday, March 17 2020")
        
        
       
    }
    
}
