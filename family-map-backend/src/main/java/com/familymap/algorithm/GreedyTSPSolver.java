package com.familymap.algorithm;

import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * 貪心算法 + 2-opt 優化的 TSP 求解器
 * 適用於小規模問題（< 15 個景點）
 */
@Component
public class GreedyTSPSolver implements TSPSolver {

    @Override
    public List<Integer> solve(double[][] distanceMatrix) {
        int n = distanceMatrix.length;
        if (n == 0) return new ArrayList<>();
        if (n == 1) return List.of(0);

        // 使用貪心算法找初始解
        List<Integer> route = nearestNeighbor(distanceMatrix);

        // 使用 2-opt 優化
        route = twoOptOptimize(route, distanceMatrix);

        return route;
    }

    @Override
    public List<Integer> solveWithTimeWindows(double[][] distanceMatrix,
                                               TimeWindow[] timeWindows,
                                               int startTime) {
        // 基本實作：先用貪心算法，再調整以符合時間窗口
        List<Integer> route = solve(distanceMatrix);

        // TODO: 實作時間窗口約束的調整邏輯

        return route;
    }

    /**
     * 貪心最近鄰居算法
     */
    private List<Integer> nearestNeighbor(double[][] distanceMatrix) {
        int n = distanceMatrix.length;
        boolean[] visited = new boolean[n];
        List<Integer> route = new ArrayList<>();

        // 從第一個點開始
        int current = 0;
        route.add(current);
        visited[current] = true;

        for (int i = 1; i < n; i++) {
            int nearest = -1;
            double minDist = Double.MAX_VALUE;

            for (int j = 0; j < n; j++) {
                if (!visited[j] && distanceMatrix[current][j] < minDist) {
                    minDist = distanceMatrix[current][j];
                    nearest = j;
                }
            }

            if (nearest != -1) {
                route.add(nearest);
                visited[nearest] = true;
                current = nearest;
            }
        }

        return route;
    }

    /**
     * 2-opt 優化
     */
    private List<Integer> twoOptOptimize(List<Integer> route, double[][] distanceMatrix) {
        boolean improved = true;
        List<Integer> bestRoute = new ArrayList<>(route);

        while (improved) {
            improved = false;
            for (int i = 0; i < bestRoute.size() - 1; i++) {
                for (int j = i + 1; j < bestRoute.size(); j++) {
                    List<Integer> newRoute = twoOptSwap(bestRoute, i, j);
                    if (calculateTotalDistance(newRoute, distanceMatrix) <
                        calculateTotalDistance(bestRoute, distanceMatrix)) {
                        bestRoute = newRoute;
                        improved = true;
                    }
                }
            }
        }

        return bestRoute;
    }

    /**
     * 2-opt 交換操作
     */
    private List<Integer> twoOptSwap(List<Integer> route, int i, int j) {
        List<Integer> newRoute = new ArrayList<>();

        // 0 到 i-1 保持不變
        for (int k = 0; k < i; k++) {
            newRoute.add(route.get(k));
        }

        // i 到 j 反轉
        for (int k = j; k >= i; k--) {
            newRoute.add(route.get(k));
        }

        // j+1 到結束保持不變
        for (int k = j + 1; k < route.size(); k++) {
            newRoute.add(route.get(k));
        }

        return newRoute;
    }

    /**
     * 計算路徑總距離
     */
    private double calculateTotalDistance(List<Integer> route, double[][] distanceMatrix) {
        double total = 0;
        for (int i = 0; i < route.size() - 1; i++) {
            total += distanceMatrix[route.get(i)][route.get(i + 1)];
        }
        return total;
    }
}
