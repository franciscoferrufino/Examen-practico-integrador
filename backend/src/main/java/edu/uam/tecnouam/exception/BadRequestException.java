package edu.uam.tecnouam.exception;

/**
 * Excepción para datos de entrada inválidos o reglas de formato/fechas incumplidas (HTTP 400 Bad Request).
 */
public class BadRequestException extends RuntimeException {
    public BadRequestException(String message) {
        super(message);
    }
}
