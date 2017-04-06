//
//  MainViewController.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/03/28.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import FirebaseTwitterAuthUI
import FirebaseDatabase

class MainViewController: UITabBarController, FUIAuthDelegate {
    
    fileprivate var authStateDidChangeHandle: FIRAuthStateDidChangeListenerHandle?
    
    fileprivate(set) var auth: FIRAuth?
    fileprivate(set) var authUI: FUIAuth?
    fileprivate(set) var customAuthUIDelegate: FUIAuthDelegate = FUICustomAuthDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = FIRAuth.auth()
        authUI = FUIAuth.defaultAuthUI()
        
        authUI?.delegate = self.customAuthUIDelegate
        authUI?.providers = self.getListOfIDPs()
        
        //I use this method for signing out when I'm developing
        //try! authUI?.signOut()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isUserSignedIn() {
            showLoginView()
        }
    }
    
    private func isUserSignedIn() -> Bool {
        guard FIRAuth.auth()?.currentUser != nil else { return false }
        return true
    }
    
    private func showLoginView() {
        if let authVC = FUIAuth.defaultAuthUI()?.authViewController() {
            present(authVC, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.authStateDidChangeHandle = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if user != nil {
                let authUserId = (user! as FIRUser).uid
                let newUser : User = User()
                newUser.name = (user?.email)!
                newUser.onlineStatus = "online"
                
                FIRDatabase.database().reference().child("users").child(authUserId).child("user").observe(FIRDataEventType.value, with: { (snapshot) in
                    if !snapshot.exists() {
                        FIRDatabase.database().reference().child("users").child(authUserId).child("user").setValue(["name":newUser.name,"onlineStatus":newUser.onlineStatus])
                    } else {
                        print("user exists")
                    }
                })
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let handle = self.authStateDidChangeHandle {
            FIRAuth.auth()?.removeStateDidChangeListener(handle)
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        
        guard let user = user else {
            print(error)
            return
        }
    }
    
    func updateUI(auth: FIRAuth, user: FIRUser?) {
    }
    
    func getListOfIDPs() -> [FUIAuthProvider] {
        var providers = [FUIAuthProvider]()
        providers.append(FUIGoogleAuth(scopes: [kGoogleUserInfoEmailScope, kGoogleUserInfoProfileScope]))
        //providers.append(FUITwitterAuth())
        providers.append(FUIFacebookAuth(permissions: ["public_profile", "email", "user_friends"]))
        
        return providers
    }
}
