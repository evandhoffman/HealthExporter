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