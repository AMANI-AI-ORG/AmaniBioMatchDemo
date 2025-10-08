//
//  MainViewController.swift
//  BioMatchDemo
//
//  Created by Bedri Doğan on 2.10.2025.
//


import UIKit
import Foundation
//import AmaniUI
import AmaniSDK

class MainViewController: UIViewController {
  var amaniSDK: Amani = Amani.sharedInstance
  private var selfieView: UIView?
  private var isStartingSelfie = false
  private var didCompleteSelfie = false
  private var customerInfo: CustomerInfo?
  
    // MARK: - UI
  private let tokenTextField: UITextField = {
    let tf = UITextField(frame: .zero)
    tf.placeholder = "Token"
    tf.autocorrectionType = .no
    tf.autocapitalizationType = .none
    tf.keyboardType = .asciiCapable
    

    tf.backgroundColor = .white
    tf.textColor = .black
    tf.tintColor = .black
    tf.keyboardAppearance = .light
    if #available(iOS 13.0, *) {
      tf.overrideUserInterfaceStyle = .light
    }
    
    tf.borderStyle = .none
    tf.layer.cornerRadius = 8
    tf.layer.masksToBounds = true
    tf.layer.borderColor = UIColor.black.cgColor
    tf.layer.borderWidth = 1.0 / UIScreen.main.scale
    
  
    let padL = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
    tf.leftView = padL
    tf.leftViewMode = .always
    let padR = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
    tf.rightView = padR
    tf.rightViewMode = .always
    
    tf.attributedPlaceholder = NSAttributedString(
      string: "Token",
      attributes: [.foregroundColor: UIColor.darkGray]
    )
    
    tf.clearButtonMode = .whileEditing
    tf.translatesAutoresizingMaskIntoConstraints = false
    return tf
  }()
  
  private let tfButtonsSpacer: UIView = {
    let v = UIView()
    v.translatesAutoresizingMaskIntoConstraints = false
    return v
  }()
  
  private let enablebioPayButton: UIButton = {
    let b = UIButton(type: .system)
    b.setTitle("Enable Pin", for: .normal)
    b.setTitleColor(.white, for: .normal)
    b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    b.backgroundColor = UIColor(red: 0.75, green: 0.24, blue: 0.36, alpha: 1.0)
    b.layer.cornerRadius = 20
    b.layer.masksToBounds = true
    b.translatesAutoresizingMaskIntoConstraints = false
    return b
  }()
  
  private let disablebioPayButton: UIButton = {
    let b = UIButton(type: .system)
    b.setTitle("Disable Pin", for: .normal)
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
    
    enablebioPayButton.addTarget(self, action: #selector(didTapEnableBioPay), for: .touchUpInside)
    disablebioPayButton.addTarget(self, action: #selector(didTapDisableBiopay), for: .touchUpInside)
    
    
    let stack = UIStackView(arrangedSubviews: [tokenTextField, tfButtonsSpacer, enablebioPayButton, disablebioPayButton])
    stack.axis = .vertical
    stack.alignment = .fill
    stack.spacing = 16
    stack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stack)
    
    NSLayoutConstraint.activate([
      
      stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
      
 
      stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      
 
      tokenTextField.heightAnchor.constraint(equalToConstant: 44),
      enablebioPayButton.heightAnchor.constraint(equalToConstant: 56),
      disablebioPayButton.heightAnchor.constraint(equalToConstant: 56),
      
   
      tfButtonsSpacer.heightAnchor.constraint(equalToConstant: 60)
    ])
  }

  
    // MARK: - Amani init (token zorunlu)
  private func startAmaniKYC(completion: (() -> Void)? = nil) {
    let raw = tokenTextField.text ?? ""
    let token = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    guard token.isEmpty == false else {
      presentTokenAlert(title: "Eksik Token", message: "Lütfen token alanını doldurun.")
      return
    }
    
    let customer = CustomerRequestModel(name: "", email: "", phone: "", idCardNumber: "")
    
    amaniSDK.initAmani(server: "", token: token, customer: customer) { result, error in
      if let error = error {
        self.presentTokenAlert(title: "Init Hatası", message: "Amani init başarısız: \(error.localizedDescription)")
        return
      }
      _ = self.amaniSDK.customerInfo().getCustomer()
      completion?()
    }
  }

    // MARK: - Actions
  @objc private func didTapEnableBioPay() {
    
    startAmaniKYC { [weak self] in
      self?.didTapEnableBioPayPin()
    }
  }
  
  @objc private func didTapDisableBiopay() {
     
   disableBiopayPin()
    
  }
  
  private func didTapEnableBioPayPin() {
    amaniSDK.customerInfo().enablePin("1234") { [weak self] result in
      guard let self = self else { return }
      DispatchQueue.main.async {
        switch result {
        case .success(let model):
          self.presentResultAlert(title: "Enable PIN",
                                  message: "Başarılı.\n\(String(describing: model))")
        case .failure(let error):
          self.presentResultAlert(title: "Enable PIN",
                                  message: "Hata: \(error.localizedDescription)")
        default:
          self.presentResultAlert(title: "Enable PIN",
                                  message: "Bilinmeyen cevap.")
        }
      }
    }
  }
  
  private func disableBiopayPin() {
    amaniSDK.customerInfo().disablePin { [weak self] result in
      guard let self = self else { return }
      DispatchQueue.main.async {
        switch result {
        case .success(let model):
          self.presentResultAlert(title: "Disable PIN",
                                  message: "Başarılı.\n\(String(describing: model))")
        case .failure(let error):
          self.presentResultAlert(title: "Disable PIN",
                                  message: "Hata: \(error.localizedDescription)")
        default:
          self.presentResultAlert(title: "Disable PIN",
                                  message: "Bilinmeyen cevap.")
        }
      }
    }
  }
}

  // MARK: - Alerts
extension MainViewController {
  private func presentTokenAlert(title: String, message: String) {
    DispatchQueue.main.async {
      let actions: [(String, UIAlertAction.Style)] = [("OK", .default)]
      AlertDialogueUtility.shared.showAlertWithActions(
        vc: self,
        title: title,
        message: message,
        actions: actions
      ) { _ in }
    }
  }
  
   
  private func presentResultAlert(title: String, message: String) {
    DispatchQueue.main.async {
      let actions: [(String, UIAlertAction.Style)] = [("OK", .default)]
      AlertDialogueUtility.shared.showAlertWithActions(
        vc: self, title: title, message: message, actions: actions
      ) { _ in
        Loader.shared.stop()
      }
    }
  }
}

