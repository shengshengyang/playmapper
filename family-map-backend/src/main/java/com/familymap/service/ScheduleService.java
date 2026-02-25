package com.familymap.service;

import com.familymap.model.entity.Place;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScheduleService {

    private final RouteOptimizationService routeOptimizationService;

    private static final LocalTime LUNCH_START = LocalTime.of(11, 30);
    private static final LocalTime LUNCH_END = LocalTime.of(13, 30);
    private static final LocalTime DINNER_START = LocalTime.of(17, 30);
    private static final LocalTime DINNER_END = LocalTime.of(19, 30);
    private static final int MEAL_DURATION_MINUTES = 60;
    private static final int MAX_CONTINUOUS_DRIVING_MINUTES = 120;
    private static final int BREAK_DURATION_MINUTES = 20;

    public ScheduleResult createSchedule(List<Place> orderedPlaces, LocalDateTime startTime) {
        ScheduleResult result = new ScheduleResult();
        LocalDateTime currentTime = startTime;
        int continuousDrivingMinutes = 0;
        boolean hasLunch = false;
        boolean hasDinner = false;

        for (int i = 0; i < orderedPlaces.size(); i++) {
            Place place = orderedPlaces.get(i);

            // 檢查是否需要用餐
            MealCheckResult mealCheck = checkAndInsertMealTime(
                result, currentTime, hasLunch, hasDinner
            );
            currentTime = mealCheck.currentTime;
            if (mealCheck.hadLunch) hasLunch = true;
            if (mealCheck.hadDinner) hasDinner = true;

            // 計算開車時間
            if (i > 0) {
                Place prevPlace = orderedPlaces.get(i - 1);
                int drivingTime = routeOptimizationService.estimateDrivingTimeMinutes(
                    routeOptimizationService.calculateDistance(prevPlace, place)
                );
                continuousDrivingMinutes += drivingTime;

                // 檢查是否需要休息
                if (continuousDrivingMinutes >= MAX_CONTINUOUS_DRIVING_MINUTES) {
                    result.addScheduleItem(new ScheduleItem(
                        ScheduleItemType.BREAK,
                        currentTime,
                        currentTime.plusMinutes(BREAK_DURATION_MINUTES),
                        "休息時間",
                        BREAK_DURATION_MINUTES,
                        null
                    ));
                    currentTime = currentTime.plusMinutes(BREAK_DURATION_MINUTES);
                    continuousDrivingMinutes = 0;
                }

                // 加入開車時間
                result.addScheduleItem(new ScheduleItem(
                    ScheduleItemType.DRIVING,
                    currentTime,
                    currentTime.plusMinutes(drivingTime),
                    "前往 " + place.getName(),
                    drivingTime,
                    null
                ));
                currentTime = currentTime.plusMinutes(drivingTime);
            }

            // 安排景點停留
            int duration = place.getSuggestedDurationMinutes() != null ?
                place.getSuggestedDurationMinutes() : 60;

            result.addScheduleItem(new ScheduleItem(
                ScheduleItemType.PLACE,
                currentTime,
                currentTime.plusMinutes(duration),
                place.getName(),
                duration,
                place.getId()
            ));

            currentTime = currentTime.plusMinutes(duration);
        }

        result.setEndTime(currentTime);
        result.setTotalDurationMinutes((int) java.time.Duration.between(startTime, currentTime).toMinutes());

        return result;
    }

    private MealCheckResult checkAndInsertMealTime(ScheduleResult result,
                                                    LocalDateTime time,
                                                    boolean hasLunch,
                                                    boolean hasDinner) {
        MealCheckResult checkResult = new MealCheckResult();
        checkResult.currentTime = time;
        checkResult.hadLunch = hasLunch;
        checkResult.hadDinner = hasDinner;

        LocalTime timeOfDay = time.toLocalTime();

        // 午餐時段
        if (!hasLunch && timeOfDay.isAfter(LUNCH_START) && timeOfDay.isBefore(LUNCH_END)) {
            result.addScheduleItem(new ScheduleItem(
                ScheduleItemType.MEAL,
                time,
                time.plusMinutes(MEAL_DURATION_MINUTES),
                "午餐",
                MEAL_DURATION_MINUTES,
                null
            ));
            checkResult.currentTime = time.plusMinutes(MEAL_DURATION_MINUTES);
            checkResult.hadLunch = true;
        }

        // 晚餐時段
        if (!hasDinner && timeOfDay.isAfter(DINNER_START) && timeOfDay.isBefore(DINNER_END)) {
            result.addScheduleItem(new ScheduleItem(
                ScheduleItemType.MEAL,
                time,
                time.plusMinutes(MEAL_DURATION_MINUTES),
                "晚餐",
                MEAL_DURATION_MINUTES,
                null
            ));
            checkResult.currentTime = time.plusMinutes(MEAL_DURATION_MINUTES);
            checkResult.hadDinner = true;
        }

        return checkResult;
    }

    // Inner classes for schedule results
    public static class ScheduleResult {
        private List<ScheduleItem> scheduleItems = new ArrayList<>();
        private LocalDateTime endTime;
        private int totalDurationMinutes;

        public void addScheduleItem(ScheduleItem item) {
            scheduleItems.add(item);
        }

        public List<ScheduleItem> getScheduleItems() {
            return scheduleItems;
        }

        public LocalDateTime getEndTime() {
            return endTime;
        }

        public void setEndTime(LocalDateTime endTime) {
            this.endTime = endTime;
        }

        public int getTotalDurationMinutes() {
            return totalDurationMinutes;
        }

        public void setTotalDurationMinutes(int totalDurationMinutes) {
            this.totalDurationMinutes = totalDurationMinutes;
        }
    }

    public enum ScheduleItemType {
        PLACE, DRIVING, MEAL, BREAK
    }

    public static class ScheduleItem {
        private ScheduleItemType type;
        private LocalDateTime startTime;
        private LocalDateTime endTime;
        private String description;
        private int durationMinutes;
        private Long placeId;

        public ScheduleItem(ScheduleItemType type, LocalDateTime startTime,
                           LocalDateTime endTime, String description,
                           int durationMinutes, Long placeId) {
            this.type = type;
            this.startTime = startTime;
            this.endTime = endTime;
            this.description = description;
            this.durationMinutes = durationMinutes;
            this.placeId = placeId;
        }

        // Getters
        public ScheduleItemType getType() { return type; }
        public LocalDateTime getStartTime() { return startTime; }
        public LocalDateTime getEndTime() { return endTime; }
        public String getDescription() { return description; }
        public int getDurationMinutes() { return durationMinutes; }
        public Long getPlaceId() { return placeId; }
    }

    private static class MealCheckResult {
        LocalDateTime currentTime;
        boolean hadLunch;
        boolean hadDinner;
    }
}
