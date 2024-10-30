;;----------LICENSE NOTICE-------------------------------------------------------------------------------------------------------;;
;;  This file is part of GBTelera: A Gameboy Development Framework                                                               ;;
;;  Copyright (C) 2024 ronaldo / Cheesetea / ByteRealms (@FranGallegoBR)                                                         ;;
;;                                                                                                                               ;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    ;;
;; files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy,    ;;
;; modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the         ;;
;; Softwareis furnished to do so, subject to the following conditions:                                                           ;;
;;                                                                                                                               ;;
;; The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.;;
;;                                                                                                                               ;;
;; THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          ;;
;; WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         ;;
;; COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   ;;
;; ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         ;;
;;-------------------------------------------------------------------------------------------------------------------------------;;

SECTION "Entry point", ROM0[$150]

Setup:
   ld a, 00
   ld [gameState],a
   call copiaRutinaDMA ;;Antes de nada copiamos la rutina DMA en HRAM
   call interruptSetup ;;Habilitamos las interrupciones; en cada vblank habrá una transferencia DMA
   call Apagar_pantalla ;;Apagamos la pantalla para poder borrar y cargar los tiles
   call Borrar_pantalla ;;Borramos la pantalla
   call Cargar_tiles    ;;Cargamos los tiles aprovechando la pantalla apagada
   call Cargar_tile_enemigos
   call Cargar_letras
   call Cargar_Fondos
ret


main::
   ; En el archivo principal (main.asm o similar)
   

   call Setup
   call Encender_pantalla ;;Encendemos la pantalla de nuevo
   call borrarOAM         ;;Borramos el contenido de la OAM (en la copia)

   EstadoInicio:
      push hl
      push de
      ld hl, linea
      call escribeDialogo
      pop de
      pop hl

      .loop:

         call Cambiar_banco_fondo_1
         call pulsarparainiciarjuego    
         ld a, [gameState]
         cp 01
         jr z, EstadoJuego          
                  
      jp .loop 
   ret

   EstadoJuego:
      ld a, 30          
      ld [posicionXBase], a 
      push hl
      push de
      ld hl, linea2
      call escribeDialogo
      pop de
      pop hl
      ld de, playerData      ;;datos de los sprites del jugador en manager.asm
      call initEntity        ;; Iniciamos la estructura donde esta nuestro jugador

      call bucleenemigos

      ; Inicializar el jugador
      ld bc, ENTITY_SIZE 
      call configSprites
      call Cambiar_banco_fondo 
      call Cargar_mapa
         .gameplay:
         ld de, entityArray
         call updateMove
         call updatePosEnemigos
         call checkearposiciones
         call verificar_terminajuego
         call disparar
         call update_bullet
         call updateOAM
         call waitVBlank
         jp .gameplay
   ret


   jr @
   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)

