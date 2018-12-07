//  TodoTableViewController.swift
//  Assignment2-TodoListApp
//  App Description: A simple todo list with all basic operations using core data
//
//  Created by Jose Aleixo Porpino Filho on 2018-12-07.
//  Student ID 301005491
//
//  Version 1.0.0

import UIKit
import CoreData

class TodoTableViewController: UITableViewController {
    
    // Results of the tasks in coredata
    var resultsController: NSFetchedResultsController<Task>!
    let coreDataStack = CoreDataStack()
    
    // Bi Dimensional
    var tasks:[[Task]] = [[]]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Populate all the core data in the array tasks.
        populateTasksInArray()
        reloadTableView()
    }
    //Reload the tableview with the new data.
    func reloadTableView() {
        UIView.transition(with: tableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.tableView.reloadData() })
    }
    
    // Get the core data with sort and push to tasks array
    func populateTasksInArray() {
        tasks = [[]]
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        // sort tasks by date
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        
        request.sortDescriptors = [sortDescriptors]
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.manageContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        do {
            try resultsController.performFetch()
            if resultsController.fetchedObjects != nil {
                for t in resultsController.fetchedObjects! {
                    if tasks.count == 0 {
                        tasks.append([])
                        tasks.append([])
                    } else if tasks.count == 1 {
                        tasks.append([])
                    }
                    if t.completed {
                        tasks[1].append(t)
                    } else {
                        tasks[0].append(t)
                    }
                }
            }
        } catch {
            print("Fetch error ocurred: \(error)")
            return
        }
    }
    
    // Number of sections that the table view will have
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }

    // Number of the tasks per section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks[section].count
    }
    
    // Set the header of the sections
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel.init(frame: CGRect(x:50,y:0,width: 100,height:60))
        label.font = UIFont(name:"Charter", size: 20.0)
        if section == 0 {
            label.text = "Tasks"
            label.backgroundColor = UIColor(rgb:0x004C93)
        } else {
            label.text = "Completed tasks"
            label.backgroundColor = UIColor(rgb:0x0074E0)
        }
        
        label.textColor = .white
        return label
    }
    
    // Return the cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        
        let task = tasks[indexPath.section][indexPath.row]
        populate(cell: cell, task: task)
        
        return cell
    }
    
    // When swipe to the right will show the Delete button
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completion) in
            
            let taskSelected:Task = self.tasks[indexPath.section][indexPath.row]
            print("section: \(indexPath.section), row: \(indexPath.row)")
            self.resultsController.managedObjectContext.delete(taskSelected)
            do {
                try self.resultsController.managedObjectContext.save()
                self.tasks[indexPath.section].remove(at: indexPath.row)
                self.reloadTableView()
                completion(true)
            } catch {
                print("Error when try to delete: \(error)")
                completion(false)
            }
        }
        action.backgroundColor = UIColor(rgb:0x941100)
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // When swipe to the left will show the Check button
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = self.tasks[indexPath.section][indexPath.row]
        // Verify if this task can be completed or not
        if task.completed == false {
            let action = UIContextualAction(style: .destructive, title: "Check") {
                (action, view, completion) in
                
                    task.completed = true
                    do {
                        self.tasks[indexPath.section].remove(at: indexPath.row)
                        self.tasks[indexPath.section+1].append(task)
                        try self.resultsController.managedObjectContext.save()
                        self.reloadTableView()
                        completion(true)
                    } catch {
                        print("Error when try to check: \(error)")
                        completion(false)
                    }
                }
            action.backgroundColor = UIColor(rgb: 0x009051)
    
            return UISwipeActionsConfiguration(actions: [action])
        }else{
            return nil
        }
    }
    
    // Show the details or add new task screen
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
                let task = tasks[indexPath.section][indexPath.row]
                vc.task = task
            }
        }
    }
    
    // set the cell components according to the task
    func populate(cell: UITableViewCell, task:Task) {
        
        cell.textLabel!.font = UIFont(name:"Charter", size: 17.0)
        cell.detailTextLabel!.font = UIFont(name:"Charter", size: 13.0)
        
        if task.completed {
            cell.isUserInteractionEnabled = false
            let uiColor:UIColor = UIColor(rgb: 0xE2E2E2)
            cell.backgroundColor = uiColor
        } else {
            cell.isUserInteractionEnabled = true
            let uiColor:UIColor = UIColor.init(rgb: 0xFFFFFF)
            uiColor.withAlphaComponent(1.0)
            cell.backgroundColor = uiColor
        }
        
        cell.textLabel?.text = task.name ?? ""
        cell.detailTextLabel?.text = task.notes
        
        if let date = task.duedate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: "en_CA")
            dateFormatter.dateFormat = "d MMM yyyy, h:mm a"
            
            let label = UILabel.init(frame: CGRect(x:0,y:0,width:130,height:20))
            label.text = dateFormatter.string(from: date)
            label.font = UIFont(name:"Charter", size: 13.0)
            cell.accessoryView = label
        } else {
            cell.accessoryView = nil
        }
    }
}


// RGB converter
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
