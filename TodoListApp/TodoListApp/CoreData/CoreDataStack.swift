//
//  CoreDataStack.swift
//  TodoListApp
//
//  Created by Aleixo Porpino Filho on 2018-12-02.
//  Copyright © 2018 Porpapps. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    var container: NSPersistentContainer{
        let container = NSPersistentContainer(name: "Tasks")
        container.loadPersistentStores { (description, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
        }
        return container
    }
    
    var manageContext: NSManagedObjectContext {
        return container.viewContext
    }
}
