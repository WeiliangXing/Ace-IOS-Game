//
//  Card.swift
//  flipEffect
//
//  Created by Weiliang Xing on 6/27/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import Foundation
import UIKit

class Card: UIView{
    var position: CGPoint!
    var width, height: CGFloat!
    
    var ShowTimerAndLabel: Bool!
    
    
    let originCenter:CGPoint!
    var preCenter: CGPoint!
    
    var frontCard: SubCard!
    var backCard: SubCard!
    
    // set front portriat
    var setFront: Bool!
    
    
    var flipTime: Double
    
    var timer: NSTimer!
    var timerLabel: UILabel!
    var tenseconds: Int!
    var seconds: Int!
    var milseconds: Int!
    var timerMarker: Bool!
    
    var uniqueMarker: Bool!
    
    var blinkStatus: Bool!
    
    var cardName: String!
    
    //for test: determine whether timer ends
    //var timerEnds: Bool!
    
    // determine which kind of flip function
    var flipKind: String!
    var isPlayerA: Bool!
    
    
    init(cardImage: String, position:CGPoint, width: CGFloat, height: CGFloat) {
        
        flipTime = 1.0
        
        super.init(frame: CGRectMake(position.x, position.y, width, height))
        self.position = position
        self.width = width
        self.height = height
        
        frontCard = SubCard(cardImage: cardImage, position: CGPoint(x : 0.0, y : 0.0), width: width, height: height)
        backCard = SubCard(cardImage: "cardBack60*100", position: CGPoint(x : 0.0, y : 0.0), width: width, height: height)
        addSubview(frontCard)
        addSubview(backCard)
        setFront = true
        var originCenterX = self.center.x
        var originCenterY = self.center.y
        originCenter = CGPoint(x:originCenterX, y:originCenterY)
        preCenter = originCenter
        
        ShowTimerAndLabel = true
        //timerEnds = true
        
        timerMarker = false
        
        uniqueMarker = true
        
        cardName = cardImage
        
        flipKind = ""
        
    }
    
    func getCardName() -> String{
        return cardName
    }
    
    func previousCenter(center: CGPoint){
        self.preCenter = center
    }
    
    func  setFrontCard(#setFront: Bool){
        self.setFront = setFront
        if(self.setFront == true){
            bringSubviewToFront(backCard)
        }else{
            bringSubviewToFront(frontCard)
        }
    }
    
    func setTimer(#Label: UILabel){
        // timer setting : 5 seconds for reading the down side, then flip back
        tenseconds = 50
        timerLabel = Label
        
        setNewTimer(tenseconds)
        
        timerMarker = false
        // blinking effect
        blinkStatus = false
    }
    
    func setNewTimer(leftseconds: Int){
        seconds = leftseconds / 10
        milseconds = leftseconds % 10
        timerLabel.text = NSString(format: "%02d : %02d", seconds, milseconds * 10)
        timerLabel.textColor = UIColor.blackColor()
        
        
    }
    
    func flipCard(#auto: Bool, label: UILabel?){
        if(auto == false){
            // for future peaking flipping
            //generate timer and label
            flipFunc(label: label!)
        }else{
            // only for future auto flip
            setFront =  flip(viewOneVisible: setFront, flipTime: 0.5)
        }
    }
    
    func flipFunc(#label: UILabel){
        // prepared for termination before count down finished.
        if (timerMarker == false ){
            setTimer(Label: label)
            setFront = flip(viewOneVisible: setFront,flipTime: 0.2)
            
            // timer countdown begins, when to zero, flip back
            timer = NSTimer.scheduledTimerWithTimeInterval( 0.1 , target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            timerMarker = true
            
            
        }else {
            timerMarker = false
            uniqueMarker = false
            timer.invalidate()
            timer = nil
            tenseconds = 50
            setNewTimer(tenseconds)
            //setFront = false
            setFront = flip(viewOneVisible: setFront, flipTime: 0.2)
            // for stage1: who play first (default:A)
            self.isPlayerA = !self.isPlayerA
            
            // pass the natural termination to global variable
            dataManager.dataIsPlayerA = self.isPlayerA
            dataManager.didBlindTakeEnd = self.isPlayerA
            dataManager.didBlindSwapEnd = self.isPlayerA
            
        }
    }
    
    
    
    // timer related update function
    func update(){
        if(tenseconds > 0) {
            //timerEnds = false
            
            timerMarker = true
            tenseconds = tenseconds - 1
            
            setNewTimer(tenseconds)
            
            if(seconds > 1) {
                if(blinkStatus == false){
                    timerLabel.textColor = UIColor.blackColor()
                    blinkStatus = true
                }
                else if(tenseconds % 10 == 0) {
                    //timerLabel.textColor = UIColor.redColor()
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
            //timerEnds = true
            timerMarker = false
            uniqueMarker = false
            //setFront = false
            timer.invalidate()
            timer = nil
            tenseconds = 50
            setNewTimer(tenseconds)
            setFront = flip(viewOneVisible: setFront,flipTime: 0.2)
            self.isPlayerA = !self.isPlayerA
            
            // pass the natural termination to global variable
            dataManager.dataIsPlayerA = self.isPlayerA
            dataManager.didBlindTakeEnd = self.isPlayerA
            dataManager.didBlindSwapEnd = self.isPlayerA
        }
        
    }
    
    func stopTimer(){
        if(timer){
            timer.invalidate()
            timer = nil
            tenseconds = 50
            setNewTimer(tenseconds)
        }
    }
    
    func flip(#viewOneVisible: Bool, flipTime: Double) ->  Bool{
        var viewVisible = viewOneVisible
        if( viewVisible){
            //addSubview(self.frontCard)
            bringSubviewToFront(self.backCard)
            UIView.transitionWithView(self.backCard, duration: flipTime, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: {
                //self.tileUp.removeFromSuperview()
                //self.view.addSubview(self.tileDown)
                UIView.transitionWithView(self.frontCard, duration: flipTime, options: UIViewAnimationOptions.TransitionFlipFromRight,
                    animations: {
                        self.backCard.hidden = true
                        self.frontCard.hidden = false
                        //self.tileUp.removeFromSuperview()
                    },
                    completion: nil)
                }, completion: {(fished: Bool) -> Void in
                    
                    //self.backCard.removeFromSuperview()
                })
            viewVisible = !viewVisible
            //peakLabel.hidden = false
            
            return viewVisible
            
        }else {
            
            // UIView tileUp will remain, while tileDown will be removed.
            //addSubview(self.backCard)
            bringSubviewToFront(self.frontCard)
            UIView.transitionWithView(self.frontCard, duration: flipTime, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
                UIView.transitionWithView(self.backCard, duration: flipTime, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
                    self.backCard.hidden = false
                    self.frontCard.hidden = true
                    }, completion: nil)
                }, completion: {(fished: Bool) -> Void in
                    
                    
                    // init peaking procedure
                    if(self.flipKind == "stage1"){
                        // for stage 1, remove the peak card from the peaking location
                        UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
                            self.center = CGPoint(x: self.center.x + 60, y: self.center.y)
                            }, completion: {(Bool) -> Void in
                                self.removeFromSuperview()
                            })
                    }
                    // blind take peaking procedure
                    if(self.flipKind == "blindTake"){
                        UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
                            self.center = CGPoint(x: self.center.x + 60, y: self.center.y)
                            }, completion: {(Bool) -> Void in
                                self.removeFromSuperview()
                            })
                    }
                    
                    // blind Swap peaking procedure
                    if(self.flipKind == "blindSwap"){
                        UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
                            self.center = CGPoint(x: self.center.x + 60, y: self.center.y)
                            }, completion: {(Bool) -> Void in
                                self.removeFromSuperview()
                            })
                    }
                    
                })
            viewVisible = !viewVisible
            //peakLabel.hidden = true
            
            return viewVisible
        }
        
    }
    
    
    
    // by pressing the card,  the card could be highlighted
    func highlight(){
        
        let tilePopStartScale: CGFloat = 0.1
        let tilePopMaxScale: CGFloat = 1.1
        let tilePopDelay: NSTimeInterval = 0.02
        let tileExpandTime: NSTimeInterval = 0.09
        let tileContractTime: NSTimeInterval = 0.04
        
        UIView.animateWithDuration(tileExpandTime, delay: tilePopDelay, options: UIViewAnimationOptions.TransitionNone,
            animations: { () -> Void in
                // Make the tile 'pop'
                self.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopMaxScale, tilePopMaxScale))
            },
            completion: { (fished: Bool) -> Void in
                // Shrink the tile after it 'pops'
                UIView.animateWithDuration(tileContractTime, animations: { () -> Void in
                    self.layer.setAffineTransform(CGAffineTransformIdentity)
                    })
            })
    }
    
    func frameHighlight(){
        var targetFrame = SubCard(cardImage: "frameHighlight", position: CGPoint(x: 0, y: 0), width: width, height: height)
        self.addSubview(targetFrame)
        
        let tilePopStartScale: CGFloat = 0.1
        let tilePopMaxScale: CGFloat = 1.1
        let tilePopDelay: NSTimeInterval = 0.02
        let tileExpandTime: NSTimeInterval = 0.2
        let tileContractTime: NSTimeInterval = 0.1
        
        UIView.animateWithDuration(tileExpandTime, delay: tilePopDelay, options: UIViewAnimationOptions.TransitionNone,
            animations: { () -> Void in
                // Make the tile 'pop'
                targetFrame.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopMaxScale, tilePopMaxScale))
            },
            completion: { (fished: Bool) -> Void in
                // Shrink the tile after it 'pops'
                UIView.animateWithDuration(tileContractTime, animations: { () -> Void in
                    targetFrame.layer.setAffineTransform(CGAffineTransformIdentity)
                    targetFrame.removeFromSuperview()
                    })
            })
        
        
    }
}


class SubCard: UIView {
    var showLabel: UILabel
    init(cardImage: String, position:CGPoint, width: CGFloat, height: CGFloat) {
        showLabel = UILabel(frame: CGRectMake(0,0, width, height))
        showLabel.textAlignment = NSTextAlignment.Center
        showLabel.minimumScaleFactor = 0.5
        showLabel.numberOfLines = 2
        
        super.init(frame: CGRectMake(position.x, position.y, width, height))
        
        //set the card front image
        backgroundColor = UIColor(patternImage:(UIImage(named: cardImage)))
        
    }
    
    func addShowLabel(text: String){
        showLabel.text = text
        addSubview(showLabel)
    }
}