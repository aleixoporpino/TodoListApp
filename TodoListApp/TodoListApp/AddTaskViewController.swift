//  AddTaskViewController.swift
//  Assignment2-TodoListApp
//  App Description: A simple todo list with all basic operations using core data
//
//  Created by Jose Aleixo Porpino Filho on 2018-12-07.
//  Student ID 301005491
//
//  Version 1.0.0

import UIKit
import CoreData
class AddTaskViewController: UIViewController {
    
    var managedContext: NSManagedObjectContext!
    var task: Task?

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var switchDueDate: UISwitch!
    @IBOutlet weak var dueDate: UIDatePicker!
    @IBAction func onSwitchDueDate(_ sender: UISwitch) {
        dueDate.isHidden = !sender.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // Set the buttons with rounds
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
        cancelButton.layer.cornerRadius = 10
        cancelButton.clipsToBounds = true
        dueDate.setValue(UIColor.white, forKey: "textColor")
        
        textView.becomeFirstResponder()
        
        // Get the task if existent from another screen
        if let task = task {
            textView.text = ""
            textView.text = task.name
            notesTextView.text = "Type here.."
            notesTextView.text = task.notes
            priorityControl.selectedSegmentIndex = Int(task.priority)
            
            if task.duedate != nil {
                switchDueDate.isOn = true
                dueDate.date = task.duedate!
            } else {
                switchDueDate.isOn = false
            }
        }
        
        dueDate.isHidden = !switchDueDate.isOn
    }
    
    // Cancel button
    @IBAction func cancel(_ sender: UIButton) {
        dismiss()
    }
    
    // Save the task in core data and dismiss
    @IBAction func save(_ sender: UIButton) {
        if let task = self.task {
            setTaskValues(task)
        } else {
            let task = Task(context: managedContext)
            task.date = Date()
            setTaskValues(task)
        }
        
        do {
            try managedContext.save()
            dismiss()
        } catch {
            print("Error when try to save: \(error)")
        }
    }
    
    // Dismiss the screen
    func dismiss() {
        dismiss(animated: true)
        textView.resignFirstResponder()
    }
    
    // Set the properties of the tasks according to the functionality
    func setTaskValues(_ task:Task) {
        guard let name = textView.text, !name.isEmpty else {
            return
        }
        task.name = name
        task.notes = notesTextView.text ?? ""
        if notesTextView.text == "Type here..." {
            task.notes = ""
        }
        task.priority = Int16(priorityControl.selectedSegmentIndex)
        task.completed = false
        if switchDueDate.isOn {
           task.duedate = dueDate.date
        } else {
            task.duedate = nil
        }
    }
}

// Extension to unhide the save button when user tap in the texts
extension AddTaskViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if saveButton.isHidden || textView.text.contains("Type here") {
            textView.text.removeAll()
            textView.textColor = .white
            
            saveButton.isHidden = false
            
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

// Extension to hide the keyboard if tap in the screen
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
