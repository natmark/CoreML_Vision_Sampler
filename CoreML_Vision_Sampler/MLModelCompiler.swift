//
//  MLModelCompiler.swift
//  CoreML_Vision_Sampler
//
//  Created by AtsuyaSato on 2018/06/30.
//  Copyright © 2018年 Atsuya Sato. All rights reserved.
//

import Foundation
import CoreML

protocol MLModelRequest {
    var url: URL { get }
    var fileName: String { get }
}

enum MLModelCompilerError {
    case failedToCompile
    case failedToLocateCompiledModel
    case failedToDownload
    case failedToLocateDownloadedModel
    case unexpectedError
}

struct MLModelCompiler {
    static func request(_ modelRequest: MLModelRequest, _ block: @escaping (Either<MLModel, MLModelCompilerError>) -> Void) {
        Swift.print("MLModel Request")
        MLModelCompiler.fetch(modelRequest) { result in
            switch result {
            case .left(let url):
                block(MLModelCompiler.compile(url))
            case .right(let error):
                block(Either.right(error))
            }
        }
    }

    static private func fetch(_ modelRequest: MLModelRequest, _ block: @escaping (Either<URL, MLModelCompilerError>) -> Void) {
        Swift.print("Start MLModel fetching")
        guard var filePath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            block(Either.right(.unexpectedError))
            return
        }

        filePath.appendPathComponent(modelRequest.fileName, isDirectory: false)

        if FileManager.default.fileExists(atPath: filePath.path) {
            block(Either.left(filePath))
            return
        }

        let task = URLSession.shared.downloadTask(with: modelRequest.url) {  (url, urlResponse, error) in
            if let _ = error {
                block(Either.right(.failedToDownload))
                return
            }

            guard let url = url else {
                block(Either.right(.failedToDownload))
                return
            }

            do {
                try FileManager.default.moveItem(at: url, to: filePath)
            } catch {
                block(Either.right(.failedToLocateDownloadedModel))
                return
            }
            block(Either.left(filePath))
        }
        task.resume()
    }

    static private func compile(_ url: URL) -> Either<MLModel, MLModelCompilerError> {
        Swift.print("Start MLModel Compiling")
        let compiledUrl: URL
        do {
            compiledUrl = try MLModel.compileModel(at: url)
        } catch {
            return Either.right(.failedToCompile)
        }

        guard let directory = try? FileManager.default.url(for: .applicationSupportDirectory,
                                                           in: .userDomainMask,
                                                           appropriateFor: compiledUrl,
                                                           create: true) else {
            return Either.right(.unexpectedError)
        }

        let permanentUrl = directory.appendingPathComponent(compiledUrl.lastPathComponent, isDirectory: false)
        do {
            if FileManager.default.fileExists(atPath: permanentUrl.path) {
                _ = try FileManager.default.replaceItemAt(permanentUrl, withItemAt: compiledUrl)
            } else {
                try FileManager.default.copyItem(at: compiledUrl, to: permanentUrl)
            }
        } catch {
            return Either.right(.failedToCompile)
        }

        do {
            let model = try MLModel(contentsOf: permanentUrl)
            return Either.left(model)
        } catch {
            return Either.right(.failedToLocateCompiledModel)
        }
    }
}
