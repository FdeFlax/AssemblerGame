SECTION "Fisicas", ROM0

    
    ;Actualiza la posicon del sprite del jugador en funcion de su velocidad
    ;Parametros de entrada:  DE direccion de la entidad
    ;Input b: direccion de movimiento
    updatePos::
        ;Actualizar la poscion en X
        ld a, [entityArray + ENTITY_POSX]
        add b
        ld [entityArray + ENTITY_POSX], a 
        call waitVBlank
        ret

    updateOAM::
        ;Actualizar la posicon en la OAM
        ld hl, copiaOAM  ;;Principio de la OAM
        ld a, [entityArray + ENTITY_POSY]
        ld [hl+], a     
        ld a, [entityArray + ENTITY_POSX]
        ld [hl+], a
        inc hl
        inc hl
        ld a, [entityArray + ENTITY_POSY]
        ld [hl+], a     
        ld a, [entityArray + ENTITY_POSX]
        add 8  
        ld [hl],a  
        ret