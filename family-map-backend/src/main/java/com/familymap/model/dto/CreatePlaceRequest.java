package com.familymap.model.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreatePlaceRequest {

    @NotBlank(message = "名稱不能為空")
    @Size(max = 200, message = "名稱不能超過 200 個字元")
    private String name;

    @NotBlank(message = "設施類型不能為空")
    @Size(max = 50, message = "設施類型不能超過 50 個字元")
    private String infrastructureType;

    @Size(max = 2000, message = "描述不能超過 2000 個字元")
    private String description;

    @Size(max = 500, message = "地址不能超過 500 個字元")
    private String address;

    private Double latitude;

    private Double longitude;

    @Min(value = 0, message = "最小年齡不能小於 0")
    private Integer minAge = 0;

    @Max(value = 18, message = "最大年齡不能大於 18")
    private Integer maxAge = 18;

    private Integer suggestedDurationMinutes;

    private Map<String, Object> openingHours;

    private List<String> facilities;

    private BigDecimal ticketPrice;

    private String phone;

    private String website;

    private List<String> images;
}
