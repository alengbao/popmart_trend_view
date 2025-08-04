import Foundation

// MARK: - 强烈买入策略
class StrongBuyStrategy: Strategy {
    let name = "强烈买入信号"
    
    func getLevel() -> StrategyLevel {
        return .strong
    }
    
    func execute(data: [String: [TrendData]]) -> StrategyResult {
        // 获取谷歌趋势数据
        let googleData = data["谷歌趋势"] ?? []
        
        guard !googleData.isEmpty else {
            return StrategyResult(
                isTriggered: false,
                strategyType: .buy,
                message: "谷歌趋势数据不足，无法分析",
                timestamp: Date(),
                strategyName: name,
                level: .strong
            )
        }
        
        // 按日期排序
        let sortedData = googleData.sorted { $0.date < $1.date }
        
        // 获取最近7天的数据
        let recentData = Array(sortedData.suffix(7))
        
        guard recentData.count >= 7 else {
            return StrategyResult(
                isTriggered: false,
                strategyType: .buy,
                message: "数据点不足，需要至少7个数据点",
                timestamp: Date(),
                strategyName: name,
                level: .strong
            )
        }
        
        // 计算7日均值
        let values = recentData.map { $0.value }
        let sevenDayAverage = values.reduce(0, +) / Double(values.count)
        let latestValue = values.last ?? 0
        
        // 计算涨幅百分比
        let increasePercentage = ((latestValue - sevenDayAverage) / sevenDayAverage) * 100
        
        // 强烈买入条件：最新数据超过7日均值80%
        if increasePercentage > 80 {
            return StrategyResult(
                isTriggered: true,
                strategyType: .buy,
                message: "强烈买入信号！最新数据(\(String(format: "%.1f", latestValue)))超过7日均值(\(String(format: "%.1f", sevenDayAverage)))\(String(format: "%.1f", increasePercentage))%",
                timestamp: Date(),
                strategyName: name,
                level: .strong
            )
        }
        
        return StrategyResult(
            isTriggered: false,
            strategyType: .buy,
            message: "不满足强烈买入条件，涨幅: \(String(format: "%.1f", increasePercentage))%",
            timestamp: Date(),
            strategyName: name,
            level: .strong
        )
    }
}

// MARK: - 强烈卖出策略
class StrongSellStrategy: Strategy {
    let name = "强烈卖出信号"
    
    func getLevel() -> StrategyLevel {
        return .strong
    }
    
    func execute(data: [String: [TrendData]]) -> StrategyResult {
        // 获取谷歌趋势数据
        let googleData = data["谷歌趋势"] ?? []
        
        guard !googleData.isEmpty else {
            return StrategyResult(
                isTriggered: false,
                strategyType: .sell,
                message: "谷歌趋势数据不足，无法分析",
                timestamp: Date(),
                strategyName: name,
                level: .strong
            )
        }
        
        // 按日期排序
        let sortedData = googleData.sorted { $0.date < $1.date }
        
        // 获取最近7天的数据
        let recentData = Array(sortedData.suffix(7))
        
        guard recentData.count >= 7 else {
            return StrategyResult(
                isTriggered: false,
                strategyType: .sell,
                message: "数据点不足，需要至少7个数据点",
                timestamp: Date(),
                strategyName: name,
                level: .strong
            )
        }
        
        // 计算7日均值
        let values = recentData.map { $0.value }
        let sevenDayAverage = values.reduce(0, +) / Double(values.count)
        let latestValue = values.last ?? 0
        
        // 计算跌幅百分比
        let decreasePercentage = ((sevenDayAverage - latestValue) / sevenDayAverage) * 100
        
        // 强烈卖出条件：最新数据低于7日均值80%
        if decreasePercentage > 80 {
            return StrategyResult(
                isTriggered: true,
                strategyType: .sell,
                message: "强烈卖出信号！最新数据(\(String(format: "%.1f", latestValue)))低于7日均值(\(String(format: "%.1f", sevenDayAverage)))\(String(format: "%.1f", decreasePercentage))%",
                timestamp: Date(),
                strategyName: name,
                level: .strong
            )
        }
        
        return StrategyResult(
            isTriggered: false,
            strategyType: .sell,
            message: "不满足强烈卖出条件，跌幅: \(String(format: "%.1f", decreasePercentage))%",
            timestamp: Date(),
            strategyName: name,
            level: .strong
        )
    }
}

// MARK: - 普通买入策略
class NormalBuyStrategy: Strategy {
    let name = "普通买入信号"
    
    func getLevel() -> StrategyLevel {
        return .normal
    }
    
    func execute(data: [String: [TrendData]]) -> StrategyResult {
        // 获取谷歌趋势数据
        let googleData = data["谷歌趋势"] ?? []
        
        guard !googleData.isEmpty else {
            return StrategyResult(
                isTriggered: false,
                strategyType: .buy,
                message: "谷歌趋势数据不足，无法分析",
                timestamp: Date(),
                strategyName: name,
                level: .normal
            )
        }
        
        // 按日期排序
        let sortedData = googleData.sorted { $0.date < $1.date }
        
        // 获取最近7天的数据
        let recentData = Array(sortedData.suffix(7))
        
        guard recentData.count >= 7 else {
            return StrategyResult(
                isTriggered: false,
                strategyType: .buy,
                message: "数据点不足，需要至少7个数据点",
                timestamp: Date(),
                strategyName: name,
                level: .normal
            )
        }
        
        // 计算7日均值
        let values = recentData.map { $0.value }
        let sevenDayAverage = values.reduce(0, +) / Double(values.count)
        let latestValue = values.last ?? 0
        
        // 计算涨幅百分比
        let increasePercentage = ((latestValue - sevenDayAverage) / sevenDayAverage) * 100
        
        // 普通买入条件：最新数据超过7日均值30%
        if increasePercentage > 30 {
            return StrategyResult(
                isTriggered: true,
                strategyType: .buy,
                message: "普通买入信号！最新数据(\(String(format: "%.1f", latestValue)))超过7日均值(\(String(format: "%.1f", sevenDayAverage)))\(String(format: "%.1f", increasePercentage))%",
                timestamp: Date(),
                strategyName: name,
                level: .normal
            )
        }
        
        return StrategyResult(
            isTriggered: false,
            strategyType: .buy,
            message: "不满足普通买入条件，涨幅: \(String(format: "%.1f", increasePercentage))%",
            timestamp: Date(),
            strategyName: name,
            level: .normal
        )
    }
}

// MARK: - 普通卖出策略
class NormalSellStrategy: Strategy {
    let name = "普通卖出信号"
    
    func getLevel() -> StrategyLevel {
        return .normal
    }
    
    func execute(data: [String: [TrendData]]) -> StrategyResult {
        // 获取谷歌趋势数据
        let googleData = data["谷歌趋势"] ?? []
        
        guard !googleData.isEmpty else {
            return StrategyResult(
                isTriggered: false,
                strategyType: .sell,
                message: "谷歌趋势数据不足，无法分析",
                timestamp: Date(),
                strategyName: name,
                level: .normal
            )
        }
        
        // 按日期排序
        let sortedData = googleData.sorted { $0.date < $1.date }
        
        // 获取最近7天的数据
        let recentData = Array(sortedData.suffix(7))
        
        guard recentData.count >= 7 else {
            return StrategyResult(
                isTriggered: false,
                strategyType: .sell,
                message: "数据点不足，需要至少7个数据点",
                timestamp: Date(),
                strategyName: name,
                level: .normal
            )
        }
        
        // 计算7日均值
        let values = recentData.map { $0.value }
        let sevenDayAverage = values.reduce(0, +) / Double(values.count)
        let latestValue = values.last ?? 0
        
        // 计算跌幅百分比
        let decreasePercentage = ((sevenDayAverage - latestValue) / sevenDayAverage) * 100
        
        // 普通卖出条件：最新数据低于7日均值30%
        if decreasePercentage > 30 {
            return StrategyResult(
                isTriggered: true,
                strategyType: .sell,
                message: "普通卖出信号！最新数据(\(String(format: "%.1f", latestValue)))低于7日均值(\(String(format: "%.1f", sevenDayAverage)))\(String(format: "%.1f", decreasePercentage))%",
                timestamp: Date(),
                strategyName: name,
                level: .normal
            )
        }
        
        return StrategyResult(
            isTriggered: false,
            strategyType: .sell,
            message: "不满足普通卖出条件，跌幅: \(String(format: "%.1f", decreasePercentage))%",
            timestamp: Date(),
            strategyName: name,
            level: .normal
        )
    }
}
