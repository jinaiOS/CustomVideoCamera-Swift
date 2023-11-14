//
//  ListModel.swift
//  MZ-Dictionary
//
//  Created by 김지은 on 2023/11/09.
//

import Foundation

struct ListModel: Codable {
    let isNew: Bool?
    let title: String?
    let content: String?
    let image: String?
    let star: Bool?
    
    enum CodingKeys: String, CodingKey {
        case isNew
        case title
        case content
        case image
        case star
    }
}
