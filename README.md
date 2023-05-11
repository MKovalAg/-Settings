# Settings

## 1. Example code with the enum extension

```
enum MyRawValue {
    case appSettingsKey(AppSettingsKey)
    case newKey(NewKey)
}

enum NewKey: AppSettingsKeyProtocol {
    // auth
    case newUsername
    case newPassword
    case newToken
    
    // app
    case newIsSeenOnboarding
    
    // newCase
    case error
    
    typealias RawValue = MyRawValue
    
    init?(rawValue: RawValue) {
        switch rawValue {
        case .appSettingsKey(let appSettingsKey):
            switch appSettingsKey {
            case .username:
                self = .newUsername
            case .token:
                self = .newToken
            case .password:
                self = .newPassword
            case .isSeenOnboarding:
                self = .newIsSeenOnboarding
            }
        case .newKey(let newKey):
            self = newKey
        }
    }
    
    var rawValue: RawValue {
        switch self {
        case .newUsername:
            return .appSettingsKey(.username)
        case .newPassword:
            return .appSettingsKey(.password)
        case .newToken:
            return .appSettingsKey(.token)
        case .newIsSeenOnboarding:
            return .appSettingsKey(.isSeenOnboarding)
        case .error:
            return .newKey(.error)
        }
    }
}
```

## 2. example of getting all new .case

```
    let allCases = NewKey.allCases
```
