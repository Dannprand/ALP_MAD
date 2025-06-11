import SwiftUI
import FirebaseFirestore

struct PreferencesView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedSports: [SportCategory] = []
    @State private var skillLevel: SkillLevel = .beginner
    @State private var notificationEnabled = true
    @State private var radius = 20.0
    @State private var isSaving = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerSection()
                sportSelectionSection()
                skillLevelSection()
//                notificationSection()
//                radiusSection()
                saveButtonSection()
                
                Spacer()
            }
            .padding(.vertical)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Subviews

    @ViewBuilder
    private func headerSection() -> some View {
        VStack(spacing: 10) {
            Text("Set Your Preferences")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Theme.primaryText)

            Text("Help us find the best events for you")
                .font(.subheadline)
                .foregroundColor(Theme.secondaryText)
        }
        .padding(.top, 40)
    }

    @ViewBuilder
    private func sportSelectionSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Favorite Sports")
                .font(.headline)
                .foregroundColor(Theme.primaryText)

            Text("Select sports you're interested in")
                .font(.caption)
                .foregroundColor(Theme.secondaryText)

            let columns = [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ]

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(SportCategory.allCases, id: \.self) { sport in
                    SportPillView(
                        sport: sport,
                        isSelected: selectedSports.contains(sport)
                    ) {
                        toggleSportSelection(sport)
                    }
                    .frame(height: 50)
                }
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func skillLevelSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Skill Level")
                .font(.headline)
                .foregroundColor(Theme.primaryText)

            Picker("Skill Level", selection: $skillLevel) {
                ForEach(SkillLevel.allCases, id: \.self) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(Theme.cardBackground)
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func saveButtonSection() -> some View {
        Button(action: savePreferences) {
            if isSaving {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Save Preferences")
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(selectedSports.isEmpty || isSaving)
        .padding()
    }

    // MARK: - Logic

    private func toggleSportSelection(_ sport: SportCategory) {
        if selectedSports.contains(sport) {
            selectedSports.removeAll { $0 == sport }
        } else {
            selectedSports.append(sport)
        }
    }

    private func savePreferences() {
        guard let userId = authViewModel.currentUser?.id else { return }
        
        isSaving = true
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "preferences": selectedSports.map { $0.rawValue },
            "skillLevel": skillLevel.rawValue,
            "notificationEnabled": notificationEnabled,
            "searchRadius": radius
        ]) { error in
            isSaving = false
            if let error = error {
                print("Error saving preferences: \(error)")
            } else {
                Task {
                    await authViewModel.fetchUser()
                }
            }
        }
    }
}

// MARK: - Sport Pill View

struct SportPillView: View {
    let sport: SportCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconForSport(sport))
                    .font(.subheadline)

                Text(sport.rawValue)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, 12)
            .background(isSelected ? Theme.accentOrange : Theme.cardBackground)
            .foregroundColor(isSelected ? .white : Theme.primaryText)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Theme.accentOrange, lineWidth: 1)
            )
        }
    }

    private func iconForSport(_ sport: SportCategory) -> String {
        switch sport {
        case .football: return "soccerball"
        case .basketball: return "basketball.fill"
        case .tennis: return "tennis.racket"
        case .volleyball: return "volleyball.fill"
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        case .swimming: return "figure.pool.swim"
        case .gym: return "dumbbell.fill"
        case .other: return "sportscourt.fill"
        }
    }
}
