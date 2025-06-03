import Foundation
import FirebaseFirestore
import CoreLocation
import Combine

// Make sure this AuthService class exists in your project
// Either import it or define it here if it's missing
class AuthService {
    func getCurrentUserId() throws -> String {
        // Implement your authentication logic here
        // This is just a placeholder - replace with your actual implementation
        return "user-id-placeholder"
    }
}

class EventViewModel: ObservableObject {
    @Published var featuredEvents: [Event] = []
    @Published var nearbyEvents: [Event] = []
    @Published var popularEvents: [Event] = []
    @Published var myEvents: [Event] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var error: Error?
    @Published var selectedCategory: SportCategory? {
        didSet {
            Task {
                await fetchEvents()
            }
        }
    }
    
    private let eventService = EventService()
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    private let authService = AuthService()
    
    // MARK: - Event Fetching
    @MainActor
    func fetchEvents() async {
        isLoading = true
        do {
            let userId = try authService.getCurrentUserId()
            
            async let featuredFetch = eventService.fetchEvents { _ in }
            async let myEventsFetch = eventService.fetchEvents(forHostId: userId) { _ in }
            
            let (featuredResult, myEventsResult) = await (try featuredFetch, try myEventsFetch)
            
            let allEvents = try featuredResult.get()
            let myHostedEvents = try myEventsResult.get()
            
            // Filter by selected category if any
            let filteredEvents = selectedCategory == nil ?
                allEvents :
                allEvents.filter { $0.sport == selectedCategory }
            
            featuredEvents = filteredEvents.filter { $0.isFeatured }.sorted { $0.date.dateValue() < $1.date.dateValue() }
            popularEvents = filteredEvents.sorted { $0.participants.count > $1.participants.count }
            myEvents = myHostedEvents.sorted { $0.date.dateValue() < $1.date.dateValue() }
            
            if let userLocation = locationManager.lastLocation {
                nearbyEvents = filteredEvents.sorted {
                    let loc1 = CLLocation(latitude: $0.location.latitude, longitude: $0.location.longitude)
                    let loc2 = CLLocation(latitude: $1.location.latitude, longitude: $1.location.longitude)
                    return userLocation.distance(from: loc1) < userLocation.distance(from: loc2)
                }
            } else {
                nearbyEvents = filteredEvents
            }
            
            isLoading = false
        } catch {
            self.error = error
            showError = true
            isLoading = false
        }
    }
    
    // MARK: - Event Management
    func createEvent(
        title: String,
        description: String,
        sport: SportCategory,
        date: Date,
        expiryDate: Date,
        location: EventLocation,
        maxParticipants: Int,
        isFeatured: Bool = false,
        isTournament: Bool = false,
        prizePool: String? = nil,
        rules: String? = nil,
        requirements: String? = nil
    ) async -> Bool {
        do {
            let userId = try authService.getCurrentUserId()
            let newEvent = Event(
                title: title,
                description: description,
                hostId: userId,
                sport: sport,
                date: Timestamp(date: date),
                expiryDate: Timestamp(date: expiryDate),
                location: location,
                maxParticipants: maxParticipants,
                participants: [],
                isFeatured: isFeatured,
                isTournament: isTournament,
                prizePool: prizePool,
                rules: rules,
                requirements: requirements,
                chatId: UUID().uuidString,
                createdAt: Timestamp(date: Date())
            ) // Fixed the missing closing parenthesis here
            
            let result = try await eventService.createEvent(newEvent) { _ in }
            await fetchEvents()
            return true
        } catch {
            self.error = error
            showError = true
            return false
        }
    }
    
    func updateEvent(_ event: Event) async -> Bool {
        do {
            try await eventService.updateEvent(event) { _ in }
            await fetchEvents()
            return true
        } catch {
            self.error = error
            showError = true
            return false
        }
    }
    
    func deleteEvent(_ event: Event) async -> Bool {
        do {
            try await eventService.deleteEvent(event) { _ in }
            await fetchEvents()
            return true
        } catch {
            self.error = error
            showError = true
            return false
        }
    }
    
    // MARK: - Participant Management
    func joinEvent(_ event: Event) async -> Bool {
        do {
            let userId = try authService.getCurrentUserId()
            try await eventService.joinEvent(eventId: event.id ?? "", userId: userId) { _ in }
            await fetchEvents()
            return true
        } catch {
            self.error = error
            showError = true
            return false
        }
    }
    
    func leaveEvent(_ event: Event) async -> Bool {
        do {
            let userId = try authService.getCurrentUserId()
            try await eventService.leaveEvent(eventId: event.id ?? "", userId: userId) { _ in }
            await fetchEvents()
            return true
        } catch {
            self.error = error
            showError = true
            return false
        }
    }
    
    // MARK: - Location
    func requestUserLocation() {
        locationManager.requestLocation()
    }
    
    var lastKnownLocation: CLLocation? {
        locationManager.lastLocation
    }
    
    // MARK: - Cleanup
    func cleanupExpiredEvents() async -> Bool {
        do {
            let result = try await eventService.cleanupExpiredEvents() { _ in }
            await fetchEvents()
            return true
        } catch {
            self.error = error
            showError = true
            return false
        }
    }
}
