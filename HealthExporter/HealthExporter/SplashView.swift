import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack {
            Text("Health Exporter")
                .font(.largeTitle)
                .padding()
            Text("Export your health data to CSV")
                .font(.subheadline)
                .padding()
            Spacer()
            NavigationLink(destination: DataSelectionView()) {
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
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}