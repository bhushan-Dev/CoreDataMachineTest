//
//  UpdateCourseViewController.swift
//  CoreDataStudentTeacherCourse
//
//  Created by Bhushan Udawant on 09/12/18.
//  Copyright © 2018 Bhushan Udawant. All rights reserved.
//

import UIKit

class UpdateCourseViewController: UIViewController {

    // MARK: Constants

    var course: Course?
    let felixApi = FelixAPI.sharedInstance

    // MARK: IBOutlet

    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var detailsTextField: UITextField!


    // MARK: Life cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        if let course = course {
            detailsTextField.text = course.courceDetails
            courseLabel.text = course.courceName
        }
    }

    // MARK: Actions

    @IBAction func updateCourse(_ sender: UIButton) {
        guard let _ = course else {
            return
        }

        course?.courceDetails = detailsTextField.text
        felixApi.updateData()

        self.navigationController?.popViewController(animated: true)
    }
}
