//
//  GlobalObservable.swift
//  IZA_xhomol29_PROJ
//
//  Created by Radim Homola on 17.05.2023.
//

import Foundation
import CoreData
import Combine

class GlobalCarObservable: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    let FRC: NSFetchedResultsController<Car>
    
    static let shared = GlobalCarObservable()
    
    @Published var allCars: [Car] = []
    
    
    func refresh() {
        try? FRC.performFetch()
        guard let _ff = FRC.fetchedObjects else { fatalError() }
        allCars = _ff
    }
    
    override init() {
        FRC = NSFetchedResultsController(fetchRequest: Car.FR(),
                                         managedObjectContext: MOC(),
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        super .init()
        FRC.delegate = self
        refresh()
    }
}

class GlobalTripObservable: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    let FRC: NSFetchedResultsController<Trip>
    
    static let shared = GlobalTripObservable()
    
    @Published var allTrips: [Trip] = []
    
    
    func refresh() {
        try? FRC.performFetch()
        guard let _ff = FRC.fetchedObjects else { fatalError() }
        allTrips = _ff
    }
    
    override init() {
        FRC = NSFetchedResultsController(fetchRequest: Trip.FR(),
                                         managedObjectContext: MOC(),
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        super .init()
        FRC.delegate = self
        refresh()
    }
}
