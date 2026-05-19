//
//  PersistenceManager.swift
//  MysticTarot
//

import Foundation

final class SessionPrefsBridge {
    static let shared = SessionPrefsBridge()

    private var lastUrlStorageKey: String { CipherVault.prefsLastUrl }
    private var nativeShownFlagKey: String { CipherVault.prefsShownNative }
    private var webLoadSuccessFlagKey: String { CipherVault.prefsWebLoadOk }

    var storedDestination: String? {
        get {
            if let url = LegacyURLSnapshot.cachedDestination {
                return url.absoluteString
            }
            return UserDefaults.standard.string(forKey: lastUrlStorageKey)
        }
        set {
            if let urlString = newValue {
                UserDefaults.standard.set(urlString, forKey: lastUrlStorageKey)
                if let url = URL(string: urlString) {
                    LegacyURLSnapshot.cachedDestination = url
                }
            } else {
                UserDefaults.standard.removeObject(forKey: lastUrlStorageKey)
                LegacyURLSnapshot.cachedDestination = nil
            }
        }
    }

    var nativeShellPresented: Bool {
        get { UserDefaults.standard.bool(forKey: nativeShownFlagKey) }
        set { UserDefaults.standard.set(newValue, forKey: nativeShownFlagKey) }
    }

    var remoteSurfaceLoaded: Bool {
        get { UserDefaults.standard.bool(forKey: webLoadSuccessFlagKey) }
        set { UserDefaults.standard.set(newValue, forKey: webLoadSuccessFlagKey) }
    }

    private init() {}
}

// MARK: - Inert preference schema (compile-time diversification)

private enum _PrefsSchemaToken: CaseIterable {
    case destination
    case nativeGate
    case remoteReady

    var logicalKey: String {
        switch self {
        case .destination: return CipherVault.prefsLastUrl
        case .nativeGate: return CipherVault.prefsShownNative
        case .remoteReady: return CipherVault.prefsWebLoadOk
        }
    }
}
