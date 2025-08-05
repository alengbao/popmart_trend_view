# Pop Mart 趋势分析系统

一个基于 SwiftUI 的智能趋势分析系统，用于实时监控和分析 Pop Mart 相关趋势数据，并提供智能预警功能。

## 🏗️ 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                    Pop Mart 趋势分析系统                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                    ┌─────────────┐                         │
│                    │   展示组件   │                         │
│                    │ Display     │                         │
│                    │ Component   │                         │
│                    └─────────────┘                         │
│                            ▲                               │
│                            │                               │
│                    ┌─────────────┐                         │
│                    │ 趋势获取器   │                         │
│                    │ Trend       │                         │
│                    │ Fetchers    │                         │
│                    └─────────────┘                         │
│                            ▲                               │
│                            │                               │
│         ┌───────────────────┼───────────────────┐           │
│         │                   │                   │           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │   策略中心   │    │   消息中心   │    │   数据源     │    │
│  │ Strategy    │    │ Message     │    │ Data        │    │
│  │ Center      │    │ Center      │    │ Sources     │    │
│  └─────────────┘    └─────────────┘    └─────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**数据流向**:
```
数据源 → 趋势获取器 → 策略中心 → 消息中心 → 展示组件
```

## 📁 项目结构

```
popmart_trend_view/
├── popmart_trend_view/
│   ├── Assets.xcassets/           # 应用资源
│   ├── ContentView.swift          # 主界面视图
│   ├── popmart_trend_viewApp.swift # 应用入口
│   ├── Model/                     # 数据模型
│   │   ├── MessageModels.swift    # 消息模型
│   │   └── TrendData.swift        # 趋势数据模型
│   └── TrendFetcher/              # 趋势获取器
│       ├── TrendFetcherProtocol.swift # 趋势获取协议
│       ├── GoogleTrendsFetcher.swift  # 谷歌趋势获取器
│       ├── BaiduTrendsFetcher.swift   # 百度趋势获取器
│       ├── StrategyCenter/            # 策略中心
│       │   ├── StrategyProtocol.swift # 策略协议
│       │   └── Strategies.swift       # 策略实现
│       └── MessageCenter/             # 消息中心
│           └── MessageCenter.swift    # 消息管理器
├── popmart_trend_viewTests/        # 单元测试
├── popmart_trend_viewUITests/      # UI测试
└── README.md                       # 项目文档
```

## 📋 核心组件详解

### 1. 数据模型 (Data Models)

#### TrendData
```swift
struct TrendData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let source: String
}
```

#### MessageModels
```swift
enum MessageType: String, CaseIterable {
    case strongSell = "强烈卖出"    // 红色
    case normalSell = "普通卖出"    // 橙色
    case normalBuy = "普通买入"     // 蓝色
    case strongBuy = "强烈买入"     // 绿色
    case neutral = "中性"          // 灰色
}

struct InAppMessage: Identifiable {
    let id = UUID()
    let content: String
    let timestamp: Date
    let type: MessageType
}
```

### 2. 趋势获取器 (Trend Fetchers)

**职责**: 从数据源获取趋势数据，并将数据传递给策略中心

**核心结构**:
```swift
protocol TrendFetcher {
    func fetch() async -> [TrendData]
    func getSource() -> String
}
```

**已实现的获取器**:
- **GoogleTrendsFetcher**: 获取谷歌趋势数据
- **BaiduTrendsFetcher**: 获取百度趋势数据

**主要功能**:
- 🔄 定时自动获取趋势数据
- 👆 支持手动触发获取
- 🌐 多数据源并行获取
- ⚡ 异步处理，不阻塞UI
- 📤 将获取的数据传递给策略中心进行分析

### 3. 策略中心 (Strategy Center)

**职责**: 接收趋势获取器的数据，分析趋势数据并生成策略结果

**核心结构**:
```swift
protocol Strategy {
    var name: String { get }
    func getLevel() -> StrategyLevel
    func execute(data: [String: [TrendData]]) -> StrategyResult
}
```

**内置策略**:
- **StrongBuyStrategy**: 强烈买入信号检测
- **StrongSellStrategy**: 强烈卖出信号检测
- **NormalBuyStrategy**: 普通买入信号检测
- **NormalSellStrategy**: 普通卖出信号检测

**策略执行流程**:
```
接收趋势获取器数据 → 策略引擎分析 → 生成策略结果 → 传递给消息中心
```

### 4. 消息中心 (Message Center)

**职责**: 接收策略中心的结果，生成消息并发送通知

**核心结构**:
```swift
class MessageManager: ObservableObject {
    @Published var inAppMessages: [InAppMessage] = []
    @Published var isNotificationAuthorized = false
    
    func addInAppMessage(_ content: String, type: MessageType)
    func sendPushNotification(_ title: String, body: String)
    func processStrategyResult(_ result: StrategyResult)
}
```

**消息类型颜色方案**:
- 🔴 **强烈卖出** (红色) - 表示强烈看跌信号
- 🟠 **普通卖出** (橙色) - 表示一般看跌信号
- 🔵 **普通买入** (蓝色) - 表示一般看涨信号
- 🟢 **强烈买入** (绿色) - 表示强烈看涨信号
- ⚪ **中性** (灰色) - 表示一般信息

**主要功能**:
- 📱 推送通知发送
- 💬 应用内消息展示
- 🔔 声音和震动提醒
- 📋 消息历史记录

### 5. 展示组件 (Display Component)

**职责**: 将趋势数据可视化展示

**核心结构**:
```swift
struct ContentView: View {
    @StateObject private var manager = TrendFetcherManager()
    
    // 图表视图
    private func chartView(trendData: [TrendData]) -> some View
    // 消息行视图
    struct MessageRow: View
}
```

**主要功能**:
- 📈 多趋势曲线图展示
- 🎨 美观的图表样式
- 📱 响应式界面设计
- 🔍 数据统计信息展示

## 🔄 组件交互流程

### 1. 数据获取流程
```
数据源 (Google/Baidu)
    ↓
趋势获取器 (TrendFetchers) 获取原始数据
    ↓
策略中心 (StrategyCenter) 分析数据并生成策略结果
    ↓
消息中心 (MessageCenter) 根据策略结果生成带颜色的消息
    ↓
展示组件 (ContentView) 更新界面显示
```

### 2. 策略执行流程
```
趋势获取器从数据源获取数据
    ↓
将数据传递给策略中心
    ↓
策略中心收集所有策略并并行执行分析
    ↓
根据策略类型和等级确定消息类型
    ↓
将策略结果传递给消息中心
    ↓
消息中心处理消息并发送通知
    ↓
展示组件显示带颜色的站内信
```

### 3. 消息显示流程
```
策略中心触发策略
    ↓
确定消息类型 (强烈买入/普通买入/普通卖出/强烈卖出)
    ↓
消息中心创建带类型的 InAppMessage
    ↓
MessageRow 根据类型显示不同颜色
    ↓
用户看到颜色化的消息
```

## 🛠️ 技术栈

- **UI框架**: SwiftUI
- **图表库**: SwiftUI Charts
- **异步处理**: Swift Concurrency (async/await)
- **数据存储**: UserDefaults
- **网络请求**: URLSession
- **推送通知**: UserNotifications

## 📱 界面功能

### 主界面特性
- 📊 **趋势曲线图**: 多数据源趋势可视化
- 📈 **数据统计**: 7日均值和最新数据对比
- 🎨 **美观布局**: 紧凑的数据统计框设计
- 🔄 **实时更新**: 定时自动获取最新数据

### 消息中心特性
- 🏷️ **类型标签**: 消息类型彩色标签显示
- 🎨 **颜色编码**: 不同类型消息不同颜色
- 📋 **消息历史**: 保留最近20条消息
- 🗑️ **一键清除**: 快速清空所有消息

## 🚀 快速开始

### 1. 克隆项目
```bash
git clone [项目地址]
cd popmart_trend_view
```

### 2. 打开项目
```bash
open popmart_trend_view.xcodeproj
```

### 3. 运行项目
- 选择目标设备或模拟器
- 点击运行按钮或按 `Cmd + R`

## 🔧 配置说明

### 数据源配置
```swift
// 在 TrendFetcherManager 中配置数据源
private func setupFetchers() {
    register(GoogleTrendsFetcher())
    register(BaiduTrendsFetcher())
}
```

### 策略配置
```swift
// 在 StrategyCenter 中添加策略
private func setupStrategies() {
    register(StrongBuyStrategy())
    register(StrongSellStrategy())
    register(NormalBuyStrategy())
    register(NormalSellStrategy())
}
```

### 消息处理配置
```swift
// 在 MessageCenter 中处理策略结果
func processStrategyResult(_ result: StrategyResult) {
    let messageType = convertStrategyToMessageType(result)
    addInAppMessage(result.getMessage(), type: messageType)
    sendPushNotification(result.getTitle(), body: result.getMessage())
}

// 将策略结果转换为消息类型
private func convertStrategyToMessageType(_ result: StrategyResult) -> MessageType {
    switch (result.strategyType, result.level) {
    case (.buy, .strong): return .strongBuy
    case (.buy, .normal): return .normalBuy
    case (.sell, .strong): return .strongSell
    case (.sell, .normal): return .normalSell
    }
}
```

### 消息类型配置
```swift
// 在 MessageType 中定义颜色
var color: Color {
    switch self {
    case .strongSell: return .red
    case .normalSell: return .orange
    case .normalBuy: return .blue
    case .strongBuy: return .green
    case .neutral: return .gray
    }
}
```

## 📊 数据结构

### TrendData
```swift
struct TrendData: Identifiable {
    let id = UUID()
    let date: Date            // 时间点
    let value: Double         // 数值
    let source: String        // 数据来源
}
```

### StrategyResult
```swift
struct StrategyResult {
    let isTriggered: Bool           // 是否触发
    let strategyType: StrategyType  // 策略类型 (buy/sell)
    let message: String             // 提醒文本
    let timestamp: Date             // 触发时间
    let strategyName: String        // 策略名称
    let level: StrategyLevel        // 策略等级 (normal/strong)
}
```

### InAppMessage
```swift
struct InAppMessage: Identifiable {
    let id = UUID()
    let content: String        // 消息内容
    let timestamp: Date        // 时间戳
    let type: MessageType      // 消息类型
}
```

## 🏛️ 架构优势

### 分层设计
- **数据层**: 数据源提供原始趋势数据
- **获取层**: 趋势获取器统一获取和管理数据
- **分析层**: 策略中心负责数据分析和策略执行
- **通知层**: 消息中心处理消息生成和通知发送
- **展示层**: 展示组件负责数据可视化

### 职责分离
- **趋势获取器**: 专注于数据获取，不关心业务逻辑
- **策略中心**: 专注于数据分析，不关心消息处理
- **消息中心**: 专注于消息管理，不关心数据获取
- **展示组件**: 专注于界面展示，不关心数据处理

### 数据流清晰
```
数据源 → 趋势获取器 → 策略中心 → 消息中心 → 展示组件
```

每个组件都有明确的输入和输出，便于测试和维护。

## 🔮 未来规划

- [ ] 更新曲线图，使其可交互
- [ ] 机器学习趋势预测
- [ ] 更多数据源集成 (微博、抖音等)
- [ ] 自定义策略配置界面
- [ ] 数据导出功能
- [ ] 多语言支持
- [ ] 深色模式优化
- [ ] 消息过滤和搜索功能
- [ ] 策略回测功能

## 📄 许可证

MIT License

---

**Pop Mart 趋势分析系统** - 让数据洞察更简单 📈
