import SwiftUI
import FirebaseFirestore

struct UserDetailView: View {
    let user: User
    @State private var hostedEvents: [Event] = []
    @State private var isFollowing: Bool = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private let db = Firestore.firestore()
    

    // OLD CODE
    // var body: some View {
    //     ScrollView {
    //         VStack(spacing: 16) {
    //             // Profile photo or initials placeholder
    //             if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
    //                 AsyncImage(url: url) { phase in
    //                     switch phase {
    //                     case .empty:
    //                         ProgressView()
    //                             .frame(width: 100, height: 100)
    //                             .background(Color.gray.opacity(0.3))
    //                             .clipShape(Circle())
    //                     case .success(let image):
    //                         image
    //                             .resizable()
    //                             .scaledToFill()
    //                             .frame(width: 100, height: 100)
    //                             .clipShape(Circle())
    //                     case .failure(_):
    //                         Text(user.initials)
    //                             .font(.largeTitle)
    //                             .foregroundColor(.white)
    //                             .frame(width: 100, height: 100)
    //                             .background(Color.orange)
    //                             .clipShape(Circle())
    //                     @unknown default:
    //                         EmptyView()
    //                     }
    //                 }
    //             } else {
    //                 Text(user.initials)
    //                     .font(.largeTitle)
    //                     .foregroundColor(.white)
    //                     .frame(width: 100, height: 100)
    //                     .background(Color.orange)
    //                     .clipShape(Circle())
    //             }
                
    //             // Fullname
    //             Text(user.fullname)
    //                 .font(.title2)
    //                 .fontWeight(.bold)
                
    //             // Followers & Following count
    //             HStack(spacing: 40) {
    //                 VStack {
    //                     Text("\(user.followers?.count ?? 0)")
    //                         .font(.headline)
    //                     Text("Followers")
    //                         .font(.caption)
    //                         .foregroundColor(.gray)
    //                 }
    //                 VStack {
    //                     Text("\(user.following?.count ?? 0)")
    //                         .font(.headline)
    //                     Text("Following")
    //                         .font(.caption)
    //                         .foregroundColor(.gray)
    //                 }
    //             }
                
    //             // Skill level & sport preferences
    //             VStack(spacing: 8) {
    //                 if let skill = user.skillLevel {
    //                     HStack {
    //                         Text("Skill Level:")
    //                             .bold()
    //                         Text(skill.rawValue.capitalized)
    //                     }
    //                 }
    //                 if !user.preferences.isEmpty {
    //                     VStack(alignment: .leading) {
    //                         Text("Favorite Sports:")
    //                             .bold()
    //                         WrapView(items: user.preferences.map { $0.rawValue }) { sport in
    //                             Text(sport)
    //                                 .font(.caption)
    //                                 .padding(6)
    //                                 .background(Color.orange.opacity(0.2))
    //                                 .cornerRadius(8)
    //                         }
    //                     }
    //                 }
    //             }
    //             .frame(maxWidth: .infinity, alignment: .leading)
    //             .padding(.horizontal)
                
    //             // Follow / Unfollow Button (disabled if own profile)
    //             if authViewModel.currentUser?.id != user.id {
    //                 Button(action: {
    //                     toggleFollow()
    //                 }) {
    //                     Text(isFollowing ? "Unfollow" : "Follow")
    //                         .frame(maxWidth: .infinity)
    //                         .padding()
    //                         .background(isFollowing ? Color.gray : Color.orange)
    //                         .foregroundColor(.white)
    //                         .cornerRadius(10)
    //                 }
    //                 .padding(.horizontal)
    //             }
                
    //             Divider()
    //                 .padding(.vertical, 8)
                
    //             // Hosted events list
    //             VStack(alignment: .leading) {
    //                 Text("Hosted Events")
    //                     .font(.headline)
    //                     .padding(.horizontal)
                    
    //                 if hostedEvents.isEmpty {
    //                     Text("No hosted events")
    //                         .foregroundColor(.gray)
    //                         .padding()
    //                 } else {
    //                     ForEach(hostedEvents) { event in
    //                         NavigationLink(destination: EventDetailView(event: event)) {
    //                             EventRow(event: event)
    //                                 .padding(.horizontal)
    //                         }
    //                     }
    //                 }
    //             }
                
    //         }
    //         .padding(.top)
    //     }
    //     .navigationTitle("User Profile")
    //     .navigationBarTitleDisplayMode(.inline)
    //     .onAppear {
    //         checkFollowingStatus()
    //         fetchHostedEvents()
    //     }
    // }
    
     var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Profile photo or initials placeholder
                if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 100, height: 100)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        case .failure(_):
                            Text(user.initials)
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 100)
                                .background(Color.orange)
                                .clipShape(Circle())
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Text(user.initials)
                        .font(.largeTitle)
                        .foregroundColor(Theme.accentOrange)
                        .frame(width: 100, height: 100)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
                
                // Fullname
                Text(user.fullname)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.primaryText)
                
                // Followers & Following count
                HStack(spacing: 40) {
                    VStack {
                        Text("\(user.followers?.count ?? 0)")
                            .font(.headline)
                            .foregroundColor(Theme.accentOrange)
                        Text("Followers")
                            .font(.caption)
                            .foregroundColor(Theme.secondaryText)
                    }
                    VStack {
                        Text("\(user.following?.count ?? 0)")
                            .font(.headline)
                            .foregroundColor(Theme.accentOrange)
                        Text("Following")
                            .font(.caption)
                            .foregroundColor(Theme.secondaryText)
                    }
                }
                
                // Skill level & sport preferences
                VStack(spacing: 8) {
                    if let skill = user.skillLevel {
                        HStack {
                            Text("Skill Level:")
                                .bold()
                            Text(skill.rawValue.capitalized)
                                .foregroundColor(Theme.secondaryText)
                        }
                    }
                    if !user.preferences.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Favorite Sports:")
                                .bold()
                            WrapView(items: user.preferences.map { $0.rawValue }) { sport in
                                Text(sport)
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Follow / Unfollow Button (disabled if own profile)
                if authViewModel.currentUser?.id != user.id {
                    Button(action: {
                        toggleFollow()
                    }) {
                        Text(isFollowing ? "Unfollow" : "Follow")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFollowing ? Theme.accentOrangeDark : Theme.accentOrange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                // Hosted events list
                VStack(alignment: .leading) {
                    Text("Hosted Events")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if hostedEvents.isEmpty {
                        Text("No hosted events")
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        ForEach(hostedEvents) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                EventRow(event: event)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                
            }
            .padding(.top)
        }
        .navigationTitle("User Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkFollowingStatus()
            fetchHostedEvents()
        }
    }

    // MARK: - Functions
    
    private func checkFollowingStatus() {
        guard let currentUser = authViewModel.currentUser else { return }
        isFollowing = currentUser.following?.contains(user.id) ?? false
    }
    
    private func toggleFollow() {
        guard let currentUser = authViewModel.currentUser else { return }
        let currentUserRef = db.collection("users").document(currentUser.id)
        let targetUserRef = db.collection("users").document(user.id)
        
        if isFollowing {
            // Unfollow: remove from following and followers arrays
            currentUserRef.updateData([
                "following": FieldValue.arrayRemove([user.id])
            ])
            targetUserRef.updateData([
                "followers": FieldValue.arrayRemove([currentUser.id])
            ])
            isFollowing = false
        } else {
            // Follow: add to following and followers arrays
            currentUserRef.updateData([
                "following": FieldValue.arrayUnion([user.id])
            ])
            targetUserRef.updateData([
                "followers": FieldValue.arrayUnion([currentUser.id])
            ])
            isFollowing = true
        }
    }
    
    private func fetchHostedEvents() {
        guard !user.hostedEvents.isEmpty else {
            hostedEvents = []
            return
        }
        let eventsRef = db.collection("events")
        // Batasi fetch hanya event yg id-nya ada di user.hostedEvents
        eventsRef.whereField(FieldPath.documentID(), in: user.hostedEvents)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching hosted events: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                hostedEvents = documents.compactMap { doc -> Event? in
                    try? doc.data(as: Event.self)
                }
            }
    }
}

// MARK: - Helper Views

// Simple wrap view for tags (sports)
struct WrapView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content
    
    @State private var totalHeight
        = CGFloat.zero       // dynamic height of the whole view
    
    var body: some View {
        GeometryReader { geo in
            self.generateContent(in: geo)
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in geo: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > geo.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == items.first! {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if item == items.first! {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geo -> Color in
            DispatchQueue.main.async {
                binding.wrappedValue = geo.size.height
            }
            return Color.clear
        }
    }
}

// MARK: - EventRow for event list in user detail
struct EventRow: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 12) {
            Image(event.sport.rawValue.lowercased())
                .resizable()
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.headline)
                Text(event.date.dateValue().formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}
