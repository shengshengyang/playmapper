package com.familymap.controller;

import com.familymap.service.StatisticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/admin/statistics")
@RequiredArgsConstructor
@Tag(name = "Admin Statistics", description = "統計數據 API")
public class StatisticsController {

    private final StatisticsService statisticsService;

    @GetMapping
    @Operation(summary = "獲取統計數據")
    public ResponseEntity<Map<String, Object>> getStatistics() {
        return ResponseEntity.ok(Map.of(
            "totalPlaces", statisticsService.getTotalPlaces(),
            "pendingReview", statisticsService.getPendingReview(),
            "approved", statisticsService.getApproved(),
            "rejected", statisticsService.getRejected(),
            "totalUsers", 0L, // TODO: 實作使用者統計
            "monthlyNew", statisticsService.getMonthlyNew()
        ));
    }
}
