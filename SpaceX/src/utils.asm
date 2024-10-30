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
    ld bc, Nav_end - Nave ;;Contador
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






