//
//  AccountManager.swift
//  Ace1.0
//
//  Created by Weiliang Xing on 6/16/14.
//  Copyright (c) 2014 Weiliang Xing. All rights reserved.
//

import Foundation
import UIKit


// create a global reference of the single account; 
// the better way is to create the delegate in relative classes.
var accountSingle: AccountManager = AccountManager()

struct profile{
    
    // if want to retrieve the number in database (which is string), use: var rank:Int = rank.toInt()!
    var rank:Int16 = 10000
    var level:Int16 = 0
    var win:Int16 = 0
    var total:Int16 = 0
    var money:Int16 = 0
    
}

struct account{
    var username = ""
    var password = ""
    var email = ""
    var checkUpdate = true
    var checkTerm = true
    var profileInfo = profile()
    //var portrait:UIImage!
}

class AccountManager: NSObject {
    var tasks = account[]()
    var info = profile()
    
    func addTask(#username: String, password: String, email: String, checkUpdate: Bool, checkTerm: Bool, profileInfo: profile){
        tasks.append(account(username:username, password:password,email: email, checkUpdate: checkUpdate, checkTerm: checkTerm, profileInfo: profileInfo))
    }
    
    func addInfo(#rank: Int16, level: Int16, win: Int16, total: Int16, money: Int16){
        info.rank = rank
        info.level = level
        info.win = win
        info.total = total
        info.money = money
    }
    
    
}
