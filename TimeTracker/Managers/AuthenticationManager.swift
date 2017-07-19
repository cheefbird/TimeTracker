//
//  AuthenticationManager.swift
//  TimeTracker
//
//  Created by Francis Breidenbach on 7/15/17.
//  Copyright © 2017 Francis Breidenbach. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire
import SwiftyJSON
import RealmSwift


class AuthenticationManager {
  
  // MARK: - Observable Properties
  let helperText = Variable<String>("Login using your API key to continue.")
  let authStatus = Variable<Bool>(false)
  
  // MARK: - Observable Methods
  
  
  func authorizationRequest(withKey key: String) -> Observable<User> {
    
    return RxAlamofire
      .requestJSON(TeamworkAPI.Router.authenticate(key))
      .filter { (response, _) in
        return 200..<300 ~= response.statusCode
      }
      .map { (_, data) -> JSON in
        let json = data as! [String: Any]
        return JSON(json)
      }
      .map { json -> User in
        let user = User(fromJSON: json)
        self.saveUser(user)
        return user
    }
    
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
