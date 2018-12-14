//
//  UpdateStudentViewController.swift
//  CoreDataStudentTeacherCourse
//
//  Created by Bhushan Udawant on 06/12/18.
//  Copyright © 2018 Bhushan Udawant. All rights reserved.
//

import UIKit

class UpdateStudentViewController: UIViewController {

    // MARK: Constants

    var student: Dictionary<String, Any>?
    var students: Array<Student>?
    var courses: Array<Course>?
    var teachers: Array<Teacher>?
    let felixApi = FelixAPI.sharedInstance
    var selectedCourse: Course? {
        didSet {
            filterTeacherList()
        }
    }
    var selectedTeacher: Teacher?
    var studentEntity: Student?
    var courseIndex = 0

    // MARK: IBOutlets

    @IBOutlet weak var editTeacherButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var coursePickerView: UIPickerView!
    @IBOutlet weak var teacherPickerView: UIPickerView!

    // MARK: Life cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure view
        configureView()

        // fetch records
        fetchFelixManagementRecords()

        coursePickerView.delegate = self
        coursePickerView.dataSource = self
        teacherPickerView.delegate = self
        teacherPickerView.dataSource = self

        // Set course picker to selected course
        setCoursePickerToPreviouslySaved()
    }

    // MARK: Implementation

    private func configureView() {
        guard let student = student else {
            return
        }

        nameTextField.text = student["sname"] as? String
        addressTextView.text = student["address"] as? String
        courseLabel.text = student["cname"] as? String
        teacherLabel.text = student["tname"] as? String
    }

    private func togglePicker(containerView: Toggle, teacherPicker: Toggle, coursePicker: Toggle) {
        pickerContainer.isHidden = containerView.isHidden
        coursePickerView.isHidden = coursePicker.isHidden
        teacherPickerView.isHidden = teacherPicker.isHidden
    }

    func fetchFelixManagementRecords() {
        students = felixApi.fetchStudentData()
        teachers = felixApi.fetchTeachersData()
        courses = felixApi.fetchCoursesData()
    }

    func fetchTeachers() {
        teachers = felixApi.fetchTeachersData()
    }

    func setCoursePickerToPreviouslySaved() {

        if let courses = courses {
            for (index, course) in courses.enumerated() {
                if course.courceName == courseLabel.text {
                    selectedCourse = course
                    courseIndex = index
                }
            }
        }

        for student in students! {
            if student.name == self.student!["tname"] as? String {
                for teacher in teachers! {
                    if teacher.teacherId == student.teacherId {
                        selectedTeacher = teacher
                    }
                }
            }
        }


        coursePickerView.selectRow(courseIndex, inComponent: 0, animated: false)
    }

    func filterTeacherList() {
        toggleEditTeacherButton(Toggle.show)

        // Fetch all teacher records
        fetchTeachers()

        var filteredTeacherList: [Teacher]? = [Teacher]()

        if let teachers = teachers,
            teachers.count > 0 {
            for teacher in teachers {
                if let selectedCourse = selectedCourse,
                    selectedCourse.courseId == teacher.courseId {
                    filteredTeacherList?.append(teacher)
                }
            }

            self.teachers = filteredTeacherList
            teacherPickerView.reloadAllComponents()
        }
    }

    func toggleEditTeacherButton(_ button: Toggle) {
        editTeacherButton.isHidden = button.isHidden
    }

    // MARK: IBActions
    
    @IBAction func doneWithPicker(_ sender: UIButton) {
        togglePicker(containerView: .hide, teacherPicker: .hide, coursePicker: .hide)
    }
    
    @IBAction func editCourse(_ sender: UIButton) {
        togglePicker(containerView: .show, teacherPicker: .hide, coursePicker: .show)
    }

    @IBAction func editTeacher(_ sender: UIButton) {
        togglePicker(containerView: .show, teacherPicker: .show, coursePicker: .hide)
    }
    
    @IBAction func updateStudentInfo(_ sender: UIButton) {
        guard let _ = studentEntity else {
            return
        }
        
        studentEntity?.name = nameTextField.text
        studentEntity?.address = addressTextView.text
        studentEntity?.courseId = selectedCourse?.courseId
        studentEntity?.teacherId = selectedTeacher?.teacherId
        // No need to update uuid of student

        felixApi.updateData()
        navigationController?.popViewController(animated: true)
    }
}


// MARK: Picker Delegate

extension UpdateStudentViewController: UIPickerViewDelegate {

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String? {

        if pickerView == coursePickerView {
            if let courses = courses,
                courses.count > 0 {
                let course = courses[row]
                // FIXME
                courseLabel.text = course.courceName
                
                return course.courceName
            }
        } else if pickerView == teacherPickerView {
            if let teachers = teachers,
                teachers.count > 0 {
                let teacher = teachers[row]
                // FIXME
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
        if pickerView == coursePickerView,
            let courses = courses,
            courses.count > 0 {
            selectedCourse = courses[row]
        } else if pickerView == teacherPickerView,
            let teachers = teachers,
            teachers.count > 0 {
            selectedTeacher = teachers[row]
        }
    }

}

// MARK: Picker Data source

extension UpdateStudentViewController: UIPickerViewDataSource {

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
