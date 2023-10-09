import PhotonMacros
import Foundation

class AppSettings {
    static var customStore: UserDefaults = UserDefaults.init(suiteName: "com.juniperphoton")!
    
    @UserDefaultsAccess(defaultValue: false, key: "enable_notification")
    var enableNotification: Bool
    
    @UserDefaultsAccess(defaultValue: "", store: AppSettings.customStore)
    var userId: String
    
    @UserDefaultsAccess(defaultValue: 0)
    var deleteCount: Int
}
