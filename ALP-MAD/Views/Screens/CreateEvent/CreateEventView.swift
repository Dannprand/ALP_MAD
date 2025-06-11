import SwiftUI
import MapKit
import FirebaseFirestore

struct CreateEventView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = CreateEventViewModel()
    @State private var eventTitle = ""
    @State private var eventDescription = ""
    @State private var selectedSport: SportCategory = .football
    @State private var eventDate = Date()
    @State private var maxParticipants = 10
    @State private var isTournament = false
    @State private var prizePool = ""
    @State private var rules = ""
    @State private var requirements = ""
    @State private var showLocationPicker = false
    @State private var isCreating = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Event title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Event Title")
                        .font(.headline)
                        .foregroundColor(Theme.primaryText)
                    
                    TextField("Enter event title", text: $eventTitle)
                        .textFieldStyle(SportHubTextFieldStyle())
                }
                
                // Event description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                        .foregroundColor(Theme.primaryText)
                    
                    TextEditor(text: $eventDescription)
                        .frame(minHeight: 100)
                        .padding(10)
                        .background(Theme.cardBackground)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Theme.accentOrange.opacity(0.5), lineWidth: 1)
                        )
                        .foregroundColor(Theme.primaryText)
                }
                
                // Sport selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sport Category")
                        .font(.headline)
                        .foregroundColor(Theme.primaryText)
                    
                    Picker("Sport", selection: $selectedSport) {
                        ForEach(SportCategory.allCases, id: \.self) { sport in
                            Text(sport.rawValue).tag(sport)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Theme.accentOrange.opacity(0.5), lineWidth: 1)
                    )
                }
                
                // Date and time
                DatePicker(
                    "Date & Time",
                    selection: $eventDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .padding()
                .background(Theme.cardBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Theme.accentOrange.opacity(0.5), lineWidth: 1)
                )
                
                // Max participants
                Stepper(
                    value: $maxParticipants,
                    in: 2...100,
                    step: 1
                ) {
                    HStack {
                        Text("Max Participants")
                            .font(.headline)
                            .foregroundColor(Theme.primaryText)
                        Spacer()
                        Text("\(maxParticipants)")
                            .foregroundColor(Theme.accentOrange)
                    }
                }
                .padding()
                .background(Theme.cardBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Theme.accentOrange.opacity(0.5), lineWidth: 1)
                )
                
                // Location
                VStack(alignment: .leading, spacing: 8) {
                    Text("Location")
                        .font(.headline)
                        .foregroundColor(Theme.primaryText)
                    
                    if let location = viewModel.selectedLocation {
                        VStack(alignment: .leading) {
                            Text(location.name)
                                .font(.subheadline)
                                .foregroundColor(Theme.primaryText)
                            Text(location.address)
                                .font(.caption)
                                .foregroundColor(Theme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Theme.accentOrange.opacity(0.5), lineWidth: 1)
                        )
                    }
                    
                    Button(action: { showLocationPicker = true }) {
                        Text(viewModel.selectedLocation == nil ? "Select Location" : "Change Location")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                
                // Tournament toggle
                Toggle("Is this a tournament?", isOn: $isTournament)
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Theme.accentOrange.opacity(0.5), lineWidth: 1)
                    )
                    .tint(Theme.accentOrange)
                
                // Tournament details
                if isTournament {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Prize Pool (optional)")
                                .font(.headline)
                                .foregroundColor(Theme.primaryText)
                            
                            TextField("e.g., $500 cash prize", text: $prizePool)
                                .textFieldStyle(SportHubTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rules (optional)")
                                .font(.headline)
                                .foregroundColor(Theme.primaryText)
                            
                            TextEditor(text: $rules)
                                .frame(minHeight: 60)
                                .padding(10)
                                .background(Theme.cardBackground)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Theme.accentOrange.opacity(0.5), lineWidth: 1)
                                )
                                .foregroundColor(Theme.primaryText)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Requirements (optional)")
                                .font(.headline)
                                .foregroundColor(Theme.primaryText)
                            
                            TextEditor(text: $requirements)
                                .frame(minHeight: 60)
                                .padding(10)
                                .background(Theme.cardBackground)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Theme.accentOrange.opacity(0.5), lineWidth: 1)
                                )
                                .foregroundColor(Theme.primaryText)
                        }
                    }
                }
                
                // Create button
                Button(action: createEvent) {
                    if isCreating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Create Event")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!formIsValid || isCreating)
                .padding(.vertical)
            }
            .padding()
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Create Event")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerView(viewModel: viewModel)
        }
        .alert("Event Created", isPresented: $viewModel.showSuccessAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        }
    }
    
    private var formIsValid: Bool {
        !eventTitle.isEmpty &&
        !eventDescription.isEmpty &&
        viewModel.selectedLocation != nil
    }
    
    private func createEvent() {
        guard let user = authViewModel.currentUser,
              let location = viewModel.selectedLocation else { return }
        
        isCreating = true
        
        let event = Event(
            id: UUID().uuidString,
            title: eventTitle,
            description: eventDescription,
            hostId: user.id,
            sport: selectedSport,
            date: Timestamp(date: eventDate),
            location: location,
            maxParticipants: maxParticipants,
            participants: [user.id],
            isFeatured: false,
            isTournament: isTournament,
            prizePool: isTournament && !prizePool.isEmpty ? prizePool : nil,
            rules: isTournament && !rules.isEmpty ? rules : nil,
            requirements: isTournament && !requirements.isEmpty ? requirements : nil,
            chatId: UUID().uuidString,
            createdAt: Timestamp(date: Date())
        )

        
        viewModel.createEvent(event) {
            isCreating = false
        }
    }
}

class CreateEventViewModel: ObservableObject {
    @Published var selectedLocation: EventLocation?
    @Published var showSuccessAlert = false

    func createEvent(_ event: Event, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let documentRef = db.collection("events").document() // <-- fix ini
        
        do {
            var eventWithID = event
            eventWithID.id = documentRef.documentID
            let data = try Firestore.Encoder().encode(eventWithID)

            documentRef.setData(data) { error in
                if let error = error {
                    print("Error creating event: \(error)")
                } else {
                    self.showSuccessAlert = true

                    // Tambah ke hostedEvents user
                    let userId = event.hostId
                    db.collection("users").document(userId).updateData([
                        "hostedEvents": FieldValue.arrayUnion([documentRef.documentID])
                    ])
                }
                completion()
            }
        } catch {
            print("Error creating event: \(error)")
            completion()
        }
    }


}

struct LocationPickerView: View {
    @StateObject var viewModel: CreateEventViewModel
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Theme.secondaryText)
                    
                    TextField("Search for a location", text: $searchText, onCommit: searchForLocation)
                        .foregroundColor(Theme.primaryText)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Theme.secondaryText)
                        }
                    }
                }
                .padding(10)
                .background(Theme.cardBackground)
                .cornerRadius(10)
                .padding()
                
                // Search results or map
                if !searchResults.isEmpty {
                    List(searchResults, id: \.self) { item in
                        Button(action: {
                            selectLocation(item)
                        }) {
                            VStack(alignment: .leading) {
                                Text(item.name ?? "Unknown location")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.primaryText)
                                Text(item.placemark.title ?? "")
                                    .font(.caption)
                                    .foregroundColor(Theme.secondaryText)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .background(Theme.background)
                } else {
                    Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: viewModel.selectedLocation != nil ? [viewModel.selectedLocation!] : []) { location in
                        MapAnnotation(coordinate: location.coordinate) {
                            Image(systemName: "mappin")
                                .font(.title)
                                .foregroundColor(Theme.accentOrange)
                        }
                    }
                    .cornerRadius(10)
                    .padding()
                }
                
                Spacer()
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.accentOrange)
                    .disabled(viewModel.selectedLocation == nil)
                }
            }
            .onAppear {
                // Update region if we already have a selected location
                if let location = viewModel.selectedLocation {
                    region.center = location.coordinate
                    region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                }
            }
        }
    }
    
    private func searchForLocation() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error searching for locations: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            searchResults = response.mapItems
        }
    }
    
    private func selectLocation(_ mapItem: MKMapItem) {
        let placemark = mapItem.placemark
        viewModel.selectedLocation = EventLocation(
            name: mapItem.name ?? "Selected Location",
            address: placemark.title ?? "",
            latitude: placemark.coordinate.latitude,
            longitude: placemark.coordinate.longitude
        )
        searchResults = []
        searchText = ""
        
        // Update map region to selected location
        withAnimation {
            region.center = placemark.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        }
    }
}


//struct LocationPickerView: View {
//    @ObservedObject var viewModel: CreateEventViewModel
//    @State private var searchText = ""
//    @State private var searchResults: [MKMapItem] = []
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), // Default to London
//        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//    )
//    @Environment(\.dismiss) var dismiss
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                // Search bar
//                HStack {
//                    Image(systemName: "magnifyingglass")
//                        .foregroundColor(Theme.secondaryText)
//                    
//                    TextField("Search for a location", text: $searchText, onCommit: searchForLocation)
//                        .foregroundColor(Theme.primaryText)
//                    
//                    if !searchText.isEmpty {
//                        Button(action: {
//                            searchText = ""
//                            searchResults = []
//                        }) {
//                            Image(systemName: "xmark.circle.fill")
//                                .foregroundColor(Theme.secondaryText)
//                        }
//                    }
//                }
//                .padding(10)
//                .background(Theme.cardBackground)
//                .cornerRadius(10)
//                .padding()
//                
//                // Search results or map
//                if !searchResults.isEmpty {
//                    List(searchResults, id: \.self) { item in
//                        Button(action: {
//                            selectLocation(item)
//                        }) {
//                            VStack(alignment: .leading) {
//                                Text(item.name ?? "Unknown location")
//                                    .font(.subheadline)
//                                    .foregroundColor(Theme.primaryText)
//                                Text(item.placemark.title ?? "")
//                                    .font(.caption)
//                                    .foregroundColor(Theme.secondaryText)
//                            }
//                        }
//                    }
//                    .listStyle(.plain)
//                    .background(Theme.background)
//                } else {
//                    Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: viewModel.selectedLocation != nil ? [viewModel.selectedLocation!] : []) { location in
//                        MapAnnotation(coordinate: location.coordinate) {
//                            MapPin()
//                        }
//                    }
//                    .cornerRadius(10)
//                    .padding()
//                    .overlay(
//                        Image(systemName: "mappin")
//                            .font(.title)
//                            .foregroundColor(Theme.accentOrange)
//                    )
//                }
//                
//                Spacer()
//            }
//            .background(Theme.background.ignoresSafeArea())
//            .navigationTitle("Select Location")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") {
//                        dismiss()
//                    }
//                    .foregroundColor(Theme.accentOrange)
//                    .disabled(viewModel.selectedLocation == nil)
//                }
//            }
//        }
//    }
//    
//    private func searchForLocation() {
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = searchText
//        request.region = region
//        
//        let search = MKLocalSearch(request: request)
//        search.start { response, error in
//            guard let response = response else {
//                print("Error searching for locations: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            
//            searchResults = response.mapItems
//        }
//    }
//    
//    private func selectLocation(_ mapItem: MKMapItem) {
//        let placemark = mapItem.placemark
//        viewModel.selectedLocation = EventLocation(
//            name: mapItem.name ?? "Selected Location",
//            address: placemark.title ?? "",
//            latitude: placemark.coordinate.latitude,
//            longitude: placemark.coordinate.longitude
//        )
//        searchResults = []
//        searchText = ""
//        
//        // Update map region to selected location
//        withAnimation {
//            region.center = placemark.coordinate
//            region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//        }
//    }
//}
