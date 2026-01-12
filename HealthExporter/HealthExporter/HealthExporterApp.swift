import SwiftUI

@main
struct HealthExporterApp: App {
    @StateObject private var settings = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SplashView(settings: settings)
            }
        }
    }
}