package com.familymap.service;

import com.familymap.model.entity.Place;
import com.familymap.model.entity.PlaceReview;
import com.familymap.repository.PlaceRepository;
import com.familymap.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final PlaceRepository placeRepository;

    public List<PlaceReview> getPendingReviews() {
        return reviewRepository.findByAction("pending");
    }

    public List<Place> getPendingPlaces() {
        return placeRepository.findByStatus("pending");
    }

    public Optional<PlaceReview> findById(Long id) {
        return reviewRepository.findById(id);
    }

    @Transactional
    public PlaceReview approvePlace(Long placeId, Long reviewerId, String comment) {
        Place place = placeRepository.findById(placeId)
            .orElseThrow(() -> new RuntimeException("Place not found with id: " + placeId));

        place.setStatus("approved");
        placeRepository.save(place);

        PlaceReview review = PlaceReview.builder()
            .place(place)
            .reviewerId(reviewerId)
            .action("approved")
            .comment(comment)
            .build();

        PlaceReview savedReview = reviewRepository.save(review);
        log.info("Approved place: {} by reviewer: {}", place.getName(), reviewerId);
        return savedReview;
    }

    @Transactional
    public PlaceReview rejectPlace(Long placeId, Long reviewerId, String comment) {
        Place place = placeRepository.findById(placeId)
            .orElseThrow(() -> new RuntimeException("Place not found with id: " + placeId));

        place.setStatus("rejected");
        placeRepository.save(place);

        PlaceReview review = PlaceReview.builder()
            .place(place)
            .reviewerId(reviewerId)
            .action("rejected")
            .comment(comment)
            .build();

        PlaceReview savedReview = reviewRepository.save(review);
        log.info("Rejected place: {} by reviewer: {}", place.getName(), reviewerId);
        return savedReview;
    }

    public List<PlaceReview> getReviewHistory(Long placeId) {
        return reviewRepository.findByPlaceIdOrderByReviewedAtDesc(placeId);
    }
}
