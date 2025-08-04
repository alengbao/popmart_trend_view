import Foundation

// MARK: - 策略类型枚举
enum StrategyType {
    case buy      // 买入信号
    case sell     // 卖出信号
}

// MARK: - 策略等级枚举
enum StrategyLevel {
    case normal   // 普通
    case strong   // 强烈
}

// MARK: - 策略结果结构
struct StrategyResult {
    let isTriggered: Bool           // 是否触发
    let strategyType: StrategyType  // 策略类型
    let message: String             // 提醒文本
    let timestamp: Date             // 触发时间
    let strategyName: String        // 策略名称
    let level: StrategyLevel        // 策略等级

    func getTitle() -> String {
        return strategyName
    }
    func getMessage() -> String {
        return message
    }
}

// MARK: - 策略协议
protocol Strategy {
    /// 策略名称
    var name: String { get }
    
    /// 获取策略等级
    func getLevel() -> StrategyLevel
    
    /// 执行策略分析
    /// - Parameter data: 趋势数据，key为数据来源，value为该来源的数据序列
    /// - Returns: 策略结果
    func execute(data: [String: [TrendData]]) -> StrategyResult
}

// MARK: - 策略管理中心
class StrategyCenter: ObservableObject {
    @Published var strategyResults: [StrategyResult] = []
    
    // 按等级分组的策略
    private var strongStrategies: [Strategy] = []
    private var normalStrategies: [Strategy] = []
    
    // 策略触发记录，用于防止重复触发
    // key: StrategyType, value: (level: StrategyLevel, timestamp: Date)
    private var triggerHistory: [StrategyType: (level: StrategyLevel, timestamp: Date)] = [:]
    private let triggerCooldown: TimeInterval = 30 * 60 // 30分钟冷却时间
    
    init() {
        setupStrategies()
    }
    
    // MARK: - 策略注册
    private func setupStrategies() {
        // 注册所有策略
        register(StrongBuyStrategy())
        register(StrongSellStrategy())
        register(NormalBuyStrategy())
        register(NormalSellStrategy())
    }
    
    func register(_ strategy: Strategy) {
        let level = strategy.getLevel()
        switch level {
        case .strong:
            strongStrategies.append(strategy)
            print("📊 注册强烈策略: \(strategy.name)")
        case .normal:
            normalStrategies.append(strategy)
            print("📊 注册普通策略: \(strategy.name)")
        }
    }
    
    // MARK: - 策略执行
    func runStrategies(data: [String: [TrendData]]) -> [StrategyResult] {
        print("🚀 开始执行策略分析...")
        
        var results: [StrategyResult] = []
        
        // 1. 先执行强烈策略
        print("🔥 执行强烈策略...")
        let strongResults = executeStrategyGroup(strongStrategies, data: data)
        results.append(contentsOf: strongResults)
        
        // 2. 再执行普通策略
        print("📈 执行普通策略...")
        let normalResults = executeStrategyGroup(normalStrategies, data: data)
        results.append(contentsOf: normalResults)
        
        print("✅ 策略分析完成，共触发 \(results.count) 个策略")
        return results
    }
    
    // MARK: - 策略组执行
    private func executeStrategyGroup(_ strategies: [Strategy], data: [String: [TrendData]]) -> [StrategyResult] {
        var results: [StrategyResult] = []
        
        for strategy in strategies {
            let result = strategy.execute(data: data)
            
            if result.isTriggered {
                // 检查是否在冷却期内
                if shouldTriggerStrategy(result.strategyType, result.level) {
                    results.append(result)
                    updateTriggerHistory(result.strategyType, result.level)
                    print("🎯 策略触发: \(result.strategyName) - \(result.message)")
                } else {
                    print("⏰ 策略被冷却期阻止: \(result.strategyName)")
                }
            }
        }
        
        return results
    }
    
    // MARK: - 冷却期管理
    private func shouldTriggerStrategy(_ type: StrategyType, _ level: StrategyLevel) -> Bool {
        guard let (lastLevel, lastTriggerTime) = triggerHistory[type] else {
            return true // 没有触发记录，可以触发
        }
        
        let timeSinceLastTrigger = Date().timeIntervalSince(lastTriggerTime)
        let isInCooldown = timeSinceLastTrigger < triggerCooldown
        
        if isInCooldown {
            // 在冷却期内，检查等级
            switch level {
            case .strong:
                // 强烈信号：只有在之前触发的是普通信号时才允许触发
                return lastLevel == .normal
            case .normal:
                // 普通信号：直接阻止
                return false
            }
        }
        
        return true // 不在冷却期内，可以触发
    }
    
    private func updateTriggerHistory(_ type: StrategyType, _ level: StrategyLevel) {
        triggerHistory[type] = (level: level, timestamp: Date())
    }
}
