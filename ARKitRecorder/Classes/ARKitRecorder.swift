//
//  ARKitRecorder.swift
//  ARKitRecorder
//
//  Created by Tomoya Hirano on 2017/10/31.
//

import UIKit
import ARKit

public class ARKitRecorder: NSObject, ARSCNViewDelegate {
  private let renderer = SCNRenderer(device: nil, options: nil)
  private let size: CGSize
  private let outputURL: URL
  private var writer: AVAssetWriter!
  
  private lazy var input: AVAssetWriterInput = .init(mediaType: .video, outputSettings: [
      AVVideoCodecKey: AVVideoCodecType.h264,
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
  
  public init(with arSCNView: ARSCNView, outputURL: URL) throws {
    self.size = arSCNView.snapshot().size
    self.outputURL = outputURL
    super.init()
    arSCNView.delegate = self
    renderer.scene = arSCNView.scene
    _ = pixelBufferAdaptor
    try resetWriter()
  }
  
  public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    DispatchQueue.main.async { [weak self] in
      self?.processVideo(with: renderer, updateAtTime: time)
    }
  }
  
  private func processVideo(with renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    autoreleasepool {
      currentTime = time
      guard isWriting else { return }
      guard writer.status == .writing else { return }
      guard input.isReadyForMoreMediaData else { return }
      guard let pool = pixelBufferAdaptor.pixelBufferPool else { return }
      let image = self.renderer.snapshot(atTime: time,
                                         with: size,
                                         antialiasingMode: SCNAntialiasingMode.multisampling4X)
      guard let pixelBuffer = PixelBufferFactory.make(with: size, from: image, usingBuffer: pool) else { return }
      pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: CMTimeMakeWithSeconds(time, 1000000))
    }
  }
  
  public func startWriting() throws {
    try resetWriter()
    FileController.delete(file: outputURL)
    writer.startWriting()
    writer.startSession(atSourceTime: CMTimeMakeWithSeconds(currentTime, 1000000))
    isWriting = true
  }
  
  public func finishWriting(completionHandler: ((URL) -> Void)? = nil) {
    isWriting = false
    writer.finishWriting { [weak self] in
      guard let url = self?.outputURL else { return }
      completionHandler?(url)
    }
  }
  
  private func resetWriter() throws {
    writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
    writer.add(input)
  }
}


