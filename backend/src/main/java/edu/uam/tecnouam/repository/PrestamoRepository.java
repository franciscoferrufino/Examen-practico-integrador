package edu.uam.tecnouam.repository;

import edu.uam.tecnouam.model.EstadoPrestamo;
import edu.uam.tecnouam.model.Prestamo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio Spring Data JPA para la entidad Prestamo.
 */
@Repository
public interface PrestamoRepository extends JpaRepository<Prestamo, Long> {

    List<Prestamo> findAllByOrderByIdDesc();

    boolean existsByEquipoIdAndEstado(Long equipoId, EstadoPrestamo estado);

    long countByEquipoIdAndEstado(Long equipoId, EstadoPrestamo estado);

    /**
     * Elimina los préstamos asociados a un equipo según su estado (por ejemplo DEVUELTO).
     * Se utiliza de forma transaccional al eliminar un equipo que no posee préstamos activos
     * pero sí historial de préstamos ya devueltos, evitando errores de clave foránea.
     */
    void deleteByEquipoIdAndEstado(Long equipoId, EstadoPrestamo estado);
}
