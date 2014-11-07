//
//  TaskModel.swift
//  TaskIt
//
//  Created by Dan Manteufel on 11/6/14.
//  Copyright (c) 2014 ManDevil Programming. All rights reserved.
//

import Foundation
import CoreData

@objc(TaskModel)//Bridge to be able to use Obj-C in the future if needed
class TaskModel: NSManagedObject {

    @NSManaged var completed: NSNumber
    @NSManaged var date: NSDate
    @NSManaged var subtask: String
    @NSManaged var task: String

}
