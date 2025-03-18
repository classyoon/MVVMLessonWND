//
//  Core.swift
//  MVVMLessonWND
//
//  Created by Conner Yoon on 3/17/25.
//

import Foundation
enum Place : String, CaseIterable, Identifiable {
    var id : Self { self }
    case outside, inside, farm, grave
}
struct SurvivorData : Identifiable {
    var name : String
    var location : Place
    var id : UUID
    init(name: String, location: Place, id: UUID = UUID()) {
        self.name = name
        self.location = location
        self.id = id
    }
}

class SurvivorVM : ObservableObject {
    @Published private(set) var people : [SurvivorData] = []
    func add(survivor : SurvivorData){
        people.append(survivor)
    }
    func update(survivor: SurvivorData){
        guard let index = people.firstIndex(where: {$0.id == survivor.id}) else { return }
        people[index] = survivor
    }
    func delete(offsets : IndexSet){
        for index in offsets {
            delete(survivor: people[index])
        }
    }
    func delete(survivor: SurvivorData){
        guard let index = people.firstIndex(where: {$0.id == survivor.id}) else { return
        }
        people.remove(at: index)
    }
    
}
import SwiftUI
struct SurvivorTrackerView : View {
    @StateObject var vm = SurvivorVM()
    @State var selectedPlace = Place.inside
    @State var name = ""
    var body: some View {
        NavigationStack {
            List {
                Text("Num of People : \(vm.people.count)")
                TextField("Name", text: $name)
                Picker("Location", selection: $selectedPlace) {
                    ForEach(Place.allCases){ place in
                        Text(place.rawValue)
                        
                    }
                }
                .pickerStyle(.segmented)
                ForEach(vm.people) { data in
                 
                        SurvivorEditView(data: data, update: vm.update)
                   

                    
                }.onDelete(perform: vm.delete)
                
            }.toolbar {
                Button("Add"){
                    vm.add(survivor: SurvivorData(name: name, location: selectedPlace))
                }
            }
        }
    }
}
struct SurvivorEditView : View {
    @State var data : SurvivorData
    @State var selectedPlace = Place.inside
    @State var name = ""
    var update : (SurvivorData)->()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            TextField("Name", text: $name)
                .onChange(of: name) { newValue, oldValue in
                    data.name = newValue
                    update(data)
                }
            Picker("Location", selection: $selectedPlace) {
                ForEach(Place.allCases){ place in
                    Text(place.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedPlace) { newValue, oldValue in
                data.location = newValue
                update(data)
            }
        }.toolbar {
            Button("Update"){
                update(SurvivorData(name: name, location: selectedPlace, id: data.id))
                dismiss()
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var vm : SurvivorVM = .init()
    SurvivorTrackerView(vm: vm)
}
