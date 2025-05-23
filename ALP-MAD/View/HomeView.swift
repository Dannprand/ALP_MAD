import SwiftUI

struct HomeView: View {
    @State private var showingAddEvent = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(0..<10) { index in
                        EventCardView(
                            eventTitle: "Event \(index + 1)",
                            eventDate: "12 Juni 2025",
                            hostName: "Host \(index + 1)",
                            imageName: "sport\(index % 3 + 1)"
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Sport Hub")
                        .foregroundColor(.orange)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingAddEvent = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.orange)
                            .font(.title2)
                    }
                }
            }
            .background(Color.black.ignoresSafeArea())
            .sheet(isPresented: $showingAddEvent) {
                AddEventView()
            }
        }
    }
}

#Preview {
    HomeView()
}
