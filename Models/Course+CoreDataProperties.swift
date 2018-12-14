//
//  Course+CoreDataProperties.swift
//  CoreDataStudentTeacherCourse
//
//  Created by Bhushan Udawant on 20/11/18.
//  Copyright © 2018 Bhushan Udawant. All rights reserved.
//
//

import Foundation
import CoreData


extension Course {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Course> {
        return NSFetchRequest<Course>(entityName: "Course")
    }

    @NSManaged public var courseId: UUID?
    @NSManaged public var courceName: String?
    @NSManaged public var courceDetails: String?

}
