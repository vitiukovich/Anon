//
//  AppDelegate.swift
//  chatApp
//
//  Created by Stanislav Vitiuk on 12/22/24.
//

import UIKit
import Firebase
import FirebaseMessaging
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupRealmMigrations()
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        setupNotifications()
        setDefaultSettings()
        deleteExpiredMessages()
        return true
    }
    
    func deleteExpiredMessages() {
        let realm = try! Realm()
        let allChats = realm.objects(Chat.self)

        for chat in allChats {
            LocalChatService.shared.deleteExpiredMessages(for: chat)
        }
    }

    func setupNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                UserDefaults.standard.set(false, forKey: "notificationsEnabled")
            }
        }
    }
    
    func setupRealmMigrations() {
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: Chat.className()) { _, newObject in
                        newObject?["deleteTimer"] = nil
                    }
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }

    private func setDefaultSettings() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "notificationsEnabled") == nil {
            defaults.set(true, forKey: "notificationsEnabled")
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        guard let fcmToken = fcmToken else { return }
        
        if let currentUID = UserManager.shared.currentUID {
            UserService.shared.updateCurrentUserData(userID: currentUID, fcmToken: fcmToken, completion: {_ in })
        }
        
    }
}

