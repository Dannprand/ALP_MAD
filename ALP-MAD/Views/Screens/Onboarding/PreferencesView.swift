//
//  PreferencesView.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

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
                    
                    FlowLayout(spacing: 10) {
                        ForEach(SportCategory.allCases, id: \.self) { sport in
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
                
                // Notification preferences
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notifications")
                        .font(.headline)
                        .foregroundColor(Theme.primaryText)
                    
                    Toggle("Enable notifications for nearby events", isOn: $notificationEnabled)
                        .tint(Theme.accentOrange)
                }
                .padding(.horizontal)
                
                // Search radius
                VStack(alignment: .leading, spacing: 12) {
                    Text("Search Radius")
                        .font(.headline)
                        .foregroundColor(Theme.primaryText)
                    
                    HStack {
                        Text("\(Int(radius)) km")
                            .frame(width: 60, alignment: .leading)
                            .foregroundColor(Theme.accentOrange)
                        
                        Slider(value: $radius, in: 5...100, step: 5) {
                            Text("Search radius")
                        } minimumValueLabel: {
                            Text("5")
                                .font(.caption)
                                .foregroundColor(Theme.secondaryText)
                        } maximumValueLabel: {
                            Text("100")
                                .font(.caption)
                                .foregroundColor(Theme.secondaryText)
                        }
                        .tint(Theme.accentOrange)
                    }
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
                .buttonStyle(PrimaryButtonStyle())
                .disabled(selectedSports.isEmpty || isSaving)
                .padding()
                
                Spacer()
            }
            .padding(.vertical)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
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
                // Update local user object
                Task {
                    await authViewModel.fetchUser()
                }
            }
        }
    }
}

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
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
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

enum SkillLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case professional = "Professional"
}

// Custom layout for tags that wrap to next line
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for size in sizes {
            if lineWidth + size.width + spacing > proposal.width ?? 0 {
                totalHeight += lineHeight + spacing
                totalWidth = max(totalWidth, lineWidth)
                lineWidth = 0
                lineHeight = 0
            }
            
            lineWidth += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        totalHeight += lineHeight
        totalWidth = max(totalWidth, lineWidth)
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var point = CGPoint(x: bounds.minX, y: bounds.minY)
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if point.x + size.width > (proposal.width ?? 0) {
                point.x = bounds.minX
                point.y += lineHeight + spacing
                lineHeight = 0
            }
            
            subview.place(
                at: point,
                proposal: ProposedViewSize(size)
            )
            
            point.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
