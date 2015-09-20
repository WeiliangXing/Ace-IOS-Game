

import UIKit

class highlight: UIViewController {
    //    // tiles
    var tileDown: tileView!
    
    var location : CGPoint!
    var tapGesture: UITapGestureRecognizer!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var w = 60.0 as CGFloat
        var h = 100.0 as CGFloat
        
        tileDown = tileView(position: CGPointMake(self.view.center.x-w/2, self.view.center.y - h/2), width: w,height: h,cardImage: "King60*100", label: 1)
        
        // here sets the appearing effect
        //tileDown.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopStartScale, tilePopStartScale))
        self.view.addSubview(tileDown)
        self.view.bringSubviewToFront(tileDown)
        
        tapGesture = UITapGestureRecognizer(target: self, action: Selector("highlightGesture"))
        self.view.addGestureRecognizer(tapGesture)
        //var r = arc4random()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func highlightGesture(){
        let tilePopStartScale: CGFloat = 0.1
        let tilePopMaxScale: CGFloat = 1.1
        let tilePopDelay: NSTimeInterval = 0.05
        let tileExpandTime: NSTimeInterval = 0.18
        let tileContractTime: NSTimeInterval = 0.08
        
        location = tapGesture.locationInView(self.view)
        var startRect: CGRect = tileDown.frame
        var touchIn = CGRectContainsPoint(startRect, location)
        println(startRect)
        println(location)
        if(touchIn == true){
            
            UIView.animateWithDuration(tileExpandTime, delay: tilePopDelay, options: UIViewAnimationOptions.TransitionNone,
                animations: { () -> Void in
                    // Make the tile 'pop'
                    self.tileDown.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopMaxScale, tilePopMaxScale))
                },
                completion: { (fished: Bool) -> Void in
                    // Shrink the tile after it 'pops'
                    UIView.animateWithDuration(tileContractTime, animations: { () -> Void in
                        self.tileDown.layer.setAffineTransform(CGAffineTransformIdentity)
                        })
                })
        }

    }
    
    func highlight(#touchInside:CBool, tile: tileView){
        
        let tilePopStartScale: CGFloat = 0.1
        let tilePopMaxScale: CGFloat = 1.1
        let tilePopDelay: NSTimeInterval = 0.05
        let tileExpandTime: NSTimeInterval = 0.18
        let tileContractTime: NSTimeInterval = 0.08
        
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