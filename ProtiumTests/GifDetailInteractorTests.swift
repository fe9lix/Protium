import XCTest
import RxSwift
import RxCocoa
@testable import Protium

class GifDetailInteractorTests: XCTestCase {
    private var actions: GifDetailsUI.Actions!
    private var interactor: GifDetailsInteractor!
    private let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOpenURL() {
        let testExpectation = expectation(description: "Open URL.")
        
        actions = GifDetailsUI.Actions(
            copyEmbedLink: Driver.empty(),
            openGiphy: Driver.just(())
        )
        
        let gif = GifPM(Gif(
            URL(string: "https://giphy.com/gifs/thisisgiphy-reaction-audience-3o7qDPfGhunRMZikI8")!
        ))
       
        interactor = GifDetailsInteractor(gateway: GifStubGateway(), gif: Observable.just(gif), actions: actions)
        
        interactor.urlToOpen.drive(onNext: { url in
            XCTAssertEqual(url, gif.url!)
            testExpectation.fulfill()
        })
        .addDisposableTo(disposeBag)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
