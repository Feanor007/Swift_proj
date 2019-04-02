//
//  NumberCardsSet.swift
//  TrailingTest
//
//  Created by 唐泽宇 on 2019/3/28.
//  Copyright © 2019 唐泽宇. All rights reserved.
//

import Foundation
struct NumberCardsSet: Codable{
    var numberCards = [CardInfo]()
    struct CardInfo: Codable{
        let x: Int
        let y: Int
        let text: String
        let size: Int
    }
    init?(json:Data){
        if let newValue = try? JSONDecoder().decode(NumberCardsSet.self, from: json){
            self = newValue
        }else{
            return nil
        }
    }
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    init (numberCards:[CardInfo]){
        self.numberCards = numberCards
}
}
