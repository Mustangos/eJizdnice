//
//  garage-model.swift
//  IZA_xhomol29_PROJ
//
//  Created by Radim Homola on 17.05.2023.
//

import Foundation
import CoreData

enum CarFuel: Int16, CaseIterable {
    case Benzin = 1
    case Nafta = 2
    case LPG = 3
    case Elektro = 4
    
    var description: String {
        switch self {
        case .Benzin:
            return "Benzin"
        case .Nafta:
            return "Nafta"
        case .LPG:
            return "LPG"
        case .Elektro:
            return "Elektro"
        }
    }
}

extension Car {
    
    static func FR() -> NSFetchRequest<Car> {
        let _fr = NSFetchRequest<Car>(entityName: "Car")
        _fr.sortDescriptors = [NSSortDescriptor(key: "dateChange", ascending: false)]
        return _fr
    }
    
    static func LOADALL() -> [Car] {
        let _fr = FR()
        
        if let _result = try? MOC().fetch(_fr) {
            return _result
        }
        
        return []
    }
    
    static func addNewCar(name: String, spz: String, yearManufacture: Int16, fuel: CarFuel)->Car{
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        let year = components.year
        
        let _car = Car(context: MOC())
        _car.id = UUID()
        _car.name = name
        _car.spz = spz
        _car.fuel = fuel.rawValue
        _car.dateChange = Date()
        if ((yearManufacture > 1501) && (yearManufacture < year!+1)){
            _car.yearManufacture = yearManufacture
        }
        SAVE()
        globalRefresh()
        return _car
    }
    
    func editCar(name: String, spz: String, yearManufacture: Int16, fuel: CarFuel){
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        let year = components.year
        
        self.name = name
        self.spz = spz
        if ((yearManufacture > 1501) && (yearManufacture < year!+1)){
            self.yearManufacture = yearManufacture
        }
        self.fuel = fuel.rawValue
        self.dateChange = Date()
        SAVE()
        globalRefresh()
    }
    
    static func deleteCar(car: Car){
        car.vozidloCesta?.forEach{ trip in
            MOC().delete(trip as! NSManagedObject)
        }
        MOC().delete(car)
        SAVE()
        globalRefresh()
    }
    
    func getLastTrip() -> Trip? {
        let trips = self.vozidloCesta?.allObjects as? [Trip]
        let sortedTrips = trips?.sorted(by: { $0.kmsAfter > $1.kmsAfter })
        return sortedTrips?.first
    }
}
