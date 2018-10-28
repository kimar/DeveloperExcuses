//
//  UserDefaults+LastLine.swift
//  OnelinerKit
//
//  Created by Marcus Kida on 17.12.17.
//  Copyright © 2017 Marcus Kida. All rights reserved.
//

import Foundation

extension UserDefaults {
    static var lastOneline: String? {
        get {
            return UserDefaults.standard.string(forKey: .lastOneline)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: .lastOneline)
            UserDefaults.standard.synchronize()
        }
    }
}
