//
//  FireStoreManager.swift
//  MZ-Dictionary
//
//  Created by 김지은 on 2023/11/09.
//

import Foundation
import FirebaseFirestore

class FireStoreManager {
    static let shared = FireStoreManager()
    private let db = Firestore.firestore()
    var lastDoc: QueryDocumentSnapshot?
    
    //MARK: Fetch
    func fetchNumberOfDoc() async -> (result: Int?, error: Error?) {
        let ref = db.collection("list")
        let countQuery = ref.count
        do {
            let snapshot = try await countQuery.getAggregation(source: .server)
            print(snapshot.count.intValue)
            return (snapshot.count.intValue, nil)
        } catch {
            print(error)
            return (nil, error)
        }
    }
    
    func fetchNumberOfStarDoc() async -> (result: Int?, error: Error?) {
        let ref = db.collection("list").whereField("star", isEqualTo: true)
        let countQuery = ref.count
        do {
            let snapshot = try await countQuery.getAggregation(source: .server)
            print(snapshot.count.intValue)
            return (snapshot.count.intValue, nil)
        } catch {
            print(error)
            return (nil, error)
        }
    }
    
    /// fetch list
    func fetchList(pageSize: Int, completion: @escaping ([ListModel]?) -> Void) {
        var dic: [[String: Any]] = []
        var value: [ListModel]?

        let query: Query = db.collection("list").limit(to: pageSize)
        if pageSize == 10 {
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion(value) // 호출하는 쪽에 빈 배열 전달
                    return
                }
                
                for document in querySnapshot?.documents ?? [] {
                    dic.append(document.data())
                }
                self.lastDoc = querySnapshot?.documents.last
                dic.remove(at: 0)
                value = self.dictionaryToObject(objectType: ListModel.self, dictionary: dic)
                print("list result: \(String(describing: value))")
                completion(value) // 성공 시 이름 배열 전달
            }
        } else {
            query.addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Error retrieving list: \(error.debugDescription)")
                    return
                }
                
                guard let lastSnapshot = snapshot.documents.last else {
                    print("Error retrieving list: \(error.debugDescription)")
                    return
                }
                
                query.start(afterDocument: self.lastDoc!).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                        completion(value) // 호출하는 쪽에 빈 배열 전달
                        return
                    }
                    
                    for document in querySnapshot?.documents ?? [] {
                        dic.append(document.data())
                    }
                    
                    //                dic.remove(at: 0)
                    print(self.dicToObject(objectType: ListModel.self, dictionary: lastSnapshot.data()))

                    value = self.dictionaryToObject(objectType: ListModel.self, dictionary: dic)
                    print("list result: \(String(describing: value))")
                    completion(value) // 성공 시 이름 배열 전달
                }
            }
        }
    }
    
    /// fetch list
    func fetchStarList(pageSize: Int, completion: @escaping ([ListModel]?) -> Void) {
        var dic: [[String: Any]] = []
        var value: [ListModel]?

        let query: Query = db.collection("list").limit(to: pageSize).whereField("star", isEqualTo: true)
        if pageSize == 10 {
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion(value) // 호출하는 쪽에 빈 배열 전달
                    return
                }
                
                for document in querySnapshot?.documents ?? [] {
                    dic.append(document.data())
                }
                self.lastDoc = querySnapshot?.documents.last
                dic.remove(at: 0)
                value = self.dictionaryToObject(objectType: ListModel.self, dictionary: dic)
                print("list result: \(String(describing: value))")
                completion(value) // 성공 시 이름 배열 전달
            }
        } else {
            query.addSnapshotListener { (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Error retrieving list: \(error.debugDescription)")
                    return
                }
                
                guard let lastSnapshot = snapshot.documents.last else {
                    print("Error retrieving list: \(error.debugDescription)")
                    return
                }
                
                query.start(afterDocument: self.lastDoc!).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                        completion(value) // 호출하는 쪽에 빈 배열 전달
                        return
                    }
                    
                    for document in querySnapshot?.documents ?? [] {
                        dic.append(document.data())
                    }
                    
                    //                dic.remove(at: 0)
                    print(self.dicToObject(objectType: ListModel.self, dictionary: lastSnapshot.data()))

                    value = self.dictionaryToObject(objectType: ListModel.self, dictionary: dic)
                    print("list result: \(String(describing: value))")
                    completion(value) // 성공 시 이름 배열 전달
                }
            }
        }
    }
    
    //MARK: Store
    func storeStarList(index: Int, isStar: Bool) {
        let ref = db.collection("list").document(String(index))
        
        ref.updateData([
            "star": isStar
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
//                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
}
extension FireStoreManager {
    public enum StoreError: Error {
        case failedToFetch
        
        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "데이터 가져오기 실패"
            }
        }
    }
}
extension FireStoreManager {
    func dictionaryToObject<T:Decodable>(objectType:T.Type,dictionary:[[String:Any]]) -> [T]? {
        guard let dictionaries = try? JSONSerialization.data(withJSONObject: dictionary) else { return nil }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let objects = try? decoder.decode([T].self, from: dictionaries) else { return nil }
        return objects
    }
    
    func dicToObject<T:Decodable>(objectType:T.Type,dictionary:[String:Any]) -> T? {
        guard let dictionaries = try? JSONSerialization.data(withJSONObject: dictionary) else { return nil }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let objects = try? decoder.decode(T.self, from: dictionaries) else { return nil }
        return objects
    }
}
