import SwiftUI

struct SplashView: View {
    @ObservedObject var settings: SettingsManager
    @State private var showingSettings = false
    
    var body: some View {
        ZStack {
            VStack {
                Text("Health Exporter")
                    .font(.largeTitle)
                    .padding()
                Text("Export your health data to CSV")
                    .font(.subheadline)
                    .padding()
                
                // Developer Account Status Info Box
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: BuildConfig.hasPaidDeveloperAccount ? "checkmark.circle.fill" : "info.circle.fill")
                            .foregroundColor(BuildConfig.hasPaidDeveloperAccount ? .green : .orange)
                        Text("Developer Account Status")
                            .font(.headline)
                    }
                    
                    Text("Account Type: \(BuildConfig.hasPaidDeveloperAccount ? "Paid" : "Free")")
                        .font(.caption)
                    
                    Text("Clinical Health Records: \(BuildConfig.hasPaidDeveloperAccount ? "Enabled ✓" : "Disabled 💰")")
                        .font(.caption)
                    
                    if !BuildConfig.hasPaidDeveloperAccount {
                        Text("A1C export requires paid Apple Developer account")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .padding()
                .background(BuildConfig.hasPaidDeveloperAccount ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
                NavigationLink(destination: DataSelectionView(settings: settings)) {
                    Text("Next")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: settings)
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(settings: SettingsManager())
    }
}