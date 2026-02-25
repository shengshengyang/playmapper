package com.familymap.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "place_reviews")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlaceReview {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "place_id", nullable = false)
    private Place place;

    @Column(name = "reviewer_id")
    private Long reviewerId;

    @Column(nullable = false, length = 20)
    private String action;  // approved, rejected, pending

    @Column(columnDefinition = "TEXT")
    private String comment;

    @Column(name = "reviewed_at")
    @CreationTimestamp
    private LocalDateTime reviewedAt;
}
