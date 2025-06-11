//

//  EventCard.swift

//  ALP-MAD

//

//  Created by student on 22/05/25.

//



import SwiftUI



struct EventCard: View {

    let event: Event

    

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            // Event image

            ZStack(alignment: .topTrailing) {

                Image(event.sport.rawValue.lowercased())

                    .resizable()

                    .scaledToFill()

                    .frame(width: 220, height: 120)

                    .clipped()

                

                if event.isFeatured {

                    Text("Featured")

                        .font(.caption)

                        .fontWeight(.bold)

                        .padding(.horizontal, 8)

                        .padding(.vertical, 4)

                        .background(Theme.accentOrange)

                        .foregroundColor(.white)

                        .clipShape(Capsule())

                        .padding(8)

                }

            }

            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            

            // Event details

            VStack(alignment: .leading, spacing: 4) {

                Text(event.title)

                    .font(.headline)

                    .foregroundColor(Theme.primaryText)

                    .lineLimit(1)

                

                HStack(spacing: 4) {

                    Image(systemName: "calendar")

                        .font(.caption)

                    Text(event.date.dateValue().formatted(date: .abbreviated, time: .omitted))

                        .font(.caption)



                    

                    Image(systemName: "clock")

                        .font(.caption)

                    Text(event.date.dateValue().formatted(date: .omitted, time: .shortened))

                        .font(.caption)

                }

                .foregroundColor(Theme.secondaryText)

                

                HStack(spacing: 4) {

                    Image(systemName: "mappin.and.ellipse")

                        .font(.caption)

                    Text(event.location.name)

                        .font(.caption)

                        .lineLimit(1)

                }

                .foregroundColor(Theme.secondaryText)

                

                HStack {

                    HStack(spacing: 2) {

                        Image(systemName: "person.2.fill")

                            .font(.caption)

                        Text("\(event.participants.count)/\(event.maxParticipants)")

                            .font(.caption)

                    }

                    

                    Spacer()

                    

                    if let prize = event.prizePool {

                        HStack(spacing: 2) {

                            Image(systemName: "trophy.fill")

                                .font(.caption)

                            Text(prize)

                                .font(.caption)

                        }

                    }

                }

                .foregroundColor(Theme.accentOrange)

            }

            .padding(.horizontal, 8)

            .padding(.bottom, 8)

        }

        .frame(width: 220)

        .background(Theme.cardBackground)

        .cornerRadius(12)

        .overlay(

            RoundedRectangle(cornerRadius: 12)

                .stroke(Theme.accentOrange.opacity(0.3), lineWidth: 1)

        )

    }

}
