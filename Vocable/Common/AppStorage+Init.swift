import Foundation
import SwiftUI

extension AppStorage {

    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == String {
        self.init(wrappedValue: wrappedValue, key.value, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.value, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == Int {
        self.init(wrappedValue: wrappedValue, key.value, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == Double {
        self.init(wrappedValue: wrappedValue, key.value, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == URL {
        self.init(wrappedValue: wrappedValue, key.value, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value == Data {
        self.init(wrappedValue: wrappedValue, key.value, store: store)
    }

    init(wrappedValue: Value, _ key: UserDefaultsKey, store: UserDefaults? = nil) where Value: RawRepresentable, Value.RawValue == Int {
        self.init(wrappedValue: wrappedValue, key.value, store: store)
    }
}

extension UserDefaultsKey {
    static let darkModeEnabled = UserDefaultsKey("darkModeEnabled")
}

struct AppSettings {
    @AppStorage(.darkModeEnabled) var darkModeEnabled: Bool = false
}
