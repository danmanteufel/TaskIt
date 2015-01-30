//
//  ViewController.swift
//  TaskIt
//
//  Created by Dan Manteufel on 11/2/14.
//  Copyright (c) 2014 ManDevil Programming. All rights reserved.
//

import UIKit
import CoreData

//MARK: VCDefines
let kShouldCapitalizeTaskKey = "Should Capitalize Task"
let kCompleteNewTodoKey = "Complete New Todo"

//MARK: - Root View Controller
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    var selectedIndexPath: NSIndexPath?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frc = NSFetchedResultsController(fetchRequest: taskFetchRequest(),
                                         managedObjectContext: moc!,
                                         sectionNameKeyPath: "completed",
                                         cacheName: nil)
        frc.delegate = self
        frc.performFetch(nil)
        if frc.sections!.count == 0 {
            addExampleData()
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (tableView.indexPathForSelectedRow() != nil) {
            tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: false)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        switch segue.identifier! {
        case "Show Task Detail":
            let destVC = segue.destinationViewController as TaskDetailViewController
            destVC.indexPath = tableView.indexPathForSelectedRow()! //Could also go through sender

        case "Show Add Task":
            let destVC = segue.destinationViewController as AddTaskViewController
        default:
            break
        }
    }
    
    //MARK: Helper Functions
    
    func taskFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "TaskModel")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        let completedDescriptor = NSSortDescriptor(key: "completed", ascending: true)
        fetchRequest.sortDescriptors = [completedDescriptor, sortDescriptor] //could have multiple sorts
        return fetchRequest
    }
    
    func addExampleData() {

        var exampleDataToAdd = [["task": "Study French",
                                 "subtask": "Verbs",
                                 "date": Date.fromYear(2014, month: 11, day: 3),
                                 "completed": false],
                                ["task": "Eat Dinner",
                                 "subtask": "Burgers",
                                 "date": Date.fromYear(2014, month: 11, day: 5),
                                 "completed": false],
                                ["task": "Gym",
                                 "subtask": "Leg Day",
                                 "date": Date.fromYear(2014, month: 11, day: 4),
                                 "completed": false],
                                ["task": "Code",
                                 "subtask": "Task Project",
                                 "date": Date.fromYear(2014, month: 11, day: 1),
                                 "completed": true]]
        for data in exampleDataToAdd {
            let entityDescription = NSEntityDescription.entityForName("TaskModel", inManagedObjectContext: moc!) //Maps entity to persistent store
            let task = TaskModel(entity: entityDescription!, insertIntoManagedObjectContext: moc!) //
            task.task = data["task"] as String
            task.subtask = data["subtask"] as String
            task.date = data["date"] as NSDate
            task.completed = data["completed"] as Bool
        }
        appDelegate.saveContext()
    }
    
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return frc.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.sections![section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("My Cell") as TaskCell
        //cell.editingAccessoryView = TaskCell.setCompletionAccessory()
        //cell.editingAccessoryType = UITableViewCellAccessoryType.Checkmark
        
        let task = frc.objectAtIndexPath(indexPath) as TaskModel
        
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
        //THIS SECTION WOULD NEED TO BE UPDATED TO HAVE THE SECTIONS RIGHT WITH NO EVENTS
//        let sectionCount = frc.sections!.count
//        var complete = true
//        if sectionCount == 1 {
//            let firstTask = frc.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as TaskModel
//            complete = Bool(firstTask.completed)
//        }
//
//        if sectionCount == 0 {
//            return "Add Tasks"
//        } else if sectionCount == 1 && !complete {
//            return "To Do"
//        } else if sectionCount == 1 && complete {
//            return "Completed"
//        } else if section == 0 {
//            return "To Do"
//        } else {
//            return "Completed"
//        }
//MY IMPLEMENTATION -- CLASS IMPLEMENTATION BELOW
        
        if frc.sections?.count == 1 {
            let fetchedObjects = frc.fetchedObjects!
            let testTask: TaskModel = fetchedObjects[0] as TaskModel
            if testTask.completed == true {
                return "Completed"
            } else {
                return "To Do"
            }
        } else {
            if section == 0 {
                return "To Do"
            } else {
                return "Completed"
            }
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var actionTitle = indexPath.section == 0 ? "Complete" : "Incomplete"
        
        let sectionCount = frc.sections!.count
        if sectionCount == 1 {
            let firstTask = frc.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as TaskModel
            if Bool(firstTask.completed) {
                actionTitle = "Incomplete"
            }
            
        }
        
        var completionButton = UITableViewRowAction(style: .Normal,
                                                    title: actionTitle,
                                                    handler: {(action, index) in
                                                        var task = frc.objectAtIndexPath(index) as TaskModel
                                                        task.completed = !Bool(task.completed)
                                                        appDelegate.saveContext()})
        completionButton.backgroundColor = .lightGrayColor()
        
        return [completionButton]
    }
    
    //This enables the swipe to take action functionality even though it's empty
    func tableView(tableView: UITableView,
                   commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                   forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    //MARK: NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
}

//MARK: - Task Detail View Controller
class TaskDetailViewController: UIViewController, UITextFieldDelegate {
    var indexPath = NSIndexPath()
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var subtaskTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        let detailTaskModel = frc.objectAtIndexPath(indexPath) as TaskModel
        taskTextField.text = detailTaskModel.task
        subtaskTextField.text = detailTaskModel.subtask
        dueDatePicker.date = detailTaskModel.date
    }
    
    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        let detailTaskModel = frc.objectAtIndexPath(indexPath) as TaskModel
        detailTaskModel.task = taskTextField.text
        detailTaskModel.subtask = subtaskTextField.text
        detailTaskModel.date = dueDatePicker.date
        appDelegate.saveContext() //saved updates to entity we passed in
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Add Task View Controller
class AddTaskViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var subtaskTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dueDatePicker.date = Date.now()
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addButtonPressed(sender: UIButton) {
        let entityDescription = NSEntityDescription.entityForName("TaskModel", inManagedObjectContext: moc!) //Maps entity to persistent store
        let task = TaskModel(entity: entityDescription!, insertIntoManagedObjectContext: moc!) //
        task.task = taskTextField.text
        task.subtask = subtaskTextField.text
        task.date = dueDatePicker.date
        task.completed = false
        appDelegate.saveContext()
        
//        var request = NSFetchRequest(entityName: "TaskModel")
//        var error: NSError? = nil
//        var results = moc!.executeFetchRequest(request, error: &error)!
//        
//        print(results)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Settings View Controller
class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: Defines
    let kVersionNumber = "1.0"
    let kNumberOfSections = 2
    let kCapitalizeCellID = "Capitalize Cell"
    let kCompleteNewTodoCellID = "Complete New Todo Cell"
    let kNoCapsMessage = "No - Do Not Capitalize"
    let kYesCapsMessage = "Yes - Capitalize"
    let kDoNotCompleteMessage = "Do Not Complete Task"
    let kCompleteMessage = "Complete Task"
    let kCapitalizeTVTitle = "Capitalize New Task?"
    let kCompleteNewTaskTVTitle = "Complete New Task?"
    
    //MARK: Globals
    @IBOutlet weak var capitalizeTV: UITableView!
    @IBOutlet weak var completeNewTodoTV: UITableView!
    @IBOutlet weak var versionLabel: UILabel!

    //MARK: Flow Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        versionLabel.text = kVersionNumber
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done",
                                                           style: .Plain,
                                                           target: self,
                                                           action: Selector("doneBarButtonItemPressed"))
        
    }
    
    func doneBarButtonItemPressed(barButtonItem: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: Helper Functions
    
    //MARK: UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == capitalizeTV {
            var capitalizeCell = tableView.dequeueReusableCellWithIdentifier(kCapitalizeCellID) as UITableViewCell
            if indexPath.row == 0 {
                capitalizeCell.textLabel?.text = kNoCapsMessage
                if NSUserDefaults.standardUserDefaults().boolForKey(kShouldCapitalizeTaskKey) {
                    capitalizeCell.accessoryType = .None
                } else {
                    capitalizeCell.accessoryType = .Checkmark
                }
            } else {
                capitalizeCell.textLabel?.text = kYesCapsMessage
                if NSUserDefaults.standardUserDefaults().boolForKey(kShouldCapitalizeTaskKey) {
                    capitalizeCell.accessoryType = .Checkmark
                } else {
                    capitalizeCell.accessoryType = .None
                }
            }
            return capitalizeCell
        } else {
            var completeNewTodoCell = tableView.dequeueReusableCellWithIdentifier(kCompleteNewTodoCellID) as UITableViewCell
            if indexPath.row == 0 {
                completeNewTodoCell.textLabel?.text = kDoNotCompleteMessage
                if NSUserDefaults.standardUserDefaults().boolForKey(kCompleteNewTodoKey) {
                    completeNewTodoCell.accessoryType = .None
                } else {
                    completeNewTodoCell.accessoryType = .Checkmark
                }
            } else {
                completeNewTodoCell.textLabel?.text = kCompleteMessage
                if NSUserDefaults.standardUserDefaults().boolForKey(kCompleteNewTodoKey) {
                    completeNewTodoCell.accessoryType = .Checkmark
                } else {
                    completeNewTodoCell.accessoryType = .None
                }
            }
            return completeNewTodoCell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kNumberOfSections
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == capitalizeTV {
            return kCapitalizeTVTitle
        } else {
            return kCompleteNewTaskTVTitle
        }
    }
    
    //MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == capitalizeTV {
            if indexPath.row == 0 {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: kShouldCapitalizeTaskKey)
            } else {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: kShouldCapitalizeTaskKey)
            }
        } else {
            if indexPath.row == 0 {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: kCompleteNewTodoKey)
            } else {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: kCompleteNewTodoKey)
            }
        }
        NSUserDefaults.standardUserDefaults().synchronize()
        tableView.reloadData()
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
let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate //Next line doesn't work without typecast
let moc = appDelegate.managedObjectContext
let kAlreadyLoadedKey = "Already Loaded Once"

//MARK: Globals
var frc = NSFetchedResultsController()

//MARK: Structs

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

