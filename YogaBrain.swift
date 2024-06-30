//
//  YogaBrain.swift
//  Yoga Timer App
//
//  Created by Chiraag Nadig on 2/28/21.
//  Copyright © 2021 Chiraag Nadig. All rights reserved.
//

import Foundation

struct YogaBrain {
    var countSpeed = 0
    var countsIn = 0
    var inHold = 0
    var countsOut = 0
    var outHold = 0
    var sets = 0
    
    mutating func calculateValues(exercise: Int) {
        
        if exercise == 1 {
            countSpeed = 4
            countsIn = 0
            inHold = 0
            countsOut = 20
            outHold = 0
            sets = 1
        }
        else if exercise == 2 {
            countSpeed = 4
            countsIn = 1
            inHold = 0
            countsOut = 1
            outHold = 0
            sets = 20
        }
        else if exercise == 3 {
            countSpeed = 3
            countsIn = 5
            inHold = 0
            countsOut = 10
            outHold = 0
            sets = 2
        }
        else if exercise == 4 {
            countSpeed = 3
            countsIn = 5
            inHold = 0
            countsOut = 10
            outHold = 0
            sets = 1
        }
        else if exercise == 5 {
            countSpeed = 3
            countsIn = 5
            inHold = 5
            countsOut = 10
            outHold = 0
            sets = 1
        }
        else if exercise == 6 {
            countSpeed = 3
            countsIn = 5
            inHold = 0
            countsOut = 10
            outHold = 5
            sets = 1
        }
        else if exercise == 7 {
            countSpeed = 3
            countsIn = 5
            inHold = 5
            countsOut = 10
            outHold = 5
            sets = 1
        }
        
    }
    
    func returnCountSpeed() -> Int {
        return countSpeed
    }
    
    func returnCountsIn() -> Int {
        return countsIn
    }
    
    func returnInHold() -> Int {
        return inHold
    }
    
    func returnCountsOut() -> Int {
        return countsOut
    }
    
    func returnOutHold() -> Int {
        return outHold
    }
    
    func returnSets() -> Int {
        return sets
    }
}
