package com.familymap.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "trip_places",
       uniqueConstraints = @UniqueConstraint(
           columnNames = {"trip_id", "day_number", "visit_order"}))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TripPlace {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trip_id", nullable = false)
    private Trip trip;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "place_id", nullable = false)
    private Place place;

    @Column(name = "day_number", nullable = false)
    private Integer dayNumber;

    @Column(name = "visit_order", nullable = false)
    private Integer visitOrder;

    @Column(name = "scheduled_arrival")
    private LocalTime scheduledArrival;

    @Column(name = "scheduled_departure")
    private LocalTime scheduledDeparture;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
