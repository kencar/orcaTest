import Foundation
let epsilon = 0.00001
let timeStep = 0.25
let Vector = VectorFunc()

extension Agent{
    func linearProgram1(lines:[Line],lineNo:Int,radius:Double,optVelocity:Vectors,directionOpt:Bool,inout preferResult:Vectors)->Bool{
        
        let dotProduct = lines[lineNo].point * lines[lineNo].direction
        let discriminant = dotProduct*dotProduct + radius*radius - Vector.absSq(lines[lineNo].point)
        if discriminant < 0 {
            return false
        }
        let sqrtDiscriminant = sqrt(discriminant)
        var tLeft = -dotProduct - sqrtDiscriminant
        var tRight = -dotProduct + sqrtDiscriminant
        for i in 0..<lineNo{
            let denominator = Vector.det(lines[lineNo].direction, b: lines[i].direction)
            let numerator = Vector.det(lines[i].direction, b: lines[lineNo].point - lines[i].point)
            if fabs(denominator)<epsilon{
                if numerator < 0{
                    return false
                }else{
                    continue
                }
            }
            let t = numerator / denominator
            if denominator>=0{
                tRight = min(tRight, b: t)
            }else{
                tLeft = max(tLeft, b: t)
            }
            if tLeft > tRight{
                return false
            }
        }
        if directionOpt{
            if optVelocity * lines[lineNo].direction > 0{
                preferResult.set(lines[lineNo].point + lines[lineNo].direction * tRight)
            }else{
                preferResult.set(lines[lineNo].point + lines[lineNo].direction * tLeft)
            }
        }else{
            let t = lines[lineNo].direction * (optVelocity - lines[lineNo].point)
            if t < tLeft{
                preferResult.set(lines[lineNo].point + lines[lineNo].direction * tLeft)
            }else if t > tRight{
                preferResult.set(lines[lineNo].point + lines[lineNo].direction * tRight)
            }else{
                preferResult.set(lines[lineNo].point + lines[lineNo].direction * t)
            }
        }
        return true
    }
    func linearProgram2(lines:[Line],radius:Double,optVelocity:Vectors,directionOpt:Bool,inout preferResult:Vectors)->Int{
        
        if directionOpt{
            preferResult.set(optVelocity * radius)
        }else if Vector.absSq(optVelocity)>radius*radius{
            preferResult.set(Vector.normalize(optVelocity) * radius)
        }else{
            preferResult.set(optVelocity)
        }
        for i in 0..<lines.count{
            if Vector.det(lines[i].direction, b: lines[i].point - preferResult)>0{
                let tempResult = Vectors(x: preferResult.x, y: preferResult.y)
                let go:Bool
                go=linearProgram1(lines, lineNo: i, radius: radius, optVelocity: optVelocity, directionOpt: directionOpt, preferResult: &preferResult)
                if !go{
                    preferResult.set(tempResult)
                    return i
                }
            }
        }
        return lines.count
    }
    func linearProgram3(lines:[Line],numObstLines:Int,beginLine:Int,radius:Double,inout preferResult:Vectors){
        
        var distance:Double = 0.0
        for i in beginLine..<lines.count{
            if Vector.det(lines[i].direction, b: lines[i].point - preferResult)>distance{
                var projLines = [Line]()
                
                for j in numObstLines..<i{
                    var line = Line()
                    let determinant = Vector.det(lines[i].direction, b: lines[j].direction)
                    if fabs(determinant) < epsilon{
                        if lines[i].direction * lines[j].direction>0{
                            continue
                        }else{
                            line.point = (lines[i].point + lines[j].point) * 0.5
                        }
                    }else{
                        line.point = lines[i].point + lines[i].direction * (Vector.det(lines[j].direction, b: lines[i].point - lines[j].point) / determinant)
                    }
                    line.direction = Vector.normalize(lines[j].direction - lines[i].direction)
                    projLines.append(line)
                }
                let tempResult = Vectors(x: preferResult.x, y: preferResult.y)
                // 这个不应该发生，但是次次都发生了
                let go:Int
                go=linearProgram2(projLines, radius: radius, optVelocity: Vectors(x: -lines[i].direction.y,y: lines[i].direction.x), directionOpt: true, preferResult: &preferResult)
                if go < projLines.count{
                    preferResult.set(tempResult)
                    print("happen")
                }
                
                distance = Vector.det(lines[i].direction, b: lines[i].point - preferResult)
            }
        }
    }
    mutating func computeNewVelocity(agentNeighbors:[Agent]){
        let numObstLines = 0
        let invTimeHorizon = 1/timeHorizon
        for i in 0..<agentNeighbors.count{
            guard position != agentNeighbors[i].position else {continue}
            let relativePosition = agentNeighbors[i].position - position
            let relativeVelocity = velocity - agentNeighbors[i].velocity
            let distSq = Vector.absSq(relativePosition)
            let combinedRadius = radius + agentNeighbors[i].radius
            let combinedRadiusSq = combinedRadius*combinedRadius
            var line = Line()
            var u = Vectors()
            if distSq > combinedRadiusSq{
                let w = relativeVelocity - relativePosition * invTimeHorizon
                let wLengthSq = Vector.absSq(w)
                let dotProduct1 = w * relativePosition
                if (dotProduct1 < 0) && (dotProduct1*dotProduct1>combinedRadiusSq*wLengthSq){
                    let wLength = sqrt(wLengthSq)
                    let unitW = w / wLength
                    u = unitW * (combinedRadius*invTimeHorizon - wLength)
                    line.direction = Vectors(x: unitW.y, y: -unitW.x)
                    
                }else{
                    let leg = sqrt(distSq-combinedRadius)
                    if Vector.det(relativePosition, b: w)>0{
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
                let wLength = Vector.abs(w)
                let unitW = w / wLength
                line.direction = Vectors(x: unitW.y, y: -unitW.x)
                u = unitW * (combinedRadius * invTimeStep - wLength)
            }
            line.point = velocity + u * 0.5
            orcaLines.append(line)
        }
        let lineFail:Int
        lineFail = linearProgram2(orcaLines, radius: maxSpeed, optVelocity: preVelocity, directionOpt: false, preferResult: &newVelocity)
        if lineFail < orcaLines.count{
            linearProgram3(orcaLines, numObstLines: numObstLines, beginLine: lineFail, radius: maxSpeed, preferResult: &newVelocity)
        }
    }
    mutating func update(){
        velocity = newVelocity
        position = position + velocity * timeStep
        orcaLines.removeAll()
    }
}
