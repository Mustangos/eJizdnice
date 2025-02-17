//
//  GarageView.swift
//  IZA_xhomol29_PROJ
//
//  Created by Radim Homola on 17.05.2023.
//

import Foundation
import SwiftUI

struct GarageView: View {
    
    @ObservedObject var gm = GlobalCarObservable.shared
    @State var showBottomCar = false
    @State var isEditing = false
    
    func toggleShowBottomCar()  {
        showBottomCar.toggle()
    }
    var body: some View {
        NavigationView {
            List {
                if (gm.allCars == []){
                    Button(action: toggleShowBottomCar) {
                        HStack{
                            Spacer()
                            Text("Nové vozidlo")
                            Image(systemName: "plus")
                            Spacer()
                        }
                    }
                }else{
                    ForEach(gm.allCars) { car in
                        NavigationLink {
                            CarDetailView(car: car)
                        } label: {
                            CarMenuView(car: car)
                        }
                    }
                    .onDelete {indices in
                        indices.forEach { index in
                            let car = gm.allCars[index]
                            Car.deleteCar(car:car)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.isEditing.toggle()
                    }) {
                        if self.isEditing {
                            Text("Hotovo")
                        } else {
                            Text("Upravit")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: toggleShowBottomCar) { Image(systemName: "plus")}
                }
            }
            .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
            .navigationTitle("Vozidla")
            .sheet(isPresented: $showBottomCar){
                BottomSheetCarEdit()
            }
        }
    }
}

struct CarDetailView: View {
    
    @ObservedObject var gm = GlobalCarObservable.shared
    @State var showBottomEdit = false
    @State var car: Car
    
    init(car: Car) {
        _car = State(initialValue: car)
    }
    
    
    func toggleShowBottomEdit()  {
        showBottomEdit.toggle()
    }
    
    var body: some View {
        if gm.allCars.firstIndex(of: car) != nil {
            ScrollView {
                VStack(spacing:20){
                    Text(car.name!)
                        .font(.system(size: 36, weight: .bold))
                        .padding(35)
                    VStack(spacing: 15){
                        HStack(){
                            Spacer()
                            Text("Detail vozidla")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color("defaultGreen"))
                            Spacer()
                        }
                        HStack(){
                            Image(systemName: "car.fill")
                            Text("SPZ:")
                                .font(.system(size: 13, weight: .regular))
                            Spacer()
                            if (car.spz! == ""){
                                Text("N/A")
                                    .font(.system(size: 16, weight: .bold))
                            }else{
                                Text(car.spz ?? "N/A")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        HStack(){
                            Image(systemName: "fuelpump.fill")
                            Text("Typ paliva:")
                                .font(.system(size: 13, weight: .regular))
                            Spacer()
                            Text(CarFuel(rawValue: car.fuel)!.description)
                                .font(.system(size: 16, weight: .bold))
                        }
                        HStack(){
                            Image(systemName: "calendar")
                            Text("Rok výroby:")
                                .font(.system(size: 13, weight: .regular))
                            Spacer()
                            if (car.yearManufacture != 0){
                                Text(formatYear(car.yearManufacture))
                                    .font(.system(size: 16, weight: .bold))
                            } else {
                                Text("N/A")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        
                        if(car.vozidloCesta != []){
                            HStack(){
                                Spacer()
                                Text("Detail cest")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color("defaultGreen"))
                                Spacer()
                            }
                            VStack(spacing: 4){
                                CarTripInfoDetailView(anyTrips: car.vozidloCesta!.allObjects, tripTime: .currentMonth)
                                CarTripInfoDetailView(anyTrips: car.vozidloCesta!.allObjects, tripTime: .lastMonth)
                                CarTripInfoDetailView(anyTrips: car.vozidloCesta!.allObjects, tripTime: .currentYear)
                                CarTripInfoDetailView(anyTrips: car.vozidloCesta!.allObjects, tripTime: .lastYear)
                                CarTripInfoDetailView(anyTrips: car.vozidloCesta!.allObjects, tripTime: .all)
                            }
                        }
                        
                        Spacer()
                        HStack(){
                            Spacer()
                            Text("Poslední datum úpravy " + dateString(from: car.dateChange ?? Date()))
                                .font(.system(size: 10, weight: .light))
                                .padding(6)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: toggleShowBottomEdit) { Text("Upravit")}
                    }
                }
                .sheet(isPresented: $showBottomEdit){
                    BottomSheetCarEdit(car: car)
                }
            }
        }
    }
}

struct BottomSheetCarEdit: View{
    
    var car: Car?
    var editing : Bool = false
    @Environment(\.dismiss) var dismiss
    @ObservedObject var gm = GlobalCarObservable.shared
    @State private var name: String
    @State private var spz: String
    @State private var yearManufacture: Int16
    @State private var fuel: CarFuel
    
    var formatter: YearBoundFormatter = YearBoundFormatter()
    var title: String = "Nové vozidlo"
    
    init(car: Car? = nil) {
        self.car=car
        if (car != nil){
            _name = State(initialValue: car!.name ?? "")
            _spz = State(initialValue: car!.spz ?? "")
            _yearManufacture = State(initialValue: car!.yearManufacture)
            _fuel = State(initialValue: CarFuel(rawValue: car!.fuel) ?? .Benzin)
            self.title = "Úprava vozidla"
            self.editing=true
        }else{
            _name = State(initialValue: "")
            _spz = State(initialValue: "")
            _yearManufacture = State(initialValue: 0)
            _fuel = State(initialValue: .Benzin)
        }
    }
    
    var chatMessageIsValid: Bool {
        return !name.isEmpty
    }
    
    var buttonColor: Color {
        return chatMessageIsValid ?  Color("defaultGreen") : .gray
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Název*")) {
                    TextField("Název*", text: $name)
                        .onChange(of: name) { newValue in
                            name = newValue.replacingOccurrences(of: " ", with: "_")
                        }
                }
                Section(header: Text("SPZ")) {
                    TextField("SPZ", text: $spz)
                }
                Section(header: Text("Rok výroby")) {
                    TextField("Rok výroby", value: $yearManufacture, formatter: formatter)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Typ paliva")) {
                    Picker("Palivo", selection: $fuel) {
                        ForEach(CarFuel.allCases, id: \.self) { st in
                            Text(st.description)
                        }
                    }.pickerStyle(.segmented)
                }
            }
            .navigationBarTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if (editing){
                        Button(action: saveEdit) {
                            Text("Uložit")
                                .foregroundColor(buttonColor)
                                .disabled(chatMessageIsValid)
                        }
                    } else {
                        Button(action: saveCar) {
                            Text("Uložit")
                                .foregroundColor(buttonColor)
                                .disabled(chatMessageIsValid)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zavřít"){
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveEdit() {
        if (name != ""){
            car!.editCar(name: name, spz:spz, yearManufacture: yearManufacture, fuel:fuel)
            dismiss()
        }
    }
    
    private func saveCar() {
        if (name != ""){
            let _ = Car.addNewCar(name: name, spz: spz, yearManufacture: yearManufacture, fuel: fuel)
            dismiss()
        }
    }
}

struct CarMenuView: View {
    
    @ObservedObject var gm = GlobalCarObservable.shared
    @State var car: Car
    
    init(car: Car) {
        _car = State(initialValue: car)
    }
    
    var body: some View {
        Text(car.name ?? "NONAME")
    }
}


struct CarTripInfoDetailView: View {
    @State var trips: [Trip]
    let tripTime: TripTime
    let minKms: Int64
    let maxKms: Int64
    let kms: Int64
    let tripCnt: Int
    
    
    
    init(anyTrips: [Any], tripTime: TripTime) {
        let tmpTrips = anyTrips as! [Trip]
        _trips = State(initialValue: tmpTrips)
        self.tripTime = tripTime
        
        var minKms : Int64  = Int64.max
        var maxKms : Int64 = Int64.min
        var tripCnt = 0
        tmpTrips.forEach{ trip in
            let newTrip = TripFilter(trip: trip, tripTime: tripTime)
            if (newTrip != nil){
                tripCnt+=1
                if (trip.kmsBefore < minKms){
                    minKms = trip.kmsBefore
                }
                if(trip.kmsAfter > maxKms){
                    maxKms = trip.kmsAfter
                }
            }
        }
        if (tripCnt == 0){
            self.kms = 0
            self.minKms = 0
            self.maxKms = 0
        } else {
            self.kms = maxKms - minKms
            self.minKms = minKms
            self.maxKms = maxKms
        }
        self.tripCnt = tripCnt
        
    }
    
    var body: some View {
        HStack(){
            Spacer()
            Text(tripTime.description)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color("defaultGreen"))
            Spacer()
        }
        HStack(){
            Image(systemName: "road.lanes")
            Text("Nájezd")
                .font(.system(size: 11, weight: .regular))
            Spacer()
            Text(String(kms)+"km")
                .font(.system(size: 13, weight: .bold))
        }
        HStack(){
            Image(systemName: "location.fill")
            Text("Počet cest")
                .font(.system(size: 11, weight: .regular))
            Spacer()
            Text(String(tripCnt))
                .font(.system(size: 13, weight: .bold))
        }
        HStack(){
            Image(systemName: "speedometer")
            Text("Tachometr před")
                .font(.system(size: 11, weight: .regular))
            Spacer()
            Text(String(minKms)+"km")
                .font(.system(size: 13, weight: .bold))
        }
        HStack(){
            Image(systemName: "speedometer")
            Text("Tachometr po")
                .font(.system(size: 11, weight: .regular))
            Spacer()
            Text(String(maxKms)+"km")
                .font(.system(size: 13, weight: .bold))
        }
    }
}
