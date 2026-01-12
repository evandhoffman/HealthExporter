import SwiftUI
import GoogleSignIn

@main
struct HealthExporterApp: App {
    @StateObject private var settings = SettingsManager()
    @State private var showSecretsWarning = false
    @State private var secretsWarningMessage = ""
    
    init() {
        // Check for secrets errors
        if SecretsManager.shared.hasError(), let error = SecretsManager.shared.secretsLoadError {
            secretsWarningMessage = error
            showSecretsWarning = true
        }
        
        // Try to configure Google Sign-In if we have a Client ID
        if let clientID = SecretsManager.shared.googleClientID() {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                // Restore previous sign-in if available
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SplashView(settings: settings)
            }
            .alert("Configuration Missing", isPresented: $showSecretsWarning) {
                Button("OK") { }
            } message: {
                Text(secretsWarningMessage)
            }
        }
    }
}