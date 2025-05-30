import SwiftUI

struct EventRowView: View {
    let event: Event

    var body: some View {
        HStack(spacing: 12) {
            Image(event.sport.rawValue.lowercased())
                .resizable()
                .frame(width: 80, height: 80)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(Theme.primaryText)
                Text(event.timeRemaining)
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
                Text("\(event.participants.count)/\(event.maxParticipants) joined")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}
