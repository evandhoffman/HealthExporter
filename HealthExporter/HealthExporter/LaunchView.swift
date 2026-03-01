import SwiftUI

struct LaunchView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image("AppIconImage")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(radius: 8)

            Text("Health Exporter")
                .font(.largeTitle)
                .fontWeight(.bold)

            ProgressView()
                .scaleEffect(1.2)

            Spacer()

            Text("© \(Calendar.current.component(.year, from: Date())) Evan Hoffman")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom, 32)
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
