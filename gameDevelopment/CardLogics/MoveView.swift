//
//  MoveView.swift
//  flipEffect
//
//  Created by Weiliang Xing on 6/26/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import Foundation

import UIKit

class MoveView: UIViewController {
    //    // tiles
    var tileDown: tileView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var w = 60.0 as CGFloat
        var h = 100.0 as CGFloat
        
        tileDown = tileView(position: CGPointMake(self.view.center.x-w/2, self.view.center.y - h/2), width: w,height: h,cardImage: "King60*100", label: 1)
        
        // here sets the appearing effect
        //tileDown.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopStartScale, tilePopStartScale))
        self.view.addSubview(tileDown)
        self.view.bringSubviewToFront(tileDown)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        
        var touch:UITouch = touches.anyObject() as! UITouch
        // locationInview build the cooridate system based on its paremeter!!!
        // here only related to location, not type
        var touchLocation: CGPoint = touch.locationInView(self.view)
        var startRect: CGRect = tileDown.frame
        var touchIn = CGRectContainsPoint(startRect, touchLocation)
 
        
        if(touchIn == true){
            var location: CGPoint = touch.locationInView(self.view)
            tileDown.center = location
            return
            
        }
        
        
    }
    
}