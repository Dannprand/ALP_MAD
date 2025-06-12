//
//  PreferencesView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI
import FirebaseFirestore
import Foundation

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
                // Header
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

                // Favorite sports
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
                            sportPill(for: sport)
                        }
                    }
                }
                .padding(.horizontal)

                // Skill level
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

                // Save button
                Button(action: savePreferences) {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Save Preferences")
                    }
                }
//                .buttonStyle(PrimaryButtonStyle())
                .disabled(selectedSports.isEmpty || isSaving)
                .padding()

                Spacer()
            }
            .padding(.vertical)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Helper Function
    @ViewBuilder
    private func sportPill(for sport: SportCategory) -> some View {
        SportPill(
            sport: sport,
            isSelected: selectedSports.contains(sport)
        ) {
            if selectedSports.contains(sport) {
                selectedSports.removeAll { $0 == sport }
            } else {
                selectedSports.append(sport)
            }
        }
        .frame(height: 50)
    }

    // MARK: - Save to Firestore
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
                // Update local user object
                Task {
                    await authViewModel.fetchUser()
                }
            }
        }
    }
}

// MARK: - Sport Pill Component

struct SportPill: View {
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
