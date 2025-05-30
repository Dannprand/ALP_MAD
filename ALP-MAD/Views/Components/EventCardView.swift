import SwiftUI

struct EventCardView: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(event.sport.rawValue.lowercased())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 120)
                .clipped()
                .cornerRadius(12)

            Text(event.title)
                .font(.headline)
                .foregroundColor(Theme.primaryText)
            Text(event.timeRemaining)
                .font(.caption)
                .foregroundColor(Theme.secondaryText)
        }
        .frame(width: 200)
        .background(Theme.cardBackground)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
