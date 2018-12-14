//
//  AddStudentViewController.swift
//  CoreDataStudentTeacherCourse
//
//  Created by Bhushan Udawant on 26/11/18.
//  Copyright © 2018 Bhushan Udawant. All rights reserved.
//

import UIKit
import CoreData

class AddStudentViewController: UIViewController {

    // MARK: IBOutlets

    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var addCourseButton: UIButton!
    @IBOutlet weak var addTeacherButton: UIButton!
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var teacherPickerView: UIPickerView!
    @IBOutlet weak var coursePickerView: UIPickerView!
    @IBOutlet weak var donePickerButton: UIButton!

    // MARK: Constants

    var appDelegate: AppDelegate?
    var teachers: [Teacher]?
    var courses: [Course]?
    var selectedCourse: Course? {
        didSet {
            filterTeacherList()
        }
    }
    var selectedTeacher: Teacher?
    let felixApi = FelixAPI.sharedInstance


    // MARK: Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = UIApplication.shared.delegate as? AppDelegate

        // Configure view
        configurePickerView()

        // Toggle view
        toggleAddTeacherButton(Toggle.hide)

        // Fetch Courses
        fetchCourses()

        // Fetch Teachers
        fetchTeachers()
    }

    // MARK: Actions

    @IBAction func addCourseAndTeacher(_ sender: UIButton) {
        if sender == addCourseButton {
            beginAddingCourse()
        } else if sender == addTeacherButton {
            beginAddingTeacher()
        }
    }

    @IBAction func saveStudentInfo(_ sender: UIButton) {
        resignAllTextFields()

        if nameTxtField.text == "" || addressTextView.text == "" || courseLabel.text == "" || teacherLabel.text == "" {
            showAlert(title: "Warning", message: "\nFill all the fields")
        } else {

            if let context = felixApi.context {
                let student = Student(context: context)
                student.name = nameTxtField.text
                student.address = addressTextView.text

                if let _ = selectedCourse,
                    let _ = selectedTeacher {
                    student.courseId = selectedCourse?.courseId
                    student.teacherId = selectedTeacher?.teacherId

                    felixApi.saveData()
                    navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    @IBAction func doneWithChangingPickerValue(_ sender: UIButton) {
        togglePicker(containerView: .hide, teacherPicker: .hide, coursePicker: .hide)
    }

    // MARK: Helpers

    private func beginAddingCourse() {
        coursePickerView.delegate = self
        coursePickerView.dataSource = self

        if let courses = courses,
            courses.count > 0 {
            // Set initial value
            selectedCourse = courses.first

            togglePicker(containerView: .show, teacherPicker: .hide, coursePicker: .show)
        } else {
            togglePicker(containerView: .hide, teacherPicker: .hide, coursePicker: .hide)
            
            showAlert(title: "Warning", message: "\nThere are no courses to choose from")
        }
    }

    private func beginAddingTeacher() {
        teacherPickerView.delegate = self
        teacherPickerView.dataSource = self

        if let teachers = teachers,
            teachers.count > 0 {
            // Set initial value
            selectedTeacher = teachers.first

            togglePicker(containerView: .show, teacherPicker: .show, coursePicker: .hide)
        } else {
            togglePicker(containerView: .hide, teacherPicker: .hide, coursePicker: .hide)

            showAlert(title: "Warning", message: "\nThere are no teacher to choose from")
        }
    }

    func resignAllTextFields() {
        nameTxtField.resignFirstResponder()
        addressTextView.resignFirstResponder()
    }

    private func togglePicker(containerView: Toggle, teacherPicker: Toggle, coursePicker: Toggle) {
        pickerContainer.isHidden = containerView.isHidden
        coursePickerView.isHidden = coursePicker.isHidden
        teacherPickerView.isHidden = teacherPicker.isHidden
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

    func fetchCourses() {
        courses = felixApi.fetchCoursesData()
    }

    func fetchTeachers() {
        teachers = felixApi.fetchTeachersData()
    }

    func filterTeacherList() {
        addTeacherButton.isHidden = false

        // Fetch all teacher records
        fetchTeachers()

        var filteredTeacherList: [Teacher]? = [Teacher]()

        if let teachers = teachers,
            teachers.count > 0 {
            for teacher in teachers {
                if selectedCourse?.courseId == teacher.courseId {
                    filteredTeacherList?.append(teacher)
                }
            }

            self.teachers = filteredTeacherList
            teacherPickerView.reloadAllComponents()
        }
    }

    func configurePickerView() {
        // border radius
        pickerContainer.layer.cornerRadius = 30

        // border
        pickerContainer.layer.borderColor = UIColor.black.cgColor
        pickerContainer.layer.borderWidth = 1

        // drop shadow
        pickerContainer.layer.shadowColor = UIColor.black.cgColor
        pickerContainer.layer.opacity = 0.8
        pickerContainer.layer.shadowRadius = 3.0
        pickerContainer.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        pickerContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively
    }

    func toggleAddTeacherButton(_ button: Toggle) {
        addTeacherButton.isHidden = button.isHidden
    }
}


// MARK: Picker Delegate

extension AddStudentViewController: UIPickerViewDelegate {

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String? {

        if pickerView == coursePickerView {
            if let courses = courses,
                courses.count > 0 {
                let course = courses[row]
                courseLabel.text = course.courceName

                return course.courceName
            }
        } else if pickerView == teacherPickerView {
            if let teachers = teachers,
                teachers.count > 0 {
                let teacher = teachers[row]
                teacherLabel.text = teacher.teacherName

                return teacher.teacherName
            }
        }

        return "None Added"
    }

    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int) {
        if pickerView == coursePickerView {
            if let courses = courses,
                courses.count > 0 {
                selectedCourse = courses[row]
            }
        } else if pickerView == teacherPickerView {
            if let teachers = teachers,
                teachers.count > 0 {
                selectedTeacher = teachers[row]
            }
        }
    }

}

// MARK: Picker Data source

extension AddStudentViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int {
        if pickerView == coursePickerView {
            return courses?.count ?? 0
        } else {
            return teachers?.count ?? 0
        }
    }

}
