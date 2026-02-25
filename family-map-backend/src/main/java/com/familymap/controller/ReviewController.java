package com.familymap.controller;

import com.familymap.model.dto.PlaceDTO;
import com.familymap.model.entity.Place;
import com.familymap.model.entity.PlaceReview;
import com.familymap.service.PlaceService;
import com.familymap.service.ReviewService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/admin/reviews")
@RequiredArgsConstructor
@Tag(name = "Admin Review", description = "審核管理 API")
public class ReviewController {

    private final ReviewService reviewService;
    private final PlaceService placeService;

    @GetMapping("/pending")
    @Operation(summary = "獲取待審核景點列表")
    public ResponseEntity<List<PlaceDTO>> getPendingPlaces() {
        List<Place> places = reviewService.getPendingPlaces();
        List<PlaceDTO> dtos = places.stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @PostMapping("/{placeId}/approve")
    @Operation(summary = "通過審核")
    public ResponseEntity<PlaceReview> approvePlace(
            @PathVariable Long placeId,
            @RequestBody(required = false) Map<String, String> body) {

        String comment = body != null ? body.get("comment") : null;
        Long reviewerId = 1L; // TODO: 從認證資訊獲取

        PlaceReview review = reviewService.approvePlace(placeId, reviewerId, comment);
        return ResponseEntity.ok(review);
    }

    @PostMapping("/{placeId}/reject")
    @Operation(summary = "拒絕審核")
    public ResponseEntity<PlaceReview> rejectPlace(
            @PathVariable Long placeId,
            @RequestBody(required = false) Map<String, String> body) {

        String comment = body != null ? body.get("comment") : null;
        Long reviewerId = 1L; // TODO: 從認證資訊獲取

        PlaceReview review = reviewService.rejectPlace(placeId, reviewerId, comment);
        return ResponseEntity.ok(review);
    }

    @GetMapping("/history/{placeId}")
    @Operation(summary = "獲取景點審核歷史")
    public ResponseEntity<List<PlaceReview>> getReviewHistory(@PathVariable Long placeId) {
        List<PlaceReview> history = reviewService.getReviewHistory(placeId);
        return ResponseEntity.ok(history);
    }

    private PlaceDTO convertToDTO(Place place) {
        return PlaceDTO.builder()
            .id(place.getId())
            .name(place.getName())
            .description(place.getDescription())
            .address(place.getAddress())
            .latitude(place.getLatitude())
            .longitude(place.getLongitude())
            .minAge(place.getMinAge())
            .maxAge(place.getMaxAge())
            .suggestedDurationMinutes(place.getSuggestedDurationMinutes())
            .openingHours(place.getOpeningHours())
            .facilities(place.getFacilities())
            .ticketPrice(place.getTicketPrice())
            .phone(place.getPhone())
            .website(place.getWebsite())
            .images(place.getImages())
            .rating(place.getRating())
            .reviewCount(place.getReviewCount())
            .status(place.getStatus())
            .submitterId(place.getSubmitterId())
            .build();
    }
}
