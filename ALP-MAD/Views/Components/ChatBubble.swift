//
//  ChatBubble.swift
//  ALP-MAD
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }

            VStack(alignment: .leading, spacing: 4) {
                Text(message.senderName)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(message.text)
                    .padding(10)
                    .background(isCurrentUser ? Theme.accentOrange : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(12)

                Text(message.timeString)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
            .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)

            if !isCurrentUser { Spacer() }
        }
        .padding(isCurrentUser ? .leading : .trailing, 50)
        .padding(.vertical, 2)
    }
}
