//
//  ContentView.swift
//  popmart_trend_view
//
//  Created by hong on 2025/7/31.
//

import SwiftUI
import Charts

// 趋势数据模型
struct TrendData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let name: String
}

// 趋势输入结构体
typealias TrendInput = [TrendData]

struct ContentView: View {
    var trendInput: TrendInput?

    
    init(trendInput: TrendInput? = nil) {
        self.trendInput = trendInput
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("趋势分析")
                .font(.title)
                .fontWeight(.bold)
            
            // 图表
            if let trendInput = trendInput {
                chartView(trendInput: trendInput)
            } else {
                Text("暂无数据")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
    
    // 图表视图
    private func chartView(trendInput: TrendInput) -> some View {
        
        return Chart(trendInput) {
            LineMark(
                x: .value("时间", $0.date),
                y: .value("数值", $0.value)
            )
            .foregroundStyle(by:.value("name", $0.name))
            .lineStyle(StrokeStyle(lineWidth: 2))
        }
        .frame(height: 300)
    }
}

// 公共接口
extension ContentView {
    
    func addTrendData(name: String, data: [TrendData]) {
        print("➕ 请求添加趋势数据")
        print("📝 趋势名称: \(name)")
        print("📊 数据点数量: \(data.count)")
        print("⚠️ 注意: 当前实现不支持动态添加，需要重新创建视图")
    }
}

// 示例数据
struct TrendDataGenerator {
    static func generateSampleTrend() -> TrendInput {
        print("🔄 开始生成示例数据...")
        
        let calendar = Calendar.current
        let today = Date()
        
        var result: [TrendData] = []
        
        for i in 0..<60 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let googleValue = Double.random(in: 60...120)
                let baiduValue = Double.random(in: 40...180)
                let douyinValue = Double.random(in: 80...200)
                
                result.append(TrendData(date: date, value: googleValue, name: "谷歌趋势"))
                result.append(TrendData(date: date, value: baiduValue,name: "百度指数"))
                result.append(TrendData(date: date, value: douyinValue, name: "抖音指数"))
                
            }
        }
        return result
    }
}

#Preview {
    return ContentView(trendInput: TrendDataGenerator.generateSampleTrend())
}
