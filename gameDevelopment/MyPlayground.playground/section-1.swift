 protocol RandomNumberGenerator{
    func random() -> Double
 }
 
 class LinearCongruentialGenerator: RandomNumberGenerator {
    var lastRandom = 42.0
    let m = 139968.0
    let a = 3877.0
    let c = 29573.0
    func random() -> Double {
        lastRandom = ((lastRandom * a + c) % m)
        return lastRandom / m
    }
 }
 let generator = LinearCongruentialGenerator()
 println("Here's a random number: \(generator.random())")
 // prints "Here's a random number: 0.37464991998171"
 println("And another one: \(generator.random())")
 // prints "And another one: 0.729023776863283”
 println("And another one: \(generator.random())")
 
 var a = ((42.0 * 3877.0 + 29573.0) % 139968.0)/139968.0
 