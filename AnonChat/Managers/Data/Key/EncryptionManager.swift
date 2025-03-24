//
//  EncryptionManager.swift
//  AnonChat
//
//  Created by Stanislav Vitiuk on 1/25/25.
//

import Foundation
import Firebase
import CryptoKit

struct EncryptionManager {
    
    let keychainKey: String!
    
    private let userID: String
    private let privateKey: P256.KeyAgreement.PrivateKey
    private let publicKey: P256.KeyAgreement.PublicKey
    
    
    init(userID: String) {
        self.keychainKey = "name.vitiukovich.AnonChat.privateKey.\(userID)"
        self.userID = userID
        
        if let storedKeyData = KeychainManager.shared.read(key: keychainKey),
           let storedPrivateKey = try? P256.KeyAgreement.PrivateKey(rawRepresentation: storedKeyData) {
            self.privateKey = storedPrivateKey
        } else {
            self.privateKey = P256.KeyAgreement.PrivateKey()
            let privateKeyData = privateKey.rawRepresentation
            
            _ = KeychainManager.shared.save(key: keychainKey, data: privateKeyData)
        }
        
        self.publicKey = privateKey.publicKey
    }
    
    func checkAndUploadKey(completion: @escaping (Result<Void, Error>) -> Void) {
        let publicKeyString = getPublicKeyString()
        let userDocRef = Firestore.firestore().collection("users").document(userID)

        userDocRef.getDocument { document, error in
            if let document = document, document.exists {
                if let storedPublicKey = document.data()?["publicKey"] as? String, storedPublicKey == publicKeyString {
                    completion(.success(()))
                } else {
                    userDocRef.setData(["publicKey": publicKeyString], merge: true) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            } else {
                userDocRef.setData(["publicKey": publicKeyString]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    func getPublicKeyString() -> String {
        return publicKey.rawRepresentation.base64EncodedString()
    }
    
    func getPublicKeyFromString(_ keyString: String) -> P256.KeyAgreement.PublicKey? {
        guard let keyData = Data(base64Encoded: keyString) else { return nil }
        do {
            return try P256.KeyAgreement.PublicKey(rawRepresentation: keyData)
        } catch {
            Logger.log("Error getting public key: \(error.localizedDescription)", level: .error)
            return nil
        }
    }
    
    func deletePrivateKey() {
        _ = KeychainManager.shared.delete(key: keychainKey)
    }
    
    func savePublicKey(_ publicKeyData: Data) -> P256.KeyAgreement.PublicKey? {
        do {
            return try P256.KeyAgreement.PublicKey(rawRepresentation: publicKeyData)
        } catch {
            Logger.log("Error saving key: \(error.localizedDescription)", level: .error)
            return nil
        }
    }
    
    func generateSharedSecret(peerPublicKeyString: String) -> SymmetricKey? {
        guard let peerPublicKey = getPublicKeyFromString(peerPublicKeyString) else { return nil }
        
        guard let sharedSecret = try? privateKey.sharedSecretFromKeyAgreement(with: peerPublicKey) else {
            return nil
        }
        
        return sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: "ChatAppSalt".data(using: .utf8)!,
            sharedInfo: Data(),
            outputByteCount: 32
        )
    }
    
    
    //MARK: Text encryptor
    func encryptMessage(_ message: String, with peerPublicKeyString: String) -> String? {
        guard let symmetricKey = generateSharedSecret(peerPublicKeyString: peerPublicKeyString) else {
            return nil
        }
        
        guard let messageData = message.data(using: .utf8) else { return nil }
        guard let sealedBox = try? AES.GCM.seal(messageData, using: symmetricKey) else { return nil }
        
        return sealedBox.combined?.base64EncodedString()
    }
    
    func decryptMessage(_ encryptedMessage: String, with peerPublicKeyString: String) -> String? {
        guard let symmetricKey = generateSharedSecret(peerPublicKeyString: peerPublicKeyString) else {
            return nil
        }
        
        guard let encryptedData = Data(base64Encoded: encryptedMessage),
              let sealedBox = try? AES.GCM.SealedBox(combined: encryptedData),
              let decryptedData = try? AES.GCM.open(sealedBox, using: symmetricKey) else { return nil }
        
        return String(data: decryptedData, encoding: .utf8)
    }

    //MARK: Data encryptor
    func encryptData(_ data: Data, with peerPublicKeyString: String) -> Data? {
        guard let symmetricKey = generateSharedSecret(peerPublicKeyString: peerPublicKeyString) else {
            return nil
        }
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: symmetricKey)
            return sealedBox.combined
        } catch {
            Logger.log("Error encrypting data: \(error.localizedDescription)", level: .error)
            return nil
        }
    }

    
    func decryptData(_ encryptedData: Data, with peerPublicKeyString: String) -> Data? {
        guard let symmetricKey = generateSharedSecret(peerPublicKeyString: peerPublicKeyString) else {
            return nil
        }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            return try AES.GCM.open(sealedBox, using: symmetricKey)
        } catch {
            Logger.log("Error decrypting data: \(error.localizedDescription)", level: .error)
            return nil
        }
    }
}
