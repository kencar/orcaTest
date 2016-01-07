//
//  QuadTree.swift
//  orcaTest
//
//  Created by SunDance on 12/9/15.
//  Copyright © 2015 SunDance. All rights reserved.
//

import Foundation
let maxchild = 4

class QuadTree {
    private var nw: QuadTree? = nil
    private var ne: QuadTree? = nil
    private var sw: QuadTree? = nil
    private var se: QuadTree? = nil
    private let region : Rect
    private var child : [Agent]
    init(region:Rect){
        self.region = region
        child = []
    }
}

extension QuadTree{
    private func subdivide(){
        let x = region.origin.x
        let y = region.origin.y
        let size = region.size * 0.5
        nw = QuadTree(region: Rect(origin: Vectors(x: x, y: y), size: size))
        ne = QuadTree(region: Rect(origin: Vectors(x: x+size.x, y: y), size: size))
        sw = QuadTree(region: Rect(origin: Vectors(x: x, y: y+size.y), size: size))
        se = QuadTree(region: Rect(origin: Vectors(x: x+size.x, y: y+size.y), size: size))
    }
    func insert(a:Agent)->Bool{
        if !region.containsPoint(a.position){
            return false
        }
        if child.count<maxchild{
            child+=[a]
            return true
        }
        if nw == nil{
            subdivide()
        }
        if nw!.insert(a){
            return true
        }
        if ne!.insert(a){
            return true
        }
        if sw!.insert(a){
            return true
        }
        if se!.insert(a){
            return true
        }
        return false
    }
    func pointsInRect(rect:Rect)->[Agent]{
        var p = [Agent]()
        if !region.interSectsRect(rect){
            return p
        }
        for a in child{
            if rect.containsPoint(a.position){
                p+=[a]
            }
        }
        if nw==nil{
            return p
        }
        p += nw!.pointsInRect(rect)
        p += ne!.pointsInRect(rect)
        p += sw!.pointsInRect(rect)
        p += se!.pointsInRect(rect)
        return p
    }
    func description(){
        print(region.origin)
        
        if !(nw==nil){
            nw!.description()
            ne!.description()
            sw!.description()
            se!.description()
        }
    }
}
