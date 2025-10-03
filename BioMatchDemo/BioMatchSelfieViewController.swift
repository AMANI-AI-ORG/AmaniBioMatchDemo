//
//  BioMatchSelfieViewController.swift
//  BioMatchDemo
//
//  Created by Bedri Doğan on 2.10.2025.
//

import UIKit
import AmaniBioMatch

  var pinValue: String? = ""

class BioMatchSelfieViewController: UIViewController {
  
  var bioMatch: AmaniBioMatchSDK? = nil
 
  private var bioLoginView: UIView?
  private var selfie: Selfie?
  private var isStartingBioMatch = false
  private var didCompleteBioMatch = false
//  private var token: String?
  private var customerId: String?
  
  
  
  private let selfieButton: UIButton = {
    let b = UIButton(type: .system)
    b.setTitle("Start Biomatch Selfie", for: .normal)
    b.setTitleColor(.white, for: .normal)
    b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    b.backgroundColor = UIColor(red: 0.75, green: 0.24, blue: 0.36, alpha: 1.0)
    b.layer.cornerRadius = 20
    b.layer.masksToBounds = true
    b.translatesAutoresizingMaskIntoConstraints = false
    return b
  }()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  private func setupUI() {
    view.backgroundColor = .white
    
    selfieButton.addTarget(self, action: #selector(didTapSelfieButton), for: .touchUpInside)
    
    let stack = UIStackView(arrangedSubviews: [selfieButton])
    stack.axis = .vertical
    stack.alignment = .fill
    stack.spacing = 30
    stack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stack)
    
    NSLayoutConstraint.activate([
      
      stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      
      stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
      stack.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
      stack.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -48),
      stack.widthAnchor.constraint(greaterThanOrEqualToConstant: 220),
      selfieButton.heightAnchor.constraint(equalToConstant: 56),
      
    ])
    
    
  }
  
  @objc func didTapSelfieButton() {
    
    startBioLoginSelfie()
    
    
  }
  
  
  @MainActor
  func startBioLoginSelfie() {
    
    guard !isStartingBioMatch else { return }
    isStartingBioMatch = true
    didCompleteBioMatch = false
    
      // SDK init
    let biomatch = AmaniBioMatchSDK(baseURL: URL(string: "")!, token: token)
    self.bioMatch = biomatch
    
      // Manager
    let manager = biomatch.selfie()
    self.selfie = manager
    
    let selfieConfig = SelfieScreenConfig(
      manualCaptureButtonInnerHex: "3B82F6",
      manualCaptureButtonOuterHex: "3B82F6",
      appFontHex: "FFFFFF",
      appBackgroundHex: "FFFFFF",
      instructionText: "Align your face within the oval",
      permissionDeniedTitle: "Permissions Required",
      permissionDeniedMessage: "To capture a selfie, please grant Camera access.",
      retryButtonText: "Retry",
      settingsButtonText: "Open Settings",
      permissionHandling: .automatic( // or .manual
        alertTexts: SelfiePermissionAlertTexts(
          title: "Permissions Required",
          message: "Camera access is needed to continue.",
          openSettings: "Settings",
          cancel: "Cancel"
        )
      )
    )
    
    do {
      
      guard let view = try manager.start(config: selfieConfig, completion: { [weak self] previewImage in
        print("App closure fired, image:", previewImage)
        
        guard let self = self else { return }
        guard !self.didCompleteBioMatch else { return }
        self.didCompleteBioMatch = true
        
        Loader.shared.start()
        guard let pin = pinValue, !pin.isEmpty else {
          Loader.shared.stop()
          self.showAlert(isUploaded: false)
          self.isStartingBioMatch = false
          return
        }
        
        self.selfie?.upload(pin: pin) { [weak self] result in
          guard let self = self else { return }
          Loader.shared.stop()
          switch result {
          case .success:
            self.showAlert(isUploaded: true)
          case .failure(let error):
            print("Upload error:", error)
            self.showAlert(isUploaded: false)
          }
          
          self.bioLoginView?.removeFromSuperview()
          self.bioLoginView = nil
          self.selfie = nil
          self.isStartingBioMatch = false
        }
      }) else {
        
        isStartingBioMatch = false
        return
      }
      
      
      view.frame = self.view.bounds
      self.view.addSubview(view)
      self.bioLoginView = view
      
    } catch {
      isStartingBioMatch = false
      print("Unexpected error: \(error)")
    }
  }
  
  
  private func startBioPin() {
    DispatchQueue.main.async {
      
      let vc = BioMatchPinViewController()
      vc.modalTransitionStyle = .crossDissolve
      vc.modalPresentationStyle = .fullScreen
      
      self.present(vc, animated: true)
    }
  }
}
extension BioMatchSelfieViewController {
  private func showAlert(isUploaded: Bool) {
    DispatchQueue.main.async {
      var actions: [(String, UIAlertAction.Style)] = []
      
      actions.append(("\("Ok")", UIAlertAction.Style.default))
      
      AlertDialogueUtility.shared.showAlertWithActions(vc: self, title: "Biologin Selfie Upload Response", message: "response: \(isUploaded)", actions: actions) { index in
        if index == 0 {
          DispatchQueue.main.async {
            Loader.shared.stop()
            self.startBioPin()
          }
        }
      }
    }
  }
}
