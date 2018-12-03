//
//  AddTaskViewController.swift
//  TodoListApp
//
//  Created by Aleixo Porpino Filho on 2018-12-02.
//  Copyright © 2018 Porpapps. All rights reserved.
//

import UIKit
import CoreData
class AddTaskViewController: UIViewController {
    
    var managedContext: NSManagedObjectContext!
    var task: Task?

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var bottonConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var switchDueDate: UISwitch!
    @IBOutlet weak var dueDate: UIDatePicker!
    @IBAction func onSwitchDueDate(_ sender: UISwitch) {
        dueDate.isHidden = !sender.isOn
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
        cancelButton.layer.cornerRadius = 10
        cancelButton.clipsToBounds = true
        dueDate.setValue(UIColor.white, forKey: "textColor")
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(with: )),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        textView.becomeFirstResponder()
        
        if let task = task {
            textView.text = ""
            textView.text = task.title
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
    
    
    @objc func keyboardWillShow(with notification: Notification) {
        let key = "UIKeyboardFrameEndUserInfoKey"
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height + 16
        
        bottonConstraint.constant = keyboardHeight
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss()
    }
    
    @IBAction func save(_ sender: UIButton) {
        if let task = self.task {
            setTaskValues(task)
        } else {
            let task = Task(context: managedContext)
            setTaskValues(task)
        }
        
        do {
            try managedContext.save()
            dismiss()
        } catch {
            print("Error when try to save: \(error)")
        }
    }
    
    func dismiss() {
        dismiss(animated: true)
        textView.resignFirstResponder()
    }
    
    func setTaskValues(_ task:Task) {
        guard let title = textView.text, !title.isEmpty else {
            return
        }
        task.title = title
        task.priority = Int16(priorityControl.selectedSegmentIndex)
        task.date = Date()
        if(switchDueDate.isOn){
           task.duedate = dueDate.date
        } else {
            task.duedate = nil
        }
    }
}

extension AddTaskViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if saveButton.isHidden {
            textView.text.removeAll()
            textView.textColor = .white
            
            saveButton.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}