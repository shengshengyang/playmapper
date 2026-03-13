package com.familymap.controller;

import com.familymap.model.dto.CreatePlaceRequest;
import com.familymap.model.dto.PlaceDTO;
import com.familymap.model.entity.Place;
import com.familymap.service.PlaceService;
import com.familymap.util.GeometryHelper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/places")
@RequiredArgsConstructor
@Tag(name = "Place", description = "地點管理 API")
public class PlaceController {

    private final PlaceService placeService;

    @GetMapping
    @Operation(summary = "獲取所有已審核地點")
    public ResponseEntity<List<PlaceDTO>> getAllPlaces() {
        List<Place> places = placeService.findAllApproved();
        List<PlaceDTO> dtos = places.stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @GetMapping("/all")
    @Operation(summary = "獲取所有地點（包含待審核）")
    public ResponseEntity<List<PlaceDTO>> getAllPlacesIncludingPending() {
        List<Place> places = placeService.findAll();
        List<PlaceDTO> dtos = places.stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
        return ResponseEntity.ok(dtos);
    }

    @GetMapping("/{id}")
    @Operation(summary = "獲取地點詳情")
    public ResponseEntity<PlaceDTO> getPlaceById(@PathVariable Long id) {
        return placeService.findById(id)
            .map(place -> ResponseEntity.ok(convertToDTO(place)))
            .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/nearby")
    @Operation(summary = "獲取附近地點")
    public ResponseEntity<List<PlaceDTO>> getNearbyPlaces(
            @RequestParam Double lat,
            @RequestParam Double lng,
            @RequestParam(defaultValue = "10") Double radiusKm,
            @RequestParam(required = false) Integer minAge,
            @RequestParam(required = false) Integer maxAge) {

        List<Place> places = placeService.findNearby(lat, lng, radiusKm);

        // 年齡篩選
        if (minAge != null && maxAge != null) {
            places = places.stream()
                .filter(p -> p.getMinAge() <= maxAge && p.getMaxAge() >= minAge)
                .collect(Collectors.toList());
        }

        List<PlaceDTO> dtos = places.stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());

        return ResponseEntity.ok(dtos);
    }

    @GetMapping("/search")
    @Operation(summary = "搜尋地點")
    public ResponseEntity<List<PlaceDTO>> searchPlaces(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer age,
            @RequestParam(required = false) String facility) {

        // 基本實作：返回所有已審核地點
        // TODO: 實作完整的搜尋邏輯
        List<Place> places = placeService.findAllApproved();

        if (age != null) {
            places = places.stream()
                .filter(p -> p.getMinAge() <= age && p.getMaxAge() >= age)
                .collect(Collectors.toList());
        }

        List<PlaceDTO> dtos = places.stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());

        return ResponseEntity.ok(dtos);
    }

    @PostMapping
    @Operation(summary = "提交新地點")
    public ResponseEntity<PlaceDTO> createPlace(@Valid @RequestBody CreatePlaceRequest request) {
        Place place = Place.builder()
            .name(request.getName())
            .infrastructureType(request.getInfrastructureType())
            .description(request.getDescription())
            .address(request.getAddress())
            .location(GeometryHelper.createPoint(request.getLongitude(), request.getLatitude()))
            .minAge(request.getMinAge())
            .maxAge(request.getMaxAge())
            .suggestedDurationMinutes(request.getSuggestedDurationMinutes())
            .openingHours(request.getOpeningHours())
            .facilities(request.getFacilities())
            .ticketPrice(request.getTicketPrice())
            .phone(request.getPhone())
            .website(request.getWebsite())
            .images(request.getImages())
            .build();

        Place savedPlace = placeService.createPlace(place);
        return ResponseEntity.status(HttpStatus.CREATED).body(convertToDTO(savedPlace));
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新地點（管理員）")
    public ResponseEntity<PlaceDTO> updatePlace(@PathVariable Long id, @Valid @RequestBody CreatePlaceRequest request) {
        Place place = Place.builder()
            .name(request.getName())
            .infrastructureType(request.getInfrastructureType())
            .description(request.getDescription())
            .address(request.getAddress())
            .location(GeometryHelper.createPoint(request.getLongitude(), request.getLatitude()))
            .minAge(request.getMinAge())
            .maxAge(request.getMaxAge())
            .suggestedDurationMinutes(request.getSuggestedDurationMinutes())
            .openingHours(request.getOpeningHours())
            .facilities(request.getFacilities())
            .ticketPrice(request.getTicketPrice())
            .phone(request.getPhone())
            .website(request.getWebsite())
            .images(request.getImages())
            .build();

        Place updatedPlace = placeService.updatePlace(id, place);
        return ResponseEntity.ok(convertToDTO(updatedPlace));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "刪除地點（管理員）")
    public ResponseEntity<Void> deletePlace(@PathVariable Long id) {
        placeService.deletePlace(id);
        return ResponseEntity.noContent().build();
    }

    private PlaceDTO convertToDTO(Place place) {
        return PlaceDTO.builder()
            .id(place.getId())
            .name(place.getName())
            .infrastructureType(place.getInfrastructureType())
            .description(place.getDescription())
            .address(place.getAddress())
            .latitude(GeometryHelper.getLatitude(place.getLocation()))
            .longitude(GeometryHelper.getLongitude(place.getLocation()))
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
