SECTION "Mapeado", ROM0

    ;;Funcion encargada de cargar los tiles del mapa en el banco2
    ;;INPUTS
    ;;de ---> Inicio de los tiles
    ;;bc --->Contador, tamaño de los tiles a cargar
    Cargar_Fondos::
        ld hl, $9000 ;;Posicion inicial del banco 2
        .loop:
        ld a, [de]
        ld [hl+], a
        inc de
        dec bc
        ld a, b
        or c
        jr nz, .loop
    ret

    ;;Funcion que cambia el banco de fondo al 2
  Cambiar_banco_fondo::
    ldh a , [$40]
    and %11101111
    ldh [$40], a
    ret

    ;;Funcion que lee del mapa y dibuja el mismo en la memoria de video
    ;;Input
    ;;Hl ----> Inicio de la etiqueta del mapa
  Cargar_mapa::
    ld a, %11011000
    ldh [$47], a
    ld de, $9800 ;; puntero a memoria de video
    ld c, 10 ;; iteraciones
    ld b, 9

    call Apagar_pantalla
    .loop:
      ld a, [hl];;obtener la id
      ;; id * 4
      add a  
      add a
      push hl
      push de
      ld l, a          ;; Guarda el resultado de ID * 4 en L
      ld h, 0          ;; Establece H en 0 para usar HL como puntero de índice
      ld de, inicioSheetIndex  ;; Carga la dirección de inicio de los metatiles en DE
      add hl, de       ;; Suma el inicio de los metatiles al offset calculado
      pop de
      ;;Ahora hl apunta al metatile (4 tiles) que queremos copiar

      ;;Dibujar el metatile (copiar los cuatro tiles en un bloque 2x2)
      ld a, [hl]  ;;Carga el primer tile del metatile
      ld [de], a  ;;Lo escribe en vram
      inc de      ;;Avanzar en  la memoria de video
      ;;Segundo tile
      inc hl      ;;Avanza al siguiente tile del metatile
      ld a, [hl]    ;;Carga el segundo tile del metatile
      ld [de], a    ;;Lo escribe en VRAM
      dec de      ;;Avanza en la memoria de video

      ld a, e
      add a, $20
      ld e, a

      jr nc, .no_carry
      inc d

      .no_carry:
          ;; Tercer tile (abajo izquierda)
          inc hl
          ld a, [hl]       ;; Carga el tercer tile del metatile
          ld [de], a       ;; Escribe el tile en VRAM (abajo izquierda)
          inc de           ;; Avanza al siguiente espacio en VRAM
          inc hl           ;; Avanza al siguiente tile en el metatile

          ;; Cuarto tile (abajo derecha)
          ld a, [hl]       ;; Carga el cuarto tile del metatile
          ld [de], a       ;; Escribe el tile en VRAM (abajo derecha)
          inc de           ;; Avanza al siguiente espacio en VRAM

          ld a, e
          sub a, $20
          ld e, a
          jr nc, .no_carry_down
          dec d
          .no_carry_down:
      
      pop hl
      inc hl
      dec c
      jr nz, .loop

      ;;Pasar a la siguiente fila
      ld a, e
      add a, $2C
      ld e, a
      jr nc, .no_carry_2
      inc d
      .no_carry_2:
      ld c, 10
      dec b
      jr nz, .loop


    call Encender_pantalla
    ret