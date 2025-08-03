//
//  ContentView.swift
//  popmart_trend_view
//
//  Created by hong on 2025/7/31.
//

import SwiftUI
import Charts


struct ContentView: View {
    @StateObject private var manager = TrendFetcherManager()
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("趋势分析")
                .font(.title)
                .fontWeight(.bold)
            
            // 图表
            if !manager.trendResults.isEmpty {
                chartView(trendData: manager.trendResults)
            } else {
                Text("暂无数据")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .onAppear {
            manager.startPeriodicFetch(interval: 10)
        }
    }
    
    // 图表视图
    private func chartView(trendData: [TrendData]) -> some View {
        return Chart(trendData) {
            LineMark(
                x: .value("时间", $0.date),
                y: .value("数值", $0.value)
            )
            .foregroundStyle(by:.value("source", $0.source))
            .lineStyle(StrokeStyle(lineWidth: 2))
        }
        .frame(height: 300)
    }
}


#Preview {
    ContentView()
}
