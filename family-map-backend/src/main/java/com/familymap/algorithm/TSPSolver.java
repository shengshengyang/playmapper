package com.familymap.algorithm;

import java.util.List;

/**
 * 旅行商問題 (TSP) 求解器介面
 */
public interface TSPSolver {

    /**
     * 求解 TSP 問題，返回最佳訪問順序的索引
     *
     * @param distanceMatrix 距離矩陣
     * @return 最佳路徑的景點索引列表
     */
    List<Integer> solve(double[][] distanceMatrix);

    /**
     * 帶時間窗口約束的 TSP 求解
     *
     * @param distanceMatrix    距離矩陣
     * @param timeWindows       時間窗口（每個景點的營業時間）
     * @param startTime         開始時間（分鐘）
     * @return 最佳路徑的景點索引列表
     */
    List<Integer> solveWithTimeWindows(double[][] distanceMatrix,
                                        TimeWindow[] timeWindows,
                                        int startTime);
}
