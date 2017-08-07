//
//  Estate.swift
//  PTestMock
//
//  Created by ITP312 on 31/5/17.
//  Copyright © 2017 NYP. All rights reserved.
//

import UIKit

class Estate: NSObject {

    var name : String = ""
    var population : Int = 0
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    
    /* if give value don't need separate init 
     * if optional, know how to rewrite
     var latitude : Double? = 0.0
     
    init(name : String, population : Int, latitude : Double, longitude: Double)
    {
        self.name = name
        self.population = population
        self.latitude = latitude
        self.longitude = longitude
        
        super.init()
    }
     */
}
