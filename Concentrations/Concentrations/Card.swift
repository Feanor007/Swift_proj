//
//  Card.swift
//  Concentrations
//
//  Created by 唐泽宇 on 2018/7/26.
//  Copyright © 2018 唐泽宇. All rights reserved.
//

import Foundation
struct Card:Hashable 
{
//    var hashValue: Int {return identifier}
//    static func == (lhs:Card,rhs:Card) -> Bool{
//        return lhs.identifier == rhs.identifier
//    }
    var isFaceUp = false
    var isMatched = false
    var identifier : Int
    private static var identifierFactory = 0
    private static func getUniqueIdentifier()->Int {
          identifierFactory += 1
          return  identifierFactory
    }
    init (){
        self.identifier = Card.getUniqueIdentifier()
    }
    
}
