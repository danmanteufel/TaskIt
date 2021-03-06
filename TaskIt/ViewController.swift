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
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, TaskDetailViewControllerDelegate, AddTaskViewControllerDelegate {
    //MARK: Globals
    var selectedIndexPath: NSIndexPath?

    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Flow Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background")!)
        
        frc = NSFetchedResultsController(fetchRequest: taskFetchRequest(),
                                         managedObjectContext: ModelManager.instance.managedObjectContext!,
                                         sectionNameKeyPath: "completed",
                                         cacheName: nil)
        frc.delegate = self
        frc.performFetch(nil)
        if frc.sections!.count == 0 {
            addExampleData()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("iCloudUpdated"), name: kCoreDataUpdated, object: nil)
        
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
            destVC.delegate = self

        case "Show Add Task":
            let destVC = segue.destinationViewController as AddTaskViewController
            destVC.delegate = self
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
            let entityDescription = NSEntityDescription.entityForName("TaskModel", inManagedObjectContext: ModelManager.instance.managedObjectContext!) //Maps entity to persistent store
            let task = TaskModel(entity: entityDescription!, insertIntoManagedObjectContext: ModelManager.instance.managedObjectContext!) //
            task.task = data["task"] as String
            task.subtask = data["subtask"] as String
            task.date = data["date"] as NSDate
            task.completed = data["completed"] as Bool
        }
        ModelManager.instance.saveContext()
    }
    
    func showAlert(message: String = "Contratulations") {
        var alert = UIAlertController(title: "Change Made!", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func iCloudUpdated() {
        tableView.reloadData()
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
    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        var header = tableView.headerViewForSection(section)
//        header?.backgroundColor = .yellowColor()
//        header?.backgroundView?.backgroundColor = .yellowColor()
//        return header
//    }
    
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
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = .clearColor()
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
                                                        ModelManager.instance.saveContext()})
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
    
    //MARK: TaskDetailViewControllerDelegate
    func taskDetailEdited() {
        showAlert()
    }
    
    //MARK: AddTaskViewControllerDelegate
    func addTaskCanceled(message: String) {
        showAlert(message: message)
    }
    
    func addTask(message: String) {
        showAlert(message: message)
    }
}

//MARK: - Task Detail View Controller
@objc protocol TaskDetailViewControllerDelegate {//Have to use objc for optional
    optional func taskDetailEdited()
}

class TaskDetailViewController: UIViewController, UITextFieldDelegate {
    //MARK: Defines
    
    //MARK: Globals
    var indexPath = NSIndexPath()
    var delegate: TaskDetailViewControllerDelegate?
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var subtaskTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    //MARK: Flow Functions
    override func viewDidLoad() {
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background")!)

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
        ModelManager.instance.saveContext() //saved updates to entity we passed in
        
        navigationController?.popViewControllerAnimated(true)
        delegate?.taskDetailEdited!() //Um, not great since we called it optional.
    }
    
    //MARK: Helper Functions
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - Add Task View Controller
protocol AddTaskViewControllerDelegate {
    func addTask(message: String)
    func addTaskCanceled(message: String)
}

class AddTaskViewController: UIViewController, UITextFieldDelegate {
    //MARK: Defines
    
    //MARK: Globals
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var subtaskTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    var delegate: AddTaskViewControllerDelegate?
    
    //MARK: Flow Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background")!)

        dueDatePicker.date = Date.now()
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        //delegate?.addTaskCanceled("No Task Added")//WRONG, MUST BE CALLED AFTER YOU DISMISS
        dismissViewControllerAnimated(true, completion: nil)
        delegate?.addTaskCanceled("No Task Added")
    }
    
    @IBAction func addButtonPressed(sender: UIButton) {
        let entityDescription = NSEntityDescription.entityForName("TaskModel", inManagedObjectContext: ModelManager.instance.managedObjectContext!) //Maps entity to persistent store
        let task = TaskModel(entity: entityDescription!, insertIntoManagedObjectContext: ModelManager.instance.managedObjectContext!) //
        
//        if NSUserDefaults.standardUserDefaults().boolForKey(kShouldCapitalizeTaskKey) {
//            task.task = taskTextField.text.capitalizedString
//        } else {
//            task.task = taskTextField.text
//  
//        }
        
        task.task = NSUserDefaults.standardUserDefaults().boolForKey(kShouldCapitalizeTaskKey) ? taskTextField.text.capitalizedString : taskTextField.text
        task.subtask = subtaskTextField.text
        task.date = dueDatePicker.date
        
//        if NSUserDefaults.standardUserDefaults().boolForKey(kCompleteNewTodoKey) {
//            task.completed = true
//        } else {
//            task.completed = false
//        }
        
        task.completed = NSUserDefaults.standardUserDefaults().boolForKey(kCompleteNewTodoKey)
        
        ModelManager.instance.saveContext()
        
//        var request = NSFetchRequest(entityName: "TaskModel")
//        var error: NSError? = nil
//        var results = moc!.executeFetchRequest(request, error: &error)!
//        
//        print(results)
        
        dismissViewControllerAnimated(true, completion: nil)
        delegate?.addTask("Task Added")
    }
    
    //MARK: Helper Functions
    
    //MARK: UITextFieldDelegate
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
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background")!)

        title = "Settings"
        versionLabel.text = kVersionNumber
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done",
                                                           style: .Plain,
                                                           target: self,
                                                           action: Selector("doneBarButtonItemPressed:"))
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

