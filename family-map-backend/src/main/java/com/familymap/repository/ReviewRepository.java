package com.familymap.repository;

import com.familymap.model.entity.PlaceReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReviewRepository extends JpaRepository<PlaceReview, Long> {

    List<PlaceReview> findByAction(String action);

    List<PlaceReview> findByPlaceId(Long placeId);

    List<PlaceReview> findByPlaceIdOrderByReviewedAtDesc(Long placeId);
}
