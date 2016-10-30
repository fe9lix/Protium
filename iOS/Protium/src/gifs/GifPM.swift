import Foundation

// Presentation Model wrapping a Gif Model.
// Exposes only view-related properties be delegating to the underlying Model.
// In a more complex example, Presentation Models might have lazy properties,
// format strings, calculate and cache values etc.
struct GifPM {
    var id: String { return model.id }
    var url: URL? { return model.url }
    var embedURL: URL? { return model.embedURL }
    var imageURL: URL? { return model.originalStillURL }
    var videoURL: URL? { return model.originalVideoURL }
    
    private let model: Gif
    
    init(_ model: Gif) {
        self.model = model
    }
    
    static func empty() -> GifPM {
        return GifPM(Gif(id: ""))
    }
}
