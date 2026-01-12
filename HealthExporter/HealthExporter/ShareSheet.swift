import SwiftUI
import UniformTypeIdentifiers

struct ShareSheet: UIViewControllerRepresentable {
    let filePath: URL
    let fileName: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let csvUTI = UTType.commaSeparatedText.identifier
        let itemProvider = NSItemProvider(contentsOf: filePath)
        itemProvider?.suggestedName = fileName
        // Register as CSV explicitly
        itemProvider?.registerFileRepresentation(
            forTypeIdentifier: csvUTI,
            fileOptions: .openInPlace,
            visibility: .all
        ) { completion in
            completion(self.filePath, true, nil)
            return nil
        }
        // Also set the preferred type identifier for the activity item
        let activityVC = UIActivityViewController(activityItems: [itemProvider!], applicationActivities: nil)
        activityVC.excludedActivityTypes = [.saveToCameraRoll]
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
