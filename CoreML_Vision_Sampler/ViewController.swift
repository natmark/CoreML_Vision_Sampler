//
//  ViewController.swift
//  CoreML_Vision_Sampler
//
//  Created by AtsuyaSato on 2018/06/30.
//  Copyright © 2018年 Atsuya Sato. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let captureSession = CaptureSession(delegate: self, previewView: self.previewView)
        let request = MobileNet()

        indicatorView.startAnimating()
        MLModelCompiler.request(request) { result in
            switch result {
            case .left(let model):
                CaptureAnalyzer.mlModel = try? VNCoreMLModel(for: model)

                self.indicatorView.stopAnimating()
                self.indicatorView.isHidden = true
                captureSession.startRunning()
            case .right(_): break
            }
        }
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CaptureAnalyzer.analyze(pixelBuffer: pixelBuffer) { result in
            switch result {
            case .left(let identifier):
                self.label.text = identifier
            case .right(_): break
            }
        }
    }
}

