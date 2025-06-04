import FirebaseFirestore
import SwiftUI

struct ExploreView: View {
    @State private var searchText = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var exploreVM = ExploreViewModel()
    
    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.secondaryText)
                TextField("Search users by name...", text: $searchText)
                    .foregroundColor(Theme.primaryText)
            }
            .padding()
            .background(Theme.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)

            // User List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(exploreVM.filteredUsers, id: \.id) { user in
                        NavigationLink(destination: UserDetailView(user: user)) {
                            HStack(spacing: 16) {
                                // Profile Image with fallback
                                ZStack {
                                    Circle()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(Theme.accentOrange.opacity(0.3))
                                    
                                    if let imageUrl = user.profileImageUrl,
                                       !imageUrl.isEmpty,
                                       let url = URL(string: imageUrl) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                    } else {
                                        Text(user.initials)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(Theme.accentOrange)
                                    }
                                }
                                .frame(width: 60, height: 60)
                                
                                // User Info
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.fullname)
                                        .font(.headline)
                                        .foregroundColor(Theme.primaryText)
                                    
                                    if let level = user.skillLevel {
                                        Text(level.rawValue.capitalized)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(skillBadgeColor(level))
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                    }
                                }
                                
                                Spacer()
                                
                                // Follow / Unfollow Button
                                if let currentUserId = authViewModel.currentUser?.id,
                                   user.id != currentUserId {
                                    Button {
                                        exploreVM.toggleFollow(userId: user.id, currentUserId: currentUserId)
                                    } label: {
                                        Text(exploreVM.followingIds.contains(user.id) ? "Unfollow" : "Follow")
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(exploreVM.followingIds.contains(user.id) ? Color.gray : Theme.accentOrange)
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Theme.accentOrange, lineWidth: 1)
                                    .background(
                                        Theme.cardBackground.cornerRadius(16)
                                    )
                            )
                            .cornerRadius(16)
                            .shadow(
                                color: Color.black.opacity(0.05),
                                radius: 4,
                                x: 0,
                                y: 2
                            )
                            .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("Explore Friend")
        .onAppear {
            exploreVM.fetchUsers()
            if let currentUserId = authViewModel.currentUser?.id {
                exploreVM.fetchFollowing(currentUserId: currentUserId)
            }
        }
        .onChange(of: searchText) { newValue in
            exploreVM.filterUsers(searchText: newValue)
        }
        .background(Theme.background.ignoresSafeArea())
    }
    
    // Skill badge color tetap di View
    private func skillBadgeColor(_ level: SkillLevel) -> Color {
        switch level {
        case .beginner:
            return .gray
        case .intermediate:
            return .blue
        case .advanced:
            return Theme.accentOrange
        @unknown default:
            return .gray
        }
    }
}
