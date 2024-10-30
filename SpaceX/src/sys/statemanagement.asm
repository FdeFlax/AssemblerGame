SECTION "Inicio", ROM0 

; Función escribeTexto
escribeTexto:
    call waitVBlank  

.loop:
    ld a, [hl+]          ; Cargar el siguiente carácter del texto en A y avanzar HL
    or a                 ; Verificar si el carácter es 0 (fin de texto)
    jr z, .fin           ; Si es 0, salir de la función
    ld [de], a           ; Escribir el carácter en la memoria de vídeo (DE)
    inc de               ; Avanzar a la siguiente posición de memoria de vídeo
    jr .loop             ; Repetir para el siguiente carácter

.fin:
    ret


escribeDialogo:
    call waitVBlank
    ld de, $98E0              ; Dirección de la VRAM para diálogos
    call escribeTexto         ; Llamar a `escribeTexto` para copiar el texto
    ret


