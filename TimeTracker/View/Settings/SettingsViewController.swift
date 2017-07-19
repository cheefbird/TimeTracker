//
//  SettingsViewController.swift
//  TimeTracker
//
//  Created by Francis Breidenbach on 7/14/17.
//  Copyright © 2017 Francis Breidenbach. All rights reserved.
//

import UIKit
import RealmSwift

class SettingsViewController: UIViewController {
  
  // MARK: - Outlets
  @IBOutlet weak var firstNameLabel: UILabel!
  @IBOutlet weak var lastNameLabel: UILabel!  
  
  
  // MARK: - Properties
  var user: User?
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    firstNameLabel.text = user?.firstName ?? ""
    lastNameLabel.text = user?.lastName ?? ""
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    refreshView()
    
  }
  
  
  // MARK: - Methods
  func presentLogin() {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController

    
    self.present(loginVC, animated: true)
    
  }
  
  func refreshView() {
    
    guard let savedUser = User.retrieve() else {
      return presentLogin()
    }
    
    user = savedUser
    
    firstNameLabel.text = user?.firstName
    lastNameLabel.text = user?.lastName
    
  }
  
  
}

