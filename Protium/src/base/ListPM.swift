import Foundation

// Generic Struct for Presentation Models of a list.
// In addition to the array of items, properties for paging/infinite scrolling can be exposed here.
struct ListPM<Item> {
    let items: [Item]
    let hasMore: Bool
    
    static func empty() -> ListPM {
        return ListPM(items: [], hasMore: false)
    }
}
