//
//  Contact.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 12/27/24.
//

import RealmSwift
import FirebaseAuth

final class Contact: Object {
    @Persisted(primaryKey: true) var id: String? = ""
    @Persisted var username: String = ""
    @Persisted var status: String = ""
    @Persisted var profileImage: String = ""
    @Persisted var userID: String = ""
    @Persisted var currentUID: String = ""
    @Persisted var publicKey: String = ""
    @Persisted var isContactBlocked: Bool = false
    
    init(username: String, status: String, profileImage: String, userID: String, publicKey: String, isContactBlocked: Bool = false) {
        self.username = username
        self.status = status
        self.profileImage = profileImage
        self.userID = userID
        self.publicKey = publicKey
        self.isContactBlocked = isContactBlocked
        self.currentUID = UserManager.shared.currentUID ?? ""
        self.id = "\(UserManager.shared.currentUID ?? "")_\(userID)"
    }
    
    override init() {
        super.init()
    }
    
    func toDTO() -> ContactDTO {
        return ContactDTO(username: username, status: status, profileImage: profileImage, userID: userID, publicKey: publicKey, isContactBlocked: isContactBlocked)
    }
}

struct ContactDTO: Hashable {
    let username: String
    let status: String
    let profileImage: String
    let userID: String
    let publicKey : String
    var isContactBlocked: Bool
    
    func toContact() -> Contact {
        return Contact(username: username, status: status, profileImage: profileImage, userID: userID, publicKey: publicKey, isContactBlocked: isContactBlocked)
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userID)
    }

    static func == (lhs: ContactDTO, rhs: ContactDTO) -> Bool {
        return lhs.userID == rhs.userID
    }
}






