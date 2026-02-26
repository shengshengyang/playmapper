package com.familymap.service;

import com.familymap.model.entity.Place;
import com.familymap.repository.PlaceRepository;
import com.familymap.repository.RatingRepository;
import com.familymap.util.GeometryHelper;
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
        // radiusKm 轉換為公尺
        double radiusMeters = radiusKm * 1000;
        return placeRepository.findNearbyPlaces(latitude, longitude, radiusMeters, "approved");
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
            if (updatedPlace.getLocation() != null) {
                place.setLocation(updatedPlace.getLocation());
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
}
