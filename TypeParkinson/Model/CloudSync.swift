import CryptoKit
import Foundation

/// The person's Sign in with Apple identity. TypeParkinson has no server: the
/// identifier only keeps their record apart in their own iCloud.
struct AppleAccount: Codable, Equatable {
    var userID: String
    var name: String?
}

/// Everything that follows a person between their devices.
struct CloudSnapshot: Codable, Equatable {
    var profile: TouchProfile?
    var settings: KeyboardSettings?
    var isSetupComplete: Bool
    var modified: Date
}

/// Keeps a signed-in person's snapshot in their iCloud key-value store, which
/// syncs between devices on the same Apple Account. Only they can read it.
/// Without iCloud on the device, it simply stays on the device.
enum CloudStore {
    private static var store: NSUbiquitousKeyValueStore { .default }

    /// Whether this device is signed in to iCloud, so saved snapshots will sync.
    static var isSyncAvailable: Bool { FileManager.default.ubiquityIdentityToken != nil }

    static func load(for account: AppleAccount) -> CloudSnapshot? {
        guard let data = store.data(forKey: key(for: account)) else { return nil }
        return try? JSONDecoder().decode(CloudSnapshot.self, from: data)
    }

    static func save(_ snapshot: CloudSnapshot, for account: AppleAccount) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        store.set(data, forKey: key(for: account))
        store.synchronize()
    }

    static func remove(for account: AppleAccount) {
        store.removeObject(forKey: key(for: account))
        store.synchronize()
    }

    /// Fetches changes made on other devices since launch.
    static func refresh() {
        store.synchronize()
    }

    /// Keys are limited to 64 bytes, so the identifier is hashed.
    private static func key(for account: AppleAccount) -> String {
        let digest = SHA256.hash(data: Data(account.userID.utf8))
        return "snapshot." + digest.prefix(20).map { String(format: "%02x", $0) }.joined()
    }
}
