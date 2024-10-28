;;Constantes del jugador

    DEF ENEMY1_SPRITE_ID1 equ $80
    DEF ENEMY1_SPRITE_ID2 equ $82
    DEF ENEMY1_POSX       equ $00
    DEF ENEMY1_POSY       equ $00
    DEF ENEMY1_VX         equ $01
    DEF ENEMY1_VY         equ $00

    ; Enemy 2 Constants
    DEF ENEMY2_SPRITE_ID1 equ $84
    DEF ENEMY2_SPRITE_ID2 equ $86
    DEF ENEMY2_POSX       equ $00
    DEF ENEMY2_POSY       equ $10
    DEF ENEMY2_VX         equ $01
    DEF ENEMY2_VY         equ $00


    ; Enemy 3 Constants
    DEF ENEMY3_SPRITE_ID1 equ $88
    DEF ENEMY3_SPRITE_ID2 equ $8A
    DEF ENEMY3_POSX       equ $00
    DEF ENEMY3_POSY       equ $20
    DEF ENEMY3_VX         equ $01
    DEF ENEMY3_VY         equ $00

    ; Enemy 4 Constants
    DEF ENEMY4_SPRITE_ID1 equ $AA
    DEF ENEMY4_SPRITE_ID2 equ $AA
    DEF ENEMY4_POSX       equ $00
    DEF ENEMY4_POSY       equ $30
    DEF ENEMY4_VX         equ $01
    DEF ENEMY4_VY         equ $00

 


    DEF POSY equ 80

    DEF DEFAULT_CMP equ $01   ; Valor que indica que la entidad está en uso


    DEF masocho equ 8

    DEF SCREEN_WIDTH equ 160    ; Límite derecho de la pantalla en píxeles (ajustable)
    DEF ROW_INCREMENT equ 10  

DEF PLAYER_SPRITE_ID1 equ $00
DEF PLAYER_SPRITE_ID2 equ $02

SECTION "Entity data", ROM0 

    playerData::
    DB PLAYER_SPRITE_ID1, PLAYER_SPRITE_ID2

       enemy1Data:
    DB ENEMY1_SPRITE_ID1, ENEMY1_SPRITE_ID2, ENEMY1_POSY, ENEMY1_POSX, ENEMY1_VY, ENEMY1_VX

    enemy2Data:
    DB ENEMY2_SPRITE_ID1, ENEMY2_SPRITE_ID2, ENEMY2_POSY, ENEMY2_POSX, ENEMY2_VY, ENEMY2_VX

    enemy3Data:
    DB ENEMY3_SPRITE_ID1, ENEMY3_SPRITE_ID2, ENEMY3_POSY, ENEMY3_POSX, ENEMY3_VY, ENEMY3_VX

    enemy4Data:
    DB ENEMY4_SPRITE_ID1, ENEMY4_SPRITE_ID2, ENEMY4_POSY, ENEMY4_POSX, ENEMY4_VY, ENEMY4_VX

  

;;METODOS ANTIGUOS
    ;     initEntity::

    ;     ld a, [de]
    ;     ld [entityArray + ENTITY_SPRITE_1], a
    ;     inc de
    ;     ld a, [de]
    ;     ld [entityArray + ENTITY_SPRITE_2],a

    ;     ld a, 130
    ;     ld [entityArray + ENTITY_POSY], a
    ;     ld a, 90
    ;     ld [entityArray + ENTITY_POSX], a
    ;     ;Velocidad
    ;     ld a , 3
    ;     ld [entityArray + ENTITY_VX],a
    ;     ld [entityArray + ENTITY_VY],a


    ; ret

    ; configSprites::
    ;     ;;Poner el registro correspondiente a la paleta OBP0 en 11100100
    ;     ld a, %11100100
    ;     ldh [$48], a
    ;     ;;Ponwe un 1 en el bit 1 de la PPU para poder escribir en OAM... y tambien el el bit 2 para la paleta de color??
    ;     ldh a, [$40] 
    ;     or %00000110
    ;     ldh [$40], a

    ;     ld hl, copiaOAM  ;;Principio de la OAM
    ;     ld a, [entityArray + ENTITY_POSY]
    ;     ld [hl+], a     
    ;     ld a, [entityArray + ENTITY_POSX]  
    ;     ld [hl+],a    
    ;     ld a, [entityArray + ENTITY_SPRITE_1]
    ;     ld [hl+], a
    ;     ld [hl+],a
    ;     ;;Siguiente objeto
    ;     ld a, [entityArray + ENTITY_POSY]
    ;     ld [hl+], a     
    ;     ld a, [entityArray + ENTITY_POSX]
    ;     add 8  
    ;     ld [hl+],a    
    ;     ld a, [entityArray + ENTITY_SPRITE_2]
    ;     ld [hl+], a
    ;     ld a, $00
    ;     ld [hl], a
    ; ret



    buscar_hueco:
    ld hl, entityArray
    ld bc, ENTITY_SIZE
    ld de, 10

    .loop  
        ld a, [hl]
        cp 1
        jr nz, encontrado

        dec de
        ld a, d
        or e
        jr z, fin 

        add hl, bc
        jr .loop

    encontrado:
        ld a, 01
        ld [hl], a
        ret

    fin:
        ret
    
    
    initEnemy:
    ; Llamada para buscar un hueco y reservar espacio para la entidad
    ; ld hl, entityArray
    push bc
    ld bc, ENTITY_SIZE
    ld a, 01
    ld [hl], a


    ld a, [de]
    push hl
    push bc
    ld bc, ENTITY_SPRITE_1
    add hl, bc
    ld [hl], a    ; Guardar en la entidad
    pop bc
    pop hl

    inc de
    ; Cargar el sprite 2
    ld a, [de]
    push hl
    push bc
    ld bc, ENTITY_SPRITE_2
    add hl, bc
    ld [hl], a    ; Guardar en la entidad
    pop bc
    pop hl

    inc de
    ld a, [de]
    push hl
    push bc
    ld bc, ENTITY_POSY
    add hl, bc
    ld [hl], a    ; Guardar en la entidad
    pop bc
    pop hl

   inc de
    ; Posición X
    ld a, [posicionXBase]          ; Cargar el valor actual de posicionXBase
    push hl
    push bc
    ld bc, ENTITY_POSX
    add hl, bc
    ld [hl], a                     ; Guardar en la entidad
    pop bc
    pop hl

    ; Reducir posicionXBase en 10 para la siguiente entidad
    ld a, [posicionXBase]
    add 10
    ld [posicionXBase], a 


    inc de
    ld a, [de]
    push hl
    push bc
    ld bc, ENTITY_VY
    add hl, bc
    ld [hl], a    ; Guardar en la entidad
    pop bc
    pop hl

    inc de
    ld a, [de]
    push hl
    push bc
    ld bc, ENTITY_VX
    add hl, bc
    ld [hl], a    ; Guardar en la entidad
    pop bc
    pop hl

    
    add hl, bc
    pop bc
    ret



    initEntity:
        ;call man_entity_alloc           ; Reservar un espacio para la nueva entidad

    ; push de
    ;     call buscar_hueco
    ; pop de
    ld bc, ENTITY_SIZE
    ld a, 01
    ld [hl], a
        ld a, [de]                      
        push hl
        push bc
        ld bc, ENTITY_SPRITE_1
        add hl, bc
        ld [hl], a    ; Guardar en la entidad
        pop bc
        pop hl

        inc de
        
        ld a, [de]   
        push hl
        push bc
        ld bc, ENTITY_SPRITE_2
        add hl, bc
        ld [hl], a    ; Guardar en la entidad
        pop bc
        pop hl

    ; Posición Y
        ld a, 130                       
        push hl
        push bc
        ld bc, ENTITY_POSY
        add hl, bc
        ld [hl], a        ; Guardar en la entidad
        pop bc
        pop hl
        add 20
    ; Posición X
        ld a, 90                       
        push hl
        push bc
        ld bc, ENTITY_POSX
        add hl, bc
        ld [hl], a        ; Guardar en la entidad
        pop bc
        pop hl

    ;Velocidad en X
        ld a, 3                        
        push hl
        push bc
        ld bc, ENTITY_VX
        add hl, bc
        ld [hl], a        ; Guardar en la entidad
        pop bc
        pop hl
    ; Velocidad en Y (horizontal)
        ld a, 0 
        push hl
        push bc
        ld bc, ENTITY_VY
        add hl, bc
        ld [hl], a        ; Guardar en la entidad
        pop bc
        pop hl


        add hl, bc ; para avanzar en el bucle
        ret

    configSprites::
        ;;Poner el registro correspondiente a la paleta OBP0 en 11100100
        ld a, %11100100
        ldh [$48], a
        ;;Ponwe un 1 en el bit 1 de la PPU para poder escribir en OAM... y tambien el el bit 2 para la paleta de color??
        ldh a, [$40] 
        or %00000110
        ldh [$40], a

        ld hl, copiaOAM
        ld b, 0
        ld c, MAX_ENTITIES
        ld de, entityArray
        .loop
            ld a, [de]
            cp 1
            jr nz, .fin
            
            ld a, [entityArray + ENTITY_POSY]
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

                push hl
                ld bc, ENTITY_SPRITE_1
                ld h, d
                ld l, e
                add hl, bc
                ld a, [hl]
                pop hl
                ld [hl+], a
                ld [hl+],a

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

                push hl
                ld bc, ENTITY_SPRITE_2
                ld h, d
                ld l, e
                add hl, bc
                ld a, [hl]
                pop hl
                ld [hl+], a
                ld a, $00
                ld [hl+], a

            pop bc

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

    bucleenemigos:
        ld c, MAX_ENTITIES   ; Número máximo de entidades a generar
        ld b, 3              ; Inicializar `a` para alternar entre los tres tipos (0, 1, 2)

       ; Comprobar el valor de `b` para decidir qué enemigo crear
    .loop
            ld a, b
            cp 0
            jr z, .crearEnemy1
            cp 1
            jr z, .crearEnemy2
            cp 2
            jr z, .crearEnemy3
            cp 3
            jr z, .crearEnemy4


        .continuar:
            dec c                ; Disminuir el contador
            jr z, .fin           ; Si `c` llega a 0, salir del bucle

            inc b                ; Incrementar `b` para pasar al siguiente tipo de enemigo
            cp 4                 ; Limitar `b` a valores de 0-5
            jr c, .loop          ; Si `b` es menor que 6, continuar el bucle
            ld b, 0              ; Reiniciar `b` a 0 si supera 5
            jp .loop

        .crearEnemy1:
            ld de, enemy1Data
            jp .crear

        .crearEnemy2:
            ld de, enemy2Data
            jp .crear

        .crearEnemy3:
            ld de, enemy3Data
            jp .crear

        .crearEnemy4:
            ld de, enemy4Data
            jp .crear


        .crear:
            call initEnemy       ; Inicializar la entidad
            jp .continuar        ; Continuar con el siguiente enemigo

        .fin:
            ret


SECTION "Entity array", WRAM0

    EXPORT ENTITY_COMPONENT
    EXPORT ENTITY_VX
    EXPORT ENTITY_VY
    EXPORT ENTITY_POSY
    EXPORT ENTITY_POSX
    EXPORT ENTITY_SPRITE_1
    EXPORT ENTITY_SPRITE_2
    EXPORT ENTITY_SIZE
    Export posicionArray
    Export numOAM
    EXport MAX_ENTITIES

    

    DEF posicionArray equ 0
    DEF numOAM equ 0
    
      ; Definir tamaño de cada entidad y el tamaño total del array de entidades
    DEF ENTITY_SIZE     equ 7      ; Tamaño de cada entidad (8 bytes, con los atributos)
    DEF MAX_ENTITIES    equ 20    ; Número máximo de entidades
    DEF ENTITY_ARRAY_SIZE equ ENTITY_SIZE * MAX_ENTITIES  ; Tamaño total del array

    RSRESET
    DEF ENTITY_COMPONENT RB 1   ; Byte para indicar si la entidad está activa
    DEF ENTITY_VX        RB 1    ; Velocidad X
    DEF ENTITY_VY        RB 1    ; Velocidad Y
    DEF ENTITY_POSY      RB 1    ; Posición Y
    DEF ENTITY_POSX      RB 1    ; Posición X
    DEF ENTITY_SPRITE_1  RB 1    ; Primer sprite
    DEF ENTITY_SPRITE_2  RB 1    ; Segundo sprite

    

    entityArray::
    DS ENTITY_ARRAY_SIZE  ; Array para 10 entidades (ajústalo según sea necesario)

    




SECTION "Entity OAM Data", WRAM0
ENTITY_OAM_ADDRESS: 
    DS 2  ; Espacio para la dirección de OAM (2 bytes)


