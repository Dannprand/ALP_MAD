//
//  CreateEventView.swift
//  ALP-MAD
//
//  Created by student on 03/06/25.
//

import SwiftUI
import MapKit

struct CreateEventView: View {
    @ObservedObject var viewModel: EventViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedSport: SportCategory = .basketball
    @State private var date = Date()
    @State private var expiryDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var locationName = ""
    @State private var locationAddress = ""
    @State private var maxParticipants = 10
    @State private var isTournament = false
    @State private var prizePool = ""
    @State private var rules = ""
    @State private var requirements = ""
    @State private var showLocationSearch = false
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    
    var body: some View {
        Form {
            Section(header: Text("Event Information")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                
                Picker("Sport", selection: $selectedSport) {
                    ForEach(SportCategory.allCases, id: \.self) { sport in
                        Text(sport.rawValue.capitalized).tag(sport)
                    }
                }
                
                DatePicker("Event Date", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                
                DatePicker("Expiry Date", selection: $expiryDate, in: date..., displayedComponents: [.date, .hourAndMinute])
                
                Stepper("Max Participants: \(maxParticipants)", value: $maxParticipants, in: 2...100)
            }
            
            Section(header: Text("Location")) {
                Button(action: {
                    showLocationSearch = true
                }) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        if locationName.isEmpty {
                            Text("Select Location")
                        } else {
                            Text(locationName)
                        }
                    }
                }
                
                if !locationAddress.isEmpty {
                    Text(locationAddress)
                        .font(.caption)
                }
            }
            
            Section(header: Text("Tournament Settings")) {
                Toggle("Is Tournament", isOn: $isTournament)
                
                if isTournament {
                    TextField("Prize Pool", text: $prizePool)
                    TextField("Rules", text: $rules)
                    TextField("Requirements", text: $requirements)
                }
            }
        }
        .navigationTitle("Create Event")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Create") {
                    guard !title.isEmpty, !description.isEmpty, !locationName.isEmpty else { return }
                    
                    let location = EventLocation(
                        name: locationName,
                        address: locationAddress,
                        latitude: selectedCoordinate?.latitude ?? 0,
                        longitude: selectedCoordinate?.longitude ?? 0
                    )
                    
                    Task {
                        let success = await viewModel.createEvent(
                            title: title,
                            description: description,
                            sport: selectedSport,
                            date: date,
                            expiryDate: expiryDate,
                            location: location,
                            maxParticipants: maxParticipants,
                            isTournament: isTournament,
                            prizePool: isTournament ? prizePool : nil,
                            rules: isTournament ? rules : nil,
                            requirements: isTournament ? requirements : nil
                        )
                        
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .disabled(title.isEmpty || description.isEmpty || locationName.isEmpty)
            }
        }
        .sheet(isPresented: $showLocationSearch) {
            LocationSearchView(selectedName: $locationName,
                             selectedAddress: $locationAddress,
                             selectedCoordinate: $selectedCoordinate)
        }
    }
}
