DEF BULLET_OAM_POS equ 30 * 4   ; Posición en la OAM para el disparo (cada entrada de sprite son 4 bytes)
DEF BULLET_OAM_POS2 equ 31 * 4   ; Posición en la OAM para el disparo (cada entrada de sprite son 4 bytes)
DEF BULLET_SPRITE_TILE01 equ $04 ; Identificador de tile para el disparo
DEF BULLET_SPRITE_TILE02 equ $06 ; Identificador de tile para el disparo
DEF BULLET_SPRITE_ATTR equ $00 ; Atributos del sprite del disparo
DEF SCREEN_TOP_BOUND equ 0  
SECTION "Disparo", ROM0 

fire_bullet:
    ld a, [bullet_active]   ; Comprobar si el disparo ya está activo
    cp 1
    ret z                   ; Salir si ya hay un disparo activo

    ; Activar disparo
    ld a, 1
    ld [bullet_active], a   ; Marcar el disparo como activo

    ; Posicionar el disparo en la misma posición X de la nave
    ld a, [posicionXNave]
    ld [bullet_posx], a

    ; Posicionar el disparo ligeramente arriba de la nave
    ld a, 128
    sub 8                   ; Colocar el disparo 8 píxeles por encima de la nave
    ld [bullet_posy], a

    ; Configurar el sprite en la copia de la OAM
    ld hl, copiaOAM + BULLET_OAM_POS
    ld a, [bullet_posy]
    ld [hl], a              ; Posición Y del disparo
    inc hl
    ld a, [bullet_posx]
    ld [hl], a              ; Posición X del disparo
    inc hl
    ld a, BULLET_SPRITE_TILE01
    ld [hl], a              ; Tile del disparo
    inc hl
    ld a, BULLET_SPRITE_ATTR
    ld [hl], a              ; Atributos del sprite

    ; Configurar el sprite en la copia de la OAM
    inc hl
    ld a, [bullet_posy]
    ld [hl], a              ; Posición Y del disparo
    inc hl
    ld a, [bullet_posx]
    add 8
    ld [hl], a              ; Posición X del disparo
    inc hl
    ld a, BULLET_SPRITE_TILE02
    ld [hl], a              ; Tile del disparo
    inc hl
    ld a, BULLET_SPRITE_ATTR
    ld [hl], a              ; Atributos del sprite

    ret

update_bullet:

    ld a, [bullet_active]
    cp 0
    ret z                     ; Si el disparo no está activo, salir

    ; Mover el disparo hacia arriba
    ld a, [bullet_posy]
    sub 2                     ; Mover 2 píxeles hacia arriba
    ld [bullet_posy], a
    cp SCREEN_TOP_BOUND       ; Comprobar si está fuera de la pantalla
    jr z, .deactivate_bullet  ; Desactivar si llega al borde superior

    ; Actualizar la posición del sprite en la copia de la OAM
    ld hl, copiaOAM + BULLET_OAM_POS
    ld a, [bullet_posy]
    ld [hl], a                ; Posición Y del disparo

    ld hl, copiaOAM + BULLET_OAM_POS2
    ld a, [bullet_posy]
    ld [hl],a
    

    ret

.deactivate_bullet:
    ld a, 0
    ld [bullet_active], a     ; Desactivar disparo

    ; Ocultar el sprite al desactivar el disparo
    ld hl, copiaOAM + BULLET_OAM_POS
    ld a, $00
    ld [hl], a                ; Posición Y fuera de la pantalla para ocultar el sprite
    ret







SECTION "Bullet Data", WRAM0
    bullet_active:   ds 1     ; Estado del disparo (1 = activo, 0 = inactivo)
    bullet_posx:     ds 1     ; Posición X del disparo
    bullet_posy:     ds 1     ; Posición Y del disparo