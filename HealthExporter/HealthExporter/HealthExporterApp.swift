import SwiftUI
import GoogleSignIn

@main
struct HealthExporterApp: App {
    @StateObject private var settings = SettingsManager()
    
    init() {
        let clientID = SecretsManager.shared.googleClientID()
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            // Restore previous sign-in if available
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SplashView(settings: settings)
            }
        }
    }
}