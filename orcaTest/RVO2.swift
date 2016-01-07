//
//  RVO2.swift
//  orcaTest
//
//  Created by SunDance on 12/10/15.
//  Copyright © 2015 SunDance. All rights reserved.
//

import Foundation
let EPSILON = 0.00001
let timeStep = 0.05
let timeHorizon = 0.1
let timeHorizonObst = 5
let maxNeighbors = 10
let maxSpeed = 1.0
let neighborDist = 15.0


extension Agent{
    func linearProgram1(inout lines:[Line],lineNo:Int,radius:Double,optVelocity:Vectors,directionOpt:Bool,inout result:Vectors)->Bool{
        let dotProduct = lines[lineNo].point * lines[lineNo].direction
        let discriminant = dotProduct*dotProduct + radius*radius - lines[lineNo].point.absSq()
        
        if discriminant<0{
            return false
        }
        
        let sqrtDiscriminant = sqrt(discriminant)
        var tleft = -dotProduct - sqrtDiscriminant
        var tright = -dotProduct + sqrtDiscriminant
        
        
        for i in 0..<lineNo{
            let denominator = det(lines[lineNo].direction, b: lines[i].direction)
            let numerator = det(lines[i].direction, b: lines[lineNo].point - lines[i].point)
            
            if abs(denominator) < EPSILON{
                if numerator < 0{
                    return false
                }else{
                    continue
                }
            }
            
            let t = numerator / denominator
            
            if denominator >= 0 {
                tright = min(tright,t)
            }else{
                tleft = max(tleft,t)
            }
            
            if tleft > tright{
                return false
            }
        }
        
        if directionOpt{
            if optVelocity * lines[lineNo].direction > 0{
                result = lines[lineNo].point + lines[lineNo].direction * tright
            }else{
                result = lines[lineNo].point + lines[lineNo].direction * tleft
            }
        }else{
            let t = lines[lineNo].direction * ( optVelocity - lines[lineNo].point)
            
            if t<tleft{
                result = lines[lineNo].point + lines[lineNo].direction * tleft
            }else if t > tright{
                result = lines[lineNo].point + lines[lineNo].direction * tright
            }else{
                result = lines[lineNo].point + lines[lineNo].direction * t
            }
        }
        return true
    }
    
    
    func linearProgram2(inout lines:[Line],radius:Double,optVelocity:Vectors,directionOpt:Bool,inout result:Vectors)->Int{
        
        if directionOpt{
            result = optVelocity * radius
        }else if optVelocity.absSq() > radius*radius{
            result = optVelocity.normalize() * radius
        }else{
            result = optVelocity
        }
        
        for i in 0..<lines.count{
            
            if det(lines[i].direction, b: lines[i].point-result) > 0{
                let tempResult = result
                
                if !linearProgram1(&lines, lineNo: i, radius: radius, optVelocity: optVelocity, directionOpt: directionOpt, result: &result){
                    result = tempResult
                    return i
                }
            }
        }
        
        return lines.count
    }
    
    func linearProgram3(inout lines:[Line],beginLine:Int,radius:Double,inout result:Vectors){
        var distance = 0.0
        
        for i in beginLine..<lines.count{
            
            if det(lines[i].direction, b: lines[i].point - result) > distance{
                
                var projLines = [Line]()
                
                for j in 0..<i{
                    var line = Line()
                    let determinant = det(lines[i].direction, b: lines[j].direction)
                    
                    if abs(determinant) <= EPSILON{
                        if lines[i].direction * lines[j].direction > 0{
                            continue
                        }else{
                            line.point = (lines[i].point + lines[j].point)
                        }
                    }else{
                        line.point = lines[i].point + lines[i].direction * (det(lines[j].direction, b: lines[i].point - lines[j].point) / determinant)
                    }
                    
                    line.direction = (lines[j].direction - lines[i].direction).normalize()
                    projLines+=[line]
                }
                let tempResult = result
                if linearProgram2(&projLines, radius: radius, optVelocity: Vectors(x: -lines[i].direction.y, y: lines[i].direction.x), directionOpt: true, result: &result) < projLines.count{
                    result = tempResult
                    //print("should neverhappen but happens")
                }
                distance = det(lines[i].direction, b: lines[i].point - result)
            }
        }
    }
    
    mutating func computeNewVelocity(agentNeighbors:[Agent]){
        
        var orcaLines = [Line]()
        let invTimeHorizon = 1/timeHorizon
        
        for i in 0..<agentNeighbors.count{
            guard !(agentNeighbors[i].position == position) else {continue}
            
            let relativePosition = agentNeighbors[i].position - position
            let relativeVelocity = velocity - agentNeighbors[i].velocity
            let distSq = relativePosition * relativePosition
            let combinedRadius = radius + agentNeighbors[i].radius
            let combinedRadiusSq = combinedRadius * combinedRadius
            
            var line = Line()
            var u = Vectors()
            
            if distSq > combinedRadiusSq{
                
                let w = relativeVelocity - relativePosition * invTimeHorizon
                
                let wLengthSq = w * w
                let dotProduct1 = w * relativePosition
                
                if dotProduct1 < 0 && dotProduct1 * dotProduct1 > combinedRadiusSq * wLengthSq{
                    let wlength = sqrt(wLengthSq)
                    let unitW = w / wlength
                    
                    line.direction = Vectors(x: unitW.y, y: -unitW.x)
                    u = unitW * ( combinedRadius * invTimeHorizon - wlength)
                }else{
                    
                    let leg = sqrt(distSq - combinedRadiusSq)
                    
                    if det(relativePosition, b: w) > 0 {
                        line.direction = Vectors(x: relativePosition.x * leg - relativePosition.y * combinedRadius, y: relativePosition.x * combinedRadius + relativePosition.y * leg) / distSq
                    }else{
                        line.direction = -Vectors(x: relativePosition.x * leg + relativePosition.y * combinedRadius, y: -relativePosition.x * combinedRadius + relativePosition.y * leg) / distSq
                    }
                    
                    let dotProduct2 = relativeVelocity * line.direction
                    u = line.direction * dotProduct2 - relativeVelocity
                }
            }else{
                
                let invTimeStep = 1 / timeStep
                let w = relativeVelocity - relativePosition * invTimeStep
                
                let wlenth = w.abs()
                let unitW = w / wlenth
                
                line.direction = Vectors(x: unitW.y, y: -unitW.x)
                u = unitW * (combinedRadius * invTimeStep - wlenth)
            }
            
            line.point = velocity + u * 0.5
            orcaLines+=[line]
        }
        
        let linefail = linearProgram2(&orcaLines, radius: maxSpeed, optVelocity: preVelocity, directionOpt: false, result: &newVelocity)
        if linefail < orcaLines.count {
            linearProgram3(&orcaLines, beginLine: linefail, radius: maxSpeed, result: &newVelocity)
        }
        
    }
    
    mutating func update(){
        velocity = newVelocity
        position = position + velocity * timeStep
    }
}