include "include/hardware.inc"

DEF TILES_TOTAL equ $04b0 - $0170

SECTION "Interrupts", ROM0[$40]

  ;$40 VBLANCK
  jp vblankHandler
  ds 5, 0 ;Deja 5 byts de espacio vacios

SECTION "Variables", WRAM0
  EXPORT posicionXBase
  EXPORT posicionXAnterior
  vblankFlag:
  ds 1

  FirstLineFlag:
  ds 1

  posicionXBase: ds 1

  posicionXAnterior: ds 1

  posicionXNave: ds 1
  
  terminajuego: ds 2

SECTION "Utils", ROM0

  vblankHandler::
    push hl
    push af

    call leerBotones  ;;Actualizamos el estado de los botones aprobechando el vblack por frame
    call OAMDMA       ;;Llama a la funcion que inicia la transferencia DMA en la HRAM
    ld hl, vblankFlag
    ld a, 1
    ld [hl], a

    pop af
    pop hl

  reti

  waitVBlank:
    push hl
    push af
    push bc 
    ld hl, vblankFlag
    xor a
    ld [hl], a
    ld c, 1 ;;contador de cuantos vblanck esperar


    .wait:
      halt
      cp a, [hl]
      jr z, .wait

      ;ya ha ocurrido un VBlanck, reiniciamos la bandera
      xor a
      ld [hl], a

      dec c
      jr nz, .wait

    pop bc
    pop af
    pop hl
  ret

   ;Carga en A el valor de la PPU, y realiza la operacion AND para comprobar que la memoria de video sea accesible
   ;La funcion no devuelve hasta que no se cumpla la condicion
  CanDraw::
    ld a, [rSTAT]
    AND %00000010
    jr nz, CanDraw
  ret

  ;;FUncion para apagar la pantalla de la Nintendo, utile para grandes cargas en memoria de video
  ;;Bajo posible asesinato de Fran, asegurarse 90 veces que la PPU esta en los modos 0 o 1 antes de hacerlo
  Apagar_pantalla::
    call CanDraw ;;Comprobamos que la PPU sea accesible
    ldh a, [$40]  ;; Cargamos el valor en A
    and $7F
    ldh [$40], a ;;Apagamos la pantalla
  ret

  ;;Funcion para encender la pantalla de la nintendo pone los bites 7 y 3 de la PPU en 1
  ;;Nos la pela si la PPU esta en modo trabajo
  Encender_pantalla::
    ldh a, [$40]
    or $80 
    ldh [$40], a  
  ret

  Cargar_tiles::
    ld hl, $8000 ;; donde queremos empezar a escribir
    ld de, Nave ;; principio de nuestros tiles
    ld bc, Bullet_end - Nave ;;Contador
    .loop:
      ld a, [de] ;cargamos el valor al que apunta de en a
      ld [hl+], a ;;escribimos ese valor en la vram
      inc de
      dec bc
      ld a, b
      or c
      jr nz, .loop
  ret

    Cargar_letras::
    ld hl, $81A0 ;; donde queremos empezar a escribir
    ld de, Letras ;; principio de nuestros tiles
    ld bc, LetrasFin - Letras ;;Contador
    .loop:
      ld a, [de] ;cargamos el valor al que apunta de en a
      ld [hl+], a ;;escribimos ese valor en la vram
      inc de
      dec bc
      ld a, b
      or c
      jr nz, .loop
  ret

  Cargar_tile_enemigos::
    ld hl, $8800 ;; donde queremos empezar a escribir
    ld de, Enemigos ;; principio de nuestros tiles
    ld bc, EnemigosFin - Enemigos ;;Contador
    .loop:
      ld a, [de] ;cargamos el valor al que apunta de en a
      ld [hl+], a ;;escribimos ese valor en la vram
      inc de
      dec bc
      ld a, b
      or c
      jr nz, .loop
  ret

  Cargar_Fondos::
    ld hl, $9000 ;;Posicion inicial del banco 2
    ld de, mapTile
    ld bc, mapTileEnd - mapTile ;; Contador

    .loop:
      ld a, [de]
      ld [hl+], a
      inc de
      dec bc
      ld a, b
      or c
      jr nz, .loop
  ret

  Cambiar_banco_fondo::
    ldh a , [$40]
    and %11101111
    ldh [$40], a
    ret

  Cambiar_banco_fondo_1::
    ldh a , [$40]
    or %00010000
    ldh [$40], a
    ret

  Cargar_mapa::
    ld hl, mapaTest ;;Puntero a tilemap
    ld de, $9800 ;; puntero a memoria de video
    ld c, 1 ;; iteraciones

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
      ld de, mapTileIndex  ;; Carga la dirección de inicio de los metatiles en DE
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
      
      pop hl
      inc hl
      dec c
      jr nz, .loop

    call Encender_pantalla
    ret

  Borrar_pantalla::
    ld hl, $9800 ;;Cargamos en hl el principio de la pantalla
    ld bc, $9FFF - $9800 ;; El numero de iteracion $ultima direccion de la pantalla - prierma direccion de la pantalla
    .loopDel:
      ld [hl], $7F ;; Asignamos el valor del sprite vacio
      inc hl
      dec bc
      ld a, c
      or b
      jr nz, .loopDel
  ret

  interruptSetup::
    ld a, %00000001
    ld [rIE], a ;Habilita la interrupcion de VBLANK y deshabilita el resto
    reti     ;Retorna y activa IME

  borrarOAM::
    ld hl, copiaOAM ;;puntero al inicio de la OAM
    ld b, 40     ;;40 entradas de la OAM
    ld a, $00

    .borradoOAM:
      ld [hl+], a ;;POscion y a 0
      ld [hl+], a ;;POsicion x a 0
      inc hl
      inc hl      ;;Los ultimos 2 bytes de cada objeto nos dan igual

      dec b
      jr nz, .borradoOAM

  ret




  ;;Literalmente este copia la funcion rutina DMA en la hram en OAMDMA
  copiaRutinaDMA::
    ld hl, rutinaDMA          ;Origen de datos
    ld b, rutinaDMA.fin - rutinaDMA ;Cantidad de bytes a copiar
    ld c, LOW(OAMDMA)         ;Byte bajo de la direccion de destino
  .loopOAM
    ld a, [hl+]
    ld [c], a
    inc c
    dec b
    jr nz, .loopOAM
  ret

  ;;Esta funcion inicia la transferencia DMA y espera los 160 ciclos hasta que acabe
  rutinaDMA::
    ld a, HIGH(copiaOAM) ;Obtiene el byte alto de la direccion
    ldh [rDMA], a         ;;Inicia la transferencia DMA inmediatamente tras la instruccion
    ld a, 40            ;;Espera total de 40*4 = 160 ciclos
  .espera
    dec a            ; 1 ciclo
    jr nz, .espera   ; 3 ciclos
    ret
  .fin


SECTION "Copia OAM", WRAM0, ALIGN[8]

  copiaOAM::
  DS OAM_COUNT*sizeof_OAM_ATTRS




SECTION "OAM DMA", HRAM

  OAMDMA::
  DS rutinaDMA.fin - rutinaDMA


SECTION "Game State Variables", WRAM0
    gameState: ds 1    ; Estado del juego (00 = diálogo, 01 = iniciar juego)






