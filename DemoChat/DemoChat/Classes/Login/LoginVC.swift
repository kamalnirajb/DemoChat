//
//  ViewController.swift
//  DemoChat
//
//  Created by Niraj Kumar on 12/20/16.
//  Copyright © 2016 Niraj. All rights reserved.
//

import UIKit
import SocketIO

class LoginVC: ParentVC, UITextFieldDelegate {
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var btnBeginChat: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        constant.sh.socket.on("connect") {data, ack in
            print("socket connected")
            constant.sh.socket.emit("login", ["name" : self.txtUsername.text])
        }
        
        constant.sh.socket.on("logged in") { (data, ack) in
            constant.sh.allUsers = data[0] as! [String]
            print(constant.sh.allUsers)
            self.performSegue(withIdentifier: "login_segue", sender: self)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination
        vc.navigationItem.title = txtUsername.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        vc.navigationController?.navigationItem.backBarButtonItem?.title = ""
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }

    @IBAction func btnBeginChatClicked(_ sender: Any) {
        constant.sh.socket.connect()
    }
    
    // Mark: textfield delegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        btnBeginChat.sendActions(for: .touchUpInside)
        return true
    }
}

