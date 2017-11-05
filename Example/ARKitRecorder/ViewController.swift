//
//  ViewController.swift
//  ARKitRecorder
//
//  Created by 🦊Tomoya Hirano on 10/31/2017.
//  Copyright (c) 2017 🦊Tomoya Hirano. All rights reserved.
//

import UIKit
import ARKit
import ARKitRecorder
import Photos

final class ViewController: UIViewController {
  @IBOutlet private weak var arSCNView: ARSCNView!
  private let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "output.mp4")
  private let options = ARKitRecorder.Options()
  private lazy var writer: ARKitRecorder = try! .init(with: self.arSCNView, options: self.options)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let scene = SCNScene(named: "art.scnassets/ship.scn")!
    arSCNView.preferredFramesPerSecond = 60
    arSCNView.scene = scene
    _ = writer
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let configuration = ARWorldTrackingConfiguration()
    arSCNView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    arSCNView.session.pause()
  }
  
  @IBAction func buttonAction(_ sender: UIButton) {
    if !sender.isSelected {
      sender.isSelected = true
      sender.setTitle("Recording...", for: .normal)
      try! writer.startWriting()
    } else {
      sender.isSelected = false
      sender.setTitle("Record", for: .normal)
      writer.finishWriting(completionHandler: { [weak self] (url) in
        self?.save(with: url)
      })
    }
  }
  
  private func save(with url: URL) {
    PHPhotoLibrary.shared().performChanges({
      PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
    }) { [weak self] (done, error) in
      self?.showAlert(done: done, error: error)
    }
  }
  
  private func showAlert(done: Bool, error: Error?) {
    let alert = UIAlertController(title: done ? "Success" : "Error", message: error.debugDescription, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
  }
}

