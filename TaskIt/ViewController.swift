//
//  ViewController.swift
//  TaskIt
//
//  Created by Dan Manteufel on 11/2/14.
//  Copyright (c) 2014 ManDevil Programming. All rights reserved.
//

import UIKit

//MARK: - Root View Controller
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TaskDetailViewControllerDelegate, AddTaskViewControllerDelegate {
    
    var tasker = TaskIt()
    var selectedIndexPath: NSIndexPath?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasker.taskArray += [exampleTask1, exampleTask2, exampleTask3]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (tableView.indexPathForSelectedRow() != nil) {
            tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: false)
        }
        //println("viewDidAppear")
        //tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        switch segue.identifier! {
        case "Show Task Detail":
            let destVC = segue.destinationViewController as TaskDetailViewController
            let indexPath = tableView.indexPathForSelectedRow() //Could also go through sender
            destVC.detailTaskModel = tasker.taskArray[indexPath!.row]
            destVC.delegate = self
        case "Show Add Task":
            let destVC = segue.destinationViewController as AddTaskViewController
            destVC.delegate = self
        default:
            break
        }
    }
    
    //MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasker.taskArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("My Cell") as TaskCell
        
        let task = tasker.taskArray[indexPath.row]
        
        cell.taskLabel.text = task.task
        cell.subtaskLabel.text = task.subtask
        cell.dateLabel.text = NSDateFormatter.localizedStringFromDate(task.date,
                                                                      dateStyle: .ShortStyle,
                                                                      timeStyle: .NoStyle)
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //MARK: TaskDetailViewControllerDelegate
    func updateTask(task: TaskModel) {
        let indexPath = tableView.indexPathForSelectedRow()!
        tasker.taskArray[indexPath.row] = task
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    //MARK: AddTaskViewControllerDelegate
    func addTask(task: TaskModel) {
        tasker.taskArray += [task]
    }
}

//MARK: - Task Detail View Controller
protocol TaskDetailViewControllerDelegate {
    func updateTask(TaskModel)
}

class TaskDetailViewController: UIViewController, UITextFieldDelegate {
    var detailTaskModel = TaskModel()
    var delegate: TaskDetailViewControllerDelegate?
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var subtaskTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        taskTextField.text = detailTaskModel.task
        subtaskTextField.text = detailTaskModel.subtask
        dueDatePicker.date = detailTaskModel.date
    }
    
    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        var task = TaskModel(task: taskTextField.text,
                             subtask: subtaskTextField.text,
                             date: dueDatePicker.date)
        delegate?.updateTask(task)
        navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Add Task View Controller
protocol AddTaskViewControllerDelegate {
    func addTask(TaskModel)
}

class AddTaskViewController: UIViewController, UITextFieldDelegate {
    
    var delegate: AddTaskViewControllerDelegate?
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var subtastTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dueDatePicker.date = Date.now()
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func addButtonPressed(sender: UIButton) {
        var task = TaskModel(task: taskTextField.text,
                             subtask: subtastTextField.text,
                             date: dueDatePicker.date)
        delegate?.addTask(task)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - View
class TaskCell: UITableViewCell {
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var subtaskLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
}

//MARK: - Model

//MARK: Defines

//MARK: Structs
struct TaskIt {
    var taskArray: [TaskModel] = []
}

struct TaskModel {
    var task = ""
    var subtask = ""
    var date = NSDate(timeIntervalSinceNow: 0)
}

//MARK: Classes
class Date {
    class func fromYear(year: Int, month: Int, day: Int) -> NSDate {
        
        var components = NSDateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        var gregorianCal = NSCalendar(identifier: NSGregorianCalendar)!
        
        return gregorianCal.dateFromComponents(components)!
    }
    class func now() -> NSDate {
        return NSDate(timeIntervalSinceNow: 0)
    }
}

//MARK: Example Data
let exampleTask1 = TaskModel(task: "Study French",
                             subtask: "Verbs",
                             date: Date.fromYear(2014, month: 11, day: 3))
let exampleTask2 = TaskModel(task: "Eat Dinner",
                             subtask: "Burgers",
                             date: Date.fromYear(2014, month: 11, day: 3))
let exampleTask3 = TaskModel(task : "Gym",
                             subtask: "Leg Day",
                             date: Date.fromYear(2014, month: 11, day: 4))
