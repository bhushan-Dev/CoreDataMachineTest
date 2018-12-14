//
//  TeacherListViewController.swift
//  CoreDataStudentTeacherCourse
//
//  Created by Bhushan Udawant on 21/11/18.
//  Copyright © 2018 Bhushan Udawant. All rights reserved.
//

import UIKit
import CoreData

class TeacherListViewController: UIViewController {

    // MARK: Constant

    var teachersInfo: Array<Teacher>?
    var studentInfo: Array<Student>?
    var courseInfo: Array<Course>?
    var teacherCourseInfo: Array<Dictionary<String, Any>>?
    let felixApi = FelixAPI.sharedInstance

    // MARK: IBOutlets

    @IBOutlet weak var teacherTableView: UITableView!


    // MARK: Life cycle method

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        // Core Data
        fetchTeachersData()
        fetchCoursesData()
        fetchStudentData()
        formRelationShip()
    }

    // MARK: Helper

    func configureView() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Teacher List"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.add,
            target: self,
            action: #selector(addTeacher))
    }

    // MARK: Actions

    @objc func addTeacher() {
        let addTeacherViewController: AddTeacherViewController = storyboard?.instantiateViewController(withIdentifier: "AddTeacherViewController") as! AddTeacherViewController

        navigationController?.pushViewController(addTeacherViewController, animated: true)
    }

    func fetchTeachersData() {
        teachersInfo = felixApi.fetchTeachersData()
    }

    func fetchCoursesData() {
        courseInfo = felixApi.fetchCoursesData()
    }

    func fetchStudentData() {
        studentInfo = felixApi.fetchStudentData()
    }

    func formRelationShip() {

        if let _ = teachersInfo,
            let _ = courseInfo {

            teacherCourseInfo = Array<Dictionary<String, Any>>()

            for teacher in teachersInfo! {

                for course in courseInfo! {
                    if course.courseId == teacher.courseId {
                        var dict = Dictionary<String, Any>()
                        dict["cname"] = course.courceName
                        dict["tname"] = teacher.teacherName
                        teacherCourseInfo?.append(dict)
                        //print(teacherCourseInfo?.count)
                    }
                }
            }

            if let _ = teacherCourseInfo,
                teacherCourseInfo!.count > 0 {
                teacherTableView.delegate = self
                teacherTableView.dataSource = self
                teacherTableView.reloadData()
            }
        }
    }

    func isTeacherAssociatedToStudent(teacherIndexPath: IndexPath) -> Bool {
        // Verify whether teacher is associated to any student for removing teacher
        if let _ = self.studentInfo,
            let _ = self.teachersInfo {
            let teacher = self.teachersInfo![teacherIndexPath.row]

            for student in self.studentInfo! {
                if student.teacherId == teacher.teacherId {
                    return true
                }
            }
        }

        return false
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )

        let okButton = UIAlertAction(
            title: "OK",
            style: .default
        )

        alert.addAction(okButton)

        self.present(alert, animated: true)
    }

}


// MARK: Delegate

extension TeacherListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(
        _ tableView: UITableView,
        editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        // Edit the row at indexPath here
        let editAction = UITableViewRowAction(style: .default, title: "Edit") { (rowAction, indexPath) in
            guard let updateTeacherViewController = self.storyboard?.instantiateViewController(withIdentifier: "UpdateTeacherViewController") as? UpdateTeacherViewController,
                let teachersInfo = self.teachersInfo else {
                return
            }

            updateTeacherViewController.teacher = teachersInfo[indexPath.row]
            updateTeacherViewController.selectedTeacher = indexPath.row
            self.navigationController?.pushViewController(updateTeacherViewController, animated: true)
        }
        editAction.backgroundColor = UIColor.lightGray

        // Delete the row at indexPath here
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction, indexPath) in
            // Remove teacher flag.
            // 1. if teacher is not associated to student
            guard !self.isTeacherAssociatedToStudent(teacherIndexPath: indexPath) else {
                self.showAlert(title: "Sorry can't delete", message: "\nThis Teacher is associated to student")

                return
            }

            if let _ = self.teacherCourseInfo,
                let _ = self.teachersInfo {
                self.felixApi.deleteTeacherData(teacher: self.teachersInfo![indexPath.row])
                self.teacherCourseInfo?.remove(at: indexPath.row)
                self.teachersInfo?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
        }
        deleteAction.backgroundColor = .red

        return [editAction,deleteAction]
    }
}


// MARK: Data Source

extension TeacherListViewController: UITableViewDataSource {

    public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return teacherCourseInfo?.count ?? 0
    }

    public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TeacherListCell")

        if let _ = teacherCourseInfo {
            let teacherAndCourseDict = teacherCourseInfo![indexPath.row]
            cell?.textLabel?.text = teacherAndCourseDict["tname"] as? String
            cell?.detailTextLabel?.text = teacherAndCourseDict["cname"] as? String
        }

        return cell!
    }

}
