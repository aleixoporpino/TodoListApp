//
//  TodoTableViewController.swift
//  TodoListApp
//
//  Created by Aleixo Porpino Filho on 2018-12-02.
//  Copyright © 2018 Porpapps. All rights reserved.
//

import UIKit
import CoreData

class TodoTableViewController: UITableViewController {
    
    var resultsController: NSFetchedResultsController<Task>!
    let coreDataStack = CoreDataStack()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        
        request.sortDescriptors = [sortDescriptors]
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.manageContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        resultsController.delegate = self
        do {
            try resultsController.performFetch()
        } catch {
            print("Fetch error ocurred: \(error)")
            return
        }
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].objects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        
        let task = resultsController.object(at: indexPath)
        cell.textLabel?.text = task.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completion) in
            let task = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(task)
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("Error when try to delete: \(error)")
                completion(false)
            }
        }
        //action.image = #imageLiteral(resourceName: "cancel")
        action.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Check") {
            (action, view, completion) in
            let task = self.resultsController.object(at: indexPath)
            task.completed = true
            do {
                try self.resultsController.managedObjectContext.save()
                completion(false)
            } catch {
                print("Error when try to check: \(error)")
                completion(false)
            }
        }
        //action.image = #imageLiteral(resourceName: "success")
        action.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowAddNewTask", sender: tableView.cellForRow(at: indexPath))
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddTaskViewController {
            vc.managedContext = resultsController.managedObjectContext
        }
        
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? AddTaskViewController {
            vc.managedContext = resultsController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell) {
                let task = resultsController.object(at: indexPath)
                vc.task = task
            }
        }
    }
    
    struct CompletedSection {
        var completed: Bool
        var tasks: [Task]
    }
}


extension TodoTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                let task = resultsController.object(at: indexPath)
                cell.textLabel?.text = task.title
            }
        default:
            break
        }
    }
}
