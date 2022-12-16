//
//  GameItem.swift
//  Memorize
//
//  Created by Amini on 17/05/22.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase
import Realm
import RealmSwift

struct GameItemFirebase: Identifiable, Codable {

    @DocumentID var id: String?
    var title: String
    var LongerTimer: String
    var FastestTimer: String
    var Icon: String
    var Descriptions: String
    var ItemMatch: [String]
    var ItemImages: [String]
    var ItemPair: [String]
}

struct GameVersionFirebase: Identifiable, Codable {
    @DocumentID var id: String?
    var backDesign: [String]
    var number: String
}

class ItemMatch: Object {
    @objc dynamic var name = ""
    
    let ofItem = LinkingObjects(fromType: GameItem.self,
                                property: "itemMatch")
    
    convenience init(_ name: String) {
        self.init()
        self.name = name
    }
}

class ItemPair: Object {
    @objc dynamic var name = ""
    
    let ofItem = LinkingObjects(fromType: GameItem.self,
                                property: "itemPair")
    
    convenience init(_ name: String) {
        self.init()
        self.name = name
    }
}

class ItemImage: Object {
    @objc dynamic var data = ""
    
    let ofItem = LinkingObjects(fromType: GameItem.self,
                                property: "itemImage")
    
    convenience init(_ data: String){
        self.init()
        self.data = data
    }
}

class BackItemImage: Object {
    @objc dynamic var item = ""
    
    let ofItem = LinkingObjects(fromType: GameVersion.self, property: "backDesign")

    convenience init(_ stringItem: String){
        self.init()
        self.item = stringItem
    }
}

class GameVersion: Object {
    @objc dynamic var version = ""
    let backDesign = List<BackItemImage>()
    
    convenience init(_ data: String){
        self.init()
        self.version = data
    }
}

class GameItem: Object, Identifiable {
    @objc dynamic var title = ""
    @objc dynamic var descriptions = ""
    @objc dynamic var longestTimer = ""
    @objc dynamic var fastestTimer = ""
    @objc dynamic var icon = ""
    let itemImage = List<ItemImage>()
    let itemMatch = List<ItemMatch>()
    let itemPair = List<ItemPair>()
    
    convenience init(_ title: String, _ desc: String, _ longTimer: String, _ fastTimer: String, _ icon: String) {
        self.init()
        self.title = title
        self.descriptions = desc
        self.longestTimer = longTimer
        self.fastestTimer = fastTimer
        self.icon = icon
    }
}

