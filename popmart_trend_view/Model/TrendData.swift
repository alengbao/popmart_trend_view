
import SwiftUI

// 趋势数据模型
struct TrendData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let source: String
}

// 趋势输入结构体
typealias TrendInput = [TrendData]
