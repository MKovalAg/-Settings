//
//  AppSettingsKey.swift
//  
//
//  Created by Марк Коваль on 04/05/2023.
//

import Foundation

// TO DO public protocol
public protocol AppSettingsKeyProtocol : RawRepresentable, CaseIterable {

}

// MARK: Keys

// TO DO public
public enum AppSettingsKey: String {
    // auth
    case username
    case password
    case token
    
    // app
    case isSeenOnboarding
}
