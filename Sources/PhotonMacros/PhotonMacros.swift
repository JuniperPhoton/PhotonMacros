import Foundation

/// Attach this macro to a property declaration to provide get/set methods to the
/// access of UserDefaults you provided.
///
/// Currently supports String, Bool and Integer types.
@attached(accessor)
public macro UserDefaultsAccess<T>(defaultValue: T, key: String? = nil, store: UserDefaults = UserDefaults.standard) = #externalMacro(module: "PhotonMacrosImpl", type: "UserDefaultsAccessMacro")
