//
//  CaptureAnalyzer.swift
//  CoreML_Vision_Sampler
//
//  Created by AtsuyaSato on 2018/06/30.
//  Copyright © 2018年 Atsuya Sato. All rights reserved.
//

import Foundation
import Vision

enum CaptureAnalyzerError {
    case failedToAccessMLModel
    case failedPerformHandler
}

struct CaptureAnalyzer {
    static var mlModel: VNCoreMLModel?

    static func analyze(pixelBuffer: CVPixelBuffer, _ block: @escaping (Either<String, CaptureAnalyzerError>) -> Void) {
        guard let mlModel = mlModel else {
            block(Either.right(.failedToAccessMLModel))
            return
        }

        let request = VNCoreMLRequest(model: mlModel) { (request, error) in
            if let result: VNClassificationObservation = request.results?.first as? VNClassificationObservation {
                DispatchQueue.main.async {
                    block(Either.left(result.identifier))
                }
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            block(Either.right(.failedPerformHandler))
        }
    }

}
