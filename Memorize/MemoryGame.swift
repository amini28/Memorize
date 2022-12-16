//
//  MemoryGame.swift
//  Memorize
//
//  Created by Amini on 09/05/22.
//

import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable {
    private(set) var cards: Array<Card>
    
    private var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get { cards.indices.filter({ cards[$0].isFaceUp }).only }
        set { cards.indices.forEach({ cards[$0].isFaceUp = ($0 == newValue) }) }
    }
    
    mutating func choose(_ card: Card){
        if let choosenIndex = cards.firstIndex(where: { $0.id == card.id}),
            !cards[choosenIndex].isFaceUp,
            !cards[choosenIndex].isMatched {

            if let potentionalMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                if cards[choosenIndex].content == cards[potentionalMatchIndex].content {
                    cards[choosenIndex].isMatched = true
                    cards[potentionalMatchIndex].isMatched = true
                }
                cards[choosenIndex].isFaceUp = true
            } else {
                indexOfTheOneAndOnlyFaceUpCard = choosenIndex
            }
            cards[choosenIndex].isFaceUp.toggle()
        }

        print("\(cards)")
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    init(numberOfPairsOfCards: Int,
         createCardContent: (Int) -> CardContent) {
        cards = []
        //add numbersOfPairOfCards x 2 cards to cards array
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = createCardContent(pairIndex)
            cards.append(Card(content: content, id: pairIndex*2))
            cards.append(Card(content: content, id: pairIndex*2+1))
        }
    }
    
    struct Card: Identifiable {
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        let content: CardContent
        let id: Int
    }
}

extension Array {
    var only: Element? { count == 1 ? first : nil }
}
