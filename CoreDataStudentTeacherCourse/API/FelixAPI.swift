//
//  FelixRecords.swift
//  CoreDataStudentTeacherCourse
//
//  Created by Bhushan Udawant on 04/12/18.
//  Copyright © 2018 Bhushan Udawant. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum FelixRecords: String {
    case teacher = "Teacher"
    case student = "Student"
    case course = "Course"
}

class FelixAPI {

    // MARK: Shared Instance

    static let sharedInstance = FelixAPI()

    // Mark: Constants

    let context: NSManagedObjectContext?
    let appDelegate: AppDelegate?

    /**
     *  Init
     */
    init() {
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.context = appDelegate?.persistentContainer.viewContext
    }

    // MARK: Fetch records methods

    /**
     *  Fetch teachers records
     */
    func fetchTeachersData() -> [Teacher]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: FelixRecords.teacher.rawValue)

        return fetchRecords(with: request) as? [Teacher]
    }

    /**
     *  Fetch courses
     */
    func fetchCoursesData() -> [Course]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: FelixRecords.course.rawValue)

        return fetchRecords(with: request) as? [Course]
    }

    /**
     *  Fetch students records
     */
    func fetchStudentData() -> [Student]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: FelixRecords.student.rawValue)

        return fetchRecords(with: request) as? [Student]
    }

    /**
     *  Fetch records
     */
    func fetchRecords(with request: NSFetchRequest<NSFetchRequestResult>) -> [Any]? {
        //let context = appDelegate?.persistentContainer.viewContext
        
        do {
            return try context?.fetch(request)
        } catch let error {
            print(error.localizedDescription)
        }

        return nil
    }


    // MARK: Delete records methods

    /**
     *  Delete student records
     */
    func deleteStudentData(student: Student) {
        context?.delete(student)

        do {
            try context?.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    /**
     *  Delete course records
     */
    func deleteCourseData(course: Course) {
        context?.delete(course)

        do {
            try context?.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    /**
     *  Delete teacher records
     */
    func deleteTeacherData(teacher: Teacher) {
        context?.delete(teacher)

        do {
            try context?.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    /**
     *  Update records
     */
    func updateData() {
        saveData()
    }

    /**
     *  Save records
     */
    func saveData() {
        do {
            try context?.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }

}
