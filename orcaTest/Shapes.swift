//
//  Shapes.swift
//  orcaTest
//
//  Created by SunDance on 12/10/15.
//  Copyright © 2015 SunDance. All rights reserved.
//

import Foundation

struct Line {
    var point = Vectors()
    var direction = Vectors()
}

struct Agent{
    var agentNeighbors = [Agent]()
    var newVelocity = Vectors()
    
    var position = Vectors()
    var velocity = Vectors()
    var preVelocity = Vectors()
    var id = 0
    let radius = 0.3
    var goal = Vectors()
    var walktype = 0
}
extension Agent:Equatable{}
func == (a:Agent,b:Agent)->Bool{
    return a.position == b.position
}