package com.familymap.controller;

import com.familymap.model.dto.OptimizedRouteResponse;
import com.familymap.model.dto.TripPlanRequest;
import com.familymap.model.entity.Place;
import com.familymap.service.PlaceService;
import com.familymap.service.RouteOptimizationService;
import com.familymap.service.ScheduleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/planner")
@RequiredArgsConstructor
@Tag(name = "Planner", description = "行程規劃 API")
public class PlannerController {

    private final PlaceService placeService;
    private final RouteOptimizationService routeOptimizationService;
    private final ScheduleService scheduleService;

    @PostMapping("/optimize")
    @Operation(summary = "智慧行程規劃")
    public ResponseEntity<OptimizedRouteResponse> optimizeRoute(@Valid @RequestBody TripPlanRequest request) {
        // 1. 獲取所有選擇的景點
        List<Place> places = new ArrayList<>();
        for (Long placeId : request.getPlaceIds()) {
            placeService.findById(placeId).ifPresent(places::add);
        }

        if (places.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        // 2. 路徑優化
        List<Place> optimizedPlaces = routeOptimizationService.optimizeRoute(places);

        // 3. 建立時間排程
        ScheduleService.ScheduleResult scheduleResult = scheduleService.createSchedule(
            optimizedPlaces, request.getStartTime()
        );

        // 4. 建立回應
        List<Long> optimizedRoute = optimizedPlaces.stream()
            .map(Place::getId)
            .collect(Collectors.toList());

        double totalDistance = routeOptimizationService.calculateTotalDistance(optimizedPlaces);

        List<OptimizedRouteResponse.ScheduleItemDTO> scheduleItems = scheduleResult.getScheduleItems().stream()
            .map(item -> OptimizedRouteResponse.ScheduleItemDTO.builder()
                .type(item.getType().name().toLowerCase())
                .placeId(item.getPlaceId())
                .placeName(item.getDescription())
                .startTime(item.getStartTime())
                .endTime(item.getEndTime())
                .durationMinutes(item.getDurationMinutes())
                .build())
            .collect(Collectors.toList());

        OptimizedRouteResponse response = OptimizedRouteResponse.builder()
            .optimizedRoute(optimizedRoute)
            .totalDistance(totalDistance)
            .totalDuration(scheduleResult.getTotalDurationMinutes())
            .schedule(scheduleItems)
            .build();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/distance-matrix")
    @Operation(summary = "計算景點間距離矩陣")
    public ResponseEntity<double[][]> calculateDistanceMatrix(@RequestBody List<Long> placeIds) {
        List<Place> places = new ArrayList<>();
        for (Long placeId : placeIds) {
            placeService.findById(placeId).ifPresent(places::add);
        }

        if (places.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        double[][] matrix = routeOptimizationService.calculateDistanceMatrix(places);
        return ResponseEntity.ok(matrix);
    }
}
