//
//  ViewController.swift
//  orcaTest
//
//  Created by SunDance on 12/8/15.
//  Copyright © 2015 SunDance. All rights reserved.
//

import Cocoa

var agents = [Agent]()
var thisAgent = Agent()
var thatAgent = Agent()
let amplifyNumber:CGFloat = 20

class MyView:NSView {
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        let contexts = NSGraphicsContext.currentContext()!.CGContext
        for c in agents{
            drawAgent(contexts, agents: c)
        }
//        drawAgent(contexts, agents: thisAgent)
//        drawAgent(contexts, agents: thatAgent)
    }
    final func drawAgent(context:CGContextRef ,agents:Agent){
        CGContextBeginPath(context)
        if agents.walktype == 1{
            CGContextSetFillColorWithColor(context, NSColor.blueColor().CGColor)
        }else{
            CGContextSetFillColorWithColor(context, NSColor.greenColor().CGColor)
        }
        
        CGContextAddArc(context, CGFloat(agents.position.x)*amplifyNumber, CGFloat(agents.position.y)*amplifyNumber, CGFloat(agents.radius)*amplifyNumber, CGFloat(0.0), CGFloat(2 * M_PI), 0)
        CGContextFillPath(context)
    }
}
class MyViewController: NSViewController {

    @IBOutlet var simview: MyView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        setTimer()
        for i in 0...49{
            var a = Agent()
            a.velocity = Vectors(x: 1, y: 0)
            //a.goal = Vectors(x: Double(i/5), y: Double(i%5) * 0.8)
            a.preVelocity = Vectors(x: 1, y: 0)
            a.position = Vectors(x: Double(i/5)+10, y: Double(i%5) * 0.8 + 10)
            a.id = i
            a.walktype = 0
            agents+=[a]
            
        }
        for i in 0...49{
            var a = Agent()
            a.velocity = Vectors(x: -1, y: 0)
            a.preVelocity = Vectors(x: -1, y: 0)
            a.id = i+50
            //a.goal = Vectors(x: 1.5, y: Double(51-i) * 0.8)
            a.position = Vectors(x: Double(i/5)+30, y: Double(i%5) * 0.8 + 10)
            
            a.walktype = 1
            agents+=[a]
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)){

            while agents.count>0{
                let qtree = QuadTree(region: Rect(origin: Vectors(x: 0, y: 0), size: Vectors(x: 120, y: 120)))
                for a in agents{
                    qtree.insert(a)
                }
                for i in 0..<agents.count{
                    let p = qtree.pointsInRect(Rect(origin: agents[i].position-Vectors(x: 1, y: 1), size: Vectors(x: 2, y: 2)))
                    agents[i].computeNewVelocity(p)
                }
                for i in 0..<agents.count{
                    agents[i].update()
                    if agents[i].walktype == 0 && agents[i].position.x>33{
                        agents[i].position.x = 15
                    }
                    if agents[i].walktype == 1 && agents[i].position.x<17{
                        agents[i].position.x = 35
                    }
                    
                }
            }
        }
        
        
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    final func refresh(){//刷新UI
        simview.needsDisplay=true
    }
    
    final func setTimer(){//定时刷新
        _ = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("refresh"), userInfo: nil, repeats: true)
    }

}
