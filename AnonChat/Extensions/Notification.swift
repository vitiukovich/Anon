//
//  Notification.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/25/25.
//

import Foundation

extension Notification.Name {
    static let newAutoDeleteTime = Notification.Name("newAutoDeleteTime")
    static let newMessageReceived = Notification.Name("newMessageReceived")
    static let newMessageSaved = Notification.Name("newMessageSaved")
    static let chatWillBeDeleted = Notification.Name("chatWillBeDeleted")
}
