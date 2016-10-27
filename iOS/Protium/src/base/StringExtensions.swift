import Foundation

// Convenience extension for localization. 
// Returns the localized version of the String itself from the Localizable.strings file.
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
