package com.familymap.service;

import com.familymap.repository.PlaceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;

@Service
@RequiredArgsConstructor
public class StatisticsService {

    private final PlaceRepository placeRepository;

    public long getTotalPlaces() {
        return placeRepository.count();
    }

    public long getPendingReview() {
        return placeRepository.countByStatus("pending");
    }

    public long getApproved() {
        return placeRepository.countByStatus("approved");
    }

    public long getRejected() {
        return placeRepository.countByStatus("rejected");
    }

    public long getMonthlyNew() {
        LocalDateTime startOfMonth = LocalDateTime.now()
            .with(TemporalAdjusters.firstDayOfMonth())
            .withHour(0)
            .withMinute(0)
            .withSecond(0)
            .withNano(0);
        return placeRepository.countByCreatedAtAfter(startOfMonth);
    }
}
