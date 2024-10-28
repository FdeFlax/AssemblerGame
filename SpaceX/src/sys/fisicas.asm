DEF SCREEN_TOP_BOUND equ 0         ; Límite superior
DEF SCREEN_BOTTOM_BOUND equ 144     ; Límite inferior (altura de la pantalla Game Boy)
DEF SCREEN_LEFT_BOUND equ 0      ; Límite izquierdo
DEF SCREEN_RIGHT_BOUND equ 160   ; Límite derecho (resolución de la pantalla Game Boy)
DEF mas4 equ 8
DEF masocho equ 4

SECTION "Fisicas", ROM0

    
    ;Actualiza la posicon del sprite del jugador en funcion de su velocidad
    ;Parametros de entrada:  DE direccion de la entidad
    ;Input b: direccion de movimiento
updatePos:
  ;Actualizar la poscion en X
    ld a, [entityArray + ENTITY_POSX]
    add b
    ld [entityArray + ENTITY_POSX], a 
    call waitVBlank
    ret


 updatePosEnemigos::
    ld c, MAX_ENTITIES                    
    ld de, entityArray           
    push hl
    ld hl, entityArray
    ld de, ENTITY_SIZE
    add hl, de
    ld d, h
    ld e, l
    pop hl

    .loop
        ld a, [de]                  
        cp 1                         
        jp nz, .continuacion                  ; Si no está activa, continuar al siguiente

        ; Actualizar la posición en X
        push hl
        ld bc, ENTITY_POSX
        ld h, d
        ld l, e
        add hl, bc                   ; Calcular posición ENTITY_POSX en la entidad
        ld a, [hl]                   
        pop hl

        push hl
        ld bc, ENTITY_VX
        ld h, d
        ld l, e
        add hl, bc                   ; Calcular posición ENTITY_VX en la entidad
        add [hl]                     ; Sumar la velocidad en X
        pop hl

        cp SCREEN_RIGHT_BOUND        
        jr nc, .reverse_direction_x  

        cp SCREEN_LEFT_BOUND        
        jr c, .reverse_direction_x  

        push hl
        ld bc, ENTITY_POSX
        ld h, d
        ld l, e
        add hl, bc
        ld [hl], a                   ; Guardar la posición X actualizada en ENTITY_POSX
        pop hl

        ; Actualizar la posición en Y
        push hl
        ld bc, ENTITY_POSY
        ld h, d
        ld l, e
        add hl, bc                
        ld a, [hl]                   
        pop hl

        push hl
        ld bc, ENTITY_VY
        ld h, d
        ld l, e
        add hl, bc                  
        add [hl]                   
        pop hl

        ; Comprobar si toca el borde inferior
        cp SCREEN_BOTTOM_BOUND       
        jp nc, .eliminar_entidad    ; Si toca el límite inferior, eliminar

        cp SCREEN_TOP_BOUND          
        jr c, .reverse_direction_y  

        push hl
        ld bc, ENTITY_POSY
        ld h, d
        ld l, e
        add hl, bc
        ld [hl], a                  
        pop hl

    .continuacion:
        push bc
        push hl
        ld bc, ENTITY_SIZE           ; Tamaño de cada entidad
        ld h, d
        ld l, e
        add hl, bc                   ; Avanzar a la siguiente entidad
        ld d, h
        ld e, l
        pop hl
        pop bc

        dec c
        jp nz, .loop                   ; Si se procesaron todas las entidades, terminar

        ret

    .reverse_direction_x:
        push hl
        ld bc, ENTITY_VX
        ld h, d
        ld l, e
        add hl, bc
        ld a, [hl]
        xor $FF                       ; Invertir la velocidad en X
        inc a
        ld [hl], a                    
        pop hl

        push hl
        ld bc, ENTITY_POSY
        ld h, d
        ld l, e
        add hl, bc
        ld a, [hl]
        add 10                        ; Reducir Y en 10
        ld [hl], a                   
        pop hl

        jp .continuacion

.reverse_direction_y:
    push hl
    ld bc, ENTITY_VY
    ld h, d
    ld l, e
    add hl, bc
    ld a, [hl]
    xor $FF                       ; Invertir la velocidad en Y
    inc a
    ld [hl], a                    ; Invertir la velocidad Y en lugar de enviar al borde opuesto
    pop hl

    push hl
    ld bc, ENTITY_POSY
    ld h, d
    ld l, e
    add hl, bc
    ld a, [hl]
    sub 10                        ; Reducir Y en 10
    ld [hl], a                   
    pop hl

    jp .continuacion

.eliminar_entidad:
    push hl
    ld bc, ENTITY_COMPONENT
    ld h, d
    ld l, e
    add hl, bc
    ld a, 0                        ; Cargar 0 en `a` para desactivar la entidad
    ld [hl], a                     ; Marcar entidad como inactiva
    pop hl
    jp .continuacion

    .fin:
        ret




updateOAM::
        ld hl, copiaOAM  ;; Principio de la OAM
        ld c, MAX_ENTITIES
        ld de, entityArray
        ; Sprite 1
            .loop
                ld a, [de]
                cp 1
                jr nz, .continuar

                push bc

                push hl
                ld bc, ENTITY_POSY
                ld h, d
                ld l, e
                add hl, bc
                ld a, [hl]
                pop hl
                ld [hl+], a     
                
                push hl
                ld bc, ENTITY_POSX
                ld h, d
                ld l, e
                add hl, bc
                ld a, [hl]
                pop hl
                ld [hl+],a   

                inc hl
                inc hl

                push hl
                ld bc, ENTITY_POSY
                ld h, d
                ld l, e
                add hl, bc
                ld a, [hl]
                pop hl
                ld [hl+], a
    
                push hl
                ld bc, ENTITY_POSX
                ld h, d
                ld l, e
                add hl, bc
                ld a, [hl]
                pop hl
                add 8  
                ld [hl+],a    
                
                inc hl
                inc hl


            pop bc                     ; Guardar la posición X en la OAM
                ; Fin de la actualización de la OAM
            .continuar
                dec c
                jr z, .fin
            
                push bc
                push hl
                ld bc, ENTITY_SIZE
                ld h, d
                ld l, e
                add hl, bc
                ld d, h
                ld e, l
                pop hl
                pop bc
                jr .loop
                ret
      .fin:
      ret


; ANTIGUO UPDATE OAM
    ; updateOAM::
    ;     ;Actualizar la posicon en la OAM
    ;     ld hl, copiaOAM  ;;Principio de la OAM
    ;     ld a, [entityArray + ENTITY_POSY]
    ;     ld [hl+], a     
    ;     ld a, [entityArray + ENTITY_POSX]
    ;     ld [hl+], a
    ;     inc hl
    ;     inc hl
    ;     ld a, [entityArray + ENTITY_POSY]
    ;     ld [hl+], a     
    ;     ld a, [entityArray + ENTITY_POSX]
    ;     add 8  
    ;     ld [hl],a  
    ;     ret
      