package edu.uam.tecnouam.model;

import edu.uam.tecnouam.exception.BadRequestException;

import java.text.Normalizer;
import java.util.Locale;

/**
 * Catálogo y normalizador de tipos de equipo tecnológico permitidos por TecnoUAM:
 * - Computadora portátil
 * - Proyector
 * - Tableta
 */
public enum TipoEquipo {
    COMPUTADORA_PORTATIL("Computadora portátil"),
    PROYECTOR("Proyector"),
    TABLETA("Tableta");

    private final String etiqueta;

    TipoEquipo(String etiqueta) {
        this.etiqueta = etiqueta;
    }

    public String getEtiqueta() {
        return etiqueta;
    }

    /**
     * Valida y normaliza el texto recibido (por ejemplo "Computadora portátil",
     * "computadora portatil", "COMPUTADORA_PORTATIL", "Proyector", "Tableta")
     * hacia la etiqueta canónica almacenada en la base de datos.
     */
    public static String normalizarYValidar(String valor) {
        if (valor == null || valor.trim().isEmpty()) {
            throw new BadRequestException("El tipo de equipo es obligatorio. Valores permitidos: Computadora portátil, Proyector, Tableta.");
        }

        String limpio = sinAcentos(valor.trim()).toUpperCase(Locale.ROOT)
                .replace('-', '_')
                .replaceAll("\\s+", "_");

        if (limpio.equals("COMPUTADORA_PORTATIL") || limpio.equals("PORTATIL") || limpio.equals("LAPTOP")) {
            return COMPUTADORA_PORTATIL.getEtiqueta();
        }
        if (limpio.equals("PROYECTOR")) {
            return PROYECTOR.getEtiqueta();
        }
        if (limpio.equals("TABLETA") || limpio.equals("TABLET")) {
            return TABLETA.getEtiqueta();
        }

        throw new BadRequestException(
                "Tipo de equipo inválido: '" + valor + "'. Los tipos permitidos son: Computadora portátil, Proyector o Tableta."
        );
    }

    private static String sinAcentos(String texto) {
        String normalizado = Normalizer.normalize(texto, Normalizer.Form.NFD);
        return normalizado.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
    }
}
