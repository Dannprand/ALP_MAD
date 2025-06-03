import Foundation
import FirebaseFirestore
import Combine

class ExploreViewModel: ObservableObject {
    @Published var allUsers: [User] = []
    @Published var filteredUsers: [User] = []
    @Published var followingIds: Set<String> = []
    
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
}
