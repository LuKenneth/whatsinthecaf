//
//  CafCredHandler.swift
//  WhatsInTheCaf
//
//  Created by Luke Patterson on 8/12/17.
//  Copyright © 2017 Luke Patterson. All rights reserved.
//

import Foundation
import Firebase

struct CafCredHandler {
    
    static let sharedInstance = CafCredHandler()
    private let ref = FIRDatabase.database().reference()
    private var cred: Int!
    
    func updateCafCred(score: Int, pUser: String) {
        
        getCred(pUser: pUser) { (cafCred) in
            
            if var cred = cafCred {
                cred += score
                self.ref.child("Users").child(pUser).child("CafCred").setValue(cred)
            }
            else {
                self.ref.child("Users").child(pUser).child("CafCred").setValue(score)
            }
        }
        
    }
    
    private func getCred(pUser: String, callback: @escaping (Int?)->()) {
        
        ref.child("Users").child(pUser).child("CafCred").observeSingleEvent(of: .value) { (snapshot) in
            callback(snapshot.value as? Int)
        }

    }
    
    
}
