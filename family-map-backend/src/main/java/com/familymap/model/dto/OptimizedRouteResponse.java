package com.familymap.model.dto;

import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OptimizedRouteResponse {

    private List<Long> optimizedRoute;

    private Double totalDistance;  // km

    private Integer totalDuration;  // minutes

    private List<ScheduleItemDTO> schedule;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ScheduleItemDTO {
        private String type;  // place, driving, meal, break
        private Long placeId;
        private String placeName;
        private LocalDateTime startTime;
        private LocalDateTime endTime;
        private Integer durationMinutes;
        private Double distance;  // for driving type
        private String mealType;  // for meal type: lunch, dinner
    }
}
