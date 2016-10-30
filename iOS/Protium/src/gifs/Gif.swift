import Foundation
import JASON

// Simple struct for storing some Gif properties.
// The extension provides a convenience initializer that uses the JASON library 
// for parsing JSON into model properties.
struct Gif {
    let id: String
    let url: URL?
    let embedURL: URL?
    let originalStillURL: URL?
    let originalVideoURL: URL?
    
    init(id: String) {
        self.id = id
        self.url = nil
        self.embedURL = nil
        self.originalStillURL = nil
        self.originalVideoURL = nil
    }
}

extension Gif {
    init(_ json: JSON) {
        id = json["id"].stringValue
        url = json["url"].nsURL
        embedURL = json["embed_url"].nsURL
        originalStillURL = json["images"]["original_still"]["url"].nsURL
        originalVideoURL = json["images"]["original"]["mp4"].nsURL
    }
}
