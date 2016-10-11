import Foundation

struct ListPM<Item> {
    let items: [Item]
    let hasMore: Bool
    
    static func empty() -> ListPM {
        return ListPM(items: [], hasMore: false)
    }
}
