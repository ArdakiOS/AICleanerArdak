//
//  MessagesModel.swift
//  AICleanerArdak
//
//  Created by Ardak Tursunbayev on 22.01.2025.
//

import Foundation

struct FolderMessagesResponse : Hashable, Decodable {
    let messages : [Messages]
    let nextPageToken : String?
}

struct Messages : Hashable, Decodable {
    let id : String
    let threadId : String
}

struct MessagesDetailedResponse : Hashable, Decodable {
    let id : String
    let payload : MessagesDetailedPayload
    let internalDate : String
}

struct MessagesDetailedPayload : Hashable, Decodable {
    let headers : [Header]
}

struct Header : Hashable, Decodable {
    let name : String
    let value : String
}

struct MessagesToDisplay : Hashable {
    var id : String
    var title : String
    var text : String
    var date : String
}


struct DeleteMessagesRequest : Hashable, Codable{
    var ids : [String]
}
