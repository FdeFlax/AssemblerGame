SECTION "Fisicas", ROM0

    
    ;Actualiza la posicon del sprite del jugador en funcion de su velocidad
    ;Parametros de entrada:  DE direccion de la entidad
    updatePos::
        ;Actualizar la poscion en X
        ld a, [entityArray + ENTITY_POSX]
        ld hl, entityArray + ENTITY_VX
        add [hl]
        ld [entityArray + ENTITY_POSX], a 
        ;Actualizar la poscion en Y
        ld a, [entityArray + ENTITY_POSY]
        ld hl, entityArray + ENTITY_VY
        add [hl]
        ld [entityArray + ENTITY_POSY], a 

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