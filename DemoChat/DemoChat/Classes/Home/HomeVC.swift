//
//  ViewController.swift
//  DemoChat
//
//  Created by Niraj Kumar on 12/20/16.
//  Copyright © 2016 Niraj. All rights reserved.
//

import UIKit

class SendMessageCell: UICollectionViewCell {
    @IBOutlet weak var lblMessage: UILabel!
}

class ReceivedMessageCell: UICollectionViewCell {
    @IBOutlet weak var lblMessage: UILabel!
}


class HomeVC: ParentVC, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    
    weak var activeField: UITextView?
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var viewMessage: UIView!
    
    @IBOutlet weak var btnGotoTop: UIButton!
    @IBOutlet weak var cvMessages: UICollectionView!
    
    var messages:[Dictionary<String, AnyObject>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollview.contentSize = CGSize(width: scrollview.frame.size.width, height: 3000.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        constant.sh.socket.on("message") { (data, ack) in
            if let mb = data[0] as? Dictionary<String, AnyObject> {
                self.messages.append(mb)
                self.cvMessages.reloadData()
            }
        }
        
        constant.sh.socket.on("logged in") { (data, ack) in
            constant.sh.allUsers = (data[0] as! [String]).filter{$0 != self.navigationItem.title!}
            print(constant.sh.allUsers)
        }

    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //mark: collection view delegates
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (messages.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellDictionary:[String:AnyObject] = (messages[indexPath.row])
        
        if self.navigationItem.title?.caseInsensitiveCompare(cellDictionary["sourceUser"]! as! String) == .orderedSame  {
            let cell:ReceivedMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chat_receive", for: indexPath) as! ReceivedMessageCell
            cell.lblMessage.text = cellDictionary["messageBody"]! as? String
            return cell
        }
        let cell:SendMessageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chat_send", for: indexPath) as! SendMessageCell
        cell.lblMessage.text = cellDictionary["messageBody"]! as? String
        return cell
    }
    
    //MARK: collectionview flow layout delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width - 5.0, height: 40.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        btnGotoTop.isHidden = !(indexPath.row > 15)
    }
    
    //MARK: TEXTVIEW DELEGATE
    func textViewDidChange(_ textView: UITextView) {
        lblPlaceHolder.isHidden = !(textView.text.isEmpty)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.activeField = nil
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.activeField = textView
    }
    
    
    
    func keyboardDidShow(notification: NSNotification) {
        if let activeField = self.activeField, let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.scrollview.contentInset = contentInsets
            self.scrollview.scrollIndicatorInsets = contentInsets
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.size.height
            if (!aRect.contains(activeField.frame.origin)) {
                self.scrollview.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        self.scrollview.contentInset = contentInsets
        self.scrollview.scrollIndicatorInsets = contentInsets
    }
    
    @IBAction func hidekeyboard(_ sender: Any) {
        if activeField != nil {
            activeField?.resignFirstResponder()
        }
    }
    
    
    @IBAction func btnGotoTopClicked(_ sender: Any) {
        let indexPath:IndexPath = IndexPath(item: 0, section: 0)
        cvMessages.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    @IBAction func btnSendClicked(_ sender: Any) {
        txtMessage.resignFirstResponder()
        constant.sh.socket.emit("message", ["messageBody" : txtMessage.text!, "sourceUser": "\(self.navigationItem.title!)", "destinationUser" : constant.sh.allUsers])
    }
}

