//
//  Publisher+Extension.swift
//  mobiquity-ios-challenge
//
//  Created by Gustavo Campos on 29/8/21.
//

import Combine
import Foundation

extension Publisher where Failure: Error {
    func result() -> AnyPublisher<Result<Output, Failure>, Never> {
        map { .success($0) }
        .catch { Just(.failure($0)) }
        .eraseToAnyPublisher()
    }
}
