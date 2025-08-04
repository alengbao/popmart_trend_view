import Foundation
import SwiftUI

// 消息类型枚举
enum MessageType: String, CaseIterable {
    case strongSell = "强烈卖出"
    case normalSell = "普通卖出"
    case normalBuy = "普通买入"
    case strongBuy = "强烈买入"
    case neutral = "中性"
    
    var color: Color {
        switch self {
        case .strongSell:
            return .red
        case .normalSell:
            return .orange
        case .normalBuy:
            return .blue
        case .strongBuy:
            return .green
        case .neutral:
            return .gray
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .strongSell:
            return .red.opacity(0.1)
        case .normalSell:
            return .orange.opacity(0.1)
        case .normalBuy:
            return .blue.opacity(0.1)
        case .strongBuy:
            return .green.opacity(0.1)
        case .neutral:
            return .gray.opacity(0.1)
        }
    }
}

// 站内信模型
struct InAppMessage: Identifiable {
    let id = UUID()
    let content: String
    let timestamp: Date
    let type: MessageType
    
    init(content: String, type: MessageType = .neutral) {
        self.content = content
        self.timestamp = Date()
        self.type = type
    }
}
