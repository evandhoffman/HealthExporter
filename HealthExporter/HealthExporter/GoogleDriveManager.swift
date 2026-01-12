import Foundation
import Combine
import GoogleSignIn

class GoogleDriveManager: NSObject, ObservableObject {
    @Published var isSignedIn = false
    @Published var uploadProgress = ""
    
    private var clientID: String? {
        SecretsManager.shared.googleClientID()
    }
    
    override init() {
        super.init()
        configureGoogleSignIn()
        checkSignInStatus()
    }
    
    private func configureGoogleSignIn() {
        guard let clientID = clientID else {
            print("⚠️ Client ID not configured")
            return
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    }
    
    private func checkSignInStatus() {
        if GIDSignIn.sharedInstance.currentUser != nil {
            self.isSignedIn = true
        } else {
            self.isSignedIn = false
        }
    }
    
    func signIn(presentingViewController: UIViewController, completion: @escaping (Bool, Error?) -> Void) {
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] signInResult, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let user = signInResult?.user else {
                completion(false, NSError(domain: "GoogleDrive", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sign in failed"]))
                return
            }
            
            self.isSignedIn = true
            completion(true, nil)
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isSignedIn = false
    }
    
    func uploadFile(data: Data, fileName: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            completion(false, NSError(domain: "GoogleDrive", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not signed in"]))
            return
        }
        
        user.refreshTokensIfNeeded { [weak self] refreshedUser, error in
            guard let self = self else {
                completion(false, NSError(domain: "GoogleDrive", code: -1, userInfo: [NSLocalizedDescriptionKey: "Lost self reference"]))
                return
            }
            
            guard let refreshedUser = refreshedUser else {
                completion(false, error ?? NSError(domain: "GoogleDrive", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token refresh failed"]))
                return
            }
            
            let accessToken = refreshedUser.accessToken.tokenString
            guard !accessToken.isEmpty else {
                completion(false, NSError(domain: "GoogleDrive", code: -1, userInfo: [NSLocalizedDescriptionKey: "No access token"]))
                return
            }
            
            self.uploadToGoogleDrive(data: data, fileName: fileName, accessToken: accessToken, completion: completion)
        }
    }
    
    private func uploadToGoogleDrive(data: Data, fileName: String, accessToken: String, completion: @escaping (Bool, Error?) -> Void) {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        // Add metadata
        let metadata = """
        {
          "name": "\(fileName)",
          "mimeType": "text/csv"
        }
        """
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json; charset=UTF-8\r\n\r\n".data(using: .utf8)!)
        body.append(metadata.data(using: .utf8)!)
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Type: text/csv\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        var request = URLRequest(url: URL(string: "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/related; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { responseData, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.uploadProgress = "Upload failed"
                    completion(false, error)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    self.uploadProgress = "✓ Uploaded to Google Drive"
                    completion(true, nil)
                } else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    self.uploadProgress = "Upload failed"
                    completion(false, NSError(domain: "GoogleDrive", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Upload failed with status \(statusCode)"]))
                }
            }
        }.resume()
    }
}
