import PhotonMacros
import Foundation

class AppSettings {
    static var customStore: UserDefaults = UserDefaults.init(suiteName: "com.juniperphoton")!
    
    @PropertyAccess(defaultValue: false, key: "enable_notification")
    var enableNotification: Bool
    
    @PropertyAccess(defaultValue: "", store: AppSettings.customStore)
    var userId: String
    
    @PropertyAccess(defaultValue: 0)
    var deleteCount: Int
}
