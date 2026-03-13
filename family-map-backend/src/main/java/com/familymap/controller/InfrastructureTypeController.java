package com.familymap.controller;

import com.familymap.model.dto.InfrastructureTypeDTO;
import com.familymap.model.dto.InfrastructureTypeRequest;
import com.familymap.service.InfrastructureTypeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@Tag(name = "Infrastructure Type", description = "設施類型管理 API")
public class InfrastructureTypeController {

    private final InfrastructureTypeService infrastructureTypeService;

    @GetMapping("/places/infrastructure-types")
    @Operation(summary = "取得可用設施類型選項")
    public ResponseEntity<List<InfrastructureTypeDTO>> getActiveInfrastructureTypes() {
        return ResponseEntity.ok(infrastructureTypeService.getActiveOptions());
    }

    @GetMapping("/admin/infrastructure-types")
    @Operation(summary = "管理員取得所有設施類型")
    public ResponseEntity<List<InfrastructureTypeDTO>> getAllInfrastructureTypes() {
        return ResponseEntity.ok(infrastructureTypeService.getAllForAdmin());
    }

    @PostMapping("/admin/infrastructure-types")
    @Operation(summary = "管理員新增設施類型")
    public ResponseEntity<InfrastructureTypeDTO> createInfrastructureType(
        @Valid @RequestBody InfrastructureTypeRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED).body(infrastructureTypeService.create(request));
    }

    @PutMapping("/admin/infrastructure-types/{id}")
    @Operation(summary = "管理員更新設施類型")
    public ResponseEntity<InfrastructureTypeDTO> updateInfrastructureType(
        @PathVariable Long id,
        @Valid @RequestBody InfrastructureTypeRequest request
    ) {
        return ResponseEntity.ok(infrastructureTypeService.update(id, request));
    }

    @DeleteMapping("/admin/infrastructure-types/{id}")
    @Operation(summary = "管理員刪除設施類型")
    public ResponseEntity<Void> deleteInfrastructureType(@PathVariable Long id) {
        infrastructureTypeService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
