package com.familymap.service;

import com.familymap.model.dto.InfrastructureTypeDTO;
import com.familymap.model.dto.InfrastructureTypeRequest;
import com.familymap.model.entity.InfrastructureType;
import com.familymap.repository.InfrastructureTypeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
@RequiredArgsConstructor
public class InfrastructureTypeService {

    private final InfrastructureTypeRepository infrastructureTypeRepository;

    public List<InfrastructureTypeDTO> getActiveOptions() {
        return infrastructureTypeRepository.findByIsActiveTrueOrderBySortOrderAscNameAsc()
            .stream()
            .map(this::toDto)
            .toList();
    }

    public List<InfrastructureTypeDTO> getAllForAdmin() {
        return infrastructureTypeRepository.findAllByOrderBySortOrderAscNameAsc()
            .stream()
            .map(this::toDto)
            .toList();
    }

    @Transactional
    public InfrastructureTypeDTO create(InfrastructureTypeRequest request) {
        infrastructureTypeRepository.findByName(request.getName().trim()).ifPresent(existing -> {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "類型名稱已存在");
        });

        InfrastructureType entity = InfrastructureType.builder()
            .name(request.getName().trim())
            .isActive(request.getIsActive())
            .sortOrder(request.getSortOrder())
            .build();

        return toDto(infrastructureTypeRepository.save(entity));
    }

    @Transactional
    public InfrastructureTypeDTO update(Long id, InfrastructureTypeRequest request) {
        InfrastructureType entity = infrastructureTypeRepository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "找不到類型"));

        if (infrastructureTypeRepository.existsByNameAndIdNot(request.getName().trim(), id)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "類型名稱已存在");
        }

        entity.setName(request.getName().trim());
        entity.setIsActive(request.getIsActive());
        entity.setSortOrder(request.getSortOrder());

        return toDto(infrastructureTypeRepository.save(entity));
    }

    @Transactional
    public void delete(Long id) {
        InfrastructureType entity = infrastructureTypeRepository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "找不到類型"));
        infrastructureTypeRepository.delete(entity);
    }

    public void validateActiveTypeOrThrow(String infrastructureType) {
        String normalizedType = infrastructureType == null ? "" : infrastructureType.trim();
        if (!infrastructureTypeRepository.existsByNameAndIsActiveTrue(normalizedType)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "設施類型不存在或未啟用");
        }
    }

    private InfrastructureTypeDTO toDto(InfrastructureType type) {
        return InfrastructureTypeDTO.builder()
            .id(type.getId())
            .name(type.getName())
            .isActive(type.getIsActive())
            .sortOrder(type.getSortOrder())
            .build();
    }
}
