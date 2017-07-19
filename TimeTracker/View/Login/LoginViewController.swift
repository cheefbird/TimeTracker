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
      .observeOn(MainScheduler.instance)
      .filter { $0 }
      .subscribe(onNext: { [weak self] _ in
          guard let presentingVC = self?.presenter else { return }
          presentingVC.dismiss(animated: true) {
            presentingVC.refreshView()
          }
      })
      .disposed(by: disposeBag)
    
  }
  
  deinit {
    print("ALERT ** LoginViewController Deinitialized ** ALERT")
  }
  
  
  
  private lazy var presenter: SettingsViewController? = {
    guard let presentingVC = self.presentingViewController as? UITabBarController,
      let actualPresenter = presentingVC.selectedViewController as? SettingsViewController else { return nil }
    return actualPresenter
  }()
  
}






