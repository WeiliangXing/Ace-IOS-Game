import Foundation
import UIKit
import AVFoundation

class GameScene: UIViewController, UIGestureRecognizerDelegate {
    
    var gameboard: GameBoard!
    
    var moveGesture : UIPanGestureRecognizer!
    var tapGesture :  UITapGestureRecognizer!
    
    var timerLabelA: UILabel!
    var timerLabelB: UILabel!
    
    var bingoButtonA: UILabel!
    var bingoButtonB: UILabel!
    
    //another way to initialize the array
    var cardGroup: [Card] = []
    
    // for stage 1 peak cards
    var peakCards: [Card] = []
    
    // very important: make the current action unique
    var stopMeAtStageOne: Bool!
    
    // locker for init deal: prohibit taps when dealing works : currently it is useless
    var lockTapWhileDealing: Bool!
    
    // player order decision
    var isPlayerA: Bool!
    
    // deal end marker
    var isDealEnd:Bool!
    
    //decide whether blind take occurs; if true, block all other operations(tap)
    var didBlindTakeBegin: Bool!
    //var didBlindTakeEnd: Bool!
    var blindTakeCard: Card!
    
    var blindSwapCard: Card!
    
    var stolenCard: Card!
    var exchangedCard: Card!
    var didStolenPeakBegin: Bool!
    var didLockInit: Bool! // for ace effect
    var aceOpponentKey: String!
    
    // for test
    var test: String!
    
    @IBOutlet var startButton: UIButton! // x: 250, y: 230, width: 60, height: 30  "deal"
    @IBOutlet var playerButton: UIButton!// x: 250, y: 260, width: 77, height: 30   "play"
    @IBOutlet var replayButton: UIButton!// x: 250, y: 260, width: 77, height: 30   "replay"
    @IBOutlet var continueButton: UIButton!//x: 250, y: 260, width: 77, height: 30  “continue”
    
    var didTimerEnds: Bool!
    //timer for each player
    var timer: NSTimer!
    var tenseconds : Int!
    var seconds : Int!
    var milseconds : Int!
    var blinkStatus: Bool!
    var timerLabel: UILabel!
    
    var didMoveBegin: Bool!
    
    // swap markers
    var didSwapBegin: Bool!
    var didSwapEnd: Bool!
    var didBlindSwapBegin: Bool!
    var didBlindSwapEnd: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var w: CGFloat = self.view.frame.width
        var h: CGFloat = self.view.frame.height
        gameboard = GameBoard(cardImage: "Board320*480",position: CGPoint(x: 0, y: 0), width: w,height: h)
        startButton.setTitle("Deal", forState: UIControlState.Normal)
        playerButton.setTitle("Play", forState: UIControlState.Normal)
        replayButton.setTitle("Replay", forState: UIControlState.Normal)
        continueButton.setTitle("Continue", forState: UIControlState.Normal)
        startButton.hidden = false
        startButton.enabled = true
        playerButton.hidden = true
        playerButton.enabled = false
        replayButton.hidden = true
        replayButton.enabled = false
        continueButton.hidden = true
        continueButton.enabled = false
        
        
        self.view.addSubview(gameboard)
        self.view.addSubview(startButton)
        self.view.addSubview(playerButton)
        self.view.addSubview(replayButton)
        
        timerLabelA = UILabel(frame: CGRectMake(250, 328, 60, 30))
        timerLabelA.text = "05 : 00"
        timerLabelA.textColor = UIColor.blackColor()
        timerLabelA.textAlignment = NSTextAlignment.Center
        self.view.addSubview(timerLabelA)
        timerLabelB = UILabel(frame: CGRectMake(10, 122, 60, 30))
        timerLabelB.text = "05 : 00"
        timerLabelB.textColor = UIColor.blackColor()
        timerLabelB.textAlignment = NSTextAlignment.Center
        timerLabelB.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        self.view.addSubview(timerLabelB)
        
        timerLabel = UILabel(frame: CGRectMake(250, 200, 60, 30))
        timerLabel.text = "Timer"
        timerLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(timerLabel)
        
        bingoButtonA = UILabel(frame: CGRectMake(10, 328, 60, 30))
        bingoButtonA.text = "Bingo"
        bingoButtonA.textAlignment = NSTextAlignment.Center
        self.view.addSubview(bingoButtonA)
        
        bingoButtonB = UILabel(frame: CGRectMake(250, 122, 60, 30))
        bingoButtonB.text = "Bingo"
        bingoButtonB.textAlignment = NSTextAlignment.Center
        bingoButtonB.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        self.view.addSubview(bingoButtonB)
        
        stopMeAtStageOne = true
        
        lockTapWhileDealing = true
        
        isPlayerA = true
        isDealEnd = false
        
        didBlindTakeBegin = false
        dataManager.didBlindTakeEnd = true
        
        blindTakeCard = nil
        
        blindSwapCard = nil
        
        stolenCard = nil
        exchangedCard = nil
        
        didTimerEnds = false
        didMoveBegin = false
        
        dataManager.dataIsPlayerA = true
        
        // swap markers
        didSwapBegin = false
        didSwapEnd = true
        didBlindSwapBegin = false
        didBlindSwapEnd = true
        dataManager.didBlindSwapOccur = false
        dataManager.isPlayerA = self.gameboard.isPlayerA
        dataManager.didStoleBegin = false
        didStolenPeakBegin = false
        didLockInit = false
        aceOpponentKey = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func replayPressed(){
        replayButton.hidden = true
        replayButton.enabled = false
        startButton.hidden = false
        startButton.enabled = true
        continueButton.hidden = true
        continueButton.enabled = false
        
        self.gameboard.removeFromSuperview()
        gameboard = GameBoard(cardImage: "Board320*480",position: CGPoint(x: 0, y: 0), width: self.view.frame.width,height:self.view.frame.height)
        self.view.addSubview(gameboard)
        self.view.bringSubviewToFront(startButton)
        self.view.bringSubviewToFront(playerButton)
        self.view.bringSubviewToFront(replayButton)
        self.view.bringSubviewToFront(timerLabel)
        self.view.bringSubviewToFront(timerLabelA)
        self.view.bringSubviewToFront(timerLabelB)
        self.view.bringSubviewToFront(bingoButtonA)
        self.view.bringSubviewToFront(bingoButtonB)
        
        if(self.timer != nil){
            self.timer.invalidate()
            self.timer = nil
        }
        self.timerLabel.text = "Timer"
        self.timerLabel.transform = CGAffineTransformMakeRotation(2 * CGFloat(M_PI))
        self.gameboard.playerALabel.backgroundColor = UIColor.clearColor()
        self.gameboard.playerBLabel.backgroundColor = UIColor.clearColor()
        
        if(cardGroup != []){
            for (var i = 0;  i < cardGroup.count ; ++i){
                cardGroup[i].removeFromSuperview()
            }
        }
        peakCards[0].removeFromSuperview()
        peakCards[1].removeFromSuperview()
        // peakCards[2].removeFromSuperview()
        cardGroup = []
        peakCards = []
        
        stopMeAtStageOne = true
        
        lockTapWhileDealing = true
        
        isPlayerA = true
        isDealEnd = false
        didBlindTakeBegin = false
        
        
        didTimerEnds = false
        didMoveBegin = false
        dataManager.didStoleBegin = false
        didStolenPeakBegin = false
        didLockInit = false
        aceOpponentKey = nil
        
        resetDataManager()
        
        if((blindSwapCard) != nil){
            blindSwapCard.removeFromSuperview()
            blindSwapCard = nil
        }
        
        if((blindTakeCard) != nil){
            blindTakeCard.removeFromSuperview()
            blindTakeCard = nil
        }
        
        if((stolenCard) != nil){
            stolenCard.removeFromSuperview()
            stolenCard = nil
        }
        
        if((exchangedCard) != nil){
            exchangedCard.removeFromSuperview()
            exchangedCard = nil
        }
        
        self.moveGesture.enabled = false
    }
    
    @IBAction func playerChoosingPressed(){
        // for future dice rolling
        // game formally begin
        isDealEnd = true
        isPlayerA = true
        self.gameboard.isPlayerA = true
        self.gameboard.playerALabel.backgroundColor = UIColor.redColor()
        self.gameboard.playerBLabel.backgroundColor = UIColor.clearColor()
        self.setTimer()
        playerButton.hidden = true
        playerButton.enabled = false
        replayButton.hidden = false
        replayButton.enabled = true
        continueButton.hidden = true
        continueButton.enabled = false
        peakCards[0].removeFromSuperview()
        peakCards[1].removeFromSuperview()
    }
    
    @IBAction func startPressed(){
        startButton.hidden = true
        startButton.enabled = true
        continueButton.hidden = true
        continueButton.enabled = false
        isPlayerA = true
        // random and reorder the pile,with/without the animation
        var cardOrder = ["Clubs Ace", "Clubs 2", "Clubs 3", "Clubs 4", "Clubs 5", "Clubs 6", "Clubs 7", "Clubs 8", "Clubs 9", "Clubs 10", "Clubs Jack", "Clubs Queen", "Clubs King", "Diamonds Ace", "Diamonds 2", "Diamonds 3", "Diamonds 4", "Diamonds 5", "Diamonds 6", "Diamonds 7", "Diamonds 8", "Diamonds 9", "Diamonds 10", "Diamonds Jack", "Diamonds Queen", "Diamonds King", "Hearts Ace", "Hearts 2", "Hearts 3", "Hearts 4", "Hearts 5", "Hearts 6", "Hearts 7", "Hearts 8", "Hearts 9", "Hearts 10", "Hearts Jack", "Hearts Queen", "Hearts King", "Spades Ace", "Spades 2", "Spades 3", "Spades 4", "Spades 5", "Spades 6", "Spades 7", "Spades 8", "Spades 9", "Spades 10", "Spades Jack", "Spades Queen", "Spades King"]     
        cardOrder = randomCard(cardOrder)
        
        initGame(cardOrder)
        
        // set gesture actions
        setupAction()
    }
    
    @IBAction func continuePressed(){
        self.gameboard.remainPileLoc[self.gameboard.remainPileLoc.count - 1].flipCard(auto: true, label: nil)
        self.gameboard.remainPileLoc[self.gameboard.remainPileLoc.count - 1].setFrontCard(setFront: true)
        didLockInit = false
        changePlayer()
    }
    
    func setTimer(){
        didBlindTakeBegin = false
        didBlindSwapBegin = false
        dataManager.didBlindTakeEnd = true
        dataManager.didBlindSwapEnd = true
        tenseconds = 100
        seconds = tenseconds / 10
        milseconds = tenseconds % 10
        timerLabel.text = NSString(format: "%02d : %02d", seconds, milseconds * 10) as String
        timerLabel.textColor = UIColor.blackColor()
        blinkStatus = false
        //timerMarker = timerMarker + 1
        timer = NSTimer.scheduledTimerWithTimeInterval( 0.1 , target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        self.moveGesture.enabled = false
    }
    
    func update(){
        if(tenseconds > 0) {
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
            self.timer.invalidate()
            self.timer = nil
            didTimerEnds = true
            
            // before timer ends, no move action performed
            if(didMoveBegin == false){
                didTimerEnds = false
                
                self.changePlayer()
            }
        }
    }
    
    // random the order of the original card pile
    func randomCard<T>(arrayPile: [T]) -> [T] {
        var arry = arrayPile
        var r: Int!
        var a:T!
        for( var i = arry.count-1; i > 0; --i){
            r = Int(arc4random_uniform(UInt32(i+1)))
            a = arry[r]
            arry[r] = arry[i]
            arry[i] = a
        }
        return arry
    }
    
    // initialize the dealing procedure
    func initGame(cardOrder: [String]){
        var angle = (CGFloat)((-0.5) / 4.0) % 0.1
        var angleGroup: [CGFloat] = [angle]
        var setFront: [Bool] = []
        
        //var sound = self.loadSounds(soundName: "Dealing.wav")
        
        // set card in new random order in the scene
        // reset everything
        if(cardGroup != []){
            for (var i = 0;  i < cardGroup.count ; ++i){
                cardGroup[i].removeFromSuperview()
            }
            peakCards[0].removeFromSuperview()
            peakCards[1].removeFromSuperview()
            cardGroup = []
            peakCards = []
            setFront = []
        }
        
        // dealing procedure1: put all cards in init piles
        
//        var r = Int(arc4random_uniform(UInt32(cardOrder.count - 7)))
//        //var r = cardOrder.count - 13
//        //sound.performSelector(Selector("soundPlay"))
//        for (var i = 0;  i < cardOrder.count ; ++i){
//            
//            // cut process, add cut card at random, but not in last six cards
//            //(1) initial status: every card face up
//            //if(i == r){
//            //  setFront.append(true)
//            //}else{
//            //  setFront.append(false)
//            //}
//            // (2) initial status: every card face down
//            if(i == r){
//                if(cardOrder[i].hasSuffix("Ace") || cardOrder[i].hasPrefix("Ace")){
//                    setFront.append(true)
//                }else{
//                    setFront.append(false)
//                }
//            }else{
//                setFront.append(true)
//            }
//            
//        }
        // random the card piles, avoid ace become the cut card
        var r = Int(arc4random_uniform(UInt32(cardOrder.count - 7)))
        for (var i = 0;  i < cardOrder.count ; ++i){
            setFront.append(true)
        }
        if((cardOrder[r].hasSuffix("Ace") || cardOrder[r].hasPrefix("Ace"))){
            if(r == 0){setFront[r + 1] = false}
            else if(r == cardOrder.count - 7){setFront[r - 1] = false}
        }else{
            setFront[r] = false
        }
        
//        for (var i = 0;  i < cardOrder.count - 6 ; ++i){
//            if(setFront[i] == false && (cardOrder[i].hasSuffix("Ace") || cardOrder[i].hasPrefix("Ace"))){
//                if(i == 0){
//                    setFront[i + 1] = false
//                }else if(i == cardOrder.count - 6){
//                    setFront[i - 1] = false
//                }
//            }
//        }
        
        
        for (var i = 0;  i < cardOrder.count ; ++i){
            cardGroup.append(gameboard.setupInit(cardName: cardOrder[i], frontSet: setFront[i]))
            
            UIView.animateWithDuration(0.1, delay: Double(i)/50, options:UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
                self.cardGroup[i].center = self.gameboard.cardCenter["initPile"]!
                self.cardGroup[i].layer.setAffineTransform(CGAffineTransformMakeRotation(angle))
                //self.view.addSubview(self.cardGroup[i])
                }  , completion:{
                    (Bool) -> Void in
                    //sound.stop()
                })
            angle = (CGFloat)((-0.5 + 0.1 * (CGFloat)(i+1)) / 4.0) % 0.1
            angleGroup.append(angle)
            self.view.addSubview(cardGroup[i])
            
            if(i > cardOrder.count - 7){
                // only care is about last six cards, so here is useless
            }else{
                self.gameboard.linkCardWithPos(card: cardGroup[i], willInCenter: "initPile")
                
            }
        }
        
        
        // temporary setting: put one card on remain pile, face up
        // ==============test==================
        // the card here is dangerous to cite the card in init pile
        //        var remainCard = cardGroup[cardOrder.count - 11]
        //        remainCard.center = gameboard.cardCenter["remainPile"]!
        //        remainCard.setFrontCard(setFront: false)
        //        self.gameboard.linkCardWithPos(card: remainCard, willInCenter: "remainPile")
        //        self.view.addSubview(remainCard)
        //println(self.gameboard.initPileLoc[self.gameboard.initPileLoc.count - 2].center)
        
        // dealing procedure2: distribute last six cards into six locations
        dealCard(cardOrder.count - 1, cardOrder: cardOrder)
        
        
    }
    
    func dealCard(index: Int, cardOrder: [String]){
        var delayTime: Double
        var i = index
        var title = self.gameboard.locTitle[cardOrder.count - i - 1]
        var card: Card = self.cardGroup[i]
        if(i == cardOrder.count - 6){
            // when last card is distributed, completed with playerA peak and PlayerB peak // all delay time 1.5
            UIView.animateWithDuration(0.1, delay: 1.5, options:UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
                var title = self.gameboard.locTitle[cardOrder.count - i - 1]
                self.cardGroup[i].center = self.gameboard.cardCenter[title]!
                self.cardGroup[i].transform = CGAffineTransformIdentity
                }  , completion: {
                    (Bool) -> Void in
                    self.gameboard.linkCardWithPos(card: card, willInCenter: title)
                    // start stage1: right card peaking
                    
                    var ARightPeak = self.gameboard.peakRightCard(player: "playerA")
                    var BRightPeak = self.gameboard.peakRightCard(player: "playerB")
                    self.peakCards.append(ARightPeak)
                    self.peakCards.append(BRightPeak)
                    
                    self.lockTapWhileDealing = false
                    self.tapGesture.enabled = true
                })
        }else{
            // distribute the top six cards into six locations
            if(i == cardOrder.count - 1){
                delayTime = 1.5
            }else{
                delayTime = 1.5
            }// below time is 0.4
            UIView.animateWithDuration(0.1, delay: delayTime, options:UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
                var title = self.gameboard.locTitle[cardOrder.count - i - 1]
                self.cardGroup[i].center = self.gameboard.cardCenter[title]!
                self.cardGroup[i].transform = CGAffineTransformIdentity
                }  , completion: {(Bool) -> Void in
                    // store the new cards and their locations in six locations
                    self.gameboard.linkCardWithPos(card: card, willInCenter: title)
                    i = i - 1
                    self.dealCard(i, cardOrder: cardOrder)
                })
        }
    }
    
    func setupAction(){
        
        //highlight gesture
        //note: in action selector, donot forget the":"!!!
        tapGesture =  UITapGestureRecognizer(target: self, action: "tapCard:")
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        tapGesture.enabled = false
        self.view.addGestureRecognizer(tapGesture)
        //        if(lockTapWhileDealing == true){
        //            self.tapGesture.enabled = false
        //        }else{self.tapGesture.enabled = true}
        
        // move gesture
        moveGesture = UIPanGestureRecognizer(target: self, action: "moveCard:")
        moveGesture.minimumNumberOfTouches = 1
        moveGesture.delegate = self
        moveGesture.enabled = false
        self.view.addGestureRecognizer(moveGesture)
    }
    
    func tapCard(gr: UITapGestureRecognizer){
        var tapGestureLocation = gr.locationInView(self.view)
        
        // tap function1: highlight one of six locations
        var touchedScene: Card? = gameboard.getTouchedFrame(tapGestureLocation)
        var touchedBothPeaks: Bool! = false
        if(peakCards.count > 0){
            touchedBothPeaks = peakCards[0].uniqueMarker == false && peakCards[1].uniqueMarker == false
        }else{
            touchedBothPeaks = false
        }
        //uniqueMarker false indicate first stage ends and other operations are allowed

        if(touchedScene != nil && touchedBothPeaks && (isDealEnd == true) && (didBlindTakeBegin == false) && (didBlindSwapBegin == false) && (dataManager.didStoleBegin == false)){

            didStolenPeakBegin = false
            
            if(blindSwapCard){
                blindSwapCard.removeFromSuperview()
                blindSwapCard = nil
            }
            
            if(blindTakeCard){
                blindTakeCard.removeFromSuperview()
                blindTakeCard = nil
            }
            if(stolenCard){
                stolenCard.removeFromSuperview()
                stolenCard = nil
            }
            if(exchangedCard){
                exchangedCard.removeFromSuperview()
                exchangedCard = nil
            }
            
            var point = touchedScene!.center
            switch(point){
            case gameboard.cardCenter["ARight"]!:
                if(gameboard.isPlayerA == true){
                    gameboard.cardStoreLoc["ARight"]!.highlight()
                    gameboard.cardStoreLoc["AMiddle"]!.frameHighlight()}
            case gameboard.cardCenter["AMiddle"]!:
                if(gameboard.isPlayerA == true){
                    gameboard.cardStoreLoc["ARight"]!.frameHighlight()
                    gameboard.cardStoreLoc["AMiddle"]!.highlight()
                    gameboard.cardStoreLoc["ALeft"]!.frameHighlight()}
            case gameboard.cardCenter["ALeft"]!:
                if(gameboard.isPlayerA == true){
                    gameboard.cardStoreLoc["ALeft"]!.highlight()
                    gameboard.cardStoreLoc["AMiddle"]!.frameHighlight()}
            case gameboard.cardCenter["BRight"]!:
                if(gameboard.isPlayerA == false){
                    gameboard.cardStoreLoc["BRight"]!.highlight()
                    gameboard.cardStoreLoc["BMiddle"]!.frameHighlight()}
            case gameboard.cardCenter["BMiddle"]!:
                if(gameboard.isPlayerA == false){
                    gameboard.cardStoreLoc["BRight"]!.frameHighlight()
                    gameboard.cardStoreLoc["BMiddle"]!.highlight()
                    gameboard.cardStoreLoc["BLeft"]!.frameHighlight()}
            case gameboard.cardCenter["BLeft"]!:
                if(gameboard.isPlayerA == false){
                    gameboard.cardStoreLoc["BLeft"]!.highlight()
                    gameboard.cardStoreLoc["BMiddle"]!.frameHighlight()}
            default:
                println("something may do here for init swap operation")
            }
            self.view.bringSubviewToFront(touchedScene!)
            // make moving card unique and then enable it
            self.moveGesture.enabled = true
        }
        
        // tap function2: highlight init pile
        var didTouchInitPile = false
        
        if(self.gameboard.initPileLoc != [] && didLockInit == false){
            var topInitPile = self.gameboard.initPileLoc[self.gameboard.initPileLoc.count - 1]
            didTouchInitPile = CGRectContainsPoint(topInitPile.frame, tapGestureLocation)
            
//            if(((didTouchInitPile && touchedBothPeaks && (isDealEnd == true)) && (didBlindTakeBegin == false) && (topInitPile.setFront == true) && (dataManager.didStoleBegin == false) != nil) != nil){
            if((didTouchInitPile != nil) && touchedBothPeaks && isDealEnd && !didBlindTakeBegin && topInitPile.setFront && !dataManager.didStoleBegin){
//            if(touchedBothPeaks){
                didStolenPeakBegin = false

                topInitPile.highlight()
                self.gameboard.trackCard = topInitPile
                
                if(didBlindSwapBegin == false){
                    // swap
                    // highlight all 3 locations
                    if(gameboard.isPlayerA == true){
                        self.gameboard.cardStoreLoc["ALeft"]!.frameHighlight()
                        self.gameboard.cardStoreLoc["AMiddle"]!.frameHighlight()
                        self.gameboard.cardStoreLoc["ARight"]!.frameHighlight()
                    }else if(gameboard.isPlayerA == false){
                        self.gameboard.cardStoreLoc["BLeft"]!.frameHighlight()
                        self.gameboard.cardStoreLoc["BMiddle"]!.frameHighlight()
                        self.gameboard.cardStoreLoc["BRight"]!.frameHighlight()
                        
                    }
                    // avoid pressing twice to generate two cards
                    if(self.peakCards.count >= 3){
                        self.peakCards[self.peakCards.count - 1].removeFromSuperview()
                        self.peakCards.removeLast()
                    }
                    // in order to avoid cover when blinkTake and blinkSwap meet
                    // !!! modifications here! added blindSwapCard block
                    if(blindSwapCard){
                        blindSwapCard.removeFromSuperview()
                        blindSwapCard = nil
                        //self.peakCards.removeLast()
                    }
                    
                    if(blindTakeCard){
                        blindTakeCard.removeFromSuperview()
                        blindTakeCard = nil
                        //self.peakCards.removeLast()
                    }
                    if(stolenCard){
                        stolenCard.removeFromSuperview()
                        stolenCard = nil
                    }
                    if(exchangedCard){
                        exchangedCard.removeFromSuperview()
                        exchangedCard = nil
                    }
                    blindSwapCard = self.gameboard.setupInit(cardName: topInitPile.getCardName(), frontSet: topInitPile.setFront)
                    self.peakCards.append(blindSwapCard)
                    
                    blindSwapCard.backCard.addShowLabel("Peak Here!")
                    if(gameboard.isPlayerA == true){
                        blindSwapCard.center = self.gameboard.peakCenter["APeak"]!
                    }
                    else if (gameboard.isPlayerA == false){
                        blindSwapCard.center = self.gameboard.peakCenter["BPeak"]!
                        blindSwapCard.backCard.showLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                    }
                    self.gameboard.addSubview(blindSwapCard)
                    blindSwapCard.frameHighlight()
                    
                    
                    self.moveGesture.enabled = true
                    self.view.bringSubviewToFront(topInitPile)
                    
                }
                else if(didBlindSwapBegin == true && dataManager.didBlindSwapEnd == false) { // indicate the blind take rules: when face down, move any of three locations
                    if(gameboard.isPlayerA == true){
                        self.gameboard.cardStoreLoc["ALeft"]!.frameHighlight()
                        self.gameboard.cardStoreLoc["AMiddle"]!.frameHighlight()
                        self.gameboard.cardStoreLoc["ARight"]!.frameHighlight()
                    }else if(gameboard.isPlayerA == false){
                        self.gameboard.cardStoreLoc["BLeft"]!.frameHighlight()
                        self.gameboard.cardStoreLoc["BMiddle"]!.frameHighlight()
                        self.gameboard.cardStoreLoc["BRight"]!.frameHighlight()
                        
                    }
                    self.moveGesture.enabled = true
                }
                
            }
                // the special case in init pile that cut card(face up) meet
            else if(didTouchInitPile && touchedBothPeaks && (isDealEnd == true)) && (didBlindTakeBegin == false) && (topInitPile.setFront == false) && (dataManager.didStoleBegin == false){
                
                didStolenPeakBegin = false
                
                topInitPile.highlight()
                self.gameboard.trackCard = topInitPile
                if(self.gameboard.remainPileLoc != []){
                    self.gameboard.remainPileLoc[self.gameboard.remainPileLoc.count - 1].frameHighlight()
                }
                if(gameboard.isPlayerA == true){
                    self.gameboard.cardStoreLoc["ALeft"]!.frameHighlight()
                    self.gameboard.cardStoreLoc["AMiddle"]!.frameHighlight()
                    self.gameboard.cardStoreLoc["ARight"]!.frameHighlight()
                }else if(gameboard.isPlayerA == false){
                    self.gameboard.cardStoreLoc["BLeft"]!.frameHighlight()
                    self.gameboard.cardStoreLoc["BMiddle"]!.frameHighlight()
                    self.gameboard.cardStoreLoc["BRight"]!.frameHighlight()
                }
                self.moveGesture.enabled = true
            }
        }
        
        // tap function 2.5: flip for blind swap
        // NOTE!!!: here blind swap means the Swap method, which indicate the swap method with peaking function
        if((blindSwapCard) != nil){
            if(CGRectContainsPoint(blindSwapCard.frame, tapGestureLocation) && gameboard.isPlayerA == true){
                didBlindSwapBegin = true
                blindSwapCard.flipKind = "blindSwap"
                // need modification!!!
                blindSwapCard.isPlayerA = didBlindSwapBegin
                blindSwapCard.flipCard(auto: false, label: timerLabelA)
                dataManager.didBlindSwapEnd = blindSwapCard.isPlayerA
                
                self.moveGesture.enabled = false
                // marker for blind swap auto exchange
                dataManager.didBlindSwapOccur = true
                // marker for ace effect; peakSwap is only way to activate ace. 
                dataManager.didPeakSwapOccur = true
            }
            if(CGRectContainsPoint(blindSwapCard.frame, tapGestureLocation) && gameboard.isPlayerA == false){
                didBlindSwapBegin = true
                
                blindSwapCard.flipKind = "blindSwap"
                blindSwapCard.isPlayerA = didBlindSwapBegin
                blindSwapCard.flipCard(auto: false, label: timerLabelB)
                dataManager.didBlindSwapEnd = blindSwapCard.isPlayerA
                self.moveGesture.enabled = false
                dataManager.didBlindSwapOccur = true
                dataManager.didPeakSwapOccur = true
            }
            
        }
        
        // tap function3: highlight remain pile
        var didTouchRemainPile: Bool! = false
        if (self.gameboard.remainPileLoc != []){
            
            var topRemainPile = self.gameboard.remainPileLoc[self.gameboard.remainPileLoc.count - 1]
            didTouchRemainPile = CGRectContainsPoint(topRemainPile.frame, tapGestureLocation)
            
            if((didTouchRemainPile && touchedBothPeaks && (isDealEnd == true) && (didBlindSwapBegin == false) && (dataManager.didStoleBegin == false)) != nil){
                
                didStolenPeakBegin = false
                
                topRemainPile.highlight()
                self.gameboard.trackCard = topRemainPile
                // indicate the take rules: when face up, only move to right card
                if(topRemainPile.setFront == false){
                    if(self.peakCards.count >= 3){
                        self.peakCards[self.peakCards.count - 1].removeFromSuperview()
                        self.peakCards.removeLast()
                    }
                    
                    if(gameboard.isPlayerA == true){
                        self.gameboard.cardStoreLoc["ARight"]!.frameHighlight()
                    }
                    else if (gameboard.isPlayerA == false){
                        self.gameboard.cardStoreLoc["BRight"]!.frameHighlight()
                    }
                    self.moveGesture.enabled = true
                }else{
                    // blind take stage1: peaking before moving
                    if(didBlindTakeBegin == false){
                        // avoid pressing twice to generate two cards
                        if(self.peakCards.count >= 3){
                            self.peakCards[self.peakCards.count - 1].removeFromSuperview()
                            self.peakCards.removeLast()
                        }
                        
                        if(blindSwapCard){
                            blindSwapCard.removeFromSuperview()
                            blindSwapCard = nil
                            //self.peakCards.removeLast()
                        }
                        
                        if(blindTakeCard){
                            blindTakeCard.removeFromSuperview()
                            blindTakeCard = nil
                            //self.peakCards.removeLast()
                        }
                        if(stolenCard){
                            stolenCard.removeFromSuperview()
                            stolenCard = nil
                        }
                        if(exchangedCard){
                            exchangedCard.removeFromSuperview()
                            exchangedCard = nil
                        }
                        
                        blindTakeCard = self.gameboard.setupInit(cardName: topRemainPile.getCardName(), frontSet: topRemainPile.setFront)
                        self.peakCards.append(blindTakeCard)
                        
                        blindTakeCard.backCard.addShowLabel("Peak Here!")
                        if(gameboard.isPlayerA == true){
                            blindTakeCard.center = self.gameboard.peakCenter["APeak"]!
                        }
                        else if (gameboard.isPlayerA == false){
                            blindTakeCard.center = self.gameboard.peakCenter["BPeak"]!
                            blindTakeCard.backCard.showLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                        }
                        self.gameboard.addSubview(blindTakeCard)
                        blindTakeCard.frameHighlight()
                    }
                        // blind take stage2: moving begin
                    else if(didBlindTakeBegin == true && dataManager.didBlindTakeEnd == false){ // indicate the blind take rules: when face down, move any of three locations
                        if(gameboard.isPlayerA == true){
                            self.gameboard.cardStoreLoc["ALeft"]!.frameHighlight()
                            self.gameboard.cardStoreLoc["AMiddle"]!.frameHighlight()
                            self.gameboard.cardStoreLoc["ARight"]!.frameHighlight()
                        }else if(gameboard.isPlayerA == false){
                            self.gameboard.cardStoreLoc["BLeft"]!.frameHighlight()
                            self.gameboard.cardStoreLoc["BMiddle"]!.frameHighlight()
                            self.gameboard.cardStoreLoc["BRight"]!.frameHighlight()
                            
                        }
                        self.moveGesture.enabled = true
                    }
                }
                self.view.bringSubviewToFront(topRemainPile)
                //self.moveGesture.enabled = true
            }
        }
        
        // tap function 3.5: flip for blind take
        if((blindTakeCard) != nil){
            if(CGRectContainsPoint(blindTakeCard.frame, tapGestureLocation) && gameboard.isPlayerA == true){
                didBlindTakeBegin = true
                
                blindTakeCard.flipKind = "blindTake"
                // the isplayerA in card class is only useful in first stage peaking, here, for structure purpose, necessary but non-useful
                blindTakeCard.isPlayerA = didBlindTakeBegin
                blindTakeCard.flipCard(auto: false, label: timerLabelA)
                dataManager.didBlindTakeEnd = blindTakeCard.isPlayerA
            }
            if(CGRectContainsPoint(blindTakeCard.frame, tapGestureLocation) && gameboard.isPlayerA == false){
                didBlindTakeBegin = true
                blindTakeCard.flipKind = "blindTake"
                blindTakeCard.isPlayerA = didBlindTakeBegin
                blindTakeCard.flipCard(auto: false, label: timerLabelB)
                dataManager.didBlindTakeEnd = blindTakeCard.isPlayerA
            }
            
        }
        
        // tap function4: flip at the first stage in two peak locations
        // order of first peak: A first, then b. after that A play first.
        if((CGRectContainsPoint(peakCards[0].frame, tapGestureLocation) &&  dataManager.dataIsPlayerA ) != nil){
            // ARight Peak location
            peakCards[0].flipKind = "stage1"
            peakCards[0].isPlayerA = isPlayerA
            peakCards[0].flipCard(auto: false, label: timerLabelA)
            isPlayerA = peakCards[0].isPlayerA
            //println(isPlayerA)
        }else if(CGRectContainsPoint(peakCards[1].frame, tapGestureLocation) && !dataManager.dataIsPlayerA) {
            // BRight Peak location
            peakCards[1].flipKind = "stage2"
            peakCards[1].isPlayerA = isPlayerA
            peakCards[1].flipCard(auto: false, label: timerLabelB)
            isPlayerA = peakCards[1].isPlayerA
            
            // force each time press start button, the order is always same
            self.gameboard.isPlayerA = isPlayerA
            
            startButton.hidden = true
            startButton.enabled = false
            playerButton.hidden = false
            playerButton.enabled = true
            //   peakCards = []
        }
        
        //tap function5: tap bingo buttons to indicate the winner of each side
        if((CGRectContainsPoint(bingoButtonA.frame, tapGestureLocation) && self.gameboard.isPlayerA && touchedBothPeaks && (isDealEnd == true) && (didBlindTakeBegin == false) && (didBlindSwapBegin == false) && (dataManager.didStoleBegin == false)) != nil){
            var didAWin = (self.gameboard.cardStoreLoc["ALeft"]!.isCardJack == true) && (self.gameboard.cardStoreLoc["AMiddle"]!.isCardQueen == true) && (self.gameboard.cardStoreLoc["ARight"]!.isCardKing == true)
            self.timer.invalidate()
            self.timer = nil
            self.moveGesture.enabled = false
            self.tapGesture.enabled = false
            self.gameboard.cardStoreLoc["ALeft"]!.flipCard(auto: true, label: nil)
            self.gameboard.cardStoreLoc["AMiddle"]!.flipCard(auto: true, label: nil)
            self.gameboard.cardStoreLoc["ARight"]!.flipCard(auto: true, label: nil)
            self.gameboard.cardStoreLoc["BLeft"]!.flipCard(auto: true, label: nil)
            self.gameboard.cardStoreLoc["BMiddle"]!.flipCard(auto: true, label: nil)
            self.gameboard.cardStoreLoc["BRight"]!.flipCard(auto: true, label: nil)
            
            
            if(didAWin == true){
                // A wins, B fails, show results and then restart the game
                //println("A wins")
                var alertView = UIAlertView()
                alertView.delegate = self
                alertView.title = "Victory"
                alertView.message = "PlayerA won!"
                alertView.addButtonWithTitle("Cancel")
                alertView.show()
            }else{
                // B wins, A fails, show results and then restart the game
                //println("B wins")
                var alertView = UIAlertView()
                alertView.title = "Lose"
                alertView.message = "PlayerB won!"
                alertView.addButtonWithTitle("Cancel")
                alertView.show()
            }
            
        }
        if(((CGRectContainsPoint(bingoButtonB.frame, tapGestureLocation) && !self.gameboard.isPlayerA) && touchedBothPeaks && (isDealEnd == true) && (didBlindTakeBegin == false) && (didBlindSwapBegin == false) && (dataManager.didStoleBegin == false) != nil) != nil){
            var didBWin = (self.gameboard.cardStoreLoc["BLeft"]!.isCardJack == true) && (self.gameboard.cardStoreLoc["BMiddle"]!.isCardQueen == true) && (self.gameboard.cardStoreLoc["BRight"]!.isCardKing == true)
            self.timer.invalidate()
            self.timer = nil
            self.moveGesture.enabled = false
            self.tapGesture.enabled = false
            self.gameboard.cardStoreLoc["ALeft"]!.flipCard(auto: true, label: nil)
            self.gameboard.cardStoreLoc["AMiddle"]!.flipCard(auto: true, label: nil)
            self.gameboard.cardStoreLoc["ARight"]!.flipCard(auto: true, label: nil)
            self.gameboard.cardStoreLoc["BLeft"]!.flipCard(auto: true, label: nil)
            self.gameboard.cardStoreLoc["BMiddle"]!.flipCard(auto: true, label: nil)
            self.gameboard.cardStoreLoc["BRight"]!.flipCard(auto: true, label: nil)
            
            if(didBWin == true){
                var alertView = UIAlertView()
                alertView.title = "Victory"
                alertView.message = "PlayerB won!"
                alertView.addButtonWithTitle("Cancel")
                alertView.show()// B wins, A fails, show results and then restart the game
            }else{
                var alertView = UIAlertView()
                alertView.title = "Lose"
                alertView.message = "PlayerA won!"
                alertView.addButtonWithTitle("Cancel")
                alertView.show()// A wins, B fails, show results and then restart the game
                
            }
            
        }
        
        // tap function6: ace effect: stole card from the opponent. Tap the card of three opponent's locations
        if(dataManager.didStoleBegin == true && didStolenPeakBegin == false){
            self.replayButton.hidden = true
            self.replayButton.enabled = false
            if(self.gameboard.isPlayerA == true){
                if(CGRectContainsPoint(self.gameboard.cardStoreLoc["BLeft"]!.frame, tapGestureLocation)){
                    self.gameboard.cardStoreLoc["BLeft"]!.highlight()
                    aceOpponentKey = "BLeft"
                    exchangeAnimation()
                }else if(CGRectContainsPoint(self.gameboard.cardStoreLoc["BMiddle"]!.frame, tapGestureLocation)){
                    self.gameboard.cardStoreLoc["BMiddle"]!.highlight()
                    aceOpponentKey = "BMiddle"
                    exchangeAnimation()
                }else if(CGRectContainsPoint(self.gameboard.cardStoreLoc["BRight"]!.frame, tapGestureLocation)){
                    self.gameboard.cardStoreLoc["BRight"]!.highlight()
                    aceOpponentKey = "BRight"
                    exchangeAnimation()
                }
            }
            else if(self.gameboard.isPlayerA == false){
                if(CGRectContainsPoint(self.gameboard.cardStoreLoc["ALeft"]!.frame, tapGestureLocation)){
                    self.gameboard.cardStoreLoc["ALeft"]!.highlight()
                    aceOpponentKey = "ALeft"
                    exchangeAnimation()
                }else if(CGRectContainsPoint(self.gameboard.cardStoreLoc["AMiddle"]!.frame, tapGestureLocation)){
                    self.gameboard.cardStoreLoc["AMiddle"]!.highlight()
                    aceOpponentKey = "AMiddle"
                    exchangeAnimation()
                }else if(CGRectContainsPoint(self.gameboard.cardStoreLoc["ARight"]!.frame, tapGestureLocation)){
                    self.gameboard.cardStoreLoc["ARight"]!.highlight()
                    aceOpponentKey = "ARight"
                    exchangeAnimation()
                }
            }
        }
        
        // tap function6.5: ace effect peaking procedure: peak the stolen card in my sides' peaking area. Then exchange that card with previous location's card.
        if(stolenCard != nil && exchangedCard != nil){
            
            if(CGRectContainsPoint(stolenCard.frame, tapGestureLocation)){
                stolenCard.isPlayerA = true
                stolenCard.flipKind = "stolenCard"
                if(self.gameboard.isPlayerA == true){
                    stolenCard.flipCard(auto: false, label: timerLabelA)
                }else if (self.gameboard.isPlayerA == false){
                     stolenCard.flipCard(auto: false, label: timerLabelB)
                }
                
                // meaning exchangedCard finished first
                if((exchangedCard.isPlayerA) != nil){
                    if(exchangedCard.isPlayerA == false){
                        self.replayButton.hidden = true
                        self.replayButton.enabled = false
                        self.continueButton.hidden = false
                        self.continueButton.enabled = true
                        self.view.bringSubviewToFront(self.continueButton)
                    }
                }
            }
            if(CGRectContainsPoint(exchangedCard.frame, tapGestureLocation)){
                exchangedCard.isPlayerA = true
                exchangedCard.flipKind = "exchangedCard"
                if(self.gameboard.isPlayerA == true){
                    exchangedCard.flipCard(auto: false, label: timerLabelB)
                }else if (self.gameboard.isPlayerA == false){
                    exchangedCard.flipCard(auto: false, label: timerLabelA)
                }
                
                if((stolenCard.isPlayerA) != nil){
                    if(stolenCard.isPlayerA == false){
                        self.replayButton.hidden = true
                        self.replayButton.enabled = false
                        self.continueButton.hidden = false
                        self.continueButton.enabled = true
                        self.view.bringSubviewToFront(self.continueButton)
                    }
                }
            }
            
        }
    }

    
    func moveCard(gr:UIGestureRecognizer){
        var gesture = gr as! UIPanGestureRecognizer
        var moveGestureLocation = gesture.locationInView(self.view)
        var movedScene: Card?
        var key: String?
        
        // switch rule: only allow one side, not right to left, or left to right
        (key,movedScene) = gameboard.getMovedFrame(moveGestureLocation)
        
        // after setting rules and get the moving card, set the status of relative card
        if((movedScene) != nil){
            self.view.bringSubviewToFront(movedScene!)
            gameboard.MovedFrame(key: key!, value: movedScene!, loc: moveGestureLocation)
        }
        else{
            self.moveGesture.enabled = false
        }
        
        // below is used to realize the differentiate between swap and peaking(blind) swap: when swap moves begin before peaking, peak card will disappear
        if((movedScene) != nil){
            if((blindSwapCard) != nil){
                blindSwapCard.removeFromSuperview()
                blindSwapCard = nil
            }
            
            if((blindTakeCard) != nil){
                blindTakeCard.removeFromSuperview()
                blindTakeCard = nil
            }
        }
        
        
        
        // the marker here is used to indicate the timer whether moving happened before the timer ends,
        // if true, the timer stoped natural recycle, if false, timer start recycle
        if(gesture.state == UIGestureRecognizerState.Began){
            didMoveBegin = true
        }
        
        // below deal with the condition where timer ends before dynamic moving ends
        if(gesture.state == UIGestureRecognizerState.Changed){
            if((movedScene) != nil){
                if(didTimerEnds == true){
                    gameboard.isMoveSucceed = false
                    gameboard.reset(resetHandyCard: true, key: key!, value: movedScene!)
                    self.gameboard.followRules(c:self.gameboard.correspondingTrackCard)
                    didTimerEnds = false
                    didMoveBegin = false
                    self.changePlayer()
                }
            }
        }
        // determine the final status of moving action
        if(gesture.state == UIGestureRecognizerState.Ended){
            println("gesture end")
            didMoveBegin = false
            if(movedScene){
                // timer ends after move success or timer ends before static move ends
                // do something
                gameboard.restoreStoreLoc(key: key!,movedCard: movedScene)
                
                // set for swap/blind swap auto moving card view
                if(dataManager.autoMovedCard){
                    self.view.bringSubviewToFront(dataManager.autoMovedCard!)
                }
                
                // for the condition where timer ends before static move ends
                if(didTimerEnds == true){
                    didTimerEnds = false
                    self.changePlayer()
                }
                
                // successful move ends before timer ends
                if(self.gameboard.isMoveSucceed == true){
                
                    // ace card effect,only effect when swap with peaking finished
                    if(self.gameboard.remainPileLoc.count != 0 && dataManager.didPeakSwapOccur == true && self.gameboard.remainPileLoc[self.gameboard.remainPileLoc.count - 1].isCardAce == true && self.gameboard.remainPileLoc[self.gameboard.remainPileLoc.count - 1].isAceUsed == false){
                        // timer pause
                        self.timer.invalidate()
                        self.timer = nil
                        if(gameboard.isPlayerA == true){
                            self.gameboard.cardStoreLoc["BLeft"]!.frameHighlight()
                            self.gameboard.cardStoreLoc["BMiddle"]!.frameHighlight()
                            self.gameboard.cardStoreLoc["BRight"]!.frameHighlight()
                        }else if(gameboard.isPlayerA == false){
                            self.gameboard.cardStoreLoc["ALeft"]!.frameHighlight()
                            self.gameboard.cardStoreLoc["AMiddle"]!.frameHighlight()
                            self.gameboard.cardStoreLoc["ARight"]!.frameHighlight()
                        }
                        if(self.gameboard.initPileLoc.count == 0){
                            reShuffle()
                        }
                        self.gameboard.remainPileLoc[self.gameboard.remainPileLoc.count - 1].isAceUsed = true
                        dataManager.didPeakSwapOccur = false
                        dataManager.didStoleBegin = true
                        didLockInit = true
                        // next step following is to  do card stole operation (tap operation)
                        
                    }
                    
                    // re-shuffle the cards in remainpile except the top one when no cards in init pile
                    else if(self.gameboard.initPileLoc.count == 0){
                        reShuffle()
                    }else{
                        self.changePlayer()
                    }
                    
                    
                }
                
            }else{ // here useless. it never goes here
                //timer ends before move ends
                self.gameboard.followRules(c:self.gameboard.correspondingTrackCard)
            }
        }
    }
    func reShuffle(){
        
        var newPileOrder: [Card] = []
        var angle = (CGFloat)((-0.5) / 4.0) % 0.1
        var TopCardInRemainPile = self.gameboard.remainPileLoc[self.gameboard.remainPileLoc.count - 1]
        self.timer.invalidate()
        self.timer = nil
        for(var i = 0; i < self.gameboard.remainPileLoc.count - 1; i++){
            if(i < self.gameboard.remainPileLoc.count - 2){
                UIView.animateWithDuration(1, delay: Double(i)/14, options:UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
                    self.gameboard.remainPileLoc[i].center = CGPoint(x: -60, y: 140)
                    self.gameboard.remainPileLoc[i].setFront == true
                    newPileOrder.append(self.gameboard.remainPileLoc[i])
                    self.gameboard.remainPileLoc[i].removeFromSuperview()
                    }  , completion:{
                        (Bool) -> Void in
                        //sound.stop()
                    })
            }else if(i  == self.gameboard.remainPileLoc.count - 2){
                UIView.animateWithDuration(1, delay: Double(i)/14, options:UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
                    self.gameboard.remainPileLoc[i].center = CGPoint(x: -60, y: 140)
                    //self.gameboard.remainPileLoc[i].setFrontCard(setFront: true)
                    newPileOrder.append(self.gameboard.remainPileLoc[i])
                    self.gameboard.remainPileLoc[i].removeFromSuperview()
                    }  , completion:{
                        (Bool) -> Void in
                        // below for loop decide whether cut in next cycle
                                                for c in newPileOrder{
                                                    c.setFrontCard(setFront: true)
                                                }
                        newPileOrder = self.randomCard(newPileOrder)
                        self.gameboard.remainPileLoc.removeAll(keepCapacity: false)
                        self.gameboard.remainPileLoc.append(TopCardInRemainPile)
                        
                        for(var j = 0; j < newPileOrder.count; ++j){
                            
                            UIView.animateWithDuration(0.15, delay: Double(j)/14, options:UIViewAnimationOptions.CurveEaseOut, animations: {() -> Void in
                                newPileOrder[j].center = self.gameboard.cardCenter["initPile"]!
                                newPileOrder[j].layer.setAffineTransform(CGAffineTransformMakeRotation(angle))
                                self.gameboard.initPileLoc.append(newPileOrder[j])
                                }  , completion:{
                                    (Bool) -> Void in
                                    //sound.stop()
                                })
                            angle = (CGFloat)((-0.5 + 0.1 * (CGFloat)(j+1)) / 4.0) % 0.1
                            self.view.addSubview(newPileOrder[j])
                            if(j == newPileOrder.count - 1){
                                 self.changePlayer()
                            }
                            
                        }
                        //sound.stop()
                    })
                
            }
        }
    }
    
    func exchangeAnimation(){
        if((stolenCard) != nil){
            stolenCard.removeFromSuperview()
            stolenCard = nil
        }
        if((exchangedCard) != nil){
            exchangedCard.removeFromSuperview()
            exchangedCard = nil
        }
        
        var sideCard = self.gameboard.cardStoreLoc[dataManager.previousKey!]!
        var anotherSideCard = self.gameboard.cardStoreLoc[self.aceOpponentKey]!
        self.view.bringSubviewToFront(sideCard)
        self.view.bringSubviewToFront(anotherSideCard)
        
        var sideCenter = self.gameboard.cardStoreLoc[dataManager.previousKey!]!.center
        var anotherSideCenter = self.gameboard.cardStoreLoc[self.aceOpponentKey]!.center
        
        UIView.animateWithDuration(1.0, delay: 0.3, options: UIViewAnimationOptions.CurveLinear, animations: {
            sideCard.center = anotherSideCenter
            anotherSideCard.center = sideCenter
            }, completion: {
                (Bool) -> Void in
                self.gameboard.cardStoreLoc[dataManager.previousKey!] = anotherSideCard
                self.gameboard.cardStoreLoc[self.aceOpponentKey] = sideCard
                // the stolen card is now in playerA(suppose A's ace effect) previous location; while exchanged card in playerB's location
                self.stolenCard = self.gameboard.setupInit(cardName: anotherSideCard.getCardName(), frontSet: anotherSideCard.setFront)
                self.exchangedCard = self.gameboard.setupInit(cardName:  sideCard.getCardName(), frontSet:  sideCard.setFront)
                self.stolenCard.center = self.gameboard.cardCenter[dataManager.previousKey!]!
                self.exchangedCard.center = self.gameboard.cardCenter[self.aceOpponentKey]!
                self.stolenCard.backCard.addShowLabel("Peak Here!")
                self.exchangedCard.backCard.addShowLabel("Peak Here!")
                self.gameboard.addSubview(self.stolenCard)
                self.gameboard.addSubview(self.exchangedCard)
                if(self.gameboard.isPlayerA == true){
                    self.exchangedCard.backCard.showLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                    UIView.animateWithDuration(0.3, delay: 0.3, options: UIViewAnimationOptions.CurveLinear, animations: {
                        self.stolenCard.center = self.gameboard.peakCenter["APeak"]!
                        self.exchangedCard.center = self.gameboard.peakCenter["BPeak"]!
                        }, completion: {
                            (Bool) -> Void in
                            self.stolenCard.frameHighlight()
                            self.exchangedCard.frameHighlight()

                        })
                    
                }else if (self.gameboard.isPlayerA == false){
                    self.stolenCard.backCard.showLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                    UIView.animateWithDuration(0.3, delay: 0.5, options: UIViewAnimationOptions.CurveLinear, animations: {
                        self.stolenCard.center = self.gameboard.peakCenter["BPeak"]!
                        self.exchangedCard.center = self.gameboard.peakCenter["APeak"]!
                        }, completion: {
                            (Bool) -> Void in
                            self.stolenCard.frameHighlight()
                            self.exchangedCard.frameHighlight()
                        })
                }                
            })
        dataManager.didStoleBegin = false
    }
    
    func changePlayer(){
        self.gameboard.isPlayerA = !self.gameboard.isPlayerA
        dataManager.isPlayerA = self.gameboard.isPlayerA
        self.replayButton.hidden = false
        self.replayButton.enabled = true
        self.continueButton.hidden = true
        self.continueButton.enabled = false
        if(self.timer != nil){
            self.timer.invalidate()
            self.timer = nil
        }
        self.setTimer()
        
        
        //blind take abnoraml condition1: press the remain pile, but no more actions. The code below tries to remove the peakcard in peak area
        // blind take abnormal condition2: blind take timer ends late than timer ends
        if(self.peakCards.count >= 3){
            self.peakCards[self.peakCards.count - 1].stopTimer()
            self.peakCards[self.peakCards.count - 1].removeFromSuperview()
            self.peakCards.removeLast()
        }
        
        // player label change
        if(self.gameboard.isPlayerA == true){
            self.gameboard.playerALabel.backgroundColor = UIColor.redColor()
            self.gameboard.playerBLabel.backgroundColor = UIColor.clearColor()
            self.timerLabel.transform = CGAffineTransformMakeRotation(2 * CGFloat(M_PI))
        }else if(self.gameboard.isPlayerA == false){
            self.gameboard.playerBLabel.backgroundColor = UIColor.redColor()
            self.gameboard.playerALabel.backgroundColor = UIColor.clearColor()
            self.timerLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        }
    }
    
    func resetDataManager(){
        dataManager.dataIsPlayerA = true
        dataManager.didBlindTakeEnd = true
        dataManager.didBlindSwapEnd = true
        dataManager.didBlindSwapOccur = false
        dataManager.autoMovedCard = nil
        dataManager.isPlayerA = self.gameboard.isPlayerA
        dataManager.didPeakSwapOccur = false
        dataManager.didStoleBegin = false
        dataManager.previousKey = nil
    }
    
    // sound is not loaded properly: start and stop happened at the same time
    //    func loadSounds(#soundName: String) -> AVAudioPlayer{
    //
    //        var dealingCardsSound: AVAudioPlayer = AVAudioPlayer()
    //        //var url: NSURL = NSBundle.mainBundle().URLForResource("Dealing", withExtension: "wav")
    //        var url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(soundName, ofType: nil))
    //        var error: NSError?
    //        dealingCardsSound = AVAudioPlayer(contentsOfURL: url, error: &error)
    //
    //        dealingCardsSound.numberOfLoops = -1
    //        dealingCardsSound.prepareToPlay()
    //        
    //        return dealingCardsSound
    //    }
}

var dataManager = DataManager()

struct DataManager{
    var dataIsPlayerA: Bool! = true
    var didBlindTakeEnd: Bool! = true
    var didBlindSwapEnd: Bool! = true
    var didBlindSwapOccur: Bool! = false
    var autoMovedCard: Card? = nil
    var isPlayerA: Bool! = true
    var didPeakSwapOccur: Bool! = false
    var didStoleBegin: Bool! = false
    var previousKey: String? = nil
    
}