//
//  ExtensionDate.swift
//  Tawajud
//
//  Created by SmartVision on 28/12/2023.
//

import Foundation

extension Date {
    func toString(withDateFormate dateFormate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormate
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: self)
    }
}
