import SwiftUI

struct EventCard: View {
    let event: Event
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Event image with overlay if expired
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .center) {
                    Image(event.sport.rawValue.lowercased())
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 120)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
                    if event.isExpired {
                        Color.black.opacity(0.5)
                        Text("Expired")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
                
                if event.isFeatured && !event.isExpired {
                    Text("Featured")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.accentOrange)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(8)
                }
            }
            
            // Event details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(event.isExpired ? Theme.secondaryText : Theme.primaryText)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if onDelete != nil {
                        Button(action: {
                            onDelete?()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                        }
                    }
                }
                
                HStack(spacing: 6) {
                    Label {
                        Text(event.date.dateValue().formatted(date: .abbreviated, time: .omitted))
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    
                    Label {
                        Text(event.date.dateValue().formatted(date: .omitted, time: .shortened))
                    } icon: {
                        Image(systemName: "clock")
                    }
                }
                .font(.caption)
                .foregroundColor(event.isExpired ? Theme.secondaryText.opacity(0.7) : Theme.secondaryText)
                
                Label(event.location.name, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(event.isExpired ? Theme.secondaryText.opacity(0.7) : Theme.secondaryText)
                
                HStack {
                    Label("\(event.participants.count)/\(event.maxParticipants)", systemImage: "person.2.fill")
                        .font(.caption)
                    
                    Spacer()
                    
                    if let prize = event.prizePool, !event.isExpired {
                        Label(prize, systemImage: "trophy.fill")
                            .font(.caption)
                    }
                    
                    if !event.isExpired {
                        Text(event.expiryStatus)
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                .foregroundColor(event.isExpired ? .gray : Theme.accentOrange)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: 220)
        .background(Theme.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(event.isExpired ? Color.gray : Theme.accentOrange.opacity(0.3), lineWidth: 1)
        )
    }
}
