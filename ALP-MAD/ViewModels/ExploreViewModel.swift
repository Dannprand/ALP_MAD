import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ExploreViewModel: ObservableObject {
    @Published var allUsers: [User] = []
    @Published var filteredUsers: [User] = []
    @Published var followingIds: Set<String> = []
    @Published var hostedEvents: [Event] = []
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var isLoading: Bool = false

    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Fetch all users
    func fetchUsers() {
        isLoading = true
        db.collection("users").getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No user documents found")
                return
            }
            let users = documents.compactMap { User(document: $0) }
            DispatchQueue.main.async {
                self?.allUsers = users
                self?.filteredUsers = users
            }
        }
    }

    // MARK: - Fetch user's followers and following count
    func fetchUserStats(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching user stats: \(error.localizedDescription)")
                return
            }
            guard let data = snapshot?.data() else {
                print("No data for user stats")
                return
            }
            DispatchQueue.main.async {
                self?.followersCount = (data["followers"] as? [String])?.count ?? 0
                self?.followingCount = (data["following"] as? [String])?.count ?? 0
            }
        }
    }

    // MARK: - Filter users by search text
    func filterUsers(searchText: String) {
        if searchText.isEmpty {
            filteredUsers = allUsers
        } else {
            filteredUsers = allUsers.filter {
                $0.fullname.lowercased().contains(searchText.lowercased())
            }
        }
    }

    // MARK: - Fetch current user's following IDs
    func fetchFollowing(currentUserId: String) {
        db.collection("users").document(currentUserId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching following IDs: \(error.localizedDescription)")
                return
            }
            if let data = snapshot?.data(),
               let followingArray = data["following"] as? [String] {
                DispatchQueue.main.async {
                    self?.followingIds = Set(followingArray)
                }
            }
        }
    }

    // MARK: - Check if following specific user (sync check)
    func isFollowingUser(_ userId: String) -> Bool {
        return followingIds.contains(userId)
    }

    // MARK: - Toggle follow/unfollow user
    func toggleFollow(userId: String, currentUserId: String) {
        if followingIds.contains(userId) {
            // Unfollow
            db.collection("users").document(currentUserId).updateData([
                "following": FieldValue.arrayRemove([userId])
            ]) { error in
                if let error = error {
                    print("Error unfollowing user: \(error.localizedDescription)")
                }
            }
            db.collection("users").document(userId).updateData([
                "followers": FieldValue.arrayRemove([currentUserId])
            ]) { error in
                if let error = error {
                    print("Error removing follower: \(error.localizedDescription)")
                }
            }
            DispatchQueue.main.async {
                self.followingIds.remove(userId)
            }
        } else {
            // Follow
            db.collection("users").document(currentUserId).updateData([
                "following": FieldValue.arrayUnion([userId])
            ]) { error in
                if let error = error {
                    print("Error following user: \(error.localizedDescription)")
                }
            }
            db.collection("users").document(userId).updateData([
                "followers": FieldValue.arrayUnion([currentUserId])
            ]) { error in
                if let error = error {
                    print("Error adding follower: \(error.localizedDescription)")
                }
            }
            DispatchQueue.main.async {
                self.followingIds.insert(userId)
            }
        }
    }

    // MARK: - Fetch events hosted by user
    func fetchHostedEvents(userId: String) {
        db.collection("events")
            .whereField("hostId", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching hosted events: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("No hosted events found")
                    return
                }
                let events = documents.compactMap { Event(document: $0) }
                DispatchQueue.main.async {
                    self?.hostedEvents = events
                }
            }
    }
}
