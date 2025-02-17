//
//  ContentView.swift
//  IZA_xhomol29_PROJ
//
//  Created by Radim Homola on 17.05.2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView{
            TripView()
                .tabItem {
                    Label("Cesty", systemImage: "map.fill")
                }
            /* TankView()
             .tabItem {
             Label("Tankování", systemImage: "fuelpump.fill")
             }*/
            GarageView()
                .tabItem {
                    Label("Vozidla", systemImage: "car.2.fill")
                }
        }
        .onAppear(){
            UITabBar.appearance().backgroundColor = UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1.0)
        }
        .tint(Color("defaultGreen"))
    }
}
