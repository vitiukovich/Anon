//
//  Notification.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/25/25.
//

import Foundation

extension Notification.Name {
    static let newMessageReceived = Notification.Name("newMessageReceived")
    static let chatWillBeDeleted = Notification.Name("chatWillBeDeleted")
}
