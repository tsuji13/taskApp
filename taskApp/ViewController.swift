//
//  ViewController.swift
//  taskApp
//
//  Created by kaihatsu on 2022/06/07.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate{
    
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categorySerchBar: UISearchBar!
    let realm = try! Realm() /* Realmのインスタンス生成*/
    
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableview.fillerRowHeight = UITableView.automaticDimension
        tableview.delegate = self
        categorySerchBar.delegate = self
        tableview.dataSource = self
        //categorySerchBar.showsCancelButton = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        tableview.reloadData()
    }
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        
        return taskArray.count/*リマインドタスクの個数を返す */
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexpath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexpath)
        
        let task = taskArray[indexpath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString: String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
                
        return cell/* 各セルに表示する内容を返す(タスク一覧)*/
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        performSegue(withIdentifier: "cellSegue", sender: nil)
        
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
        
        return .delete
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == .delete{
            
            let task = self.taskArray[indexPath.row]
            
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            try! realm.write{
                
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in
                
                for request in requests {
                                    
                    print("/---------------")
                    print(request)
                    print("---------------/")
                    
                }
                
            }
            
            
        }
    }/*セルを左へスワイプさせた時の処理*/
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let inputViewController: InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"{
            
            let indexPath = self.tableview.indexPathForSelectedRow
            
            inputViewController.task = taskArray[indexPath!.row]
            
            
        }else{
            
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0{
                
                task.id = allTasks.max(ofProperty: "id")! + 1
                
            }
            
            inputViewController.task = task
            
        }
    }
    
  /*インクリメンタルサーチ用*/
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        /* ディレイをかけないと入力した文字を判別しない可能性があるので0.3秒かける*/
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
         
         self.searchBarSearchButtonClicked(searchBar)
                
     }
       return true
    }
    
    func searchBarSearchButtonClicked(_ serchBar: UISearchBar){
        
        guard let inputText = serchBar.text?.lowercased() else{
            
            taskArray=realm.objects(Task.self)
            //searchbarにnilが入っている場合保存されているタスク全てを表示
            return
          
        }
        if inputText.isEmpty || inputText.contains(" ") || inputText.contains("　"){
            
            taskArray = realm.objects(Task.self)
            //空文字が入力された時も保存されているタスクを全て表示
            
        }
        
        else{
            
        taskArray = realm.objects(Task.self).filter("category BEGINSWITH[c] '\(inputText)'")/* searchBarに入力されたカテゴリーを含むタスクのみを表示*/
        
        }
        
        tableview.reloadData()
        
    }
        
    
}

