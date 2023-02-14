//
//  ViewController.swift
//  CheckList
//
//  Created by 劒持輝泰 on 2020/05/17.
//  Copyright © 2020 Swift-Beginners.MyCheckList. All rights reserved.
//

//
//  ViewController.swift
//  買い物リスト
//
//  Created by 劒持輝泰 on 2020/04/29.
//  Copyright © 2020 Swift-Beginners. All rights reserved.
//

import UIKit
import GoogleMobileAds

//@objc protocol reloadDelegate {
//    func  tableViewReloadData()
//}



class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        
        shopingList = userDefaults?.stringArray(forKey: "shopingList") ?? []
        
    }
    
    
    
    
    let userDefaults = UserDefaults(suiteName: "group.Swift-Beginner.checkList")
    var shopingList: [String] = []
    
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var bannerView: GADBannerView!
    

    // 追加ボタンを押した時、追加画面がポップアップする
    @IBAction func addButtonAction(_ sender: Any) {
        var alertTextField: UITextField?
        alertTextField?.keyboardType = UIKeyboardType.namePhonePad
        self.shopingList = userDefaults?.stringArray(forKey: "shopingList") ?? []
        let alertController = UIAlertController(title: "チェックリストの追加", message: "追加するチェックリストを入力してください", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "決定", style: .default, handler: {_ in
            self.shopingList.append((alertTextField?.text)!)
            self.userDefaults?.set(self.shopingList, forKey: "shopingList")
            print(self.shopingList)
            let childVC = self.children[0] as! ContainerViewController
            childVC.reload()
        })
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        alertController.addTextField(configurationHandler: {(textField:UITextField!) in
            alertTextField = textField
        })
        
        self.present(alertController,animated: true, completion: nil)
    }
    
    func addButtonisHidden() {
        if addButton.isEnabled {
            addButton.isEnabled = false
            UIView.animate(withDuration: 0.15, animations: {
                self.addButton.alpha = 0
            })
        } else {
            addButton.isEnabled = true
            UIView.animate(withDuration: 0.15, animations: {
                self.addButton.alpha = 1
            })
            
        }
    }
    
   
}
