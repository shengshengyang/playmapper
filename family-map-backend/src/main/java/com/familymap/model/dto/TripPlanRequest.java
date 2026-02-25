package com.familymap.model.dto;

import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TripPlanRequest {

    @NotNull(message = "景點 ID 列表不能為空")
    private List<Long> placeIds;

    private Integer childAge;

    @NotNull(message = "開始時間不能為空")
    private LocalDateTime startTime;

    private Map<String, Object> preferences;

    // Preference options
    private Boolean includeRestaurants = true;
    private Integer maxDrivingTimePerSegment = 60;  // minutes
    private Boolean autoInsertMeals = true;
    private Boolean autoInsertBreaks = true;
}
