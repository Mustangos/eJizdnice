//
//  Helpers.swift
//  IZA_xhomol29_PROJ
//
//  Created by Radim Homola on 20.05.2023.
//

import Foundation


func formatYear(_ number: Int16) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.groupingSeparator = " "
    
    return numberFormatter.string(from: NSNumber(value: number)) ?? ""
}

func dateString(from date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    dateFormatter.locale = Locale(identifier: "cs_CZ")
    return dateFormatter.string(from: date)
}

func globalRefresh(){
    GlobalTripObservable.shared.refresh()
    GlobalCarObservable.shared.refresh()
}


enum TripTime: Int16, CaseIterable {
    case currentMonth = 1
    case lastMonth = 2
    case currentYear = 3
    case lastYear = 4
    case all = 5
    
    var description: String {
        switch self {
        case .currentMonth:
            return "Aktuální měcíc"
        case .lastMonth:
            return "Minulý měsíc"
        case .currentYear:
            return "Aktuální rok"
        case .lastYear:
            return "Minulý rok"
        case .all:
            return "Celkově"
        }
    }
}

func TripFilter(trip: Trip, tripTime: TripTime) -> Trip?{
    switch(tripTime){
    case .currentMonth:
        if (isInActualMonth(date: trip.date!)){
            return trip
        }
    case .lastMonth:
        if (isInLastMonth(date: trip.date!)){
            return trip
        }
    case .currentYear:
        if (isInActualYear(date: trip.date!)){
            return trip
        }
    case .lastYear:
        if (isInLastYear(date: trip.date!)){
            return trip
        }
    case .all:
        return trip
    }
    return nil
}

func isInActualMonth(date: Date) -> Bool {
    let calendar = Calendar.current
    let currentMonth = calendar.component(.month, from: Date())
    let currentYear = calendar.component(.year, from: Date())
    
    let targetMonth = calendar.component(.month, from: date)
    let targetYear = calendar.component(.year, from: date)
    
    return ((currentMonth == targetMonth) && (currentYear == targetYear))
}

func isInActualYear(date: Date) -> Bool {
    let calendar = Calendar.current
    let currentYear = calendar.component(.year, from: Date())
    let targetYear = calendar.component(.year, from: date)
    
    return (currentYear == targetYear)
}


func isInLastMonth(date: Date) -> Bool {
    let calendar = Calendar.current
    let currentMonth = calendar.component(.month, from: Date())
    let currentYear = calendar.component(.year, from: Date())
    
    var lastMonthComponents = DateComponents()
    lastMonthComponents.month = -1
    
    guard let lastMonth = calendar.date(byAdding: lastMonthComponents, to: Date()) else {
        return false
    }
    
    let lastMonthMonth = calendar.component(.month, from: lastMonth)
    let lastMonthYear = calendar.component(.year, from: lastMonth)
    
    let targetMonth = calendar.component(.month, from: date)
    let targetYear = calendar.component(.year, from: date)
    
    return ((lastMonthMonth == targetMonth) && (lastMonthYear == targetYear))

}

func isInLastYear(date: Date) -> Bool {
    let calendar = Calendar.current
    let currentYear = calendar.component(.year, from: Date())
    
    var lastYearComponents = DateComponents()
    lastYearComponents.year = -1
    
    guard let lastYear = calendar.date(byAdding: lastYearComponents, to: Date()) else {
        return false
    }
    
    let lastYearYear = calendar.component(.year, from: lastYear)
    
    return lastYearYear == calendar.component(.year, from: date)
}



//https://stackoverflow.com/questions/72636810/swiftui-numeric-textfield-maximum-and-minimum-values
class YearBoundFormatter: Formatter {
    
    var max: Int = 9999
    var min: Int = 0
    
    func clamp(with value: Int, min: Int, max: Int) -> Int{
        guard value <= max else {
            return max
        }
        
        guard value >= min else {
            return min
        }
        
        return value
    }
    
    func setMax(_ max: Int) {
        self.max = max
    }
    func setMin(_ min: Int) {
        self.min = min
    }
    
    override func string(for obj: Any?) -> String? {
        guard let number = obj as? Int else {
            return nil
        }
        return String(number)
        
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        guard let number = Int(string) else {
            return false
        }
        
        obj?.pointee = clamp(with: number, min: self.min, max: self.max) as AnyObject
        
        return true
    }
}
