//
//  InputViewController.swift
//  taskApp
//
//  Created by kaihatsu on 2022/06/07.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!
    let realm = try! Realm()/* Realmのインスタンスを生成*/
    
    var task: Task!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        self.view.addGestureRecognizer(tapGesture)
        
        contentsTextView.layer.borderColor = UIColor.systemPurple.cgColor
        contentsTextView.layer.borderWidth = 3.0
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        categoryTextField.text = task.category
        datePicker.date = task.date
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        
        try! realm.write{/* Realmデータベースへの書き込みトランザクション*/
            
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.category = self.categoryTextField.text!
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified)
            
        }
        
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
    
    
    func setNotification(task: Task){
        
        let content = UNMutableNotificationContent()
        
        if task.title == ""{
            
            content.title = "(タイトルなし)"
            
        }else{
            
            content.title = task.title
        }
        
        if task.contents == "" {
            
            content.body = "(内容なし)"
    
        } else{
            
            content.body = task.contents
            
        }
        
        content.sound = UNNotificationSound.default
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        
        center.add(request){(error)in
            
            print(error ?? "ローカル通知登録OK")
            
        }
            
        
        center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in
            
            for request in requests {
                
                print("/---------------")
                print(request)
                print("---------------/")
                
                
            }
            
            
        }
        
        
        
        
        
        
        
        
        
    }
    
    
    
    @objc func dismissKeyboard(){
        
        view.endEditing(true)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
