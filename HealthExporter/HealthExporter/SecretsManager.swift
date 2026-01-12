import Foundation

class SecretsManager {
    static let shared = SecretsManager()
    
    private var secrets: [String: String] = [:]
    
    private init() {
        loadSecrets()
    }
    
    private func loadSecrets() {
        guard let secretsPath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
            print("⚠️ Warning: Secrets.plist not found. Create it from Secrets.plist.example")
            return
        }
        
        guard let secretsDict = NSDictionary(contentsOfFile: secretsPath) as? [String: String] else {
            print("⚠️ Warning: Unable to parse Secrets.plist")
            return
        }
        
        self.secrets = secretsDict
    }
    
    func googleClientID() -> String {
        guard let clientID = secrets["GoogleClientID"], !clientID.isEmpty else {
            fatalError("GoogleClientID not found in Secrets.plist. Please add it or create the file from Secrets.plist.example")
        }
        return clientID
    }
}
