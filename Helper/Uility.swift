//
//  Uility.swift
//  CoreDataStudentTeacherCourse
//
//  Created by Bhushan Udawant on 23/11/18.
//  Copyright © 2018 Bhushan Udawant. All rights reserved.
//

import Foundation

public enum Toggle {
    case hide
    case show

    var isHidden: Bool {
        switch self {
        case .hide: return true
        case .show: return false
        }
    }
}

class Uility {
    static func generateUUID() -> UUID {
        let uuid = UUID()

        return uuid
    }
}
