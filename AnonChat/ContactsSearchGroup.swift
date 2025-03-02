//
//  ContactsSearchGroup.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/14/25.
//

import Foundation

enum DataSourceType {
    case local
    case network
    case separator(String)
}

struct DisplayItem {
    let type: DataSourceType
    let contact: Contact?
}
