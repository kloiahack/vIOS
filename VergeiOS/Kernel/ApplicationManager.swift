//
//  ApplicationManager.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 08-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import Foundation
import KeychainSwift

class ApplicationManager {

    static let `default` = ApplicationManager()

    private let keychain = KeychainSwift(keyPrefix: "verge_")
    private let userDefaults = UserDefaults.standard

    // Is the wallet already setup?
    var setup: Bool {
        get {
            return userDefaults.bool(forKey: "wallet.state.setup")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.state.setup")
        }
    }
    
    // Store the wallet pin in the app key chain.
    var pin: String {
        get {
            return keychain.get("wallet.pin") ?? ""
        }
        set {
            keychain.set(newValue, forKey: "wallet.pin")
        }
    }

    var pinCount: Int {
        get {
            userDefaults.register(defaults: ["wallet.pinCount": 6])
            return userDefaults.integer(forKey: "wallet.pinCount")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.pinCount")
        }
    }
    
    // User wants to use tor or not.
    var useTor: Bool {
        get {
            return userDefaults.bool(forKey: "wallet.useTor")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.useTor")
        }
    }
    
    // Store the selected wallet currency. Defaults to USD.
    // TODO: String used for now until better solution.
    var currency: String {
        get {
            return userDefaults.string(forKey: "wallet.currency") ?? "USD"
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.currency")
        }
    }
    
    var amount: NSNumber {
        get {
            return NSNumber(value: userDefaults.double(forKey: "wallet.amount"))
        }
        set {
            // Make sure wallet amount never gets less then zero.
            var correctNewValue = newValue.doubleValue
            if newValue.doubleValue < 0.0 {
                correctNewValue = 0.0
            }

            userDefaults.set(correctNewValue, forKey: "wallet.amount")

            NotificationCenter.default.post(name: .didChangeWalletAmount, object: nil)
        }
    }

    var localAuthForWalletUnlock: Bool {
        get {
            return userDefaults.bool(forKey: "wallet.localAuth.unlockWallet")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.localAuth.unlockWallet")
        }
    }

    var localAuthForSendingXvg: Bool {
        get {
            return userDefaults.bool(forKey: "wallet.localAuth.sendingXvg")
        }
        set {
            userDefaults.set(newValue, forKey: "wallet.localAuth.sendingXvg")
        }
    }

    var mnemonic: [String]? {
        get {
            var mnemonic = [String]()

            for index in 0..<12 {
                guard let word = keychain.get("mnemonic.word.\(index)") else {
                    return nil
                }
                mnemonic.append(word)
            }

            return mnemonic
        }
        set {
            guard let mnemonic = newValue as? [String] else {
                for index in 0..<12 {
                    keychain.delete("mnemonic.word.\(index)")
                }
                return
            }

            for (index, word) in mnemonic.enumerated() {
                keychain.set(word, forKey: "mnemonic.word.\(index)")
            }
        }
    }

    var walletId: String? {
        get {
            return keychain.get("wallet.id")
        }
        set {
            if let walletId = newValue {
                keychain.set(walletId, forKey: "wallet.id")
            } else {
                keychain.delete("wallet.id")
            }
        }
    }

    var walletName: String? {
        get {
            return keychain.get("wallet.name")
        }
        set {
            if let walletName = newValue {
                keychain.set(walletName, forKey: "wallet.name")
            } else {
                keychain.delete("wallet.name")
            }
        }
    }

    var walletSecret: String? {
        get {
            return keychain.get("wallet.secret")
        }
        set {
            if let walletSecret = newValue {
                keychain.set(walletSecret, forKey: "wallet.secret")
            } else {
                keychain.delete("wallet.secret")
            }
        }
    }

    // Get transactions for core date.
    func getTransactions(offset: Int = 0, limit: Int = 10) -> [Transaction] {
        // TODO: For now we fetch them from an example json file.
        if let path = Bundle.main.path(forResource: "transactions", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return try JSONDecoder().decode([Transaction].self, from: data)
            } catch {
                print(error)
                return []
            }
        }

        return []
    }

    func getTransactions(byAddress address: String, offset: Int = 0, limit: Int = 10) -> [Transaction] {
        return getTransactions(offset: offset, limit: limit)
            .filter { item in
                return item.address == address
            }
    }

    func hasTransactions() -> Bool {
        return getTransactions().count > 0
    }

    func getAddress(stealth: Bool = false) -> String {
        let length = stealth ? 68 : 34
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length - 1).map { _ in
            letters.randomElement()!
        })
    }
    
    func reset() {
        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        userDefaults.synchronize()
        keychain.clear()
    }
}
