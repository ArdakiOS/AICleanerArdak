//
//  EmailFolderModel.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 22.01.2025.
//

import Foundation

struct LabelModel : Hashable, Decodable {
    let id : String
    let name : String
    let messagesTotal : Int?
}

struct EmailFolderResponseModel : Decodable {
    let labels : [LabelModel]
}
