//
//  Concentration.swift
//  Concentrations
//
//  Created by 唐泽宇 on 2018/7/26.
//  Copyright © 2018 唐泽宇. All rights reserved.
//

import Foundation
struct Concentration {
   private(set) var cards = [Card]()
   private  var indexOfOneAndOnlyFaceUpCard: Int?{
        get{
            return cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly
//            var foundIndex : Int?
//            for index in cards.indices{
//                if cards[index].isFaceUp, foundIndex == nil{
//                    foundIndex = index
//                }
//                else{
//                    return nil
//                }
//            }
//            return foundIndex
        }
        set{
            for index in cards.indices{
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
   mutating func chooseCard(at index: Int) {
        assert(cards.indices.contains(index),"Concentration.chooseCard (at: \(index)): choose index not in the cards")
        if !cards[index].isMatched{
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index{
                //check if cards match
                if cards[matchIndex] == cards[index]{
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                }
                cards[index].isFaceUp = true
            }
            else{
                //either two cards or no card face up
                indexOfOneAndOnlyFaceUpCard = index
            }
        }
        
    }
    init (numberOfPairsOfCards : Int){
        assert(numberOfPairsOfCards > 0 , "Concentration.init(\(numberOfPairsOfCards) : you must at least have one pair of cards")
        for _ in 0..<numberOfPairsOfCards{
            let card = Card()
          cards += [card, card]
        }
        // shuffle the cards
        shuffle()
    }
    mutating func shuffle() {
     for i in 0..<cards.count{
            let randomNumber = Int(arc4random_uniform(UInt32(cards.count)))
            let tempCards = cards[i]
            cards[i] = cards[randomNumber]
            cards[randomNumber] = tempCards
        }
    }
}
extension Collection {
    var oneAndOnly:Element?{
        return count == 1 ? first : nil
    }

}

