import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let filePath: URL
    let fileName: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: [filePath], applicationActivities: nil)
        activityVC.excludedActivityTypes = [.saveToCameraRoll]
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
