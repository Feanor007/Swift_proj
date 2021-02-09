//
//  ViewController.swift
//  Concentrations
//
//  Created by 唐泽宇 on 2018/7/26.
//  Copyright © 2018 唐泽宇. All rights reserved.
//

import UIKit

class ConcentrationViewController: UIViewController {
    
    private lazy var game = Concentration(numberOfPairsOfCards:numberOfPairsOfCards )
    var numberOfPairsOfCards: Int {
           return  (cardButtons.count + 1) / 2
    }
    private(set) var flipNumber = 0 {
        didSet{
           updateFlipLabel()
        }
    }
    private func updateFlipLabel (){
        let attributes:[NSAttributedString.Key:Any] = [
            .strokeWidth : 5.0,
            .strokeColor : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        ]
        let attributedString = NSAttributedString(string: "Flips: \(flipNumber)", attributes: attributes)
        flipCountLabel.attributedText = attributedString
    }
    @IBOutlet private weak var flipCountLabel: UILabel!{
        didSet{
            updateFlipLabel()
        }
    }
    
    
    @IBOutlet private var cardButtons: [UIButton]!
    
    
    @IBAction private func touchCard(_ sender: UIButton) {
        flipNumber += 1
        if let cardNumber = cardButtons.index(of: sender){
            game.chooseCard(at : cardNumber )
            updateViewFromModel()
        }
    }
    private func updateViewFromModel(){
        if cardButtons != nil {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp{
                button.setTitle(emoji(for:card) , for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            }
            else{
                button.setTitle(" ", for: UIControl.State.normal)
                button.backgroundColor = card.isMatched ?  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) : #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            }
        }
    }
}

   // private var emojiChoices = ["🐍","🔮","🦇","🌓","🐀","🦉","👁","🎃","💀","🧟‍♀️"]
    var theme: String?{
        didSet{
            emojiChoices = theme ?? ""
            emoji = [:]
            updateViewFromModel()
        }
    }
    private var emojiChoices = "🐍🔮🦇🌓🐀🦉👁🎃💀🧟‍♀️"
    private var emoji = [Card:String]()   
    private func emoji (for card : Card)->String{
        if emoji[card] == nil, emojiChoices.count > 0 {
            let randomStringIndex = emojiChoices.index(emojiChoices.startIndex, offsetBy:emojiChoices.count.arc4random)
            emoji[card] = String(emojiChoices.remove(at: randomStringIndex))
        }
         return emoji[card] ?? "?"
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
extension Int {
    var arc4random: Int {
        if self > 0{
        return Int(arc4random_uniform(UInt32(self)))
        }
        else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        }
        else {
            return 0
        }
    }
}
