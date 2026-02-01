//
//  Card.swift
//  Concentration
//
//  Created by kamila on 01.02.2026.
//

import Foundation

struct Card {
    var identifier: Int 
    var isFaceUp = false
    var isMatched = false
    
    private static var identifierFactory = 0
    private static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        
        return identifierFactory
    }
    
    init() {
        self.identifier = Card.getUniqueIdentifier()
    }
}
