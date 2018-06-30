//
//  Either.swift
//  CoreML_Vision_Sampler
//
//  Created by AtsuyaSato on 2018/06/30.
//  Copyright © 2018年 Atsuya Sato. All rights reserved.
//

enum Either<Left, Right> {
    case left(Left)
    case right(Right)

    var left: Left? {
        switch self {
        case let .left(x):
            return x
        case .right:
            return nil
        }
    }

    var right: Right? {
        switch self {
        case .left:
            return nil
        case let .right(x):
            return x
        }
    }
}
