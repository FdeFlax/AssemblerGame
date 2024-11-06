DEF SCREEN_TOP_BOUND equ 0         ; Límite superior
DEF SCREEN_BOTTOM_BOUND equ 144     ; Límite inferior (altura de la pantalla Game Boy)
DEF SCREEN_LEFT_BOUND equ 0      ; Límite izquierdo
DEF SCREEN_RIGHT_BOUND equ 160   ; Límite derecho (resolución de la pantalla Game Boy)
    DEF VIDA_OAM_POS equ 28 * 4         ; Posición en la OAM para el icono de vida
    DEF VIDA_TILE_3 equ $A4            ; Tile cuando hay 3 vidas
    DEF VIDA_TILE_2 equ $A8             ; Tile cuando hay 2 vidas
    DEF VIDA_TILE_1 equ $AC            ; Tile cuando hay 1 vida
    DEF VIDA_SPRITE_ATTR equ $00        ; Atributos del sprite de vida
    DEF VIDA_POS_X equ $10             ; Posición X para el icono de vida
    DEF VIDA_POS_Y equ $80             ; Posición Y para el icono de vida

DEF POSY_NAVE equ 126

SECTION "Fisicas", ROM0

    
    ;Actualiza la posicon del sprite del jugador en funcion de su velocidad
    ;Parametros de entrada:  DE direccion de la entidad
    ;Input b: direccion de movimiento
updatePos:
  ;Actualizar la poscion en X
    ld a, [entityArray + ENTITY_POSX]
    ld [posicionXNave], a
    add b
    cp SCREEN_LEFT_BOUND + 8
    jp c, fueraLimites 
    cp SCREEN_RIGHT_BOUND - 8
    jp nc, fueraLimites
    ld [entityArray + ENTITY_POSX], a 
    call waitVBlank
    ret

fueraLimites:
    ret
    ;--------VER SI UN ENEMIGO HA TOCADO LA NAVE
verificar_terminajuego:
    ; Verificar si todos los enemigos fueron derrotados
    ld a, [ENEMY_TRACKER]
    cp 0
    jp z, verificar_proximo_nivel   ; Si ENEMY_TRACKER es 0, verificar si hay un próximo nivel

    ; Verificar si quedan vidas
    ld a, [LIFE_TRACKER]
    cp 0
    jp z, irEstadoFinal             ; Si LIFE_TRACKER es 0, ir a EstadoFinal

.fin:
    ret

verificar_proximo_nivel:
    ; Incrementar el nivel actual
    ld a, [currentLevel]
    inc a
    ld [currentLevel], a
    ; Verificar si alcanzamos el total de niveles
    cp TOTAL_NIVELES
    jp z, irEstadoFinal             ; Si alcanzamos el último nivel, ir al EstadoFinal

    ; Preparar el siguiente nivel
    call borrarOAM                  ; Borrar la OAM antes de iniciar el nuevo nivel
    call loadEnemyData              ; Cargar la configuración de enemigos del nuevo nivel
    call EstadoJuego                ; Reiniciar en EstadoJuego
    ret                     ; Retornar

empiezajuego1:
    ld hl, terminajuego    ; Cargar la dirección de terminajuego en HL
    ld [hl], 1          ; Poner el primer byte a 0x01
    ret                    ; Retornar
empiezajuego2:
    ld hl, terminajuego    ; Cargar la dirección de terminajuego en HL
    inc hl                 ; Avanzar a la segunda parte (segundo byte)
    ld [hl], 1          ; Poner el segundo byte a 0x01
    ret                    ; Retornar

terminajuego1:
    ld hl, terminajuego    ; Cargar la dirección de terminajuego en HL
    ld [hl], 0             ; Poner el primer byte a 0
    ret 

terminajuego2:
    ld hl, terminajuego    ; Cargar la dirección de terminajuego en HL
    inc hl                 ; Avanzar a la segunda parte (segundo byte)
    ld [hl], 0             ; Poner el segundo byte a 0
    ret 
checkearposiciones:
    
        ld c, MAX_ENTITIES                    
        ld de, entityArray   
        ld a, [entityArray + ENTITY_POSX]
        ld [posicionXNave],a  
        call empiezajuego1
        call empiezajuego2
            
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
        push bc
        ld bc, ENTITY_POSX
        ld h, d
        ld l, e
        add hl, bc                   ; Calcular posición ENTITY_POSX en la entidad
        pop bc
        
        ld a, [hl]
        ld b, a
        ld a, [posicionXNave]
        add 10
        cp b
        pop hl
        jr c, .continuacion

        ld a, b
        add 16
        ld b, a
        ld a, [posicionXNave]
        add 6
        cp b
        jr nc, .continuacion

        ; push hl
        ; call terminajuego1
        ; pop hl
        
        push hl
        push bc
        ld bc, ENTITY_POSY
        ld h, d
        ld l, e
        add hl, bc
        pop bc                   ; Calcular posición ENTITY_POSX en la entidad
        ld a, [hl]
        ld b, a
        ld a, 115
        cp b
        pop hl
        jr nc, .continuacion

        ld a, b
        add 16
        ld b, a
        ld a, 130
        cp b
        jr nc, .continuacion

        ; push hl
        ; call terminajuego2
        ; pop hl

        
        push hl
        push bc
        call .quitaVida
        pop bc
        pop hl


        .continuacion
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


        .quitaVida

            push af
            call playstartSound                      
            ld a, [LIFE_TRACKER]
            dec a
            ld [LIFE_TRACKER], a
            ; Desactivar la entidad en entityArray
            ld bc, ENTITY_COMPONENT
            ld h, d
            ld l, e
            add hl, bc
            ld a, 0
            ld [hl], a                   

            ld a, [ENEMY_TRACKER]
            dec a
            dec a
            ld [ENEMY_TRACKER], a
            pop af  

            ret  

initVidaOAM:
    ld hl, copiaOAM + VIDA_OAM_POS
    ld a, VIDA_POS_Y
    ld [hl], a                   
    inc hl
    ld a, VIDA_POS_X
    ld [hl], a                   
    inc hl
    ld a, VIDA_TILE_3            ; Inicializa con el tile para 3 vidas
    ld [hl], a                  
    inc hl
    ld a, VIDA_SPRITE_ATTR
    ld [hl], a                   
    ret
updateVidaOAM:
    ld a, [LIFE_TRACKER]
    ld hl, copiaOAM + VIDA_OAM_POS + 2  ; Dirección del tile en la OAM
    cp 3
    jr z, .tres_vidas
    cp 2
    jr z, .dos_vidas
    cp 1
    jr z, .una_vida
    jp .sin_vidas                    

.tres_vidas:
    ld a, VIDA_TILE_3
    jr .actualizar_tile
.dos_vidas:
    ld a, VIDA_TILE_2
    jr .actualizar_tile
.una_vida:
    ld a, VIDA_TILE_1
    jr .actualizar_tile

.actualizar_tile:
    ld [hl], a                       
    ret

.sin_vidas:
    call irEstadoFinal
    ret

checkearHit:

    ; obtener bala y comprobar si esta activa
    ; si esta activa obtener los enemigos del entity array
    ; comprobar uno a uno si se solapan
    ; en caso de solaparse desactivar la bala y el enemigo, tambien mover el enemigo a 0,0
    ; en caso de no solaparse no deberia pasar nada, la bala se desactivara sola al salir de la pantalla

    ld a, [bullet_active]
    cp 0
    jp z, fueraLimites


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
        jp nz, .continuacion  
        
        ld a, [bullet_active]
        cp 0
        jp z, fueraLimites                ; Si no está activa, continuar al siguiente
        
        ; Actualizar la posición en X
        push hl
        push bc
        ld bc, ENTITY_POSX
        ld h, d
        ld l, e
        add hl, bc                   ; Calcular posición ENTITY_POSX en la entidad
        pop bc


        ld a, [hl]
        ld b, a
        ld a, [bullet_posx]
        add 10
        cp b
        pop hl
        jr c, .continuacion


        ld a, b
        add 16
        ld b, a
        ld a, [bullet_posx]
        add 4
        cp b
        jr nc, .continuacion
        

        push hl
        push bc
        ld bc, ENTITY_POSY
        ld h, d
        ld l, e
        add hl, bc
        pop bc                   ; Calcular posición ENTITY_POSX en la entidad


        ld a, [hl]
        ld b, a
        ld a, [bullet_posy]
        add 8
        cp b
        pop hl
        jr c, .continuacion

        ld a, b
        add 16
        ld b, a
        ld a, [bullet_posy]
        add 4
        cp b
        jr nc, .continuacion


        call .desactivarBala
        push hl
        push bc
        call .desactivarEntidad
        pop bc
        pop hl

; -------------------------------------------------------------
; 
;                  DESACTIVAR ENEMIGO
; 
; -------------------------------------------------------------


        .continuacion
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

ret

.desactivarBala:

    call playExplosion
    ld a, 0
    call waitVBlank
    ld [bullet_active], a
    ld [copiaOAM + 30*4], a
    ld [copiaOAM + 31*4], a



.desactivarEntidad:
    ; Desactivar la entidad en entityArray
    ld bc, ENTITY_COMPONENT
    ld h, d
    ld l, e
    add hl, bc
    ld a, 0
    ld [hl], a                   
    
    ld a, [ENEMY_TRACKER]
    dec a
    ld [ENEMY_TRACKER], a

    ; Actualizar la posición en X
   
    



    ret






irEstadoInicio:
    ld a, 00
    ld [gameState],a
    call Apagar_pantalla
    call Borrar_pantalla
    call Encender_pantalla
    call borrarOAM
    call EstadoInicio
    ret

irEstadoFinal:
    ld a, 00
    ld [gameState],a
    call Apagar_pantalla
    call Borrar_pantalla
    call Encender_pantalla
    call borrarOAM
    call EstadoFinal
    ret

;;-------------ACTUALIZAR POSICIONES
 updatePosEnemigos::
    ld a, [currentEnemyCount]
    ld c, a                    
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
        jp nz, .continuacion                ; Si no está activa, continuar al siguiente
        
        ; Actualizar la posición en X
        push bc
        push hl
        ld bc, ENTITY_POSX
        ld h, d
        ld l, e
        add hl, bc                   ; Calcular posición ENTITY_POSX en la entidad
        ld a, [hl]      
                     
        pop hl
        pop bc

        push bc
        push hl
        ld bc, ENTITY_VX
        ld h, d
        ld l, e
        add hl, bc                   ; Calcular posición ENTITY_VX en la entidad
        add [hl]                     ; Sumar la velocidad en X
        pop hl
        pop bc

        cp SCREEN_RIGHT_BOUND        
        jr nc, .reverse_direction_x  

        cp SCREEN_LEFT_BOUND        
        jr c, .reverse_direction_x  
        push bc
        push hl
        ld bc, ENTITY_POSX
        ld h, d
        ld l, e
        add hl, bc
        ld [hl], a                   ; Guardar la posición X actualizada en ENTITY_POSX
        pop hl
        pop bc
        ; Actualizar la posición en Y
        push bc
        push hl
        ld bc, ENTITY_POSY
        ld h, d
        ld l, e
        add hl, bc                
        ld a, [hl]                   
        pop hl
        pop bc

        push bc
        push hl
        ld bc, ENTITY_VY
        ld h, d
        ld l, e
        add hl, bc                  
        add [hl]                   
        pop hl
        pop bc
        ; Comprobar si toca el borde inferior
  
        

        cp SCREEN_TOP_BOUND          
        jr c, .reverse_direction_y  
        push bc
        push hl
        ld bc, ENTITY_POSY
        ld h, d
        ld l, e
        add hl, bc
        ld [hl], a                  
        pop hl
        pop bc
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
        push bc
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
        pop bc

        push bc
        push hl
        ld bc, ENTITY_POSY
        ld h, d
        ld l, e
        add hl, bc
        ld a, [hl]
        add 10                        ; Reducir Y en 10
        ld [hl], a                   
        pop hl
        pop bc

        jp .continuacion

.reverse_direction_y:
    push bc
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
    pop bc
    jp .continuacion







updateOAM::
        ld hl, copiaOAM  ;; Principio de la OAM
        ld a, [currentEnemyCount]
        ld c, a
        ld de, entityArray
        ; Sprite 1
            .loop
                ld a, [de]
                cp 1
                jr nz, .borrarEntidad

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


                pop bc   
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
      .borrarEntidad:
                push bc
                push hl
                ld bc, ENTITY_POSY
                ld h, d
                ld l, e
                add hl, bc
                ld a, 0
                pop hl
                ld [hl+], a     
                
                push hl
                ld bc, ENTITY_POSX
                ld h, d
                ld l, e
                add hl, bc
                ld a, 0
                pop hl
                ld [hl+],a   

                inc hl
                inc hl

                push hl
                ld bc, ENTITY_POSY
                ld h, d
                ld l, e
                add hl, bc
                ld a, 0
                pop hl
                ld [hl+], a
    
                push hl
                ld bc, ENTITY_POSX
                ld h, d
                ld l, e
                add hl, bc
                ld a, 0
                pop hl
                add 8  
                ld [hl+],a    
                
                inc hl
                inc hl


                pop bc
            jr .continuar
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