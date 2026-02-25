package com.familymap.repository;

import com.familymap.model.entity.PlaceRating;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RatingRepository extends JpaRepository<PlaceRating, Long> {

    List<PlaceRating> findByPlaceId(Long placeId);

    List<PlaceRating> findByUserId(Long userId);

    Optional<PlaceRating> findByPlaceIdAndUserId(Long placeId, Long userId);

    @Query("SELECT AVG(r.rating) FROM PlaceRating r WHERE r.place.id = :placeId")
    Double getAverageRatingByPlaceId(@Param("placeId") Long placeId);

    @Query("SELECT COUNT(r) FROM PlaceRating r WHERE r.place.id = :placeId")
    Long countByPlaceId(@Param("placeId") Long placeId);
}
