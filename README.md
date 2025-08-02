# Pop Mart 趋势分析系统

一个基于 SwiftUI 的智能趋势分析系统，用于实时监控和分析 Pop Mart 相关趋势数据，并提供智能预警功能。

## 🏗️ 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                    Pop Mart 趋势分析系统                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │   消息组件   │    │   展示组件   │    │   策略组件   │    │
│  │ Message     │    │ Display     │    │ Strategy    │    │
│  │ Component   │    │ Component   │    │ Component   │    │
│  └─────────────┘    └─────────────┘    └─────────────┘    │
│         │                   │                   │           │
│         │                   │                   │           │
│         └───────────────────┼───────────────────┘           │
│                             │                               │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │   核心组件   │◄───┤ 趋势获取组件 │    │   数据源     │    │
│  │ Core        │    │ Trend       │    │ Data        │    │
│  │ Component   │    │ Fetcher     │    │ Sources     │    │
│  └─────────────┘    └─────────────┘    └─────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 📋 组件详解

### 1. 核心组件 (Core Component)

**职责**: 数据存储和管理的中央枢纽

**核心结构**:
```swift
struct CoreComponent {
    // 趋势数据存储 - Map结构
    // Key: 数据来源标识 (如 "sales", "social", "inventory")
    // Value: 对应的趋势数据
    private var trendDataMap: [String: TrendInput] = [:]
    
    // 数据更新通知
    private var updateCallbacks: [() -> Void] = []
}
```

**主要功能**:
- 📊 统一管理所有趋势数据
- 🔄 提供数据更新接口
- 📡 通知其他组件数据变化
- 🗂️ 数据持久化存储

**数据流**:
```
趋势获取组件 → 核心组件 → 展示组件/策略组件
```

### 2. 趋势获取组件 (Trend Fetcher Component)

**职责**: 异步获取各类趋势数据

**核心结构**:
```swift
class TrendFetcher {
    // 异步获取任务
    private var fetchTasks: [String: Task<Void, Never>] = [:]
    
    // 定时器管理
    private var timers: [String: Timer] = [:]
    
    // 数据源配置
    private let dataSources: [DataSource]
}
```

**主要功能**:
- 🔄 定时自动获取趋势数据
- 👆 支持手动触发获取
- 🌐 多数据源并行获取
- ⚡ 异步处理，不阻塞UI

**获取策略**:
- **定时获取**: 每5分钟自动获取一次
- **手动获取**: 用户点击刷新按钮
- **智能获取**: 根据数据变化频率调整获取间隔

### 3. 展示组件 (Display Component)

**职责**: 将趋势数据可视化展示

**核心结构**:
```swift
struct TrendDisplayView: View {
    @ObservedObject var coreComponent: CoreComponent
    @State private var selectedTrend: String?
    @State private var selectedPoint: TrendData?
}
```

**主要功能**:
- 📈 多趋势曲线图展示
- 🔍 支持长按查看数据点详情
- 📱 响应式界面设计
- 🎨 美观的图表样式

**交互功能**:
- **长按图表**: 查看具体数据点的时间和数值
- **切换趋势**: 在不同数据源之间切换
- **缩放查看**: 支持图表缩放和拖拽

### 4. 策略组件 (Strategy Component)

**职责**: 分析趋势数据并触发预警

**核心结构**:
```swift
protocol TrendStrategy {
    func analyze(trendData: TrendInput) -> StrategyResult
}

class StrategyEngine {
    private var strategies: [TrendStrategy] = []
    
    func runStrategies(trendData: [String: TrendInput]) -> [AlertMessage]
}
```

**内置策略**:
- 📈 **上升趋势检测**: 检测销量快速上升
- 📉 **下降趋势检测**: 检测销量异常下降
- 🎯 **目标达成检测**: 检测是否达到销售目标
- ⚠️ **异常波动检测**: 检测数据异常波动

**策略执行流程**:
```
趋势数据更新 → 策略引擎分析 → 生成预警消息 → 发送给消息组件
```

### 5. 消息组件 (Message Component)

**职责**: 消息发送和展示

**核心结构**:
```swift
struct AlertMessage {
    let id: UUID
    let title: String
    let content: String
    let level: AlertLevel
    let timestamp: Date
    let trendSource: String
}

class MessageManager {
    private var messages: [AlertMessage] = []
    private var notificationService: NotificationService
}
```

**主要功能**:
- 📱 推送通知发送
- 💬 应用内消息展示
- 🔔 声音和震动提醒
- 📋 消息历史记录

## 🔄 组件交互流程

### 1. 数据获取流程
```
用户操作/定时器触发
    ↓
趋势获取组件启动异步任务
    ↓
并行获取多个数据源
    ↓
数据传入核心组件
    ↓
核心组件更新存储并通知其他组件
    ↓
展示组件更新界面
    ↓
策略组件分析数据
    ↓
生成预警消息
    ↓
消息组件发送通知
```

### 2. 用户交互流程
```
用户长按图表
    ↓
展示组件获取点击位置
    ↓
计算最近的数据点
    ↓
显示数据点详情弹窗
```

### 3. 策略执行流程
```
趋势数据更新
    ↓
策略引擎收集所有策略
    ↓
并行执行策略分析
    ↓
汇总分析结果
    ↓
生成预警消息
    ↓
消息组件处理消息
```

## 🛠️ 技术栈

- **UI框架**: SwiftUI
- **图表库**: SwiftUI Charts
- **异步处理**: Swift Concurrency (async/await)
- **数据存储**: Core Data / UserDefaults
- **网络请求**: URLSession
- **推送通知**: UserNotifications

## 📱 界面预览

### 主界面
- 趋势曲线图展示
- 多数据源切换
- 实时数据更新
- 交互式图表操作

### 消息中心
- 预警消息列表
- 消息详情查看
- 消息状态管理
- 历史记录浏览

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
// 在 TrendFetcher 中配置数据源
let dataSources = [
    DataSource(name: "sales", url: "api/sales/trend"),
    DataSource(name: "social", url: "api/social/trend"),
    DataSource(name: "inventory", url: "api/inventory/trend")
]
```

### 策略配置
```swift
// 在 StrategyEngine 中添加策略
let strategies: [TrendStrategy] = [
    RisingTrendStrategy(),
    FallingTrendStrategy(),
    TargetAchievementStrategy(),
    AnomalyDetectionStrategy()
]
```

## 📊 数据结构

### TrendInput
```swift
struct TrendInput {
    let name: String           // 趋势名称
    let data: [TrendData]      // 趋势数据点
    let source: String         // 数据来源
    let lastUpdate: Date       // 最后更新时间
}
```

### TrendData
```swift
struct TrendData: Identifiable {
    let id = UUID()
    let date: Date            // 时间点
    let value: Double         // 数值
    let metadata: [String: Any]? // 额外元数据
}
```

## 🔮 未来规划

- [ ] 机器学习趋势预测
- [ ] 更多数据源集成
- [ ] 自定义策略配置
- [ ] 数据导出功能
- [ ] 多语言支持
- [ ] 深色模式优化

## 📄 许可证

MIT License

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

---

**Pop Mart 趋势分析系统** - 让数据洞察更简单 📈
