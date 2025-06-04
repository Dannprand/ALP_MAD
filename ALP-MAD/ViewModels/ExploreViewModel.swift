import Foundation
import FirebaseFirestore
import Combine

class ExploreViewModel: ObservableObject {
    @Published var allUsers: [User] = []
    @Published var filteredUsers: [User] = []
    @Published var followingIds: Set<String> = []
    @Published var isFollowing: Bool = false
    @Published var hostedEvents: [Event] = []
    
    private var currentUserId: String? {
            AuthViewModel.shared.currentUser?.id
        }
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    // Fetch all users dari Firestore
    func fetchUsers() {
        db.collection("users").getDocuments { [weak self] snapshot, error in
            guard let documents = snapshot?.documents else { return }
            let users = documents.compactMap { User(document: $0) }
            DispatchQueue.main.async {
                self?.allUsers = users
                self?.filteredUsers = users
            }
        }
    }
    
    // Filter users berdasarkan search text
    func filterUsers(searchText: String) {
        if searchText.isEmpty {
            filteredUsers = allUsers
        } else {
            filteredUsers = allUsers.filter {
                $0.fullname.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    // Fetch following ids dari current user
    func fetchFollowing(currentUserId: String) {
        db.collection("users").document(currentUserId).getDocument { [weak self] snapshot, error in
            if let data = snapshot?.data(),
               let followingArray = data["following"] as? [String] {
                DispatchQueue.main.async {
                    self?.followingIds = Set(followingArray)
                }
            }
        }
    }
    
    // Check if there is followed
    func checkIfFollowing(userId: String) {
         guard let currentUserId = currentUserId else { return }
         let currentUserRef = db.collection("users").document(currentUserId)
         currentUserRef.getDocument { snapshot, error in
             if let data = snapshot?.data(),
                let following = data["following"] as? [String] {
                 self.isFollowing = following.contains(userId)
             }
         }
     }
    
    // Toggle follow / unfollow
    func toggleFollow(userId: String, currentUserId: String) {
        if followingIds.contains(userId) {
            // Unfollow
            db.collection("users").document(currentUserId).updateData([
                "following": FieldValue.arrayRemove([userId])
            ])
            db.collection("users").document(userId).updateData([
                "followers": FieldValue.arrayRemove([currentUserId])
            ])
            DispatchQueue.main.async {
                self.followingIds.remove(userId)
            }
        } else {
            // Follow
            db.collection("users").document(currentUserId).updateData([
                "following": FieldValue.arrayUnion([userId])
            ])
            db.collection("users").document(userId).updateData([
                "followers": FieldValue.arrayUnion([currentUserId])
            ])
            DispatchQueue.main.async {
                self.followingIds.insert(userId)
            }
        }
    }
    
//    hosted event by user
    func fetchHostedEvents(userId: String) {
            db.collection("events")
                .whereField("hostId", isEqualTo: userId)
                .getDocuments { snapshot, error in
                    if let documents = snapshot?.documents {
                        self.hostedEvents = documents.compactMap { Event(document: $0) }
                    }
                }
        }
}
