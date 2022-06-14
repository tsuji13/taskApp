//
//  Task.swift
//  
//
//  Created by kaihatsu on 2022/06/09.
//

import RealmSwift

class Task: Object {
    
    @objc dynamic var id = 0
    
    @objc dynamic var title = ""
    
    @objc dynamic var contents = ""
    
    @objc dynamic var category = ""
    
    @objc dynamic var date = Date()
    
    override static func primaryKey() -> String? {
        
        return "id"
        
    }
    
    
}
