//
//  AddCourseViewController.swift
//  CoreDataStudentTeacherCourse
//
//  Created by Bhushan Udawant on 20/11/18.
//  Copyright © 2018 Bhushan Udawant. All rights reserved.
//

import UIKit

class AddCourseViewController: UIViewController {

    // MARK: Constants

    let courseNames = ["iOS", "Android", "UI/UX", "Java", "Angular"] // FixMe: Pass dynamic values
    var currentCourseName: String?
    let felixApi = FelixAPI.sharedInstance

    // MARK: IBOutlets

    @IBOutlet weak var courseNamePicker: UIPickerView!
    @IBOutlet weak var courseDetailsField: UITextField!


    // MARK: Life cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        courseNamePicker.delegate = self
        courseNamePicker.dataSource = self
        currentCourseName = courseNames.first
    }

    // MARK: Helper

    func emptyFieldsValidationAlert() {
        let validationAlertTitle = "Warning"
        let validationAlertMessage = "\nPlease enter all the details"
        let okTitle = "OK"

        let alert = UIAlertController(
            title: validationAlertTitle,
            message: validationAlertMessage,
            preferredStyle: UIAlertControllerStyle.alert)

        let action = UIAlertAction(
            title: okTitle,
            style: UIAlertActionStyle.default)

        alert.addAction(action)
        
        navigationController?.present(alert, animated: true)
    }

    // MARK: Action

    @IBAction func saveCourse(_ sender: UIButton) {
        courseDetailsField.resignFirstResponder()

        if courseDetailsField.text == "" {
            emptyFieldsValidationAlert()

            return
        } else {

            // Save data in database using Core Data

            if let context = felixApi.context {
                let course = Course(context: context)
                course.courceName = currentCourseName
                course.courceDetails = courseDetailsField.text
                course.courseId = Uility.generateUUID()

                felixApi.saveData()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}


// MARK: Picker Delegate

extension AddCourseViewController: UIPickerViewDelegate {

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String? {
        return courseNames[row]
    }

    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int) {
        currentCourseName = courseNames[row]
    }

}

// MARK: Picker Data source

extension AddCourseViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int {
        return courseNames.count
    }
    
}
