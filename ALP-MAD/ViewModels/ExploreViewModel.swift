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
    @Published var isFollowing: Bool = false
    @Published var selectedUser: User?
    private var db = Firestore.firestore()
 
    private var userStatsListener: ListenerRegistration?

    func observeUserStats(userId: String) {
        userStatsListener?.remove() // Hapus listener lama jika ada

        userStatsListener = db.collection("users").document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error observing user stats: \(error.localizedDescription)")
                    return
                }

                guard let data = snapshot?.data() else { return }

                DispatchQueue.main.async {
                    self?.followersCount = (data["followers"] as? [String])?.count ?? 0
                    self?.followingCount = (data["following"] as? [String])?.count ?? 0
                }
            }
    }

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

//    // MARK: - Check if following specific user (sync check)
    func checkFollowingStatus(currentUser: User, targetUser: User) {
        isFollowing = currentUser.following?.contains(targetUser.id) ?? false
    }

    // MARK: - Toggle follow/unfollow user
    func toggleFollow(currentUser: User, targetUser: User) {
            let currentUserRef = db.collection("users").document(currentUser.id)
            let targetUserRef = db.collection("users").document(targetUser.id)
            
            if isFollowing {
                currentUserRef.updateData([
                    "following": FieldValue.arrayRemove([targetUser.id])
                ])
                targetUserRef.updateData([
                    "followers": FieldValue.arrayRemove([currentUser.id])
                ])
                isFollowing = false
            } else {
                currentUserRef.updateData([
                    "following": FieldValue.arrayUnion([targetUser.id])
                ])
                targetUserRef.updateData([
                    "followers": FieldValue.arrayUnion([currentUser.id])
                ])
                isFollowing = true
            }
        }

    // MARK: - Fetch events hosted by user
    func fetchHostedEvents(for user: User) {
            guard !user.hostedEvents.isEmpty else {
                self.hostedEvents = []
                return
            }
            
            db.collection("events")
                .whereField(FieldPath.documentID(), in: user.hostedEvents)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching hosted events: \(error.localizedDescription)")
                        return
                    }
                    guard let documents = snapshot?.documents else { return }
                    self.hostedEvents = documents.compactMap {
                        try? $0.data(as: Event.self)
                    }
                }
        }
}
