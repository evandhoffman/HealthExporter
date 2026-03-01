import SwiftUI

@main
struct HealthExporterApp: App {
    @StateObject private var settings = SettingsManager()
    @State private var isLaunching = true

    var body: some Scene {
        WindowGroup {
            if isLaunching {
                LaunchView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                isLaunching = false
                            }
                        }
                    }
            } else {
                NavigationStack {
                    SplashView(settings: settings)
                }
                .transition(.opacity)
            }
        }
    }
}
