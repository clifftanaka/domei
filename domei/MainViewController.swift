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
        providers.append(FUIGoogleAuth(scopes: [kGoogleGamesScope,kGooglePlusMeScope,kGoogleUserInfoEmailScope,
                                                kGoogleUserInfoProfileScope]))
        //providers.append(FUITwitterAuth())
        providers.append(FUIFacebookAuth(permissions: ["email", "user_friends", "ads_read"]))
        
        return providers
    }
}
