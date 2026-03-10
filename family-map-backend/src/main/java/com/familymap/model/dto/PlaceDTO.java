package com.familymap.model.dto;

import lombok.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlaceDTO {

    private Long id;
    private String name;
    private String infrastructureType;
    private String description;
    private String address;
    private Double latitude;
    private Double longitude;
    private Integer minAge;
    private Integer maxAge;
    private Integer suggestedDurationMinutes;
    private Map<String, Object> openingHours;
    private List<String> facilities;
    private BigDecimal ticketPrice;
    private String phone;
    private String website;
    private List<String> images;
    private BigDecimal rating;
    private Integer reviewCount;
    private String status;
    private Long submitterId;
}
