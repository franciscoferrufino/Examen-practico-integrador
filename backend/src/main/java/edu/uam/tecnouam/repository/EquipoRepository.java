package edu.uam.tecnouam.repository;

import edu.uam.tecnouam.model.Equipo;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repositorio Spring Data JPA para la entidad Equipo.
 * Incluye bloqueo pesimista (PESSIMISTIC_WRITE) para evitar dos préstamos activos
 * simultáneos sobre el mismo equipo ante solicitudes concurrentes.
 */
@Repository
public interface EquipoRepository extends JpaRepository<Equipo, Long> {

    List<Equipo> findAllByOrderByIdAsc();

    Optional<Equipo> findByCodigoPatrimonialIgnoreCase(String codigoPatrimonial);

    boolean existsByCodigoPatrimonialIgnoreCase(String codigoPatrimonial);

    boolean existsByCodigoPatrimonialIgnoreCaseAndIdNot(String codigoPatrimonial, Long id);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT e FROM Equipo e WHERE e.id = :id")
    Optional<Equipo> findByIdWithLock(@Param("id") Long id);
}
