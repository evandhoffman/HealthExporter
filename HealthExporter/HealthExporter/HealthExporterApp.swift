import SwiftUI

@main
struct HealthExporterApp: App {
    @StateObject private var settings = SettingsManager()
    @State private var isLaunching = true

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LaunchView(settings: settings, isLaunching: $isLaunching)
                    .onAppear {
                        guard isLaunching else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                isLaunching = false
                            }
                        }
                    }
            }
        }
    }
}
