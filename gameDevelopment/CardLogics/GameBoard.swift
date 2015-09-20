//
//  GameBoard.swift
//  flipEffect
//
//  Created by Weiliang Xing on 6/29/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import Foundation
import UIKit

class GameBoard: UIView {
    
    var playerALeftScene:SubCard!
    var playerAMidScene:SubCard!
    var playerARightScene:SubCard!
    var playerBLeftScene:SubCard!
    var playerBMidScene:SubCard!
    var playerBRightScene:SubCard!
    var initPileScene:SubCard!
    var remainPileScene:SubCard!
    var playerAPeakScene:SubCard!
    var playerBPeakScene:SubCard!
    
    let cardCenter: Dictionary<String,CGPoint>!
    let peakCenter:Dictionary<String, CGPoint>!
    //let centerName:Dictionary<String, SubCard>!
    let cardScene: [SubCard]!
    let peakScene: [SubCard]!
    
    // location title  for  none-pile locations
    let locTitle: [String]!
    
    //very important: store the location  of the card
    // dictionary's key must be hashable
    // here below dictionary indicates each location reponds only to one card, so
    // be careful when dealing with piles
    var cardStoreLoc: Dictionary<String, Card>
    
    // for two piles data storage
    var initPileLoc: [Card] = []
    var remainPileLoc: [Card] = []

    var trackCard: Card!
    var trackBool: Bool!
    var correspondingCard: [Card]
    var correspondingTrackCard: String!
    
    // the moving card in hand
    var cardInHand: Card!
    var cardFrontInHand: Bool!
    
    // judge the card on top of remain pile whether front or back
    var frontTopRemain: Bool!
    
    // for card move duration
    var cardMoveTime: Double!
    
    var timerLabel:UILabel!
    var timerLabelA: UILabel!
    var timerLabelB: UILabel!
   // var startButton:UIButton!
    var playerALabel: UILabel!
    var playerBLabel: UILabel!
    
    // order for playing games
    var isPlayerA: Bool!
    
    var didTimerEnd: Bool!
    
    // move success marker
    var isMoveSucceed:Bool!
    
    //timer for each player
    var timer: NSTimer!
    var tenseconds : Int!
    var seconds : Int!
    var milseconds : Int!
    var blinkStatus: Bool!
    
    init(cardImage: String, position:CGPoint, width:CGFloat, height: CGFloat){
        // variable that without ! should initiated before super.init
        cardStoreLoc = Dictionary<String, Card>()
        cardMoveTime = 0.25
        correspondingCard = []
        super.init(frame: CGRectMake(position.x, position.y, width, height))
        backgroundColor = UIColor(patternImage:(UIImage(named: cardImage))!)
        
        //add card scene individually, totolly eight basic locations
        // Up side is playerB, down side is playerA, and the view direction is basedon playerA
        var w:CGFloat = 60.0
        var h: CGFloat = 100.0
        playerBLeftScene = SubCard(cardImage: "CardScene", position: CGPoint(x:250, y: 20), width: w, height: h)
        playerBMidScene = SubCard(cardImage: "CardScene", position: CGPoint(x:170, y: 20), width: w, height: h)
        playerBRightScene = SubCard(cardImage: "CardScene", position: CGPoint(x:90, y: 20), width: w, height: h)
        playerALeftScene = SubCard(cardImage: "CardScene", position: CGPoint(x:10, y: 360), width: w, height: h)
        playerAMidScene = SubCard(cardImage: "CardScene", position: CGPoint(x:90, y: 360), width: w, height: h)
        playerARightScene = SubCard(cardImage: "CardScene", position: CGPoint(x:170, y: 360), width: w, height: h)
        initPileScene = SubCard(cardImage: "CardScene", position: CGPoint(x:170, y: 190), width: w, height: h)
        remainPileScene = SubCard(cardImage: "CardScene", position: CGPoint(x:90, y: 190), width: w, height: h)
        
        playerBPeakScene = SubCard(cardImage: "PeakScene", position: CGPoint(x:10, y: 20), width: w, height: h)
        playerAPeakScene = SubCard(cardImage: "PeakScene", position: CGPoint(x:250, y: 360), width: w, height: h)
        
        //initialize the trackcard in peak area
        trackCard = Card(cardImage: "PeakScene", position: CGPoint(x:250, y: 360), width: w, height: h)
        trackBool = false // indicate that highlight card is not consistent with moving card
        
        timerLabel = UILabel(frame: CGRectMake(240, 200, 60, 30))
        timerLabel.text = "Timer"
        timerLabel.textAlignment = NSTextAlignment.Center
        
        playerALabel = UILabel(frame: CGRectMake(110, 325, 100, 30))
        playerALabel.text = "Player A"
        playerALabel.textAlignment = NSTextAlignment.Center
        
        playerBLabel = UILabel(frame: CGRectMake(110, 125, 100, 30))
        playerBLabel.text = "Player B"
        playerBLabel.textAlignment = NSTextAlignment.Center
        playerBLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        
        // at the first stage, assume top card on top of remain pile is face up
        frontTopRemain = false
        
        isPlayerA = true
        
        didTimerEnd = false
        
//        timerLabelA = UILabel(frame: CGRectMake(260, 328, 60, 30))
//        timerLabelA.text = "ATimer"
//        timerLabelA.textAlignment = NSTextAlignment.Center
//        
//        timerLabelB = UILabel(frame: CGRectMake(260, 122, 60, 30))
//        timerLabelB.text = "BTimer"
//        timerLabelB.textAlignment = NSTextAlignment.Center
        
//        startButton = UIButton(frame: CGRectMake(250, 230, 60, 30))
//        startButton.setTitle("Start", forState: UIControlState.Normal)

        addSubview(playerALeftScene)
        addSubview(playerAMidScene)
        addSubview(playerARightScene)
        addSubview(playerBLeftScene)
        addSubview(playerBMidScene)
        addSubview(playerBRightScene)
        addSubview(initPileScene)
        addSubview(remainPileScene)
        addSubview(playerAPeakScene)
        addSubview(playerBPeakScene)
        
       // addSubview(timerLabel)
//        addSubview(timerLabelA)
//        addSubview(timerLabelB)
     //   addSubview(startButton)
        addSubview(playerALabel)
        addSubview(playerBLabel)
        
        cardScene = [playerALeftScene,playerAMidScene,playerARightScene,playerBLeftScene, playerBMidScene, playerBRightScene, initPileScene, remainPileScene]
        peakScene = [playerAPeakScene, playerBPeakScene]
        
        //center for cardLocation and peakLocation
//        cardCenter = ["ALeft": CGPoint(x:50.0,y:410.0), "AMiddle" : CGPoint(x:130.0,y:410.0), "ARight" : CGPoint(x:210.0,y:410.0),"BLeft" :  CGPoint(x:50.0,y:70.0),"BMiddle"  :  CGPoint(x:130.0,y:70.0),"BRight" : CGPoint(x:210.0,y:70.0),"initPile" : CGPoint(x:210.0,y:240.0), "remainPile": CGPoint(x:130.0,y:240.0)]
//        peakCenter = ["APeak": CGPoint(x:290.0,y:410.0), "BPeak": CGPoint(x:290.0,y:70.0)]
        cardCenter = ["ALeft": CGPoint(x:40.0,y:410.0), "AMiddle" : CGPoint(x:120.0,y:410.0), "ARight" : CGPoint(x:200.0,y:410.0),"BLeft" :  CGPoint(x:280.0,y:70.0),"BMiddle"  :  CGPoint(x:200.0,y:70.0),"BRight" : CGPoint(x:120.0,y:70.0),"initPile" : CGPoint(x:200.0,y:240.0), "remainPile": CGPoint(x:120.0,y:240.0)]
        peakCenter = ["APeak": CGPoint(x:280.0,y:410.0), "BPeak": CGPoint(x:40.0,y:70.0)]
        
        locTitle = ["ALeft", "AMiddle", "ARight", "BLeft", "BMiddle", "BRight"]
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupInit(#cardName: String, frontSet: Bool) ->Card{
        var card = Card(cardImage: cardName , position: CGPoint(x: -60, y: 140), width: 60,height: 100)
        card.setFrontCard(setFront: frontSet)
        card.previousCenter(card.center)
        
        return card
    }
    
    
//    func setupCard(#center:String, cardName: String, frontSet: Bool ) -> Card{
//        var cardPos = CGPoint(x: cardCenter[center]!.x - 30, y: cardCenter[center]!.y - 50)
//        var card = Card(cardImage: cardName , position: cardPos, width: 60,height: 100)
//        card.setFrontCard(setFront: frontSet)
//        card.previousCenter(card.center)
//
//        self.linkCardWithPos(card: card, willInCenter: center)
//        return card
//    }
    
    func linkCardWithPos(#card: Card, willInCenter: String){
        var isInPile = false
        switch(willInCenter){
            case "initPile": initPileLoc.append(card)
            case "remainPile": remainPileLoc.append(card)
            default:
                cardStoreLoc[willInCenter] = card
        }
    }
    
    //stage 1: peak right card
    func peakRightCard(#player: String) -> Card{
        var peakCard:Card
        var peakCardName:String
        var card: Card
        if (player == "playerA"){
            card = cardStoreLoc["ARight"]!
            peakCardName = card.getCardName()
            peakCard = setupInit(cardName: peakCardName, frontSet: card.setFront)
            peakCard.center = cardCenter["ARight"]!
            UIView.animateWithDuration(1.0, delay: 0.5, options: UIViewAnimationOptions.CurveLinear, animations: {
                peakCard.center = self.peakCenter["APeak"]!}, completion: nil)
            
           
        }else{
            card = cardStoreLoc["BRight"]!
            peakCardName = card.getCardName()
            peakCard = setupInit(cardName: peakCardName, frontSet: card.setFront)
            peakCard.center = cardCenter["BRight"]!
            UIView.animateWithDuration(1.0, delay: 0.5, options: UIViewAnimationOptions.CurveLinear, animations: {
                peakCard.center = self.peakCenter["BPeak"]!}, completion: nil)
            peakCard.backCard.showLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        }
        
        peakCard.backCard.addShowLabel("Peak Here!")
        addSubview(peakCard)
        return peakCard
    }
    
    func getTouchedFrame(loc: CGPoint) -> Card?{
        for (key, value) in cardStoreLoc {
            if(CGRectContainsPoint(value.frame, loc)){
                // destinate the card that want to be moved
                trackCard = value
                trackBool = true
                return value
            }
        }

        return nil
    }
    
    func getMovedFrame(loc: CGPoint) -> (String?, Card?){


        for (key, value) in cardStoreLoc {
        // to keep moving uniquely and conituely, highlighted is required before moving a card
            if(CGRectContainsPoint(value.frame, loc) && (value == trackCard)){
                // implement the switch rules
                if(isPlayerA == true){
                    allowOneSide("playerA")
                }
                if (isPlayerA == false){
                    
                    allowOneSide("playerB")
                }

                correspondingTrackCard = setRules(key: key, value: value)
                cardInHand = value
                cardFrontInHand = cardInHand.setFront
                return (key, value)
            }
        }
        // get the remain Pile card
        var remainTop: Card
        var initTop: Card
        
        if (remainPileLoc != []) {
            remainTop = remainPileLoc[self.remainPileLoc.count - 1]
            if(CGRectContainsPoint(remainTop.frame, loc) && (remainTop == trackCard)){
               
                // set the rule for take that only allow right card being replaced
                // set the rules for blind take that all three cards are allowed to exchange
                if(isPlayerA == true){
                    allowOneSide("playerA")
                }
                if (isPlayerA == false){
                    
                    allowOneSide("playerB")
                }

                correspondingTrackCard = setRules(key: "remainPile", value: remainTop)
                
                frontTopRemain = remainTop.setFront
                // for take procedure
                cardInHand = remainTop
                cardFrontInHand = cardInHand.setFront
                return ("remainPile", remainTop)
            }        
        }
        // get init pile card
        if (initPileLoc != []) {
            initTop = initPileLoc[self.initPileLoc.count - 1]
           // println(initTop)
            if(CGRectContainsPoint(initTop.frame, loc) && (initTop == trackCard)){
                if(isPlayerA == true){
                    allowOneSide("playerA")
                }
                if (isPlayerA == false){
                    
                    allowOneSide("playerB")
                }

                correspondingTrackCard = setRules(key: "initPile", value: initTop)
                cardInHand = initTop
                return ("initPile", initTop)
            }
        }
        
        println("You need to highlight it first!")
        return (nil, nil)
    }
    
    func allowOneSide(player: String){
        switch(player){
        case "playerA":
            if let c = cardStoreLoc["BLeft"] {
                correspondingCard.append(c)
                
            }
            if let c = cardStoreLoc["BMiddle"] {
                correspondingCard.append(c)
                
            }
            if let c = cardStoreLoc["BRight"] {
                correspondingCard.append(c)
                
            }
            cardStoreLoc["BRight"] = nil
            cardStoreLoc["BMiddle"] = nil
            cardStoreLoc["BLeft"] = nil
        case "playerB":
            if let c = cardStoreLoc["ALeft"] {
                correspondingCard.append(c)
                
            }
            if let c = cardStoreLoc["AMiddle"] {
                correspondingCard.append(c)
                
            }
            if let c = cardStoreLoc["ARight"] {
                correspondingCard.append(c)
                
            }
            cardStoreLoc["ARight"] = nil
            cardStoreLoc["AMiddle"] = nil
            cardStoreLoc["ALeft"] = nil
            
        default: "error!"
            
        }
    }
    func setRules(#key: String, value: Card) -> String{
        //note: when one member in dictionary is nil, the member will totally be deleted.
        // however, copied dictionary will not work, because each time the change location will change the property of class Card member, wherever it is.
        
        switch(key){
        case "ALeft":
            
            // need force unwrap by below way
            if let c = cardStoreLoc["ARight"] {
                correspondingCard.append(c)

            }
            cardStoreLoc["ARight"] = nil
            
           // allowOneSide("playerA")
            return "ARight"
        case "BLeft":
            if let c = cardStoreLoc["BRight"] {
                correspondingCard.append(c)
            }
            cardStoreLoc["BRight"] = nil
            //allowOneSide("playerB")
            return "BRight"
        case "ARight":
            if let c = cardStoreLoc["ALeft"] {
                correspondingCard.append(c)
            }
            cardStoreLoc["ALeft"] = nil
            //allowOneSide("playerA")
            return "ALeft"
        case "BRight":
            if let c = cardStoreLoc["BLeft"] {
                correspondingCard.append(c)
            }
            cardStoreLoc["BLeft"] = nil
            //allowOneSide("playerB")
            return "BLeft"
        case "AMiddle":
            // just for the same order of correspondingCard
            correspondingCard.append(trackCard)
            
            //allowOneSide("playerA")

            return "AMiddle"
            
        case "BMiddle":
            // just for the same order of correspondingCard
            correspondingCard.append(trackCard)
            
           // allowOneSide("playerB")

            return "BMiddle"
            
        case "remainPile":
            if(value.setFront == false){
                // take operation limitation
                if (isPlayerA == true){
                    if let c = cardStoreLoc["ALeft"] {
                        correspondingCard.append(c)
                    }
                    if let c = cardStoreLoc["AMiddle"] {
                        correspondingCard.append(c)
                    }
                    cardStoreLoc["ALeft"] = nil
                    cardStoreLoc["AMiddle"] = nil
                    //allowOneSide("playerA")
                }else if(isPlayerA == false){
                    if let c = cardStoreLoc["BLeft"] {
                        correspondingCard.append(c)
                    }
                    if let c = cardStoreLoc["BMiddle"] {
                        correspondingCard.append(c)
                    }
                    cardStoreLoc["BLeft"] = nil
                    cardStoreLoc["BMiddle"] = nil
                    //allowOneSide("playerB")
                }
                
            }
            else{
                // blind take operation
                //println("more operations for blind take")
                //trackCard = value
            }
            return "remainPile"
        
        case "initPile":
            //println("more operations about init pile")
            return key
            
        default: println("default: more operations added here in future")
            return key
        }
        
 
    }
    
    func MovedFrame(#key: String, value: Card, loc: CGPoint) {
        var storeLoc = cardStoreLoc
        var nearestCenter: String
        var nearestDistanceExp:CGFloat
        
        (nearestCenter, nearestDistanceExp) = centerNear(value.center)
        
        if(key != "remainPile" && key != "initPile"){
        // use storeLoc as nil to avoid rechoosing the first card when control the second card's behavior
            storeLoc[key] = nil
        }

        var antherCard = storeLoc[nearestCenter]

            if((antherCard) != nil){
                if(value.frame.intersects(antherCard!.frame)){
                    var dist = pointDistance(start: value.center, end: loc)
                    var newX:CGFloat = antherCard!.center.x + dist.x
                    var newY:CGFloat = antherCard!.center.y + dist.y
                    antherCard!.center = CGPoint(x: newX, y: newY)
                }
                else{
                    isMoveSucceed = false
                    reset(resetHandyCard: false, key: key, value: value)
                }
            }else if(antherCard == nil){
                isMoveSucceed = false
                reset(resetHandyCard: false, key: key, value: value)
            }
        
        // cut card in init pile
//        if(value.setFront == false && self.remainPileLoc != []){
//            var remainAnotherCard = self.remainPileLoc[remainPileLoc.count - 1]
//            println(value.frame.intersects(remainAnotherCard.frame))
//            if(value.frame.intersects(remainAnotherCard.frame)){
//                var dist = pointDistance(start: value.center, end: loc)
//                var newX:CGFloat = remainAnotherCard.center.x + dist.x
//                var newY:CGFloat = remainAnotherCard.center.y + dist.y
//                //remainAnotherCard.center = CGPoint(x: newX, y: newY)
//                //println("here")
//            }else{
//                isMoveSucceed = false
//                //reset(resetHandyCard: false, key: key, value: value)
//            }
//        }else if(value.setFront == false && self.remainPileLoc == []){
//            isMoveSucceed = false
//           // reset(resetHandyCard: false, key: key, value: value)
//        }
        
        value.center = loc

    }
    
    //reset all cards back to previous status
    func reset(#resetHandyCard :Bool, key: String, value: Card) {
        if(resetHandyCard == true){ // restore everycard back to previous location
            for (k, v) in cardStoreLoc{
                moveCardAnimation(v, duration: cardMoveTime, destination: self.cardCenter[k]!)
            }
            // put the init/ remain card back to previous pile
            moveCardAnimation(value, duration: cardMoveTime, destination: self.cardCenter[key]!)
            
        }else if(resetHandyCard == false){
            for (k, v) in cardStoreLoc{
                if(k != key){ // restore everycard except the moving card
                   moveCardAnimation(v, duration: cardMoveTime, destination: self.cardCenter[k]!)
                }
            }
//            if(value.setFront == false && self.remainPileLoc != []){
            // problem is here
//                moveCardAnimation(value, duration: cardMoveTime, destination: self.cardCenter["remainPile"]!)
//            }
        }
    }

    func restoreStoreLoc(#key: String, movedCard: Card?){
        if((movedCard) != nil){
            var nearestCenter: String
            var nearestDistanceExp:CGFloat
            var anotherCard: Card
            
            var condition1: Bool = (isPlayerA == false) && (cardStoreLoc["BRight"] == nil)
            var condition2: Bool = (isPlayerA == true) && (cardStoreLoc["ARight"] == nil)
            
            (nearestCenter, nearestDistanceExp) = centerNear(movedCard!.center)
            
                if(nearestDistanceExp < 20 * 20){
                    if((cardStoreLoc[nearestCenter]) != nil){
                        
                        movedCard!.center =  cardCenter[nearestCenter]!
                        anotherCard = cardStoreLoc[nearestCenter]!
                        dataManager.autoMovedCard = anotherCard
                        if(key == "remainPile"){
                            remainPileLoc[remainPileLoc.count - 1] = anotherCard
                            resetUnrelativeCards(key: key, moveCard: movedCard!, correspCard: anotherCard)
                        }else if (key == "initPile"){
                            dataManager.previousKey = nearestCenter
                            // cut card effect on normal locations
                            if(movedCard!.setFront == false){
                                movedCard!.flipCard(auto: true, label: nil)
                                anotherCard.flipCard(auto: true, label: nil)
                            }
                            
                            remainPileLoc.append(anotherCard)
                            initPileLoc.removeLast()
                            //println(initPileLoc.count)
                            resetUnrelativeCards(key: key, moveCard: movedCard!, correspCard: anotherCard)
                        }else{
                            cardStoreLoc[key] = anotherCard
                        }
                        
                        cardStoreLoc[nearestCenter] = movedCard!
                        //take flip
                        if(key == "remainPile" && cardFrontInHand == false){
                            movedCard!.flipCard(auto: true, label: nil)
                        }
                        
                        
                        isMoveSucceed = true
                        
                        // restore the nil position back to normal
                        followRules(c:correspondingTrackCard)
                        
                        // for future animation: move the new card back to new position
                        // in this animation, the final set and all animation included
                        moveCardAnimation(anotherCard, duration: cardMoveTime, destination: self.cardCenter[key]!)
                        
                    }else{
                        
                        if(movedCard!.setFront == false){
                            // cut card effect on remain pile
                            dataManager.autoMovedCard = movedCard!
                            movedCard!.center = cardCenter["remainPile"]!
                            remainPileLoc.append(movedCard!)
                            initPileLoc.removeLast()
                            isMoveSucceed = true
                            reset(resetHandyCard: true, key: key, value: movedCard!)
                            // restore the nil position back to normal
                            followRules(c:correspondingTrackCard)
                        }else{
                            isMoveSucceed = false
                            reset(resetHandyCard: true, key: key, value: movedCard!)
                            // restore the nil position back to normal
                            followRules(c:correspondingTrackCard)
                        }
                    }
                    
                }else{
                    isMoveSucceed = false
                    reset(resetHandyCard: true, key: key, value: movedCard!)
                    // restore the nil position back to normal
                    followRules(c:correspondingTrackCard)
                }
        }
        
    }
    
    func followRules(#c: String){
        func allowBothSides(player:String){
            switch(player){
            case "playerA":
                
                cardStoreLoc["BLeft"] = correspondingCard[0]
                cardStoreLoc["BMiddle"] = correspondingCard[1]
                cardStoreLoc["BRight"] = correspondingCard[2]
            case "playerB":
                cardStoreLoc["ALeft"] = correspondingCard[0]
                cardStoreLoc["AMiddle"] = correspondingCard[1]
                cardStoreLoc["ARight"] = correspondingCard[2]

                
            default:
                println("error")
            }
        }
        
        switch(c){
            case "ALeft":
                cardStoreLoc[c] = correspondingCard[3]
                allowBothSides("playerA")
            case "ARight":
                cardStoreLoc[c] = correspondingCard[3]
                allowBothSides("playerA")
            case "BLeft":
                cardStoreLoc[c] = correspondingCard[3]
                allowBothSides("playerB")
            case "BRight":
            cardStoreLoc[c] = correspondingCard[3]
                allowBothSides("playerB")
            case "AMiddle":
                println("sth to here for AMiddle in the future")
                allowBothSides("playerA")
            case "BMiddle":
                println("sth to here for BMiddle in the future")
                allowBothSides("playerB")
            case "remainPile":
                if(isPlayerA == true){
                    allowBothSides("playerA")
                }else if(isPlayerA == false){allowBothSides("playerB")}
                
                if(frontTopRemain == false){
                    // take process follow up
                    if(isPlayerA == true){
                    cardStoreLoc["ALeft"] = correspondingCard[3]
                    cardStoreLoc["AMiddle"] = correspondingCard[4]
                    }else if(isPlayerA == false){
                    cardStoreLoc["BLeft"] = correspondingCard[3]
                    cardStoreLoc["BMiddle"] = correspondingCard[4]
                    }
                    
                    if(isMoveSucceed == false && isPlayerA == true){
                        cardStoreLoc["ARight"]!.frameHighlight()
                    }else if (isMoveSucceed == false && isPlayerA == false){
                        cardStoreLoc["BRight"]!.frameHighlight()
                    }
                    

                }else{
                    // blind take: future operations needed
                    if(isMoveSucceed == false && isPlayerA == true){
                        cardStoreLoc["ALeft"]!.frameHighlight()
                        cardStoreLoc["AMiddle"]!.frameHighlight()
                        cardStoreLoc["ARight"]!.frameHighlight()
                    }else if (isMoveSucceed == false && isPlayerA == false){
                        cardStoreLoc["BLeft"]!.frameHighlight()
                        cardStoreLoc["BMiddle"]!.frameHighlight()
                        cardStoreLoc["BRight"]!.frameHighlight()
                    }
                    
            
                }
            case "initPile":
                if(isPlayerA == true){
                    allowBothSides("playerA")
                }else if(isPlayerA == false){allowBothSides("playerB")}
                
                if(isMoveSucceed == false && isPlayerA == true){
                    cardStoreLoc["ALeft"]!.frameHighlight()
                    cardStoreLoc["AMiddle"]!.frameHighlight()
                    cardStoreLoc["ARight"]!.frameHighlight()
                }else if (isMoveSucceed == false && isPlayerA == false){
                    cardStoreLoc["BLeft"]!.frameHighlight()
                    cardStoreLoc["BMiddle"]!.frameHighlight()
                    cardStoreLoc["BRight"]!.frameHighlight()
                }
                
                //println("more operations about init pile at the end of move")
            default:
                println("sth to here in the future")
            
        }
        correspondingCard = []
    }
    
    func moveCardAnimation(card: Card, duration: Double, destination: CGPoint){
        UIView.transitionWithView(card, duration: duration, options: UIViewAnimationOptions.CurveLinear, animations: {
            
            // all conditions except swap(because swap/blind swap involved in 3 cards exchange, while others involved in 2 cards exchange)
            if(destination != self.cardCenter["initPile"]){
                card.center = destination
            }
            
            // swap or blind swap occurs only when move success, otherwise back to previous location
            if (self.isMoveSucceed == true && destination == self.cardCenter["initPile"]){
                card.center = self.cardCenter["remainPile"]!
                
            } else if(self.isMoveSucceed == false && destination == self.cardCenter["initPile"]){
                card.center = self.cardCenter["initPile"]!
            }
            
            // ramdom angle put the card in remain pile for take/blind take and swap/blind swap procedure
            if(self.isMoveSucceed == true && (destination == self.cardCenter["remainPile"]) || destination == self.cardCenter["initPile"]){
                var angle = (CGFloat)((-0.5 + 0.1 * (CGFloat)(arc4random_uniform(UInt32(46)))) / 4.0) % 0.1
                card.layer.setAffineTransform(CGAffineTransformMakeRotation(angle))
            }
            
            }, completion: {
            (Bool) -> Void in
            if(self.isMoveSucceed == true){
//                self.isPlayerA = !self.isPlayerA
//                
//                self.timer.invalidate()
//                self.timer = nil
//                self.setTimer()
                
                // take procedure
                if(destination == self.cardCenter["remainPile"] && self.cardFrontInHand == false){
                    card.flipCard(auto: true, label: nil)
                }
                
                // swap with peaking procedure
                if(destination == self.cardCenter["initPile"] && dataManager.didBlindSwapOccur == true && card.setFront == true){
                    card.flipCard(auto: true, label: nil)
                    dataManager.didBlindSwapOccur = false
                }
                
//                // player label change
//                if(self.isPlayerA == true){
//                    self.playerALabel.backgroundColor = UIColor.redColor()
//                    self.playerBLabel.backgroundColor = UIColor.clearColor()
//                    self.timerLabel.transform = CGAffineTransformMakeRotation(2 * CGFloat(M_PI))
//                }else if(self.isPlayerA == false){
//                    self.playerBLabel.backgroundColor = UIColor.redColor()
//                    self.playerALabel.backgroundColor = UIColor.clearColor()
//                    self.timerLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
//                }
            }
        })
    }
    
    // in init/ remain pile cards case, it may effect more than one cards when moving ends.
    func resetUnrelativeCards(#key: String, moveCard: Card, correspCard: Card){
        for (k,c) in cardStoreLoc {
            if (c != correspCard){
                moveCardAnimation(c, duration: cardMoveTime, destination: self.cardCenter[k]!)
            }
        }
    }
    
    func centerNear(inputCardCenter: CGPoint) -> (String, CGFloat){
        var distance: CGFloat = 0.0
        var centerDistance: [CGFloat] = []
        var compare:CGFloat = CGFloat.infinity
        var index = "" as String
        
        for (key,center) in cardCenter {
            var xDistance = inputCardCenter.x - center.x
            var yDistance = inputCardCenter.y - center.y
            distance = xDistance * xDistance + yDistance * yDistance
            
            if(distance  < compare){
                index = key
                compare = distance
            }
        }
        return (index, compare)
    }
    
    func pointDistance(#start: CGPoint, end: CGPoint) -> CGPoint {
        var distanceBetweenPoints: CGPoint = CGPoint(x: end.x - start.x, y: end.y - start.y)
        return distanceBetweenPoints
    }
    
    func triangleDistance(a: CGPoint) -> CGPoint {
                var length: CGFloat = CGFloat(sqrtf(CFloat(a.x) * CFloat(a.x) + CFloat(a.y) * CFloat(a.y)))
                var sinValue = a.x / length
                var cosValue = a.y / length
        return CGPoint(x: sinValue, y: cosValue)
    }

    
    //for remainpile location, eachtime move other card from other location to remainpile, use below fuction to set the previous card on top of pile into one memberof the gameboard
    func addCard(){}
}
