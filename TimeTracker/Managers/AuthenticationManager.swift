//
//  AuthenticationManager.swift
//  TimeTracker
//
//  Created by Francis Breidenbach on 7/15/17.
//  Copyright © 2017 Francis Breidenbach. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire
import SwiftyJSON
import RealmSwift


class AuthenticationManager {
  
  let disposeBag = DisposeBag()
  
  // MARK: - Observable Properties
  let helperText = Variable<String>("Login using your API key to continue.")
  let authStatus = Variable<Bool>(false)
  
  // MARK: - Observable Methods
  
  
  func authorizeUser(withKey key: String) {
    
    helperText.value = "Attempting login ..."
    
    let request = RxAlamofire
      .requestJSON(TeamworkAPI.Router.authenticate(key))
      .subscribeOn(MainScheduler.instance)
      .filter { (response, _) in
        return 200..<300 ~= response.statusCode
      }
      .map { (_, data) -> JSON in
        let json = data as! [String: Any]
        let account = json["account"] as! [String: Any]
        return JSON(account)
      }
      .map { json -> User in
        let user = User(fromJSON: json)
        self.saveUser(user)
        return user
      }
      .catchErrorJustReturn(User.empty)
      .share()
    
    request
      .map { user -> Bool in
        return user.hasAuthenticated
      }
      .bind(to: authStatus)
      .disposed(by: disposeBag)
    
    
    request
      .map { user -> Bool in
        return user.hasAuthenticated
      }
      .subscribe(onNext: { result in
        if !result {
          self.helperText.value = "Invalid API key. Please try again ..."
        } else {
          self.helperText.value = "Login successful!"
        }
        
      })
      .disposed(by: disposeBag)
    
    
    
    
  }
  
  
  deinit {
    print("ALERT ** AuthenticationManager Deinitialized ** ALERT")
  }
  
  
  
  // MARK: - Helper
  func saveUser(_ user: User) {
    
    let realm = try! Realm()
    
    try! realm.write {
      realm.add(user, update: true)
    }
  }
  
}
