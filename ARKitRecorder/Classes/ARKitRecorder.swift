//
//  ARKitRecorder.swift
//  ARKitRecorder
//
//  Created by Tomoya Hirano on 2017/10/31.
//

import UIKit
import ARKit
import AVFoundation

public class ARKitRecorder: NSObject, ARSCNViewDelegate {
  private let renderer = SCNRenderer(device: nil, options: nil)
  private let size: CGSize
  private var writer: AVAssetWriter!
  private let queue = DispatchQueue(label: "com.noppelabs.ARKitRecorder")
  private let options: Options
  
  private lazy var input: AVAssetWriterInput = .init(mediaType: .video, outputSettings: [
      AVVideoCodecKey: self.options.videoCodec,
      AVVideoWidthKey: self.size.width,
      AVVideoHeightKey: self.size.height
  ])
  
  private lazy var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor = .init(assetWriterInput: self.input, sourcePixelBufferAttributes: [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
    kCVPixelBufferWidthKey as String: self.size.width,
    kCVPixelBufferHeightKey as String: self.size.height,
  ])

  private(set) var isWriting = false
  private var currentTime: TimeInterval = 0
  
  public init(with arSCNView: ARSCNView, options: Options) throws {
    self.size = arSCNView.snapshot().size
    self.options = options
    super.init()
    arSCNView.delegate = self
    renderer.scene = arSCNView.scene
    _ = pixelBufferAdaptor
    try resetWriter()
  }
  
  public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    queue.async { [weak self] in
      self?.processVideo(with: renderer, updateAtTime: time)
    }
  }
  
  private func processVideo(with renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    autoreleasepool {
      currentTime = time
      guard writer.status == .writing else { return }
      guard input.isReadyForMoreMediaData else { return }
      guard let pool = pixelBufferAdaptor.pixelBufferPool else { return }
      let image = self.renderer.snapshot(atTime: time, with: size, antialiasingMode: options.antialiasingMode)
      guard let pixelBuffer = PixelBufferFactory.make(with: size, from: image, usingBuffer: pool) else { return }
      guard isWriting else { return }
      pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: CMTimeMakeWithSeconds(time, 1000000))
    }
  }
  
  public func startWriting() throws {
    try resetWriter()
    FileController.delete(file: options.outputURL)
    writer.startWriting()
    writer.startSession(atSourceTime: CMTimeMakeWithSeconds(currentTime, 1000000))
    isWriting = true
  }
  
  public func cancelWriting() {
    isWriting = false
    writer.cancelWriting()
  }
  
  public func finishWriting(completionHandler: ((URL) -> Void)? = nil) {
    isWriting = false
    writer.finishWriting { [weak self] in
      guard let url = self?.options.outputURL else { return }
      completionHandler?(url)
    }
  }
  
  private func resetWriter() throws {
    writer = try AVAssetWriter(outputURL: options.outputURL, fileType: .mp4)
    writer.movieFragmentInterval = kCMTimeInvalid
    writer.add(input)
  }
}


