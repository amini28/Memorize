//
//  DataManager.swift
//  Memorize
//
//  Created by Amini on 14/05/22.
//

import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseStorageInternal
import Realm
import RealmSwift
import SwiftUI

class DataManager: ObservableObject {
    
    private var firebaseGameItem: [GameItemFirebase] = []
    private var gameVersionFirebase: GameVersionFirebase?
    
    @Published public var item: [GameItem] = []

    @Published public var isLoading = true
    @State var noConnection = false

    @ObservedObject var monitor = NetworkMonitor()
    
    private func fetchDataVersion() {
        let db = Firestore.firestore().collection("version")
        db.addSnapshotListener { [self] snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error Fetching Documents: \(String(describing: error))")
                return
            }
            
            guard let cloudVersion = documents[0].data()["number"] as? String else {
                return
            }
            
            guard let listOfBackDesign = documents[0].data()["backDesign"] as? [String] else {
                return
            }
            
            checkVersion(cloudVersion, listOfBackDesign)
        }
    }
    
    private func fetchDataGame(complete: @escaping (_ success: Bool, _ data: [GameItemFirebase] ) -> Void ) {
        let db = Firestore.firestore().collection("Data")
        db
            .addSnapshotListener { [self] querySnapshot, error in

            guard let documents = querySnapshot?.documents else {
                print(" Error Fetching documents: \(String(describing: error))")
                return
            }

            self.firebaseGameItem = documents.compactMap { document -> GameItemFirebase? in
                do {
                    return try document.data(as: GameItemFirebase.self)
                    
                } catch {
                    print("Error decoding documents to Article: \(error)")
                    return nil
                }
            }
                complete(true, self.firebaseGameItem)
        }
    }
    
    private func checkVersion(_ cloudVersion: String, _ listOfBackDesign: [String]) {
        let realm = try! Realm()
        let version = realm.objects(GameVersion.self)
        
        if !version.isEmpty {
            let currentVersion = version[0].version as String
//            print("\(currentVersion) and cloud \(cloudVersion)")
            let backdesign = version[0].backDesign[0].item as String
            UserDefaults.standard.set(backdesign, forKey: "backdesign")

            if currentVersion != cloudVersion {
            
                self.deleteDb()
                self.updateDataItem(cloudVersion: cloudVersion, listOfBackDesign: listOfBackDesign)
                
                // update image name to base64
                updateImage()
                updateBackDesign()
            }

        } else {
            updateDataItem(cloudVersion: cloudVersion, listOfBackDesign: listOfBackDesign)
            updateImage()
            updateBackDesign()
        }
                
        updateImage()
        updateBackDesign()
        updateIcon()
        
        self.getItem()
        self.isLoading = false
        
    }
    
    private func updateDataItem(cloudVersion: String, listOfBackDesign: [String]){
        let version = GameVersion(cloudVersion)
        self.updateVersionToDb(version: version, listOfBackDesign: listOfBackDesign)
        
        fetchDataGame(complete: { state, items in
            if state {
                for item in items {
                    let gItem = GameItem()
                    
                    gItem.title = item.title
                    gItem.fastestTimer = item.FastestTimer
                    gItem.icon = item.Icon
                    gItem.descriptions = item.Descriptions
                    
                    for image in item.ItemImages {
                        let im = ItemImage(image)
                        gItem.itemImage.append(im)
                    }
                    
                    for match in item.ItemMatch {
                        let mat = ItemMatch(match)
                        gItem.itemMatch.append(mat)
                    }
                    
                    for pair in item.ItemPair {
                        let par = ItemPair(pair)
                        gItem.itemPair.append(par)
                    }

                    self.addItemTodb(item: gItem)
                }
            }
        })
    }
    
    private func getItem() {
        let realm = try! Realm()
        let items = realm.objects(GameItem.self)
        self.item = Array(items)
    }
    
    private func addItemTodb(item: GameItem) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(item)
        }

    }
    
    private func updateVersionToDb(version: GameVersion, listOfBackDesign: [String]){
        let realm = try! Realm()
        for item in listOfBackDesign {
            let backD = BackItemImage(item)
            version.backDesign.append(backD)
        }
        try! realm.write {
            realm.add(version)
        }
    }
    
    private func deleteDb() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }

    }
    
    func startCheckingNetworkCall() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.monitor.isConnected {
                self.isLoading = true
                self.noConnection = false

                self.fetchDataVersion()
            } else {
                self.isLoading = false
                self.noConnection = true

            }
        }
    }
    
    private func fetchImage(_ name: String, _ foldername: String, completion: @escaping (Bool, Data) -> Void ){
        
        let storage = Storage.storage(url: "gs://memorize-8aa44.appspot.com")
        let storageRef = storage.reference()
        let islandRef = storageRef.child("\(foldername)\(name)")
        var returnData = Data()
        
        print("#########################")
        
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
              print(error.localizedDescription)
              completion(false, Data())
          } else {
              returnData = data!
              print("returnData >>>>>>>>>>> \(returnData)")
              completion(true, returnData)
          }
        }
    }
    
    private func updateImage() {
        let realm = try! Realm()
        let gameItem = realm.objects(GameItem.self)

        if !gameItem.isEmpty {
            for item in gameItem {
                if !item.itemImage.isEmpty {
                    for image in item.itemImage {

                        self.fetchImage(image.data, "", completion: { state, data in
                            try! realm.write {

                                if state {
                                    let dataString = data.base64EncodedString(options: .lineLength64Characters)
                                    image.data = dataString
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    private func updateIcon() {
        let realm = try! Realm()
        let gameItem = realm.objects(GameItem.self)

        if !gameItem.isEmpty {
            for item in gameItem {
                if !item.icon.isEmpty {
                    self.fetchImage(item.icon, "Icon/", completion: { state, data in
                        try! realm.write {

                            if state {
                                let dataString = data.base64EncodedString(options: .lineLength64Characters)
                                item.icon = dataString
                            }
                        }
                    })
                }
            }
        }
    }
    
    private func updateBackDesign() {
        let realm = try! Realm()
        let version = realm.objects(GameVersion.self)
        if !version.isEmpty {
            for versionItem in version {
                for itemBackDesign in versionItem.backDesign {
                    self.fetchImage(itemBackDesign.item, "back/" ,completion: { state, data in
                        try! realm.write {
                            if state {
                                let dataString = data.base64EncodedString(options: .lineLength64Characters)
                                itemBackDesign.item = dataString
                            }
                        }
                    })
                }
            }
        }
    }

}

