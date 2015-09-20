import UIKit


class CardActionView: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var peakLabel: UILabel!
    
    var KingCard: Card!

    
    var moveGesture : UIPanGestureRecognizer!
    var tapGesture :  UITapGestureRecognizer!
    var setFront: Bool!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        var w = 60.0 as CGFloat
        var h = 100.0 as CGFloat
        
        setFront = true
        KingCard = Card(cardImage: "King60*100",position: CGPoint(x: 0, y: 0), width: w,height: h)
        // determine initial status of the card
        KingCard.setFrontCard(setFront: setFront)
        
        
        self.view.addSubview(KingCard)
        
        setupAction()



    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func setupAction(){
        
        //highlight gesture
        //note: in action selector, donot forget the":"!!!
        tapGesture =  UITapGestureRecognizer(target: self, action: "highlightCard:")
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        // move gesture
        moveGesture = UIPanGestureRecognizer(target: self, action: "moveCard:")
        moveGesture.minimumNumberOfTouches = 1
        moveGesture.delegate = self
        self.view.addGestureRecognizer(moveGesture)
        
    }
    
    
    func highlightCard(gr: UITapGestureRecognizer){
        var tapGestureLocation = gr.locationInView(self.view)
        var tapTouchIn = CGRectContainsPoint(KingCard.frame, tapGestureLocation)
        
        if(tapTouchIn == true){
            KingCard.highlight()
        }
    }
    
    func moveCard(gr:UIGestureRecognizer){
        var gesture = gr as! UIPanGestureRecognizer
        var moveGestureLocation = gesture.locationInView(self.view)
        var moveTouchIn = CGRectContainsPoint(KingCard.frame, moveGestureLocation)
        
        
        // for future use
        var choose = "flipManual"
        var doAuto = true
        var notAuto = false

        
        // move card by change its center
        if(moveTouchIn == true){
            KingCard.center = moveGestureLocation
        }
        

        if(gesture.state == UIGestureRecognizerState.Ended){
            
            switch(choose){
            case "flipManual" :
                KingCard.setTimer(Label: timerLabel)
               // KingCard.flipCard(auto:notAuto)
                //????issue: cannot prevent move again during countdown time

                
            case "flipAuto" : println("sth")//KingCard.flipCard(auto:doAuto)

                
            case "endHighlight":KingCard.highlight()
            case "endBackOrigin": KingCard.center =  KingCard.originCenter
            case "flipAtEnd":
                println("will have sth")
//                doesShowBack =  !doesShowBack
//                KingCard.initShowCard(doesShowBack: doesShowBack)
                
            default: println("error")
            }
            
            
        }
        
    }
    
    // gesture delegate experiments
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool{
        
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    
}
