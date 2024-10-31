SECTION "Sound engine", ROM0

initSound::

    ld hl, $FF10
    ld d, $FF23 - $FF10
    ld a, $00
    ;;Bucle que borrar el contenido de los registros de todos los canales de FF10 A FF23
    .loop:
        ld [hl+], a
        dec d
        jr nz, .loop
    ;;Activar el sonido
    ld a, $FF
    ldh [$24],a
    ldh [$25],a
    ldh a, [$26]
    or %10000000
    ldh [$26], a
    ret

playGalagaLaser::
    ;; Configurar longitud de onda en el canal 1 (Square Wave)
    ld a, %10000000         ; Longitud de onda al 50%
    ldh [$FF11], a

    ;; Configuración de envolvente de volumen
    ld a, %11100010         ; Volumen inicial alto, caída rápida
    ldh [$FF12], a

    ;; Frecuencia para un tono más grave
    ld a, %10101000         ; Parte baja de la frecuencia (grave)
    ldh [$FF13], a

    ld a, %11000110         ; Parte alta de la frecuencia y reinicio
    ldh [$FF14], a

    ret

playEnemyDestruction::
    ;; Configurar longitud de onda en el canal 1 (Square Wave)
    ld a, %10000000         ; Longitud de onda al 50%
    ldh [$FF11], a

    ;; Configuración de envolvente de volumen
    ld a, %11100010         ; Volumen inicial alto, caída rápida
    ldh [$FF12], a

    ;; Ajuste de frecuencia para una tercera mayor moderada
    ld a, %10100000         ; Parte baja de la frecuencia (un poco más alta)
    ldh [$FF13], a

    ld a, %11000110         ; Parte alta de la frecuencia y reinicio
    ldh [$FF14], a

    ret


playExplosion::
    ;; Configurar longitud de onda en el canal 1 (Square Wave)
    ld a, %10000000         ; Longitud de onda al 50%
    ldh [$FF11], a

    ;; Configuración de envolvente de volumen para explosión
    ld a, %11100001         ; Volumen inicial alto
    ldh [$FF12], a

    ;; Configuración de frecuencia para un sonido explosivo
    ld a, %1100100         ; Frecuencia inicial alta
    ldh [$FF13], a

    ld a, %11000111         ; Reinicio del canal
    ldh [$FF14], a



    ret



