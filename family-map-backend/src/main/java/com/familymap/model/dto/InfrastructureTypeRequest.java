package com.familymap.model.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class InfrastructureTypeRequest {

    @NotBlank(message = "類型名稱不能為空")
    @Size(max = 50, message = "類型名稱不能超過 50 個字元")
    private String name;

    @NotNull(message = "啟用狀態不能為空")
    private Boolean isActive = true;

    @NotNull(message = "排序不能為空")
    @Max(value = 9999, message = "排序值不能大於 9999")
    private Integer sortOrder = 0;
}
