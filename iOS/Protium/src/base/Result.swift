import Foundation

// Generic Result Monad:
// See: https://www.cocoawithlove.com/blog/2016/08/21/result-types-part-one.html
// and: https://github.com/mattgallagher/CwlUtils/blob/master/CwlUtils/CwlResult.swift
protocol ResultType {
    associatedtype Value
    associatedtype ErrorType: Error
    
    var value: Value? { get }
    var error: ErrorType? { get }
    
    func unwrap() throws -> Value
}

enum Result<V, E: Error>: ResultType {
    typealias Value = V
    typealias ErrorType = E
    
    case success(Value)
    case failure(ErrorType)
    
    init(_ capturing: () throws -> Value) {
        do {
            self = .success(try capturing())
        } catch (let e) {
            self = .failure(e as! ErrorType)
        }
    }
    
    var value: Value? {
        switch self {
        case .success(let value): return value
        case .failure: return nil
        }
    }
    
    var error: ErrorType? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }
    
    var isError: Bool {
        switch self {
        case .success: return false
        case .failure: return true
        }
    }
    
    func unwrap() throws -> Value {
        switch self {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }
}

extension Result {
    func map<U>(_ transform: @escaping (Value) throws -> U) -> Result<U, ErrorType> {
        switch self {
        case .success(let value): return Result<U, ErrorType> { try transform(value) }
        case .failure(let error): return .failure(error)
        }
    }
    
    func flatMap<U>(_ transform: (Value) -> Result<U, ErrorType>) -> Result<U, ErrorType> {
        switch self {
        case .success(let value): return transform(value)
        case .failure(let error): return .failure(error)
        }
    }
}
