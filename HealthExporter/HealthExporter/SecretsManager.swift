import Foundation

class SecretsManager {
    static let shared = SecretsManager()
    
    private var secrets: [String: String] = [:]
    var secretsLoadError: String? = nil
    
    private init() {
        loadSecrets()
    }
    
    private func loadSecrets() {
        guard let secretsPath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
            secretsLoadError = "⚠️ Secrets.plist not found. Create it from Secrets.plist.example and add your Google Client ID."
            print(secretsLoadError ?? "")
            return
        }
        
        guard let secretsDict = NSDictionary(contentsOfFile: secretsPath) as? [String: String] else {
            secretsLoadError = "⚠️ Unable to parse Secrets.plist"
            print(secretsLoadError ?? "")
            return
        }
        
        self.secrets = secretsDict
        
        // Check if Client ID is actually set
        if secrets["GoogleClientID"]?.isEmpty ?? true {
            secretsLoadError = "⚠️ GoogleClientID not set in Secrets.plist. Please add your Google Client ID."
        }
    }
    
    func googleClientID() -> String? {
        return secrets["GoogleClientID"]?.isEmpty ?? true ? nil : secrets["GoogleClientID"]
    }
    
    func hasError() -> Bool {
        return secretsLoadError != nil
    }
}
