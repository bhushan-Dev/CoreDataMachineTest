//
//  StudentListViewController.swift
//  CoreDataStudentTeacherCourse
//
//  Created by Bhushan Udawant on 20/11/18.
//  Copyright © 2018 Bhushan Udawant. All rights reserved.
//

import UIKit
import CoreData

class StudentListViewController: UIViewController {
    
    // MARK: Constants
    
    var students: Array<Student>?
    var courses: Array<Course>?
    var teachers: Array<Teacher>?
    let felixApi = FelixAPI.sharedInstance
    var studentTeacherCourseList: Array<Dictionary<String, Any>>?
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure view
        configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        // Fetch management records
        fetchFelixManagementRecords()

        // Make list
        makeTeacherAndCourseRelationshipStudentList()
    }
    
    // MARK: Helper
    
    func configureView() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Student List"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.add,
            target: self,
            action: #selector(addStudent))
    }
    
    func fetchFelixManagementRecords() {
        students = felixApi.fetchStudentData()
        teachers = felixApi.fetchTeachersData()
        courses = felixApi.fetchCoursesData()
    }
    
    func makeTeacherAndCourseRelationshipStudentList() {
        if let studentsInfo = students,
            let teachersInfo = teachers,
            let coursesInfo = courses {
            
            studentTeacherCourseList = Array<Dictionary<String, Any>>()
            var dict = Dictionary<String, Any>()
            
            // TODO: Make list
            
            for student in studentsInfo {
                for teacher in teachersInfo {
                    if teacher.teacherId == student.teacherId {
                        dict["tname"] = teacher.teacherName
                        dict["sname"] = student.name
                        let courseId = student.courseId
                        
                        for course in coursesInfo {
                            if course.courseId == courseId {
                                dict["cname"] = course.courceName
                            }
                        }
                    }
                }

                dict["address"] = student.address
                studentTeacherCourseList?.append(dict)

                if let studentTeacherCourseList = studentTeacherCourseList,
                    studentTeacherCourseList.count > 0 {
                    tableView.delegate = self
                    tableView.dataSource = self
                    tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: Actions
    
    @objc func addStudent() {
        guard let addStudentViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddStudentViewController") as? AddStudentViewController else {
            return
        }
        
        navigationController?.pushViewController(addStudentViewController, animated: true)
    }
    
}

// MARK: Delegate

extension StudentListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(
        _ tableView: UITableView,
        editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let editAction = UITableViewRowAction(style: .default, title: "Edit") { (rowAction, indexPath) in
            //Edit the row at indexPath here

            guard let updateStudentViewController = self.storyboard?.instantiateViewController(withIdentifier: "UpdateStudentViewController") as? UpdateStudentViewController,
                let list = self.studentTeacherCourseList else {
                    return
            }

            updateStudentViewController.student = list[indexPath.row]
            updateStudentViewController.studentEntity = self.students?[indexPath.row]
            self.navigationController?.pushViewController(updateStudentViewController, animated: true)
        }
        editAction.backgroundColor = UIColor.lightGray

        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction, indexPath) in
            //TODO: Delete the row at indexPath here
            guard let _ = self.students else {
                return
            }

            self.studentTeacherCourseList?.remove(at: indexPath.row)
            self.felixApi.deleteStudentData(student: self.students![indexPath.row])
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
        deleteAction.backgroundColor = .red

        return [editAction,deleteAction]
    }
}


// MARK: Data Source

extension StudentListViewController: UITableViewDataSource {
    
    public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return studentTeacherCourseList?.count ?? 0
    }
    
    public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentInfoCell")
        
        if let studentTeacherCourseList = studentTeacherCourseList {
            let student = studentTeacherCourseList[indexPath.row]
            cell?.textLabel?.text = student["sname"] as? String
            cell?.detailTextLabel?.text = student["cname"] as? String
        }

        return cell!
    }
    
}
