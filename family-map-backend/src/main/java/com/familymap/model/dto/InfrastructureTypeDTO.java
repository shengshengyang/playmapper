package com.familymap.model.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class InfrastructureTypeDTO {
    private Long id;
    private String name;
    private Boolean isActive;
    private Integer sortOrder;
}
