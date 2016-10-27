import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import Protium

extension XCTestCase {
    
    // Emits the passed in elements at the specified time intervals, e.g.:
    // stubObservable([("", 0.1), ("cars", 0.2), ("cats", 0.3)])
    // would emit "" after 0.1 seconds, "cars" after 0.2, and "cats" after 0.3.
    func stubObservable<Element>(_ elements: [(Element, TimeInterval)]) -> Observable<Element> {
        return Observable.create { observer in
            var remainingElements = elements
            if remainingElements.isEmpty {
                observer.on(.completed)
                return Disposables.create()
            }
            
            var scheduleTimer: (((Element, TimeInterval)) -> Cancelable)!
            var timerCancel: Cancelable!
            var previousTime: TimeInterval = 0.0
            
            scheduleTimer = { element in
                let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
                timer.scheduleOneshot(deadline: DispatchTime.now() + (element.1 - previousTime), leeway: .nanoseconds(0))
                previousTime = element.1
                
                timerCancel = Disposables.create {
                    timer.cancel()
                }
                
                timer.setEventHandler {
                    if timerCancel.isDisposed {
                        return
                    }
                    observer.on(.next(element.0))
                    
                    if remainingElements.isEmpty {
                        observer.on(.completed)
                    } else {
                        let nextElement = remainingElements.removeFirst()
                        timerCancel = scheduleTimer(nextElement)
                    }
                }
                timer.resume()
                
                return timerCancel
            }
            
            timerCancel = scheduleTimer(remainingElements.removeFirst())
            
            return Disposables.create {
                timerCancel.dispose()
            }
        }
    }
    
    func stubDriver<Element>(_ elements: [(Element, TimeInterval)]) -> Driver<Element> {
        return stubObservable(elements).asDriver(onErrorRecover: { error -> Driver<Element> in
            print("This can't error out.")
            return Driver.never()
        })
    }
}

// Convenience extensions for Model/Presentation Model construction.
extension Gif {
    init(_ url: URL) {
        self.id = ""
        self.url = url
        self.embedURL = nil
        self.originalStillURL = nil
        self.originalVideoURL = nil
    }
}

extension GifPM {
    init(_ id: String) {
        self.init(Gif(id: id))
    }
}
