//
//  MemoryGameModel.swift
//  Memorize
//
//  Created by Amini on 09/05/22.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import Realm
import RealmSwift

class MemoryGameModel: ObservableObject {
    
    @Published var backImage: String
    
    public var itemMatches: [ItemMatch]
    public var itemPair: [ItemPair]
    public var itemImage: [ItemImage]
        
    @Published public var cards: Array<Card> = []

    private var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get { cards.indices.filter({ cards[$0].isFaceUp }).only }
        set { cards.indices.forEach({ cards[$0].isFaceUp = ($0 == newValue )}) }
    }
    
    func choose(_ card: Card) {
        if let choosenIndex = cards.firstIndex(where: { $0.id == card.id }),
           !cards[choosenIndex].isFaceUp,
           !cards[choosenIndex].isMatched {

            if let potentionalMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                if cards[choosenIndex].pairIndex == cards[potentionalMatchIndex].pairIndex {
                    cards[choosenIndex].isMatched = true
                    cards[potentionalMatchIndex].isMatched = true
                }
                cards[choosenIndex].isFaceUp = true
            } else {
                indexOfTheOneAndOnlyFaceUpCard = choosenIndex
            }
            cards[choosenIndex].isFaceUp = true
            print(cards[choosenIndex].isFaceUp)
        }
    }
    
    init(itemImage: [ItemImage],
         itemMatches: [ItemMatch],
         itemPair: [ItemPair],
         backImage: String ) {
        self.itemImage = itemImage
        self.itemMatches = itemMatches
        self.itemPair = itemPair
        self.backImage = backImage
    }
        
    func createNewGame(with numberOfPairsOfCards: Int) {
        cards = []
        
        for pairIndex in 0..<numberOfPairsOfCards {
            cards.append(Card(id: pairIndex*2,
                              content: itemPair[pairIndex].name,
                              image: itemImage[pairIndex].data,
                              pairIndex: pairIndex,
                              backDesign: backImage))
            cards.append(Card(id: pairIndex*2+1,
                              content: itemMatches[pairIndex].name,
                              image: itemImage[pairIndex].data,
                              pairIndex: pairIndex,
                              backDesign: backImage))
        }
        cards.shuffle()
    }
    
}

struct Card: Identifiable {
    var isFaceUp: Bool = false
    var isMatched: Bool = false
    let matches: String = ""
    let pairs: String = ""
    let id: Int
    let content: String
    let image: String
    let pairIndex: Int
    let backDesign: String
}


