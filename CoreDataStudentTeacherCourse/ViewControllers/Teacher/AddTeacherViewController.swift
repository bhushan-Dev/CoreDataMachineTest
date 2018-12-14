//
//  AddTeacherViewController.swift
//  CoreDataStudentTeacherCourse
//
//  Created by Bhushan Udawant on 21/11/18.
//  Copyright © 2018 Bhushan Udawant. All rights reserved.
//

import UIKit
import CoreData

class AddTeacherViewController: UIViewController {

    // MARK: Constant

    var appDelegate: AppDelegate?
    var teachers: [Teacher]?
    var courses: [Course]?
    var selectedCourse: Course?
    let felixApi = FelixAPI.sharedInstance

    // MARK: IBOutlets

    @IBOutlet weak var teacherNameField: UITextField!
    @IBOutlet weak var teacherCoursePicker: UIPickerView!
    @IBOutlet weak var teacherAddress: UITextView!
    @IBOutlet weak var saveTeacherInfo: UIButton!


    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCourseInfo()
        teacherCoursePicker.delegate = self
        selectedCourse = courses?.first
    }

    // MARK: Actions
    
    @IBAction func saveTeacherInformation(_ sender: UIButton) {
        teacherNameField.resignFirstResponder()
        teacherAddress.resignFirstResponder()

        if teacherNameField.text == "" || teacherAddress.text == "" {
            showAlert(title: "Warning", message: "\nFill all the fields")
        } else {

            if let context = felixApi.context {
                let teacher = Teacher(context: context)
                teacher.teacherName = teacherNameField.text
                teacher.teacherAddress = teacherNameField.text
                teacher.teacherId = Uility.generateUUID()

                if let _ = selectedCourse {
                    teacher.courseId = selectedCourse!.courseId
                }

                felixApi.saveData()

                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    func fetchCourseInfo() {
        courses = felixApi.fetchCoursesData()
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

extension AddTeacherViewController: UIPickerViewDelegate {

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String? {

        if let courses = courses,
            courses.count > 0 {
            let course = courses[row]

            return course.courceName
        }

        return "None Added"
    }

    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int) {
        if let courses = courses,
            courses.count > 0 {
            selectedCourse = courses[row]
        }
    }

}

// MARK: Picker Data source

extension AddTeacherViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }


    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int {
        return courses?.count ?? 0
    }

}

