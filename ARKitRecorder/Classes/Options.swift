//
//  Options.swift
//  ARKitRecorder
//
//  Created by Tomoya Hirano on 2017/11/05.
//

import UIKit
import SceneKit
import AVFoundation

extension ARKitRecorder {
  public struct Options {
    public let outputURL: URL
    public let antialiasingMode: SCNAntialiasingMode
    public let videoCodec: AVVideoCodecType
    
    public init() {
      outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "output.mp4")
      antialiasingMode = .none
      videoCodec = AVVideoCodecType.h264
    }
  }
}
