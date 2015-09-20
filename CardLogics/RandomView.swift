import UIKit

class RandomView: UIViewController {
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cardOrder = ["HeartSix","HeartNine", "ClubQueen", "SpadeKing" ]
        
        // cannot randomlize due to the lanuage drawbacks.
         randomPile(cardOrder)
        println(cardOrder)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        
    } 
    // random the order of the original card pile
    func randomPile(arrayPile: [String]) -> [String] {
        var arry = arrayPile
        for( var i = arry.count-1; i > 0; --i){
            //var r = Int(arc4random())%(i+1)
            var r = Int(arc4random_uniform(UInt32(i+1)))
            var a = arry[r]
            arry[r] = arry[i]
            arry[i] = a
            //println(a)

        }
        return arry
    }

    
    
}