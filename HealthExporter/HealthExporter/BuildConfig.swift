import Foundation

/// Build configuration for paid/free developer accounts
struct BuildConfig {
    /// Set to true if you have a paid Apple Developer account with Clinical Health Records entitlement
    /// Set to false for free accounts (disables clinical records features)
    static let hasPaidDeveloperAccount = false
}
