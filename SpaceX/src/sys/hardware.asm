include "include/hardware.inc"

SECTION "Input variables", HRAM

    estadoBotones:
    ds 1
    flancoAscendente:
    ds 1

SECTION "Read Hardware", ROM0

;;Registros modificados A, F, B
leerBotones::
    push af
    push bc

    ld a, $20       ;Para las direcciones
    ldh [rP1], a    ;Pedirle al chip que actualice su estado
    ldh a, [rP1]    ;           
    ldh a, [rP1]    ;Esperar algunas veces... xD
    ldh a, [rP1]    ;Guardar la informacion en a
    cpl             ;Invierte bits (1 = seleccionado, 0 = no seleccionado)
    and $0F         ;Borra los bits que no indican el estado de los botones
    swap a          ;Mueve los bits nibble superior
    ld b, a         ;Guardamos en b

    ld a, $10       ;Repetimos pero ahora para los botones
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0F

    or b            ;Recuperar el estado de las direcciones
                    ;En este punto A contiene el estado de los botones
                    ;A = [D|U|L|R|St|Se|B|A]
    ld b, a
    ldh a, [estadoBotones] ;Recupera el estado de los botones el frame anterior
    xor b
    and b                   ;obtenemos el flanco ascendente en A 
    ldh [flancoAscendente], a
    ld a,b
    ldh [estadoBotones], a

    ld a, $30
    ldh [rP1], a ;Deselecciona todos los botones

    pop bc
    pop af
    ret

;;Esta funcion analiza si algun PAD(L and R) y actualiza la poscion de la nave en consecuencia
updateMove::
    ldh a, [flancoAscendente]   ;;Guardamos el valor del flancoAscendente en a
    cp PADF_LEFT                   ;;Hacemos la resta con el valor del boton A
    ld b, -5
    jp z , updatePos
    ldh a, [flancoAscendente]
    cp PADF_RIGHT
    ld b, 5
    jp z, updatePos 

ret

;; Función que lee el botón "A"
pulsarparainiciarjuego ::
    ldh a, [flancoAscendente]   
    and %00000001               
    ret z                      
    ld a, 01                      
    ld [gameState], a
    
    ret


disparar:
    ldh a, [flancoAscendente]  
    and %00000001              
    ret z                      
    call fire_bullet
    
    ret
