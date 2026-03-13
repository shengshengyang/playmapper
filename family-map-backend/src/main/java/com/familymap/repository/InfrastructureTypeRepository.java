package com.familymap.repository;

import com.familymap.model.entity.InfrastructureType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface InfrastructureTypeRepository extends JpaRepository<InfrastructureType, Long> {
    List<InfrastructureType> findByIsActiveTrueOrderBySortOrderAscNameAsc();
    List<InfrastructureType> findAllByOrderBySortOrderAscNameAsc();
    boolean existsByNameAndIsActiveTrue(String name);
    boolean existsByNameAndIdNot(String name, Long id);
    Optional<InfrastructureType> findByName(String name);
}
