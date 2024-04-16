//
//  String+Additions.swift
//  Tawajud Premium
//
//  Created by Hassan dad khan on 27/12/2023.
//

import Foundation

extension String {
    
    ///To check text field or String is blank or not
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
    
    ///Type casting string to Int
    var toInt: Int? {
        return NumberFormatter().number(from: self)?.intValue
    }
    
    ///Type casting string to Double
    var toDouble: Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    ///Removing white spaces from string
    var trimmWhiteSpace: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    ///Getting localized string
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// check for email validations
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    ///Get date with given formate
    func getDateWithFormate(formate : String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formate
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        
        if let date = dateFormatter.date(from:self) {
            return date
        }
        return nil
    }
    
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.date(from: self)
    }
    
    func isDateUpcoming(formate : String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formate
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        
        if let date = dateFormatter.date(from:self) {
            return date > Date()
        }
        return false
    }
    /*
    func getDateStringWith(format : String, dateFormat : String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = .current
        if let date = formatter.date(from: self) {
            return date.toString(withFormat: format)
        }
        return ""
    }
     */
    func format(with mask: String) -> String {
        let numbers = self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])

                // move numbers iterator to the next index
                index = numbers.index(after: index)

            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
    
    
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: .literal, range: nil)
    }
    
    func getAttributedString() -> NSAttributedString  {

        let attributedString: NSAttributedString = {
            let text = self
                return try! NSAttributedString(data: Data(text.utf8), options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue,
                ], documentAttributes: nil)
            }()
        
        return attributedString
    }
    
    func formattedDate() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            if let date = dateFormatter.date(from: self) {
                dateFormatter.dateFormat = "dd MMM yyyy"
                return dateFormatter.string(from: date)
            } else {
                return "----"
            }
        }
    
    func toDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day, .month, .year], from: date)

            if let day = components.day,
                let month = components.month,
                let year = components.year {
                return String(format: "%d/%d/%d", day, month, year)
            } else {
                return self.toDateWithMilliSeconds()
            }
        } else {
            return self.toDateWithMilliSeconds()
        }
    }
    
    func toDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day, .month, .year], from: date)

            if let day = components.day,
                let month = components.month,
                let year = components.year {
                return String(format: "%d/%d/%d", day, month, year)
            } else {
                return self.toDateWithMilliSeconds()
            }
        } else {
            return self.toDateWithMilliSeconds()
        }
    }
    
    func toDateWithMilliSeconds() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        guard let date = dateFormatter.date(from: self) else { return "" }
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
    
    
    
    func extractTime() -> String? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
            if let date = dateFormatter.date(from: self) {
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                return timeFormatter.string(from: date)
            } else {
                return nil
            }
        }
    
    func convertTo24Hours() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mma"
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        }
        
        return nil
    }
    
    func removeFromString() -> String {
        return self.replacingOccurrences(of: "/api", with: "")
    }
}


extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
