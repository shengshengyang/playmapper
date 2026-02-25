package com.familymap.service;

import com.familymap.model.entity.Place;
import com.familymap.repository.PlaceRepository;
import com.familymap.repository.RatingRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class PlaceService {

    private final PlaceRepository placeRepository;
    private final RatingRepository ratingRepository;

    private static final double EARTH_RADIUS_KM = 6371.0;

    public List<Place> findAllApproved() {
        return placeRepository.findByStatus("approved");
    }

    public List<Place> findAll() {
        return placeRepository.findAll();
    }

    public Optional<Place> findById(Long id) {
        return placeRepository.findById(id);
    }

    public List<Place> findNearby(double latitude, double longitude, double radiusKm) {
        // 計算大約的經緯度範圍
        double latDelta = radiusKm / 111.0; // 1度緯度約111公里
        double lngDelta = radiusKm / (111.0 * Math.cos(Math.toRadians(latitude)));

        double minLat = latitude - latDelta;
        double maxLat = latitude + latDelta;
        double minLng = longitude - lngDelta;
        double maxLng = longitude + lngDelta;

        List<Place> places = placeRepository.findByStatus("approved");

        // 精確篩選
        return places.stream()
            .filter(p -> p.getLatitude() != null && p.getLongitude() != null)
            .filter(p -> {
                double distance = haversineDistance(
                    latitude, longitude,
                    p.getLatitude(), p.getLongitude()
                );
                return distance <= radiusKm;
            })
            .toList();
    }

    public List<Place> findByAgeRange(Integer minAge, Integer maxAge) {
        return placeRepository.findByAgeRangeBetween(minAge, maxAge);
    }

    @Transactional
    public Place createPlace(Place place) {
        place.setStatus("pending");
        Place savedPlace = placeRepository.save(place);
        log.info("Created new place: {} with status: pending", savedPlace.getName());
        return savedPlace;
    }

    @Transactional
    public Place updatePlace(Long id, Place updatedPlace) {
        return placeRepository.findById(id).map(place -> {
            place.setName(updatedPlace.getName());
            place.setDescription(updatedPlace.getDescription());
            place.setAddress(updatedPlace.getAddress());
            place.setMinAge(updatedPlace.getMinAge());
            place.setMaxAge(updatedPlace.getMaxAge());
            place.setSuggestedDurationMinutes(updatedPlace.getSuggestedDurationMinutes());
            place.setOpeningHours(updatedPlace.getOpeningHours());
            place.setFacilities(updatedPlace.getFacilities());
            place.setTicketPrice(updatedPlace.getTicketPrice());
            place.setPhone(updatedPlace.getPhone());
            place.setWebsite(updatedPlace.getWebsite());
            if (updatedPlace.getLatitude() != null) {
                place.setLatitude(updatedPlace.getLatitude());
            }
            if (updatedPlace.getLongitude() != null) {
                place.setLongitude(updatedPlace.getLongitude());
            }
            return placeRepository.save(place);
        }).orElseThrow(() -> new RuntimeException("Place not found with id: " + id));
    }

    @Transactional
    public void deletePlace(Long id) {
        placeRepository.deleteById(id);
        log.info("Deleted place with id: {}", id);
    }

    @Transactional
    public Place updateRating(Long placeId) {
        Double avgRating = ratingRepository.getAverageRatingByPlaceId(placeId);
        Long count = ratingRepository.countByPlaceId(placeId);

        return placeRepository.findById(placeId).map(place -> {
            place.setRating(avgRating != null ?
                BigDecimal.valueOf(avgRating) : BigDecimal.ZERO);
            place.setReviewCount(count.intValue());
            return placeRepository.save(place);
        }).orElseThrow(() -> new RuntimeException("Place not found with id: " + placeId));
    }

    private double haversineDistance(double lat1, double lng1, double lat2, double lng2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLng / 2) * Math.sin(dLng / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return EARTH_RADIUS_KM * c;
    }
}
