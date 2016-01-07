//
//  Vectors.swift
//  orcaTest
//
//  Created by SunDance on 12/10/15.
//  Copyright © 2015 SunDance. All rights reserved.
//

import Foundation

struct Vectors {
    var x:Double
    var y:Double
    init(x:Double,y:Double){
        self.x=x
        self.y=y
    }
    init(){
        self.init(x:0,y:0)
    }
    
}
extension Vectors{
    func absSq()->Double{
        return self * self
    }
    func abs()->Double{
        return sqrt(self * self)
    }
    func normalize()->Vectors{
        return self / (self * self)
    }
}
extension Vectors : Equatable{}

func == (a:Vectors,b:Vectors)->Bool{
    return a.x==b.x&&a.y==b.y
}
func + (left:Vectors,right:Vectors)->Vectors{
    return Vectors(x: left.x+right.x, y: left.y+right.y)
}
func - (left:Vectors,right:Vectors)->Vectors{
    return Vectors(x: left.x-right.x, y: left.y-right.y)
}
func * (left:Vectors,right:Vectors)->Double{
    return left.x*right.x+left.y*right.y
}
func * (left:Vectors,right:Double)->Vectors{
    return Vectors(x: left.x*right, y: left.y*right)
}
func / (left:Vectors,right:Double)->Vectors{
    return Vectors(x: left.x/right, y: left.y/right)
}
prefix func - (left:Vectors)->Vectors{
    return Vectors(x: -left.x, y: -left.y)
}

func det(a:Vectors,b:Vectors)->Double{
    return a.x*b.y-a.y*b.x
}
