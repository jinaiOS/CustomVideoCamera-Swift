//
//  UserDefaultManager.swift
//  MZ-Dictionary
//
//  Created by 김지은 on 2023/11/12.
//

import Foundation

class UserDefaultManager {
    static let shared = UserDefaultManager()
    
    func storeStars(numb: Int) {
        var starArr: [Int] = []
        starArr.append(numb)
        UserDefaults.standard.set(starArr, forKey: "Star")
    }
    
    func getStars() -> Array<Any> {
        return UserDefaults.standard.object(forKey: "UserID") as? Array ?? []
    }
}
