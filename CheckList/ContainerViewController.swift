//
//  ContainerViewController.swift
//  CheckList
//
//  Created by 劒持輝泰 on 2020/05/17.
//  Copyright © 2020 Swift-Beginners.MyCheckList. All rights reserved.
//

import UIKit


class ContainerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        shopingList = userDefaults?.stringArray(forKey: "shopingList") ?? []
        checkNum = load(key: "checkNum")
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(becomeBegin(_:)) , name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(enterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        shopingListTableView.delegate = self
        shopingListTableView.dataSource = self
        
        // セルの複数選択の許可
        shopingListTableView.allowsMultipleSelection = true
        
        // セルがない部分の区切り線を消去
        shopingListTableView.tableFooterView = UIView()
        
        shopingListTableView.refreshControl = refreshControl
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: "チェックを全て外す")
        refreshControl.attributedTitle = attributeString
        refreshControl.addTarget(self, action: #selector(refreshTableView(sender:)), for: .valueChanged)
        
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
    }
    
    @objc func refreshTableView(sender: UIRefreshControl) {
        refreshControl.beginRefreshing()
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            // 0.65秒後に実行したい処理
            // ここが引っ張られるたびに呼び出される
            if self.refreshControl.isRefreshing {
                self.checkNum.removeAll()
                self.shopingListTableView.reloadData()
                // 通信終了後、endRefreshingを実行することでロードインジケーター（くるくる）が終了
                self.refreshControl.endRefreshing()
            }
        }
        return
    }
    

    fileprivate let refreshControl = UIRefreshControl()

    
        // アプリが起動した際に行われる
    @objc func becomeBegin(_ notification: Notification?) {
        shopingList = userDefaults?.stringArray(forKey: "shopingList") ?? []
        checkNum = load(key: "checkNum")
        shopingListTableView.reloadData()
        print("begin")
        print(shopingList)
        print(checkNum)
    }
        
    // アプリがバックグラウンドになった時に実行
    @objc func enterBackground(_ notification: Notification?) {
        userDefaults?.set(shopingList, forKey: "shopingList")
        userDefaults?.set(checkNum, forKey: "checkNum")
        print("background")
    }
        
    //    @objc func didFinish(_ notification: Notification?) {
    //        UserDefaults.standard.set(shopingList, forKey: "shopingList")
    //        UserDefaults.standard.set(checkList, forKey: "checkList")
    //        print("finish")
    //    }
       
    

    var shopingList:[String] = []
    var checkNum: [Int] = []
    let userDefaults = UserDefaults(suiteName: "group.Swift-Beginner.checkList")
        
    // セルの数の設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shopingList.count
    }
        
    // セルのテキストや画像の設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopingCell", for: indexPath)
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: shopingList[indexPath.row])
        if checkNum.contains(indexPath.row) {
            attributeString.addAttribute(.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
            cell.textLabel?.attributedText = attributeString
            cell.imageView?.image = UIImage(systemName: "checkmark.square")
            cell.textLabel?.textColor = UIColor.lightGray
        } else {
            cell.textLabel?.attributedText = attributeString
            cell.imageView?.image = UIImage(systemName: "square")
            cell.textLabel?.textColor = UIColor.black
            
        }
        
            
        return cell
    }
    
    // セルの高さの設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(45)
    }
        
    // セルを選択した時に実行
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let cell = shopingListTableView.cellForRow(at: indexPath)
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: shopingList[indexPath.row])
        if cell?.imageView?.image == UIImage(systemName: "square") {
            checkNum.append(indexPath.row)
            attributeString.addAttribute(.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
            cell?.textLabel?.attributedText = attributeString
            cell?.textLabel?.textColor = UIColor.lightGray
            cell?.imageView?.image = UIImage(systemName: "checkmark.square")
        } else {
            guard let index:Int = checkNum.firstIndex(of: indexPath.row) else {
                return
            }
            checkNum.remove(at: index)
            cell?.textLabel?.attributedText = attributeString
            cell?.imageView?.image = UIImage(systemName: "square")
            cell?.textLabel?.textColor = UIColor.black
        }
        shopingListTableView.deselectRow(at: indexPath, animated: true)
        print(checkNum)
        print(shopingList)
    }
        
    // セルの編集の許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
        
    // セルの削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            if let index = checkNum.firstIndex(of: indexPath.row) {
                checkNum.remove(at: index)
            }
            for i in 0..<checkNum.count {
                if checkNum[i] > indexPath.row {
                    checkNum[i] -= 1
                }
            }
            shopingList.remove(at: indexPath.row)
            userDefaults?.set(checkNum, forKey: "checkNum")
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
            userDefaults?.set(shopingList, forKey: "shopingList")
        }
        print(checkNum)
        print(shopingList)
    }
        
    // セルの削除のタイトルの変更
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    
    /*
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = shopingListTableView.cellForRow(at: indexPath)
        let redAction = UIContextualAction(style: .normal, title: "red") { (ctxAction, view, completionHandler) in
            cell?.backgroundColor = UIColor.red
            completionHandler(true)
           }
        return UISwipeActionsConfiguration(actions: [redAction])
    }
    */
    
    
    // セルの追加の際の処理
    func reload() {
        shopingList = userDefaults?.stringArray(forKey: "shopingList") ?? []
        self.shopingListTableView.beginUpdates()
        self.shopingListTableView.insertRows(at: [IndexPath(row: shopingList.count - 1, section: 0)],
                                             with: .fade)
        self.shopingListTableView.endUpdates()
    }
    


    @IBOutlet weak var shopingListTableView: UITableView!
    
    @IBOutlet weak var trashButton: UIBarButtonItem!
        
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    // IntのArrayの読み取り
    func load(key: String) -> [Int] {
        let value = userDefaults?.object(forKey: key)
        guard let date = value as? [Int] else {
            return []
        }
        return date
    }
    
    
    // セルの移動の許可
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // セルの移動の処理
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let targetTitle = shopingList[sourceIndexPath.row]
        if let index = shopingList.firstIndex(of: targetTitle) {
            shopingList.remove(at: index)
            shopingList.insert(targetTitle, at: destinationIndexPath.row)
        }
        
        // sourceIndexPath.rowがcheckNumに含まれている場合の処理
        if let index = checkNum.firstIndex(of: sourceIndexPath.row) {
            checkNum.remove(at: index)
            if sourceIndexPath.row < destinationIndexPath.row {
                for i in checkNum {
                    if destinationIndexPath.row >= i  && sourceIndexPath.row <= i{
                        guard let index1 = checkNum.firstIndex(of: i) else {return}
                        checkNum[index1] -= 1
                    }
                }
            } else {
                for i in checkNum {
                    if destinationIndexPath.row <= i && sourceIndexPath.row >= i{
                        guard let index1 = checkNum.firstIndex(of: i) else {return}
                        checkNum[index1] += 1
                    }
                }
            }
            checkNum.append(destinationIndexPath.row)
        
        
        } else {
        //sourceIndexPath.rowがcheckNumに含まれていなかった場合の処理
            if sourceIndexPath.row < destinationIndexPath.row {
                for i in checkNum {
                    if destinationIndexPath.row >= i  && sourceIndexPath.row <= i{
                        guard let index1 = checkNum.firstIndex(of: i) else {return}
                        checkNum[index1] -= 1
                    }
                }
            } else {
                for i in checkNum {
                    if destinationIndexPath.row <= i && sourceIndexPath.row >= i{
                        guard let index1 = checkNum.firstIndex(of: i) else {return}
                        checkNum[index1] += 1
                    }
                }
            }
        }
        
        
        checkNum.sort()
        print(checkNum)
    }
    
    
    
    // Editボタンを押した時に実行
    @IBAction func editButtonAction(_ sender: Any) {
        let parentVC = parent as! ViewController
        parentVC.addButtonisHidden()
        if shopingListTableView.isEditing == true {
            editButton.title = "編集"
            shopingListTableView.isEditing = false
            trashButton.isEnabled = true
            trashButton.tintColor = UIColor.link
        } else {
            editButton.title = "完了"
            shopingListTableView.isEditing = true
            trashButton.isEnabled = false
            trashButton.tintColor = UIColor.darkGray
        }
    }
    
    // trashボタンを押した時に実行
    @IBAction func trashButtonAction(_ sender: Any) {
        // AlertControllerの作成
        let alertController = UIAlertController(title: "削除", message: "メモを削除しますか", preferredStyle: .alert)
        
        // キャンセルのアクション作成
        let cancelAction = UIAlertAction(title: "いいえ", style: .cancel, handler: nil)
        
        // 全削除のアクション作成
        let allDeleateAction = UIAlertAction(title: "全削除", style: .default, handler: {_ in
            self.shopingListTableView.beginUpdates()
            for _ in 0..<self.shopingList.count {
                self.shopingList.remove(at: self.shopingList.count - 1)
                self.shopingListTableView.deleteRows(at: [IndexPath(row: (self.shopingList.count), section: 0)], with: .fade)
            }
            self.shopingListTableView.endUpdates()
            self.checkNum.removeAll()
            self.userDefaults?.set(self.checkNum, forKey: "checkNum")
            self.userDefaults?.set(self.shopingList, forKey: "shopingList")
            print(self.checkNum)
            print(self.shopingList)
        })

        // チェックのみ削除のアクション作成
        let checkDeleate = UIAlertAction(title: "チェックのみ", style: .default, handler: {_ in
            self.checkNum.sort()
            self.checkNum.reverse()
            self.shopingListTableView.beginUpdates()
            for index in self.checkNum {
               
                self.shopingList.remove(at: index)
                self.shopingListTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                self.checkNum.remove(at: 0)
                
            }
            self.shopingListTableView.endUpdates()
            self.userDefaults?.set(self.shopingList, forKey: "shopingList")
            self.userDefaults?.set(self.checkNum, forKey: "checkNum")
        })

        // AlertControllerにalertActionの追加
        alertController.addAction(cancelAction)
        alertController.addAction(allDeleateAction)
        alertController.addAction(checkDeleate)

        // alertの表示
        present(alertController, animated: true, completion: nil)
    }
    
    // 右スワイプアクション（トラッシュボタンと同じ仕様）
    @IBAction func didSwaipedAction(_ sender: Any) {
        // AlertControllerの作成
        let alertController = UIAlertController(title: "削除", message: "メモを削除しますか", preferredStyle: .alert)
        
        // キャンセルのアクション作成
        let cancelAction = UIAlertAction(title: "いいえ", style: .cancel, handler: nil)
        
        // 全削除のアクション作成
        let allDeleateAction = UIAlertAction(title: "全削除", style: .default, handler: {_ in
            self.shopingListTableView.beginUpdates()
            for _ in 0..<self.shopingList.count {
                self.shopingList.remove(at: self.shopingList.count - 1)
                self.shopingListTableView.deleteRows(at: [IndexPath(row: (self.shopingList.count), section: 0)], with: .fade)
            }
            self.shopingListTableView.endUpdates()
            self.checkNum.removeAll()
            self.userDefaults?.set(self.checkNum, forKey: "checkNum")
            self.userDefaults?.set(self.shopingList, forKey: "shopingList")
            print(self.checkNum)
            print(self.shopingList)
        })

        // チェックのみ削除のアクション作成
        let checkDeleate = UIAlertAction(title: "チェックのみ", style: .default, handler: {_ in
            self.checkNum.sort()
            self.checkNum.reverse()
            self.shopingListTableView.beginUpdates()
            for index in self.checkNum {
               
                self.shopingList.remove(at: index)
                self.shopingListTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                self.checkNum.remove(at: 0)
                
            }
            self.shopingListTableView.endUpdates()
            self.userDefaults?.set(self.shopingList, forKey: "shopingList")
            self.userDefaults?.set(self.checkNum, forKey: "checkNum")
        })

        // AlertControllerにalertActionの追加
        alertController.addAction(cancelAction)
        alertController.addAction(allDeleateAction)
        alertController.addAction(checkDeleate)

        // alertの表示
        present(alertController, animated: true, completion: nil)
    }
    
        
}
