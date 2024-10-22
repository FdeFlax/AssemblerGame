;;Constantes del jugador
DEF PLAYER_SPRITE_ID1 equ $00
DEF PLAYER_SPRITE_ID2 equ $02

SECTION "Entity data", ROM0 

    playerData::
    DB PLAYER_SPRITE_ID1, PLAYER_SPRITE_ID2

    ;;INPUT DE,direcion inical de la playerData
    initEntity::

        ld a, [de]
        ld [entityArray + ENTITY_SPRITE_1], a
        inc de
        ld a, [de]
        ld [entityArray + ENTITY_SPRITE_2],a

        ld a, 130
        ld [entityArray + ENTITY_POSY], a
        ld a, 90
        ld [entityArray + ENTITY_POSX], a
        ;Velocidad
        ld a , 3
        ld [entityArray + ENTITY_VX],a
        ld [entityArray + ENTITY_VY],a


    ret

    configSprites::
        ;;Poner el registro correspondiente a la paleta OBP0 en 11100100
        ld a, %11100100
        ldh [$48], a
        ;;Ponwe un 1 en el bit 1 de la PPU para poder escribir en OAM... y tambien el el bit 2 para la paleta de color??
        ldh a, [$40] 
        or %00000110
        ldh [$40], a

        ld hl, copiaOAM  ;;Principio de la OAM
        ld a, [entityArray + ENTITY_POSY]
        ld [hl+], a     
        ld a, [entityArray + ENTITY_POSX]  
        ld [hl+],a    
        ld a, [entityArray + ENTITY_SPRITE_1]
        ld [hl+], a
        ld [hl+],a
        ;;Siguiente objeto
        ld a, [entityArray + ENTITY_POSY]
        ld [hl+], a     
        ld a, [entityArray + ENTITY_POSX]
        add 8  
        ld [hl+],a    
        ld a, [entityArray + ENTITY_SPRITE_2]
        ld [hl+], a
        ld a, $00
        ld [hl], a
    ret

SECTION "Entity array", WRAM0

    EXPORT ENTITY_VX
    EXPORT ENTITY_VY
    EXPORT ENTITY_POSY
    EXPORT ENTITY_POSX

    RSRESET
    DEF ENTITY_POSY RB 1
    DEF ENTITY_POSX RB 1
    DEF ENTITY_VX   RB 1
    DEF ENTITY_VY   RB 1
    DEF ENTITY_SPRITE_1 RB 1
    DEF ENTITY_SPRITE_2 RB 1
    DEF ENTITY_SIZE RB 0

    entityArray::
    DS ENTITY_SIZE