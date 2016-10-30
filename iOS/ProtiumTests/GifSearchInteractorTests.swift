import XCTest
import RxSwift
import RxCocoa
@testable import Protium

// Example of integration tests for Interactors.
class GifSearchInteractorTests: XCTestCase {
    private var actions: GifSearchUI.Actions!
    private var interactor: GifSearchInteractor!
    private let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSearch() {
        let testExpectation = expectation(description: "Search gifs.")
        
        actions = GifSearchUI.Actions(
            search: stubDriver([("", 0.1), ("cars", 0.2), ("cats", 0.3)]),
            loadNextPage: Observable.empty(),
            cellSelected: Driver.empty(),
            cellImageTapped: Driver<GifPM>.empty()
        )
        
        interactor = GifSearchInteractor(gateway: GifStubGateway(), actions: actions)
       
        var count = 0
        interactor.gifList.drive(onNext: { gifList in
            count += 1
            XCTAssertEqual(gifList.value!.items.count, GifSearchInteractor.perPageLimit)
            if count == 2 {
                testExpectation.fulfill()
            }
        })
        .addDisposableTo(disposeBag)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
