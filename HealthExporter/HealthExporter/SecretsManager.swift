import Foundation

class SecretsManager {
    static let shared = SecretsManager()
    
    private init() {
        // Reserved for future secret management (e.g., secure storage of API keys or config).
        // TODO: Implement secure secret handling when external secrets are introduced.
    }
}
