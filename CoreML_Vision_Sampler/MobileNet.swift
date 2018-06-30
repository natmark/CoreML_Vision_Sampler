//
//  MobileNet.swift
//  CoreML_Vision_Sampler
//
//  Created by AtsuyaSato on 2018/06/30.
//  Copyright © 2018年 Atsuya Sato. All rights reserved.
//

import Foundation

struct MobileNet: MLModelRequest {
    var url: URL {
        return URL(string: "https://docs-assets.developer.apple.com/coreml/models/MobileNet.mlmodel")!
    }

    var fileName: String {
        return "MobileNet.mlmodel"
    }
}
