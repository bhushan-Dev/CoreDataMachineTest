//
//  Teacher+CoreDataProperties.swift
//  CoreDataStudentTeacherCourse
//
//  Created by Bhushan Udawant on 20/11/18.
//  Copyright © 2018 Bhushan Udawant. All rights reserved.
//
//

import Foundation
import CoreData


extension Teacher {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Teacher> {
        return NSFetchRequest<Teacher>(entityName: "Teacher")
    }

    @NSManaged public var teacherId: UUID?
    @NSManaged public var courseId: UUID?
    @NSManaged public var teacherName: String?
    @NSManaged public var teacherAddress: String?

}
