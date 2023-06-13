//
//  NotiModel.swift
//  NotificationRxSwift
//
//  Created by Long Tran on 08/06/2023.
//

import Foundation

struct NotiModel: Codable {
    let data: [Noti]
}

// MARK: - Noti
struct Noti: Codable {
    let id, type: String
    let title: String
    let message: Message
    let image: String
    let icon: String
    let status: String
    let subscription: Subscription?
    let readAt, createdAt, updatedAt, receivedAt: Int
    let imageThumb: String
    let animation: String
    let tracking: String?
    let subjectName: String
    let isSubscribed: Bool
}

// MARK: - Message
struct Message: Codable {
    let text: String
    let highlights: [Highlight]
}

// MARK: - Highlight
struct Highlight: Codable {
    let offset, length: Int
}

// MARK: - Subscription
struct Subscription: Codable {
    let targetID: String
    let targetType: TargetType
    let targetName: String?
    let level: Int

    enum CodingKeys: String, CodingKey {
        case targetID = "targetId"
        case targetType, targetName, level
    }
}

enum TargetType: String, Codable {
    case group = "group"
    case post = "post"
    case user = "user"
}
