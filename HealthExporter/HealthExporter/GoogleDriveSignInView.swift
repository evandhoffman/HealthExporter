import SwiftUI
import GoogleSignIn

struct GoogleDriveSignInView: UIViewControllerRepresentable {
    @ObservedObject var googleDriveManager: GoogleDriveManager
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .filter({ $0.isKeyWindow })
                .first {
                googleDriveManager.signIn(presentingViewController: window.rootViewController ?? controller) { success, error in
                    isPresented = false
                }
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
