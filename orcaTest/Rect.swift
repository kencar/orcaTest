//
//  Rect.swift
//  orcaTest
//
//  Created by SunDance on 12/9/15.
//  Copyright © 2015 SunDance. All rights reserved.
//

import Foundation
extension Vectors:Comparable{}
func < (a:Vectors,b:Vectors)->Bool{
    return a.x < b.x && a.y < b.y
}
func <= (a:Vectors,b:Vectors)->Bool{
    return a.x <= b.x && a.y <= b.y
}
struct Rect {
    var origin = Vectors()
    var size = Vectors()
    var middlePoint:Vectors {return size*0.5+origin}
}
extension Rect{
    func containsPoint(point:Vectors)->Bool{
        let x = point <= size + origin
        let y = origin < point
        return x && y
    }
    func interSectsRect(b:Rect)->Bool{
        return Rect(origin: origin-b.size*0.5, size: size+b.size).containsPoint(b.middlePoint)
    }
}
