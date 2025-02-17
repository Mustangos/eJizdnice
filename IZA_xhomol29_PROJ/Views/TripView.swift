//
//  TripView.swift
//  IZA_xhomol29_PROJ
//
//  Created by Radim Homola on 17.05.2023.
//

import Foundation
import SwiftUI

struct TripView: View {
    
    @ObservedObject var gt = GlobalTripObservable.shared
    @ObservedObject var gm = GlobalCarObservable.shared
    @State var showBottomTrip = false
    @State var isEditing = false
    
    func toggleShowBottomTrip()  {
        showBottomTrip.toggle()
    }
    var body: some View {
        NavigationView {
            List {
                if (gt.allTrips == []){
                    Button(action: toggleShowBottomTrip) {
                        HStack{
                            Spacer()
                            if (gm.allCars != []){
                                Text("Nová cesta")
                            } else {
                                Text("Nové vozidlo")
                            }
                            Image(systemName: "plus")
                            Spacer()
                        }
                    }
                }else{
                    ForEach(gt.allTrips) { trip in
                        NavigationLink {
                            TripDetailView(trip: trip)
                        } label: {
                            TripMenuView(trip:trip)
                        }
                    } .onDelete {indices in
                        indices.forEach { index in
                            let trip = gt.allTrips[index]
                            Trip.deleteTrip(trip :trip)
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
                    Button(action: toggleShowBottomTrip) { Image(systemName: "plus")}
                }
            }
            .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
            .navigationTitle("Cesty")
            .sheet(isPresented: $showBottomTrip){
                if (gm.allCars != []){
                    BottomSheetTripEdit(car: gm.allCars.first!)
                } else {
                    BottomSheetCarEdit()
                }
            }
        }
    }
}

struct BottomSheetTripEdit: View{
    
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var gm = GlobalCarObservable.shared
    
    @State private var date: Date
    @State private var from: String
    @State private var to: String
    @State private var kmsBefore: Int64
    @State private var kmsAfter: Int64
    @State private var purpose: TripPurpose = .Pracovni
    @State private var lockKmsBefore: Bool
    @State private var twoWay: Bool
    
    @State private var car: Car
    @State var lastDate: Date
    
    init(car: Car) {
        _kmsBefore = State(initialValue: 0)
        _kmsAfter = State(initialValue: 1)
        _date = State(initialValue: Date())
        _from = State(initialValue: "")
        _to = State(initialValue: "")
        _purpose = State(initialValue: .Pracovni)
        _twoWay = State(initialValue: false)
        if (car.vozidloCesta != []){
            _lockKmsBefore = State(initialValue: true)
            _kmsBefore = State(initialValue: car.getLastTrip()!.kmsAfter)
            _lastDate = State(initialValue: car.getLastTrip()!.date!)
        } else {
            _lockKmsBefore = State(initialValue: false)
            _lastDate = State(initialValue: Date.distantPast)
        }
        _car = State(initialValue: car)
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Vozidlo", selection: $car) {
                    ForEach(gm.allCars, id: \.self) { c in
                        Text(c.name!)
                    }
                }
                Section(header: Text("Stav tachometru před jízdou*")) {
                    TextField("Stav tachometru před jízdou", value: $kmsBefore, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .disabled(lockKmsBefore)
                }
                
                Section(header: Text("Stav tachometru po jízdě*")) {
                    TextField("Stav tachometru po jízdě", value: $kmsAfter, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Datum a čas*")) {
                    DatePicker("Datum a čas", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                .datePickerStyle(.automatic)
                .labelsHidden()
                Section(header: Text("Záměr cesty")) {
                    Picker("Záměr cesty", selection: $purpose) {
                        ForEach(TripPurpose.allCases, id: \.self) { purpose in
                            Text(purpose.description)
                        }
                    }
                    .pickerStyle(.segmented)
                    Toggle("Zpáteční", isOn: $twoWay)
                }
                Section(header: Text("Odkud")) {
                    TextField("Odkud", text: $from)
                }
                
                Section(header: Text("Kam")) {
                    TextField("Kam", text: $to)
                }
                
            }
            .navigationBarTitle("Nová Cesta")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button(action: saveTrip) {
                        Text("Uložit")
                            .foregroundColor(buttonColor)
                            .disabled(chatMessageIsVal)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zavřít"){
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: car, perform: switchCar)
    }
    
    private func switchCar(_: Car){
        if (car.vozidloCesta != []){
            lockKmsBefore = true
            kmsBefore = car.getLastTrip()!.kmsAfter
            lastDate = car.getLastTrip()!.date!
        } else {
            lockKmsBefore = false
            kmsBefore = 0
            lastDate = Date.distantPast
        }
    }
    
    var chatMessageIsVal: Bool {
        return ((kmsAfter > kmsBefore)&&(kmsBefore>=0)&&(kmsAfter>0)&&(date > lastDate))
    }
    
    var buttonColor: Color {
        return chatMessageIsVal ?  Color("defaultGreen") : .gray
    }
    
    private func saveTrip() {
        if (chatMessageIsVal){
            let _ = Trip.addNewTrip(car: car, kmsBefore: kmsBefore, kmsAfter: kmsAfter, from: from, to: to, purpose: purpose, date: date, twoWay: twoWay)
            dismiss()}
    }
}

struct TripDetailView: View {
    
    @ObservedObject var gt = GlobalTripObservable.shared
    @State var trip: Trip
    
    
    init(trip: Trip) {
        _trip = State(initialValue: trip)
    }
    
    var body: some View {
        if gt.allTrips.firstIndex(of: trip) != nil {
            VStack(spacing: 20){
                HStack{
                    Spacer()
                    VStack{
                        Text("Začátek")
                            .font(.system(size: 13, weight: .thin))
                            .foregroundColor(Color("defaultGreen"))
                        if (trip.from! == ""){
                            Text("N/A")
                                .font(.system(size: 20, weight: .bold))
                        }else{
                            Text(trip.from ?? "N/A")
                                .font(.system(size: 20, weight: .bold))
                        }
                    }
                    Spacer()
                    if (trip.twoWay){
                        Image(systemName: "arrow.left.arrow.right")
                    } else {
                        Image(systemName: "arrow.right")
                    }
                    Spacer()
                    VStack{
                        Text("Konec")
                            .font(.system(size: 13, weight: .thin))
                            .foregroundColor(Color("defaultGreen"))
                        if (trip.to! == ""){
                            Text("N/A")
                                .font(.system(size: 20, weight: .bold))
                        }else{
                            Text(trip.to ?? "N/A")
                                .font(.system(size: 20, weight: .bold))
                        }
                    }
                    Spacer()
                }
                .padding(40)
                VStack(spacing: 15){
                    HStack(){
                        Spacer()
                        Text("Detail cesty")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color("defaultGreen"))
                        Spacer()
                    }
                    HStack(){
                        Image(systemName: "car.fill")
                        Text("Vozidlo:")
                            .font(.system(size: 13, weight: .regular))
                        Spacer()
                        Text(trip.cestaVozidla?.name ?? "N/A")
                            .font(.system(size: 16, weight: .bold))
                    }
                    HStack(){
                        Image(systemName: "calendar")
                        Text("Datum:")
                            .font(.system(size: 13, weight: .regular))
                        Spacer()
                        Text(dateString(from: trip.date ?? Date()))
                            .font(.system(size: 16, weight: .bold))
                    }
                    HStack(){
                        Image(systemName: "arrow.triangle.branch")
                        Text("Typ:")
                            .font(.system(size: 13, weight: .regular))
                        Spacer()
                        Text(TripPurpose(rawValue: trip.puropse)!.description)
                            .font(.system(size: 16, weight: .bold))
                    }
                    HStack(){
                        Image(systemName: "speedometer")
                        Text("Tachometr před")
                            .font(.system(size: 13, weight: .regular))
                        Spacer()
                        Text(String(trip.kmsBefore)+"km")
                            .font(.system(size: 16, weight: .bold))
                    }
                    HStack(){
                        Image(systemName: "speedometer")
                        Text("Tachometr po")
                            .font(.system(size: 13, weight: .regular))
                        Spacer()
                        Text(String(trip.kmsAfter)+"km")
                            .font(.system(size: 16, weight: .bold))
                    }
                    HStack(){
                        Image(systemName: "road.lanes")
                        Text("Délka cesty")
                            .font(.system(size: 13, weight: .regular))
                        Spacer()
                        Text(String(trip.kmsAfter-trip.kmsBefore)+"km")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .padding(.horizontal, 20)
            }
            Spacer()
        }
    }
}


struct TripMenuView: View {
    @ObservedObject var gt = GlobalTripObservable.shared
    @State var trip: Trip
    
    init(trip: Trip) {
        _trip = State(initialValue: trip)
    }
    
    var body: some View {
        HStack {
            if (trip.twoWay){
                Image(systemName: "arrow.left.arrow.right")
            } else {
                Image(systemName: "arrow.right")
            }
            Text(String(trip.kmsAfter-trip.kmsBefore)+" km")
            Spacer()
            Text(trip.cestaVozidla?.name ?? "")
            Text(dateString(from: trip.date ?? Date()))
        }
    }
}
