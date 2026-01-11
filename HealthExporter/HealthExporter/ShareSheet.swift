import SwiftUI
import UniformTypeIdentifiers

struct ShareSheet: UIViewControllerRepresentable {
    let filePath: URL
    let fileName: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let itemProvider = NSItemProvider(contentsOf: filePath)
        itemProvider?.suggestedName = fileName
        itemProvider?.registerFileRepresentation(
            forTypeIdentifier: UTType.commaSeparatedText.identifier,
            fileOptions: .openInPlace,
            visibility: .all
        ) { _ in
            return (self.filePath, true)
        }
        
        let activityVC = UIActivityViewController(activityItems: [itemProvider!], applicationActivities: nil)
        activityVC.excludedActivityTypes = [.saveToCameraRoll]
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
