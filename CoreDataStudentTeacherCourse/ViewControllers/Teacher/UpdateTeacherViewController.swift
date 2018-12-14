//
//  UpdateTeacherViewController.swift
//  CoreDataStudentTeacherCourse
//
//  Created by Bhushan Udawant on 10/12/18.
//  Copyright © 2018 Bhushan Udawant. All rights reserved.
//

import UIKit

class UpdateTeacherViewController: UIViewController {

    // MARK: Constants

    var teacher: Teacher?
    var students: Array<Student>?
    var course: Course?
    var selectedTeacher: Int?
    var currentCourse: Course?
    var teachersInfo: Array<Teacher>?
    var courseInfo: Array<Course>?
    let felixApi = FelixAPI.sharedInstance

    var shouldShowPicker: Bool {
        var shouldShow = false

        for student in students! {
            if student.courseId == teacher?.courseId && student.teacherId == teacher?.teacherId {
                shouldShow = false
                break
            } else {
                shouldShow = true
            }
        }

        return shouldShow
    }

    // MARK: IBOutlets
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var teacherPicker: UIPickerView!
    @IBOutlet weak var addressTextView: UITextView!

    // MARK: Life cycle method

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch student record
        fetchStudentRecords()

        // Fetch course records
        fetchCourseRecords()

        // Configure picker
        configurePicker()
    }


    // MARK: Actions

    @IBAction func updateTeacher(_ sender: UIButton) {
        teacher?.teacherName = nameField.text
        teacher?.teacherAddress = addressTextView.text
        
        if shouldShowPicker {
            teacher?.courseId = currentCourse?.courseId
        }

        felixApi.updateData()
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func editCourse(_ sender: UIButton) {
        showAlert(title: "Warning", message: "\nCannot edit course as it is associated with student")
    }

    // MARK: Implementation

    func fetchStudentRecords() {
        students = felixApi.fetchStudentData()
    }

    func fetchCourseRecords() {
        courseInfo = felixApi.fetchCoursesData()
    }

    private func togglePicker(editButton: Toggle, courseLabel: Toggle, teacherPicker: Toggle) {
        self.editButton.isHidden = editButton.isHidden
        self.courseLabel.isHidden = courseLabel.isHidden
        self.teacherPicker.isHidden = teacherPicker.isHidden
    }

    func configurePicker() {
        if let teacher = teacher {
            nameField.text = teacher.teacherName
            addressTextView.text = teacher.teacherAddress

            if shouldShowPicker {
                togglePicker(editButton: .hide, courseLabel: .hide, teacherPicker: .show)

                courseLabel.text = ""

                teacherPicker.delegate = self
                teacherPicker.dataSource = self

                for (index, course) in courseInfo!.enumerated() {
                    if course.courseId == teacher.courseId {
                        currentCourse = course
                        teacherPicker.selectRow(
                            index,
                            inComponent: 0,
                            animated: true
                        )
                    }
                }
            } else {
                togglePicker(editButton: .show, courseLabel: .show, teacherPicker: .hide)

                for student in students! {
                    for course in courseInfo! {
                        if course.courseId == student.courseId {
                            courseLabel.text = course.courceName
                        }
                    }
                }
            }
        }
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


// MARK: Picker Delegate

extension UpdateTeacherViewController: UIPickerViewDelegate {

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String? {

        if let courseInfo = courseInfo,
            courseInfo.count > 0 {
            let course = courseInfo[row]

            return course.courceName
        }

        return "None Added"
    }

    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int) {
        if let courseInfo = courseInfo,
            courseInfo.count > 0 {
            currentCourse = courseInfo[row]
        }
    }

}

// MARK: Picker Data source

extension UpdateTeacherViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int {
        return courseInfo?.count ?? 0
    }

}
