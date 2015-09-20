//
//  ViewController.swift
//  flipEffect
//
//  Created by Weiliang Xing on 6/25/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import UIKit

class FlipTileWithBlinkingTimer: UIView {
    
    
//    // tiles
    var tileUp: tileView!
    var tileDown: tileView!
    
    
    // flip related variable
    var viewOneVisible: Bool!
    
    // timer related variables
    var timer: NSTimer!
    var timerLabel: UILabel!
    var tenseconds: Int!
    var seconds: Int!
    var milseconds: Int!
    var timerMarker: Bool!
    
    var blinkStatus: Bool!
    
    // peaking label
    var peakLabel: UILabel!
    
    
    init(position:CGPoint, tile: tileView, timerLabel: UILabel, peakLabel: UILabel){
        
        var width = tile.frame.size.width
        var height = tile.frame.size.height
        
        super.init(frame: CGRectMake(position.x, position.y, width, height))
        
        // tile setting
        tileUp = tileView(position: CGPoint(x: 0, y: 0), width: width,height: height, cardImage: "cardBack60*100", label: 0)
        tileDown = tile
        
        
        addSubview(tileUp)
        addSubview(tileDown)
        bringSubviewToFront(tileUp)
        
        
        self.timerLabel = timerLabel
        self.peakLabel = peakLabel

        // flip related setting
        viewOneVisible = true
        
        // timer setting : 5 seconds for reading the down side, then flip back
        tenseconds = 50
        seconds = tenseconds / 10
        milseconds = tenseconds % 10
        
        timerLabel.text = NSString(format: "%02d : %02d", seconds, milseconds) as String
        timerMarker = false
        // blinking effect
        blinkStatus = false
        
        //peaking label
        peakLabel.hidden = true
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func flipFunc(#touchLoc: CGPoint){
        
        //here must be self.frame to activate the touch.
        var startRect: CGRect = self.frame
        var touchIn = CGRectContainsPoint(startRect, touchLoc)
        //println(startRect)
        //println(touchLoc)
        // timerMarker false means no termination during countdown
        if (touchIn == true && timerMarker == false ){
            viewOneVisible = flip(viewOneVisible: self.viewOneVisible, tileUp: tileUp, tileDown: tileDown, flipTime: 0.2, flipDuration: 50)
            
            // timer countdown begins, when to zero, flip back
            timer = NSTimer.scheduledTimerWithTimeInterval( 0.1 , target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            
        }else if (touchIn == true && timerMarker == true){
            
            timerMarker = false
            timer.invalidate()
            timer = nil
            tenseconds = 50
            seconds = tenseconds / 10
            milseconds = tenseconds % 10
            timerLabel.text = NSString(format: "%02d : %02d", seconds, milseconds as Stringonds * 10)
            viewOneVisible = false
            viewOneVisible = flip(viewOneVisible: self.viewOneVisible, tileUp: tileUp, tileDown: tileDown, flipTime: 0.2, flipDuration: 50)
        }
    }
    
    
    func flip( #viewOneVisible: Bool, tileUp: tileView, tileDown: tileView, flipTime: Double, flipDuration: Int) -> Bool{
        
        var viewVisible = viewOneVisible
        
        tenseconds = flipDuration
        
        if( viewVisible){
            addSubview(tileDown)
            bringSubviewToFront(tileUp)
            UIView.transitionWithView(tileUp, duration: flipTime, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: {
                //self.tileUp.removeFromSuperview()
                //self.view.addSubview(self.tileDown)
                UIView.transitionWithView(self.tileDown, duration: flipTime, options: UIViewAnimationOptions.TransitionFlipFromRight,
                    animations: {
                        self.tileUp.hidden = true
                        self.tileDown.hidden = false
                        //self.tileUp.removeFromSuperview()
                    },
                    completion: nil)
                }, completion: {(fished: Bool) -> Void in
                    
                    self.tileUp.removeFromSuperview()
                })
            viewVisible = !viewVisible
            peakLabel.hidden = false
            
            return viewVisible
            
        }else {
            
            // UIView tileUp will remain, while tileDown will be removed.
            addSubview(tileUp)
            bringSubviewToFront(tileDown)
            UIView.transitionWithView(tileDown, duration: flipTime, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
                UIView.transitionWithView(self.tileUp, duration: flipTime, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
                    self.tileUp.hidden = false
                    self.tileDown.hidden = true
                    }, completion: nil)
                }, completion: {(fished: Bool) -> Void in
                    self.tileDown.removeFromSuperview()
                })
            viewVisible = !viewVisible
            peakLabel.hidden = true
            return viewVisible
        }
        
    }
    
    
    // timer related update function
    func update(){
        //println(seconds)
        
        
        if(tenseconds > 0) {
            timerMarker = true
            tenseconds = tenseconds - 1
            seconds = tenseconds / 10
            milseconds = tenseconds % 10
            timerLabel.text = NSString(format: "%02d : %02d", seconds, milseconds * 10) as String
            
            if(seconds > 1) {
                if(blinkStatus == false){
                    timerLabel.textColor = UIColor.blackColor()
                    blinkStatus = true
                }
                else if(tenseconds % 10 == 0) {
                    timerLabel.textColor = UIColor.redColor()
                    blinkStatus = false
                }
            }else{
                if(blinkStatus == false){
                    timerLabel.textColor = UIColor.blackColor()
                    blinkStatus = true
                }
                else {
                    timerLabel.textColor = UIColor.redColor()
                    blinkStatus = false
                }
            }
            
            
            
        } else{
            timerMarker = false
            viewOneVisible = false
            timer.invalidate()
            timer = nil
            tenseconds = 50
            seconds = tenseconds / 10
            milseconds = tenseconds % 10
            timerLabel.text = NSString(format: "%02d : %02d", seconds, milseconds as Stringonds * 10)
            viewOneVisible = flip(viewOneVisible: self.viewOneVisible, tileUp: tileUp, tileDown: tileDown, flipTime: 0.2, flipDuration: 50)
        }
        
    }
    
    
}


