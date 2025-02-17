//
//  trip-model.swift
//  IZA_xhomol29_PROJ
//
//  Created by Radim Homola on 19.05.2023.
//

import Foundation
import CoreData

enum TripPurpose: Int16, CaseIterable {
    case Pracovni = 1
    case Osobni = 2
    
    var description: String {
        switch self {
        case .Pracovni:
            return "Pracovní"
        case .Osobni:
            return "Osobní"
        }
    }
}

extension Trip {
    
    static func FR() -> NSFetchRequest<Trip> {
        let _fr = NSFetchRequest<Trip>(entityName: "Trip")
        _fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return _fr
    }
    
    static func LOADALL() -> [Trip] {
        let _fr = FR()
        
        if let _result = try? MOC().fetch(_fr) {
            return _result
        }
        return []
    }
    
    static func addNewTrip(car: Car, kmsBefore: Int64, kmsAfter: Int64, from:String, to:String, purpose: TripPurpose, date: Date, twoWay: Bool)->Trip{
        
        let _trip = Trip(context: MOC())
        _trip.id = UUID()
        _trip.cestaVozidla = car
        _trip.kmsBefore = kmsBefore
        _trip.kmsAfter = kmsAfter
        _trip.from = from
        _trip.to = to
        _trip.puropse = purpose.rawValue
        _trip.date = date
        _trip.twoWay = twoWay
        SAVE()
        globalRefresh()
        return _trip
    }
    
    static func deleteTrip(trip: Trip){
        MOC().delete(trip)
        SAVE()
        globalRefresh()
    }
}
