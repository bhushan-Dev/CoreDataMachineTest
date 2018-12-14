//
//  CourseListViewController.swift
//  CoreDataStudentTeacherCourse
//
//  Created by Bhushan Udawant on 20/11/18.
//  Copyright © 2018 Bhushan Udawant. All rights reserved.
//

import UIKit
import CoreData

class CourseListViewController: UIViewController {

    // MARK: Constants

    var courseList: Array<Course>?
    var teacherList: Array<Teacher>?
    var studentList: Array<Student>?
    let felixApi = FelixAPI.sharedInstance

    // MARK: IBOutlets

    @IBOutlet weak var courseTableView: UITableView!

    
    // MARK: Life cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure view
        configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        fetchCourseList()
        fetchTeacherList()
        fetchStudentList()
    }

    // MARK: Helper

    func configureView() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Course List"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.add,
            target: self,
            action: #selector(addCourse))
    }

    func fetchCourseList() {
        courseList = felixApi.fetchCoursesData()

        if let list = courseList,
            list.count > 0 {
            courseTableView.dataSource = self
            courseTableView.delegate = self
            courseTableView.reloadData()
        }
    }

    func fetchTeacherList() {
        teacherList = felixApi.fetchTeachersData()
    }

    func fetchStudentList() {
        studentList = felixApi.fetchStudentData()
    }

    func isCourseAssociatedToStudentTeacher(courseIndexPath: IndexPath) -> Bool {
        // Verify whether course is associated to student or teacher
        if let _ = self.courseList,
            let _ = self.studentList,
            let _ = self.teacherList {

            let course = self.courseList![courseIndexPath.row]
            for student in self.studentList! {
                if course.courseId == student.courseId {
                    return true
                }
            }
            for teacher in self.teacherList! {
                if course.courseId == teacher.courseId {
                    return true
                }
            }
        }

        return false
    }

    func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)

        self.present(alert, animated: true)
    }


    // MARK: Actions

    @objc func addCourse() {
        guard let addCourseViewController: AddCourseViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddCourseViewController") as? AddCourseViewController else {
            return
        }

        navigationController?.pushViewController(addCourseViewController, animated: true)
    }

}

// MARK: Delegate

extension CourseListViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(
        _ tableView: UITableView,
        editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        // Edit the row at indexPath here
        let editAction = UITableViewRowAction(
        style: .default,
        title: "Edit") { (rowAction, indexPath) in


            guard let updateCourseViewController = self.storyboard?.instantiateViewController(
                withIdentifier: "UpdateCourseViewController") as? UpdateCourseViewController,
                let list = self.courseList else {
                    return
            }

            updateCourseViewController.course = list[indexPath.row]
            self.navigationController?.pushViewController(updateCourseViewController, animated: true)
        }
        editAction.backgroundColor = UIColor.lightGray

        // Delete the row at indexPath here
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction, indexPath) in
            // Remove course flag.
            // 1. if course is not associated to teacher
            // 2. if course is not associate to student
            guard !self.isCourseAssociatedToStudentTeacher(courseIndexPath: indexPath) else {
                self.showAlert(
                    with: "Sorry can't delete",
                    message: "\nThis Course is associated to teacher or student"
                )

                return
            }

            self.felixApi.deleteCourseData(course: self.courseList![indexPath.row])
            self.courseList?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
        deleteAction.backgroundColor = .red

        return [editAction,deleteAction]
    }
}

// MARK: Data Source

extension CourseListViewController: UITableViewDataSource {

    public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return courseList?.count ?? 0
    }

    public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseListCell")

        if let list = courseList {
            let course = list[indexPath.row]
            cell?.textLabel?.text = course.courceName
            cell?.detailTextLabel?.text = course.courceDetails
        }

        return cell!
    }

}
