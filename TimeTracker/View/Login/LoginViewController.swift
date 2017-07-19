//
//  LoginViewController.swift
//  TimeTracker
//
//  Created by Francis Breidenbach on 7/15/17.
//  Copyright © 2017 Francis Breidenbach. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class LoginViewController: UIViewController {
  
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var keyTextField: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  
  var authenticationManager: AuthenticationManager!
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    authenticationManager = AuthenticationManager()
    
    let status = authenticationManager.helperText.asDriver()
    
    status
      .drive(statusLabel.rx.text)
      .disposed(by: disposeBag)
    
    let authKey = loginButton.rx.tap.asObservable()
      .withLatestFrom(keyTextField.rx.text.orEmpty)
      .filter { $0.characters.count > 0 }
    
    
    authKey
      .subscribe(onNext: { [weak self] key in
        self?.authenticationManager.authorizeUser(withKey: key)
      })
      .disposed(by: disposeBag)
    
    authenticationManager.authStatus.asObservable()
//      .observeOn(MainScheduler.instance)
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
        DispatchQueue.main.async {
          let presentingVC = self?.presenter as! SettingsViewController
          presentingVC.dismiss(animated: true) {
            presentingVC.refreshView()
          }
        }
      })
      .disposed(by: disposeBag)
    
  }
  
  
  private lazy var presenter: UIViewController = {
    let presenterVC = self.presentingViewController as! SettingsViewController
    return presenterVC
  }()
  
}






