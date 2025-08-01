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
}

// 趋势输入结构体
struct TrendInput {
    let name: String
    let data: [TrendData]
}

struct ContentView: View {
    // 接收外部传入的趋势数据
    let trendInput: TrendInput?
    @State private var selectedPoint: TrendData?
    @State private var showingDetail = false
    
    // 初始化方法，接收趋势数据
    init(trendInput: TrendInput? = nil) {
        self.trendInput = trendInput
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                Text("Pop Mart 趋势分析")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                
                // 趋势信息显示
                if let trendInput = trendInput {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("趋势名称: \(trendInput.name)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("数据点数量: \(trendInput.data.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // 曲线图
                    if !trendInput.data.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(trendInput.name) 趋势曲线")
                                .font(.headline)
                            
                            Chart(trendInput.data) { data in
                                LineMark(
                                    x: .value("时间", data.date),
                                    y: .value("数值", data.value)
                                )
                                .foregroundStyle(.purple)
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                
                                PointMark(
                                    x: .value("时间", data.date),
                                    y: .value("数值", data.value)
                                )
                                .foregroundStyle(.purple)
                                .symbolSize(50)
                            }
                            .frame(height: 300)
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { value in
                                    AxisGridLine()
                                    AxisValueLabel(format: .dateTime.day().month())
                                }
                            }
                            .chartYAxis {
                                AxisMarks { value in
                                    AxisGridLine()
                                    AxisValueLabel()
                                }
                            }
                            .onTapGesture { location in
                                // 处理点击事件，选择最近的数据点
                                handleChartTap(at: location, data: trendInput.data)
                            }
                            .gesture(
                                LongPressGesture(minimumDuration: 0.5)
                                    .onEnded { _ in
                                        showingDetail = true
                                    }
                            )
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        
                        // 数据点列表
                        VStack(alignment: .leading, spacing: 10) {
                            Text("数据点详情")
                                .font(.headline)
                            
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 5) {
                                    ForEach(trendInput.data) { data in
                                        HStack {
                                            Text(data.date, style: .date)
                                                .font(.subheadline)
                                            Spacer()
                                            Text(String(format: "%.2f", data.value))
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(5)
                                    }
                                }
                            }
                            .frame(maxHeight: 150)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                    } else {
                        // 空数据状态
                        VStack(spacing: 20) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("暂无趋势数据")
                                .font(.title2)
                                .foregroundColor(.gray)
                            
                            Text("请传入有效的趋势数据")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    // 无数据传入状态
                    VStack(spacing: 20) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("等待趋势数据")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("请传入 TrendInput 结构体")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // 示例代码
                        VStack(alignment: .leading, spacing: 5) {
                            Text("使用示例:")
                                .font(.caption)
                                .fontWeight(.bold)
                            Text("ContentView(trendInput: yourTrendInput)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(5)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("趋势分析")
            .alert("数据点详情", isPresented: $showingDetail) {
                Button("确定") { }
            } message: {
                if let selectedPoint = selectedPoint {
                    Text("时间: \(selectedPoint.date, style: .date)\n数值: \(String(format: "%.2f", selectedPoint.value))")
                }
            }
        }
    }
    
    private func handleChartTap(at location: CGPoint, data: [TrendData]) {
        // 简化版本：选择最后一个数据点
        // 在实际应用中，这里可以根据点击位置计算最近的数据点
        if let lastData = data.last {
            selectedPoint = lastData
        }
    }
}

// 示例数据生成器（用于测试）
struct TrendDataGenerator {
    static func generateSampleTrend() -> TrendInput {
        let calendar = Calendar.current
        let today = Date()
        
        var sampleData: [TrendData] = []
        
        // 生成过去30天的示例数据
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let value = Double.random(in: 10...100) // 随机数值
                sampleData.append(TrendData(date: date, value: value))
            }
        }
        
        // 按日期排序
        sampleData.sort { $0.date < $1.date }
        
        return TrendInput(name: "示例趋势", data: sampleData)
    }
}

#Preview {
    // 预览时使用示例数据
    ContentView(trendInput: TrendDataGenerator.generateSampleTrend())
}
