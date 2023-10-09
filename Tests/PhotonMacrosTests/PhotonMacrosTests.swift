import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(PhotonMacrosImpl)
import PhotonMacrosImpl

let testMacros: [String: Macro.Type] = [
    "UserDefaultsAccess": UserDefaultsAccessMacro.self
]
#endif

final class PhotonMacrosTests: XCTestCase {
    func testPropertyAccess() throws {
#if canImport(PhotonMacrosImpl)
        assertMacroExpansion(
        """
        @UserDefaultsAccess(defaultValue: false, key: "enable_notification")
        var enableNotification: Bool
        """,
        expandedSource: """
        var enableNotification: Bool {
            get {
                if UserDefaults.standard.value(forKey: "enable_notification") == nil {
                    return false
                }
                return UserDefaults.standard.bool(forKey: "enable_notification")
            }
            set {
                UserDefaults.standard.setValue(newValue, forKey: "enable_notification")
            }
        }
        """,
        macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testPropertyAccessWithDefaultKey() throws {
#if canImport(PhotonMacrosImpl)
        assertMacroExpansion(
        """
        @UserDefaultsAccess(defaultValue: false)
        var enableNotification: Bool
        """,
        expandedSource: """
        var enableNotification: Bool {
            get {
                if UserDefaults.standard.value(forKey: "enableNotification") == nil {
                    return false
                }
                return UserDefaults.standard.bool(forKey: "enableNotification")
            }
            set {
                UserDefaults.standard.setValue(newValue, forKey: "enableNotification")
            }
        }
        """,
        macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}
