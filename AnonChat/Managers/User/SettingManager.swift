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
        let timeoutSeconds: TimeInterval = 10.0
        let dispatchGroup = DispatchGroup()
        var firstError: Error? = nil
        var didComplete = false
        let lock = NSLock()

        func safeComplete(_ result: Result<Void, Error>) {
            lock.lock()
            defer { lock.unlock() }
            guard !didComplete else { return }
            didComplete = true
            completion(result)
        }
        
        dispatchGroup.enter()
        UserService.shared.deleteUserInFirestore { result in
            switch result {
            case .success(): break
            case .failure(let error):
                firstError = error
                Logger.log(error.localizedDescription, level: .error)
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        clearRealmData() { result in
            switch result {
            case .success(): break
            case .failure(let error):
                if firstError == nil {
                    firstError = error
                }
                Logger.log(error.localizedDescription, level: .error)
            }
            dispatchGroup.leave()
        }
            
        

        dispatchGroup.enter()
        AuthService.shared.deleteUser { result in
            switch result {
            case .success(): break
            case .failure(let error):
                if firstError == nil {
                    firstError = error
                }
                Logger.log(error.localizedDescription, level: .error)
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        clearUserDefaults {
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            if let firstError = firstError {
                safeComplete(.failure(firstError))
            } else {
                safeComplete(.success(()))
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + timeoutSeconds) {
            safeComplete(.failure((firstError ?? NSError(domain: "DeleteUserError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Time exceeded"]))))
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

