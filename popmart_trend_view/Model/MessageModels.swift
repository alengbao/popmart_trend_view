import Foundation
import SwiftUI

// 站内信模型
struct InAppMessage: Identifiable {
    let id = UUID()
    let content: String
    let timestamp: Date
    
    init(content: String) {
        self.content = content
        self.timestamp = Date()
    }
}
