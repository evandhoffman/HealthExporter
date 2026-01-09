import SwiftUI

struct DocumentExporter: UIViewControllerRepresentable {
    var csvContent: String
    var fileName: String
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Create a temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing file: \(error)")
        }
        
        let picker = UIDocumentPickerViewController(forExporting: [fileURL], asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(csvContent: csvContent, fileName: fileName)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let csvContent: String
        let fileName: String
        
        init(csvContent: String, fileName: String) {
            self.csvContent = csvContent
            self.fileName = fileName
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // Save to the picked location
            guard let selectedURL = urls.first else { return }
            
            do {
                try csvContent.write(to: selectedURL, atomically: true, encoding: .utf8)
                print("File saved to: \(selectedURL)")
            } catch {
                print("Error saving file: \(error)")
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Export cancelled")
        }
    }
}