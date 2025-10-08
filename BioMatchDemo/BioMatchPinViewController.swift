//
//  BioMatchPinViewController.swift
//  BioMatchDemo
//
//  Created by Bedri Doğan on 2.10.2025.
//

import UIKit
import Foundation
//import AmaniBioMatch

/*
class BioMatchPinViewController: UIViewController {
  var bioMatch: AmaniBioMatchSDK? = nil
  private var pinManager: Pin?
  private weak var pinView: UIView?
  var userPin: String = ""
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setupPinView()
    
  }
  
  private func setupPinView() {
    let biomatch = AmaniBioMatchSDK(baseURL: URL(string: "")!, token: token)
    self.bioMatch = biomatch
    
    let manager = bioMatch?.PIN()
    self.pinManager = manager
   
    
    
    let cfg = PinScreenConfig(
      title: "Ödeme Doğrulama",
      subtitle: "4 haneli PIN’i girin",
      backgroundHex: "#FFFFFF",
      titleHex: "1F2937",
      subtitleHex: "6B7280",
      pinDotFilledHex: "3B82F6",
      pinDotEmptyHex: "E5E7EB",
      keypadButtonBackgroundHex: "F9FAFB",
      keypadButtonNumberHex: "1F2937",
      keypadButtonBorderHex: "073779",
      deleteButtonContentHex: "BE2020",
      deleteButtonBackgroundHex: "999999",
      deleteButtonBorderHex: "69EF44"
    )
    
    do {
      
      DispatchQueue.main.async { [self] in
        guard let v = try? manager?.start(config: cfg, completion: { [weak self] entryedPin in
          Loader.shared.start()
          manager?.enablePin(entryedPin) { [weak self] isSuccess in
            //burada kullanıcı ilk defa pin'i enable edeceği için globalde tuttugumuz pin değerine eşitliyoruz ki daha sonra BioPay Selfie adımında göndereceğiz.
            pinValue = entryedPin
            Loader.shared.stop()
            switch isSuccess {
            case .success(let value):
              print("Success: \(value)")
              self?.showAlert(isUploaded: true)
            case .failure(let error):
              print("Error: \(error)")
              self?.showAlert(isUploaded: false)
            }
            
            
          }
          
        }) else { return }
        view.addSubview(v)
        self.pinView = v
      }
      
      
    }catch {
      
    }
    
  }
  
  private func rootToMain() {
    DispatchQueue.main.async {
      
      let vc = MainViewController()
      vc.modalTransitionStyle = .crossDissolve
      vc.modalPresentationStyle = .fullScreen
      
      self.present(vc, animated: true)
    }
  }
  
  
}

extension BioMatchPinViewController {
  private func showAlert(isUploaded: Bool) {
    DispatchQueue.main.async {
      var actions: [(String, UIAlertAction.Style)] = []
      
      actions.append(("\("Ok")", UIAlertAction.Style.default))
      
      AlertDialogueUtility.shared.showAlertWithActions(vc: self, title: "Biologin Selfie Upload Response", message: "response: \(isUploaded)", actions: actions) { index in
        if index == 0 {
          DispatchQueue.main.async {
            Loader.shared.stop()
            self.rootToMain()
          }
        }
      }
    }
  }
}
*/
