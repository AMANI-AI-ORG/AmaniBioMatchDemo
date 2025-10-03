//
//  MainViewController.swift
//  BioMatchDemo
//
//  Created by Bedri Doğan on 2.10.2025.
//


import UIKit
import Foundation
import AmaniUI
import AmaniSDK
import AmaniBioMatch

class MainViewController: UIViewController {
  var amaniSDK: Amani = Amani.sharedInstance
  private var selfieView: UIView?
  private var isStartingSelfie = false
  private var didCompleteSelfie = false
    
  private let kycButton: UIButton = {
    let b = UIButton(type: .system)
    b.setTitle("KYC & Payment Register Process", for: .normal)
    b.setTitleColor(.white, for: .normal)
    b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    b.backgroundColor = UIColor(red: 0.75, green: 0.24, blue: 0.36, alpha: 1.0)
    b.layer.cornerRadius = 20
    b.layer.masksToBounds = true
    b.translatesAutoresizingMaskIntoConstraints = false
    return b
  }()
  

  private let bioPayButton: UIButton = {
    let b = UIButton(type: .system)
    b.setTitle("Payment via Tablet Process", for: .normal)
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
    
    kycButton.addTarget(self, action: #selector(didTapKYC), for: .touchUpInside)
    bioPayButton.addTarget(self, action: #selector(didTapBioPay), for: .touchUpInside)

    
    let stack = UIStackView(arrangedSubviews: [kycButton, bioPayButton])
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
      kycButton.heightAnchor.constraint(equalToConstant: 56),
      bioPayButton.heightAnchor.constraint(equalToConstant: 56),
     
    ])
    
    startAmaniKYC()
  }
  
  
  private func startBioSelfieAndPin() {
    DispatchQueue.main.async {
      let vc = BioMatchSelfieViewController()
      vc.modalTransitionStyle = .crossDissolve
      vc.modalPresentationStyle = .fullScreen
      
      self.present(vc, animated: true)
    }
  }
  
  private func startAmaniKYC() {
    let customer:CustomerRequestModel = CustomerRequestModel(name: "", email: "", phone: "", idCardNumber: "")
    
      //    amaniSDK.init
    amaniSDK.initAmani(server: "", token: token, customer: customer) { result, error in
      
    }
  
  }
  
  func startKYCSelfie() {
    guard !isStartingSelfie else { return }
    isStartingSelfie = true
    didCompleteSelfie = false
    
    do {
      let selfie = amaniSDK.selfie()
      
      selfie.setType(type: "XXX_SE_0")
      
      guard let view = try selfie.start(completion: { [weak self] previewImage in
        guard let self = self else { return }
        
        guard !self.didCompleteSelfie else { return }
        self.didCompleteSelfie = true
        
        DispatchQueue.main.async {
          Loader.shared.start()
          selfie.upload { [weak self] isSuccess in
            DispatchQueue.main.async {
              Loader.shared.stop()
              self?.showAlert(isUploaded: isSuccess ?? false)
            }
          }
          
          
          if let v = self.selfieView, v.superview != nil {
            v.removeFromSuperview()
          }
          self.selfieView = nil
            //          self.selfie = nil
          self.isStartingSelfie = false
        }
      }) else {
        isStartingSelfie = false
        return
      }
      
      if view.superview == nil {
        view.frame = self.view.bounds
        self.view.addSubview(view)
        self.selfieView = view
      }
    } catch {
      isStartingSelfie = false
      print("Unexpected error: \(error)")
    }
  }
  
  @objc private func didTapKYC() {
    startKYCSelfie()
  }
  
  @objc private func didTapBioPay() {
    startBioSelfieAndPin()
  }
  

  private func startPinRegister() {
    DispatchQueue.main.async {
      let vc = BioMatchPinViewController()
      vc.modalTransitionStyle = .crossDissolve
      vc.modalPresentationStyle = .fullScreen
      
      self.present(vc, animated: true)
    }
    
  }

}

extension MainViewController {
  private func showAlert(isUploaded: Bool) {
    DispatchQueue.main.async {
      var actions: [(String, UIAlertAction.Style)] = []
      
      actions.append(("\("Ok")", UIAlertAction.Style.default))
      
      AlertDialogueUtility.shared.showAlertWithActions(vc: self, title: "KYC Selfie Upload Response", message: "response: \(isUploaded)", actions: actions) { index in
        if index == 0 {
          Loader.shared.stop()
          self.startPinRegister()
        }
      }
    }
  }
}
