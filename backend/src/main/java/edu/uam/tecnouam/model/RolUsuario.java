package edu.uam.tecnouam.model;

/**
 * Roles de seguridad del sistema TecnoUAM.
 * - USER: únicamente puede consultar equipos y préstamos.
 * - ADMIN: puede consultar, crear, actualizar y eliminar equipos; registrar préstamos y devoluciones.
 */
public enum RolUsuario {
    ADMIN,
    USER
}
