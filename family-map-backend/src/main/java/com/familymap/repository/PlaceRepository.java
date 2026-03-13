package com.familymap.repository;

import com.familymap.model.entity.Place;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PlaceRepository extends JpaRepository<Place, Long> {

    List<Place> findByStatus(String status);

    List<Place> findByStatusIn(List<String> statuses);

    long countByStatus(String status);

    @Query("SELECT COUNT(p) FROM Place p WHERE p.createdAt >= :startOfMonth")
    long countByCreatedAtAfter(@Param("startOfMonth") java.time.LocalDateTime startOfMonth);

    @Query(value = "SELECT * FROM places p WHERE p.status = :status " +
           "AND ST_DWithin(p.location::geography, ST_MakePoint(:lng, :lat)::geography, :radius)",
           nativeQuery = true)
    List<Place> findNearbyPlaces(@Param("lat") double latitude,
                                  @Param("lng") double longitude,
                                  @Param("radius") double radiusInMeters,
                                  @Param("status") String status);

    @Query(value = "SELECT * FROM places p WHERE p.status = 'approved' " +
           "AND p.min_age <= :age AND p.max_age >= :age",
           nativeQuery = true)
    List<Place> findByAgeRange(@Param("age") Integer age);

    @Query(value = "SELECT * FROM places p WHERE p.status = 'approved' " +
           "AND p.min_age <= :maxAge AND p.max_age >= :minAge",
           nativeQuery = true)
    List<Place> findByAgeRangeBetween(@Param("minAge") Integer minAge, @Param("maxAge") Integer maxAge);
}
