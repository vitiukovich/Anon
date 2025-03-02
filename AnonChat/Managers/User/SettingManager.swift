//
//  SettingManager.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 2/28/25.
//

import UserNotifications
import UIKit

class SettingManager {
    
    static let shared = SettingManager()
    private init() {}
    
    func turnOnNotification(_ value: Bool) {
        if value {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
            }
        } else {
            disableNotifications()
        }
    }
        
    func turnOnDarkMode(_ value: Bool) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }
        
        window.overrideUserInterfaceStyle = value ? .dark : .unspecified
    }
    
    
    func deleteCurrentUser(completion: @escaping (Result<Void, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var lastError: Error?

        dispatchGroup.enter()
        UserService.shared.deleteCurrentUser { result in
            if case .failure(let error) = result { lastError = error }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        clearRealmData { _ in
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        AuthService.shared.deleteUser { result in
            if case .failure(let error) = result { lastError = error }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        clearUserDefaults {
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            if let error = lastError {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func clearRealmData(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try LocalChatService.shared.deleteAllChats()
            try LocalContactService.shared.deleteAllContacts()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
        
    private func clearUserDefaults(completion: @escaping () -> Void) {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        for key in dictionary.keys {
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
        completion()
    }

    private func disableNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}

