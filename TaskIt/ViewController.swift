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
        
        let taskArray = [exampleTask1, exampleTask2, exampleTask3]
        let completedArray = [exampleTask4]
        tasker.baseArray = [taskArray, completedArray]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (tableView.indexPathForSelectedRow() != nil) {
            tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: false)
        }

        sortAndReload()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        switch segue.identifier! {
        case "Show Task Detail":
            let destVC = segue.destinationViewController as TaskDetailViewController
            let indexPath = tableView.indexPathForSelectedRow() //Could also go through sender
            destVC.detailTaskModel = tasker.baseArray[indexPath!.section][indexPath!.row]
            destVC.delegate = self
        case "Show Add Task":
            let destVC = segue.destinationViewController as AddTaskViewController
            destVC.delegate = self
        default:
            break
        }
    }
    
    //MARK: Helper Functions
    func sortAndReload() {
        
        //THIS IS EQUIVALENT TO THE CLOSURE BELOW
        //        func sortByDate (taskOne: TaskModel, taskTwo: TaskModel) -> Bool {
        //            return taskOne.date.timeIntervalSince1970 < taskTwo.date.timeIntervalSince1970
        //        }
        //
        //        tasker.taskArray = tasker.taskArray.sorted(sortByDate)
        
        for (index, _) in enumerate (tasker.baseArray) {
            tasker.baseArray[index] = tasker.baseArray[index].sorted{
                (taskOne: TaskModel, taskTwo: TaskModel) -> Bool in
                return taskOne.date.timeIntervalSince1970 < taskTwo.date.timeIntervalSince1970
            }
        }
        tableView.reloadData()
    }
    
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tasker.baseArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasker.baseArray[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("My Cell") as TaskCell
        //cell.editingAccessoryView = TaskCell.setCompletionAccessory()
        //cell.editingAccessoryType = UITableViewCellAccessoryType.Checkmark
        
        let task = tasker.baseArray[indexPath.section][indexPath.row]
        
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "To Do"
        }
        else if section == 1 {
            return "Completed"
        }
        else {
            return "?"
        }
    }
    
    func tableView(tableView: UITableView,
                   commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                   forRowAtIndexPath indexPath: NSIndexPath) {
        var task = tasker.baseArray[indexPath.section][indexPath.row]
        task.completed = !task.completed
        tasker.baseArray[indexPath.section].removeAtIndex(indexPath.row)
        tasker.baseArray[indexPath.section == 0 ? 1 : 0] += [task]
        sortAndReload()
    }
    
    //MARK: TaskDetailViewControllerDelegate
    func updateTask(task: TaskModel) {
        let indexPath = tableView.indexPathForSelectedRow()!
        tasker.baseArray[indexPath.section][indexPath.row] = task
        //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        //Only because we reload all after sorting in viewDidAppear
    }
    
    //MARK: AddTaskViewControllerDelegate
    func addTask(task: TaskModel) {
        tasker.baseArray[0] += [task]
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
                             date: dueDatePicker.date,
                             completed: false)
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
                             date: dueDatePicker.date,
                             completed: false)
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
    
//    class func setCompletionAccessory() -> UIView {
//        var completionBox = UIView(frame: CGRect(x: 0, y: 0,
//                                                 width: 75, height: 75))
//        completionBox.tintColor = .greenColor()
//        return completionBox
//    }
}

//MARK: - Model

//MARK: Defines

//MARK: Structs
struct TaskIt {
    var baseArray: [[TaskModel]] = [[]]
}

struct TaskModel {
    var task = ""
    var subtask = ""
    var date = NSDate(timeIntervalSinceNow: 0)
    var completed = false
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
                             date: Date.fromYear(2014, month: 11, day: 3),
                             completed: false)
let exampleTask2 = TaskModel(task: "Eat Dinner",
                             subtask: "Burgers",
                             date: Date.fromYear(2014, month: 11, day: 5),
                             completed: false)
let exampleTask3 = TaskModel(task : "Gym",
                             subtask: "Leg Day",
                             date: Date.fromYear(2014, month: 11, day: 4),
                             completed: false)
let exampleTask4 = TaskModel(task: "Code",
                             subtask: "Task Project",
                             date: Date.fromYear(2014, month: 11, day: 1),
                             completed: true)
