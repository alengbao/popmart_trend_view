//
//  ContentView.swift
//  popmart_trend_view
//
//  Created by hong on 2025/7/31.
//

import SwiftUI
import Charts
import UserNotifications

struct ContentView: View {
    @StateObject private var manager = TrendFetcherManager()
    @StateObject private var messageManager = MessageManager()
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题
            Text("趋势分析")
                .font(.title)
                .fontWeight(.bold)
            
            // 测试按钮
            HStack {
                Button("测试爬取") {
                    Task {
                        await testBaiduIndex()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            
            // 站内信列表
            if !messageManager.inAppMessages.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("站内信")
                            .font(.headline)
                        Spacer()
                        Text("\(messageManager.inAppMessages.count) 条")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(messageManager.inAppMessages) { message in
                                MessageRow(message: message)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 150)
                }
            }
            
            // 图表
            if !manager.trendResults.isEmpty {
                chartView(trendData: manager.trendResults.values.flatMap { $0 })
            } else {
                Text("暂无数据")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .onAppear {
            manager.startPeriodicFetch(interval: 300)
            messageManager.requestNotificationPermission()
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
    
    // 测试百度指数爬取
    private func testBaiduIndex() async {
        await BaiduTrendsFetcher.testFetch()
        
        DispatchQueue.main.async {
            messageManager.addInAppMessage("百度指数测试完成")
        }
    }
}

// 站内信行视图
struct MessageRow: View {
    let message: InAppMessage
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                Text(message.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    ContentView()
}
