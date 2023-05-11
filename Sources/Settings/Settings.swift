import Foundation
import SwiftKeychainWrapper
import SwiftyUserDefaults
import SwiftyBeaver

// TO DO public
public protocol SettingsProtocol: AnyObject {
    var auth: Settings.Auth  { get set }
    var app: Settings.App  { get set }
    
    func cleanOnLogout()
}

private enum SettingsStorage {
    case keychain
    case userDefaults
}

// TO DO public
public class Settings: SettingsProtocol {
    
    public static let shared: SettingsProtocol = Settings()
    
    // MARK: Params
    
    // TO DO public
    public var auth = Auth()
    public var app = App()
    
    private static let userDefaults = UserDefaults.standard
    fileprivate static let keychain = KeychainWrapper.standard
    private static var keychainCache = [String: Any?]()

    private static let elements: [AppSettingsKey: SettingsStorage] = [
        // auth
        .username           : .keychain,
        .password           : .keychain,
        .token              : .keychain,
        
        // app
        .isSeenOnboarding   : .userDefaults
    ]
    
    
    // MARK: Logic
    
    private static subscript(_ key: AppSettingsKey) -> Any? {
        get {
            guard let storageType = elements[key] else {
                assertionFailure("No such key")
                return "Error"
            }
            
            switch storageType {
            case .keychain:
                return getKeychainValue(key: key.rawValue)
            case .userDefaults:
                return getUserDefaultsValue(key: key.rawValue)
            }
        }
        set {
            guard let storageType = elements[key] else {
                assertionFailure("No such key")
                return
            }
            
            switch storageType {
            case .keychain:
                setKeychainValue(value: newValue, key: key.rawValue)
            case .userDefaults:
                setUserDefaultsValue(value: newValue, key: key.rawValue)
            }
        }
    }
    
    // MARK: Access from storages -> to Providers?
    
    private static func getKeychainValue(key: String) -> Any? {
        if let value = keychainCache[key] {
            return value
        } else {
            // TO DO заменена строка keychain.getValue(key)
            if let value = keychain.string(forKey: key) {
                keychainCache[key] = value
                return value
            }
        }
        return nil
    }
    
    private static func getUserDefaultsValue(key: String) -> Any? {
        userDefaults.value(forKey: key)
    }
    
    // MARK: Set
    
    private static func setKeychainValue(value: Any?, key: String) {
        keychainCache[key] = value
        // TO DO заменена строка keychain.setValue(value, forKey: key) + приведена к типу Data
        if let dataValue = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true) {
            keychain.set(dataValue, forKey: key)
        }
    }
    
    private static func setUserDefaultsValue(value: Any?, key: String) {
        userDefaults.setValue(value, forKey: key)
    }
}

extension Settings {
    
    // TO DO public
    public struct Auth {
        public static var userName: String {
            get { Settings.stringValue(.username) ?? "" }
            set { Settings[.username] = newValue }
        }
        public static var password: String {
            get { Settings.stringValue(.password)  ?? "" }
            set { Settings[.password] = newValue }
        }
        public static var token: String {
            get { Settings.stringValue(.token)  ?? "" }
            set { Settings[.token] = newValue }
        }
    }
    
    // TO DO public
    public struct App {
        public static var isSeenOnboarding: Bool {
            get { Settings.boolValue(.isSeenOnboarding) ?? true }
            set { Settings[.isSeenOnboarding] = newValue }
        }
    }
    
    // MARK: SettingsProtocol
    
    // TO DO public
    // + заменены строки
    // Settings.shared.auth.userName   = ""
    // Settings.shared.auth.password   = ""
    // Settings.shared.auth.token      = ""
    public func cleanOnLogout() {
        Settings.Auth.userName   = ""
        Settings.Auth.password   = ""
        Settings.Auth.token      = ""
    }
}


extension Settings {
    
    // MARK: Typed funcs
    
    private static func boolValue(_ key: AppSettingsKey) -> Bool? {
        if let value = Settings[key] as? Bool {
            return value
        }
        
        return nil
    }
    
    private static func stringValue(_ key: AppSettingsKey) -> String? {
        if let value = Settings[key] as? String {
            return value
        }
        return nil
    }
    
    private static func intValue(_ key: AppSettingsKey) -> Int? {
        if let value = Settings[key] as? Int {
            return value
        }
        return nil
    }
    
    private static func typedValue<T>(_ key: AppSettingsKey) -> T? {
        if let value = Settings[key] as? T {
            return value
        }
        return nil
    }
    
    // MARK: Codable
    
    private static func encodeData<T: Encodable>(data: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let encodedData = try? encoder.encode(data) {
            return encodedData
        }
        return nil
    }
    
    private static func decodeData<T: Decodable>(data: Any?) -> T? {
        do {
            if let data = data as? Data {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return decodedData
            }
        } catch let error {
            SwiftyBeaver.error(error.localizedDescription)
            assertionFailure("Try to decode not decodable object - check type and data")
        }
        
        return nil
    }
}

