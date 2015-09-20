//
//  ViewController.swift
//  flipEffect
//
//  Created by Weiliang Xing on 6/25/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    // tiles
    var viewOneVisible: Bool!
    var tileUp: tileView!
    var tileDown: tileView!
  //  var touchIn: Bool!
    
    // timer related variables
    var timer: NSTimer!
    @IBOutlet var timerLabel: UILabel!
    var tenseconds: Int!
    var seconds: Int!
    var milseconds: Int!
    var timerMarker: Bool!
    
    var blinkStatus: Bool!
    
    // peaking label
    @IBOutlet var peakLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tile setting
        viewOneVisible = true
        tileUp = tileView(position: CGPointMake(self.view.center.x-40, self.view.center.y - 40), width: 80.0,height: 80.0,cardImage: "what?", label: 0)
        tileDown = tileView(position: CGPointMake(self.view.center.x-40, self.view.center.y - 40), width: 80.0, height: 80.0, cardImage: "what?", label: 1)
      //  touchIn = false
        
        self.view.addSubview(tileUp)
        self.view.addSubview(tileDown)
        self.view.bringSubviewToFront(tileUp)
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        
        var touch:UITouch = touches.anyObject() as! UITouch
        // locationInview build the cooridate system based on its paremeter!!!
        // here only related to location, not type
        var touchLocation: CGPoint = touch.locationInView(self.view)
        
        // flipFunc(tile: tileUp, timerLocal: timer,)
        var startRect: CGRect = tileUp.frame
        var touchIn = CGRectContainsPoint(startRect, touchLocation)
        
        // timerMarker false means no termination during countdown
        if (touchIn == true && timerMarker == false ){
            viewOneVisible = flip(viewOneVisible: self.viewOneVisible, tileUp: tileUp, tileDown: tileDown, flipTime: 0.5, flipDuration: 50)
            
            // timer countdown begins, when to zero, flip back
            timer = NSTimer.scheduledTimerWithTimeInterval( 0.1 , target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            
        }else if (touchIn == true && timerMarker == true){
            
            timerMarker = false
            timer.invalidate()
            timer = nil
            tenseconds = 50
            seconds = tenseconds / 10
            milseconds = tenseconds % 10
            timerLabel.text = NSString(format: "%02d : %02d", seconds, milseconds * 10) as String
            viewOneVisible = false
            viewOneVisible = flip(viewOneVisible: self.viewOneVisible, tileUp: tileUp, tileDown: tileDown, flipTime: 0.5, flipDuration: 50)
        }

    }
    
    
    func flip( #viewOneVisible: Bool, tileUp: tileView, tileDown: tileView, flipTime: Double, flipDuration: Int) -> Bool{
        
        var viewVisible = viewOneVisible
        
        tenseconds = flipDuration

        if( viewVisible){
            self.view.addSubview(tileDown)
            self.view.bringSubviewToFront(tileUp)
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
            self.view.addSubview(tileUp)
            self.view.bringSubviewToFront(tileDown)
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
            timerLabel.text = NSString(format: "%02d : %02d", seconds, milseconds as Stringonds * 10)
            
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
            viewOneVisible = flip(viewOneVisible: self.viewOneVisible, tileUp: tileUp, tileDown: tileDown, flipTime: 0.5, flipDuration: 50)
        }
        
    }


}

