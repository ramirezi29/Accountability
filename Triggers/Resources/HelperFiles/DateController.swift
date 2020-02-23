//
//  DateController.swift
//  Triggers
//
//  Created by Ivan Ramirez on 1/7/19.
//  Copyright © 2019 ramcomw. All rights reserved.
//

import Foundation

extension Date {
    
    /// Returns a Date with the specified amount of components added to the one it is called with
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        let components = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
        return Calendar.current.date(byAdding: components, to: self)
    }
    
    /// Returns a Date with the specified amount of components subtracted from the one it is called with
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        return add(years: -years, months: -months, days: -days, hours: -hours, minutes: -minutes, seconds: -seconds)
    }
    
    /** Returns the `Date` as a `String` formatted to mm/dd/yy. */
       var mmddyy: String {
           
           let formatter = DateFormatter()
           formatter.dateStyle = .short
           formatter.timeStyle = .none
           return formatter.string(from: self)
       }
       
       /** Returns the `Date` as a `String` formatted to mm/dd. */
       var mmdd: String {
           
           let calendar = Calendar(identifier: .gregorian)
           let month = calendar.component(.month, from: self)
           let day = calendar.component(.day, from: self)
           return "\(month)/\(day)"
       }
       
       /**
        Returns the `Date` as a `String`. Spells out month. Leaves day as an integer.
          * Example: "March 9"
        */
       var monthDay: String {
           
           let formatter = DateFormatter()
           formatter.locale = Locale(identifier: "en_US")
           formatter.setLocalizedDateFormatFromTemplate("MMMMd")
           return formatter.string(from: self)
       }
       
       /**
        Sets the `Date` to 12pm noon.
        * Use `.isSameDay(as:)` when comparing days.
        */
       func atNoon() -> Date {
           let calendar = Calendar(identifier: .gregorian)
           var date = self
           if let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: self) { date = noon }
           return date
       }
       
       /** Returns `true` if both `Date`s share the same `.day` and `.month` component.
       * Does *not* compare `.year`.
       - parameter date: The `Date` being compared.*/
       func isSameDay(as date: Date) -> Bool {
           let calendar = Calendar(identifier: .gregorian)
           var components = DateComponents()
           components.day = calendar.component(.day, from: self)
           components.month = calendar.component(.month, from: self)
           
           return calendar.date(date, matchesComponents: components)
       }
    
}
