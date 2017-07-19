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
        print(response.statusCode)
        return 200..<300 ~= response.statusCode
      }
      .map { (_, data) -> JSON in
        let json = data as! [String: Any]
        let account = json["account"] as! [String: Any]
        print(account)
        return JSON(account)
      }
      .map { json -> User in
        let user = User(fromJSON: json)
        self.saveUser(user)
        return user
      }
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
        print("Auth from user call: \(result)")
        self.helperText.value = "Login successful!"
      })
      .disposed(by: disposeBag)
    
    
    
    
  }
  
  
  //  func authAsData(key: String) -> Observable<User> {
  //    let user = RxAlamofire.request(TeamworkAPI.Router.authenticate(key))
  //      .responseJSON()
  //  }
  
  
  // MARK: - Helper
  func saveUser(_ user: User) {
    
    let realm = try! Realm()
    
    try! realm.write {
      realm.add(user, update: true)
    }
  }
  
}
