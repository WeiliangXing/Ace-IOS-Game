//
//  ViewController.swift
//  flipEffect
//
//  Created by Weiliang Xing on 6/25/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import UIKit

class FuncViewController: UIViewController {
    
    
    // tiles
//    var tileUp: tileView!
    var tileDown: tileView!
    var tileHighlight: tileView!
    var moveEnd: Bool!
    
    @IBOutlet var timerLabel: UILabel!
    
    // peaking label
    @IBOutlet var peakLabel: UILabel!
    
    
    var flipAction: FlipTileWithBlinkingTimer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var w = 60.0 as CGFloat
        var h = 100.0 as CGFloat
        
        tileDown = tileView(position: CGPoint(x: 0, y: 0), width: w,height: h,cardImage: "King60*100", label: 1)
        
        
        flipAction = FlipTileWithBlinkingTimer(position: CGPointMake(self.view.center.x-w/2, self.view.center.y - h/2),tile: tileDown, timerLabel: timerLabel, peakLabel: peakLabel)
        
        self.view.addSubview(flipAction)
        
        //flipAction.removeFromSuperview()
        
        //add another tileView to show highlight effect
        
        tileHighlight = tileView(position: CGPoint(x: 0, y: self.view.center.y - h/2), width: w,height: h,cardImage: "King60*100", label: 1)
        self.view.addSubview(tileHighlight)
        
        moveEnd = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        
        var touch:UITouch = touches.anyObject() as! UITouch
        // locationInview build the cooridate system based on its paremeter!!!
        // here only related to location, not type
        var touchLocation: CGPoint = touch.locationInView(self.view)
    
        
        flipAction.flipFunc(touchLoc: touchLocation)
        
        
        var startRect: CGRect = tileHighlight.frame
        var touchIn = CGRectContainsPoint(startRect, touchLocation)
        highlight(touchInside: touchIn, tile: tileHighlight)
        
        
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {

        var touch:UITouch = touches.anyObject() as! UITouch
        // locationInview build the cooridate system based on its paremeter!!!
        // here only related to location, not type
        var touchLocation: CGPoint = touch.locationInView(self.view)
        var startRect: CGRect = tileHighlight.frame
        var touchIn = CGRectContainsPoint(startRect, touchLocation)
        
        
        if(touchIn == true){
            var location: CGPoint = touch.locationInView(self.view)
            tileHighlight.center = location
            return
            
        }
        
        
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        moveEnd = true
        var touch:UITouch = touches.anyObject()as!s; UITouch()
        // locationInview build the cooridate system based on its paremeter!!!
        // here only related to location, not type
        var touchLocation: CGPoint = touch.locationInView(self.view)
        var startRect: CGRect = tileHighlight.frame
        var touchIn = CGRectContainsPoint(startRect, touchLocation)
        highlight(touchInside: touchIn, tile: tileHighlight)
        
    }
    
    
    func highlight(#touchInside:CBool, tile: tileView){
        
        let tilePopStartScale: CGFloat = 0.1
        let tilePopMaxScale: CGFloat = 1.1
        let tilePopDelay: NSTimeInterval = 0.02
        let tileExpandTime: NSTimeInterval = 0.09
        let tileContractTime: NSTimeInterval = 0.04       
        
        if(touchInside == true){
            UIView.animateWithDuration(tileExpandTime, delay: tilePopDelay, options: UIViewAnimationOptions.TransitionNone,
                animations: { () -> Void in
                    // Make the tile 'pop'
                    tile.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopMaxScale, tilePopMaxScale))
                },
                completion: { (fished: Bool) -> Void in
                    // Shrink the tile after it 'pops'
                    UIView.animateWithDuration(tileContractTime, animations: { () -> Void in
                        tile.layer.setAffineTransform(CGAffineTransformIdentity)
                        })
                })
        }
    }

}
    