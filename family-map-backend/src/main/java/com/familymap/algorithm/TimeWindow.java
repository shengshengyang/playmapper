package com.familymap.algorithm;

import lombok.Builder;
import lombok.Getter;

/**
 * 時間窗口定義
 */
@Getter
@Builder
public class TimeWindow {

    private int openTime;   // 營業開始時間（分鐘，從午夜開始計算）
    private int closeTime;  // 營業結束時間（分鐘）
    private int serviceTime; // 服務/停留時間（分鐘）

    /**
     * 檢查給定時間是否在營業時間內
     */
    public boolean isOpen(int time) {
        return time >= openTime && time <= closeTime;
    }

    /**
     * 獲取下一個營業開始時間
     */
    public int getNextOpenTime(int currentTime) {
        if (currentTime < openTime) {
            return openTime;
        }
        // 假設隔天開始 - 實際應用需要更複雜的邏輯
        return openTime + 24 * 60;
    }
}
