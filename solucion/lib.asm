global intCmp
global intClone
global intDelete
global intPrint
global strCmp
global strClone
global strDelete
global strPrint
global strLen
global arrayNew
global arrayGetSize
global arrayAddLast
global arrayGet
global arrayRemove
global arraySwap
global arrayDelete
global listNew
global listGetSize
global listAddFirst
global listGet
global listRemove
global listSwap
global listClone
global listDelete

global cardNew
global cardGetSuit
global cardGetNumber
global cardGetStacked
global cardCmp
global cardClone
global cardAddStacked
global cardDelete
global cardPrint

extern listPrint,fprintf,malloc,fopen,fclose, free, getCloneFunction, getDeleteFunction, listAddLast	

section .data
%define tamaño_puntero 8
formato_fprintf_int: db '%d' , 0
formato_fprintf_string: db '%s' , 0 
formato_fprintf_card: db "{%s-%d-" , 0
formato_fprintf_llave: db "}", 0
NULL: db "NULL", 0

section .text

; ** Int **--------------------------------------------------------------------------------

; int32_t intCmp(int32_t* a, int32_t* b)
intCmp: 
; int32_t* a -> rdi 
; int32_t* b -> rsi
    push rbp
    mov rbp, rsp

    mov edx, [rdi]
    cmp edx, [rsi] 
    je .iguales
    jg .mayor

    mov dword eax, 1      ; a < b
    jmp .fin
.iguales:           ; a = b
    mov dword eax, 0
    jmp .fin
.mayor:             ; b < a 
    mov dword eax, -1 
    jmp .fin
.fin:
    pop rbp
	ret
;---------------------------------------------------
; int32_t* intClone(int32_t* a)
intClone:
;int32_t* a -> rdi
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8 

    mov dword ebx, [rdi]; preservo el numero

    mov rdi, 4 
    call malloc 
    mov [rax] , ebx

    add rsp, 8
    pop rbx
    pop rbp
    ret
;---------------------------------------------------
; void intDelete(int32_t* a)
intDelete:
    jmp free
 
;---------------------------------------------------
; void intPrint(int32_t* a, FILE* pFile)
; int32_t* a -> rdi
; FILE* pFIle -> rsi

intPrint:
    push rbp
    mov rbp, rsp
	push rbx
	push r12    
;fprintf(pFIle, "%d", a)
; pFIle = puntero ->rdi
; "%d" = formato_fprintf -> rsi
; a -> puntero a entero -> rdx

    mov rbx, rdi 	;rbx<- int*
    mov r12, rsi 	;r12<- file*

    mov rdi, r12 				 ;rdi<- file
    mov rsi, formato_fprintf_int ;rsi<- formato
    mov rdx, [rbx]				 ;rdx<- valor del puntero	
    mov rax, 0

    call fprintf   
  	
  	pop r12
  	pop rbx
    pop rbp
    ret

; ** String **-------------------------------------------------------------------------------

; int32_t strCmp(char* a, char* b)
strCmp: ;25 ints
    ;char* a -> rdi
    ;char* b -> rsi
;Stack Frame (armado)
    push rbp
    mov rbp, rsp

    mov cl, [rdi] ;a
    mov dl, [rsi] ;b
.comparacion:
    cmp byte cl, dl
    je .siguiente ;pasa al sig char
    jl .menor ;devuelve 1
    jmp .mayor ; devuelve -1
.siguiente:
    cmp byte cl, 0 ;vino aca porque son iguales, veo si estan en cero los dos
    je .iguales
    inc rdi
    mov cl, [rdi]
    inc rsi
    mov dl, [rsi]
    jmp .comparacion
.menor:
    mov eax, 1
    jmp .fin
.mayor:
    mov eax, -1
    jmp .fin

.iguales:
    mov eax, 0 
.fin:
    pop rbp
    ret
;---------------------------------------------------
; char* strClone(char* a)
strClone: ;19 inst
; char* a -> rdi
;rsi -> rbx, r12 -> rcx
    push rbp
    mov rbp, rsp
    push rbx
    push r12


    mov rbx, rdi; lo cambio de registro para el malloc
    call strLen
    inc rax
    mov rdi, rax ;lo uso para el malloc
    mov r12, rax ; para tener la long del string
    call malloc ;rax tiene el puntero a la pos alocada
    mov rdi, rax ; para traversar las pos de memoria alocadas
    ;Ciclo
.next:
    cmp r12, 0 ; rcx tiene el strLen, lo decremento hasta que ya llega a cero.
    je .fin
    mov dl, [rbx] ;le paso el char
    mov [rdi], dl ;lo escribo en la memoria
    inc rbx ;paso al sig char
    inc rdi ;paso a la sig pos de memoria
    dec r12 ;decremento la strLen
    jmp .next
;Stackframe (armado)
.fin:

    pop r12
    pop rbx
    pop rbp
    ret

;---------------------------------------------------
; void strDelete(char* a)
strDelete: ; 1 inst
;char* : rdi
    jmp free
;---------------------------------------------------
; void strPrint(char* a, FILE* pFile)
strPrint: ;18 inst
;char* a -> rdi
;FILE* pfile -> rsi

;fprintf(pFIle, "%s", a)
; pFIle = puntero ->rdi
; "%s" = formato_fprintf_string -> rsi
; a -> puntero a string -> rdx
;Stackframe (armado)
	push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8

    ;chequeo si es vacio
    mov rbx, rsi
    cmp byte [rdi], 0
    je .vacio
    ;no es vacio, hago fprintf
    mov rdx, rdi ; el char a
    mov rdi, rsi ;el pFile 
    mov rsi, formato_fprintf_string; formato_fprintf
    mov rax, 0
    call fprintf
    jmp .fin

.vacio:
    ;que escriba null
    mov rdx, 0 ; el char a
    mov rdi, rsi ;el pFile 
    mov rsi, NULL ;null
    mov rax, 0 
    call fprintf

.fin:
    mov rsi, rbx

    add rsp, 8
    pop rbx
    pop rbp
    ret
;---------------------------------------------------
; uint32_t strLen(char* a)
strLen: ;7 inst
;Stackframe (armado)
    push rbp
    mov rbp, rsp
;Codigo
    mov eax, 0
    mov sil, [rdi]
;Ciclo
.next:
    cmp byte sil, 0
    je .fin
    inc rdi
    mov sil, [rdi] 
    inc eax
    jmp .next
;Stackframe (limpieza)
.fin:
    pop rbp
    ret

; ** Array **-------------------------------------------------------------------------------------------

; array_t* arrayNew(type_t t, uint8_t capacity) 24 inst
arrayNew:
;Stackframe (armado)
   push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r14
    sub rsp, 8

;rdi<- type_t t; rsi<- 8 bits capacity
    mov ebx, edi        ;muevo el type a rbx
    mov byte r12b, sil     	  ;muevo el valor de capacity a r12b

    ;creo el espacio para el arreglo
    ;porque el arreglo guarda punteros a datos

    ;rbx<-type, r12<-capacity

    ;espacio de memoria que necesito: capacity * tamaño puntero, shl r12b, 3
    movzx rax, r12b
    shl rax, 3
    mov rdi, rax
    call malloc             ;pido los bytes
    mov r14, rax            ;guardo el puntero en r14

    ;r14<-void**

    ;creo el nodo del arreglo
    mov rdi, 16    
    call malloc         	;en rax tengo el puntero nodo principal

    ;rax<- array*

    mov [rax], ebx        ;pongo el type
    mov byte [rax+4], 0    		;pongo el size=0 (ocupados), size de int8
    mov byte [rax+5], r12b     	;pongo el capacity
    mov [rax+8], r14    	;pongo el puntero

;Stackframe (limpieza)
	add rsp, 8
    pop r14
    pop r12
    pop rbx
    pop rbp
    ret

;---------------------------------------------------
; uint8_t  arrayGetSize(array_t* a) 3 inst
arrayGetSize:
;rdi<- puntero array
	mov al, [rdi+4]
	ret
;---------------------------------------------------
; void  arrayAddLast(array_t* a, void* data) 20 inst

arrayAddLast:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp,8
;rdi<-array, rsi<- void*

	mov rbx, rdi 		;rbx<- array*
	mov r12, rsi 		;r12<- void*

	;rbx: array*, r12:void* original

	mov dl, [rbx+4] 	;rdx<- size
	cmp dl, [rbx+5]		;comparo con capacity, si son iguales chau    
	je .fin

	;hay capacity left, lo agrego
	;lo clono
	mov ecx, [rbx]
	mov edi, ecx		;muevo el type
	call getCloneFunction 	;consigo clone function del type
	mov rdi, r12 		;rdi <- void* 
	call rax			;llamo a la funcion
	mov r13, rax 		;r13 <- void* clonado
	;r13:void* clonado

	;lo muevo
	;xor rcx, rcx
	mov cl, [rbx+4]     ;rcx<-size, muevo y extiendo
	movzx rcx, cl	
	mov r8, [rbx+8] 	;r8<- void**

	;última posición libre: array* de datos +indice*tamaño
	;array*: r8, indice: rcx, tamaño: 8
	mov [r8+rcx*8], r13 	;muevo el dato 
	inc byte [rbx+4]

.fin:
	add rsp,8
	pop r13
	pop r12
	pop rbx
    pop rbp
	ret
;---------------------------------------------------
; void* arrayGet(array_t* a, uint8_t i) 8 inst
arrayGet:
 	push rbp
    mov rbp, rsp

    xor rax, rax
    cmp byte sil, [rdi+4] 	  ;comparo con el size
    jge .fin				  ;si es igual o más grande me voy	

    movzx rsi, sil
    mov rdx, [rdi+8]          ;rdx <- void**
    mov rax, [rdx+rsi*8]

.fin:
    pop rbp
    ret
;---------------------------------------------------
; void* arrayRemove(array_t* a, uint8_t i) 24 inst
arrayRemove:
    push rbp
    mov rbp, rsp
    push rbx
    push r13
    push r14
    sub rsp, 8

    xor rax, rax        ;seteo rax en 0
    cmp sil, [rdi+4]    ;comparo i con size
    jge .fin            ;fuera de rango

    ;rdi<- array, rsi<- uint8 i
    xor r14, r14
    mov r13, rdi          ;r13<- array
    mov r14b, sil         ;r14b<- int8 i

    call arrayGet
    mov rbx, rax          ;rbx <- dato* que quiero devolver 
    mov rdx, [r13+8]      ;rdx<- void

    ;r13<- array, r14b<- i
    ;rbx <- void a devolver 
    ;rdx: void
    mov byte r9b, [r13+4]
    dec r9b

.swaps:
    cmp r14b, r9b 
    je .listo
    mov r8, [rdx+r14*8+8]   ;obtengo el siguiente
    mov [rdx+r14*8], r8     ;muevo al anterior
    inc r14b
    jmp .swaps

.listo:
    dec byte [r13+4]        ;decremento el size
    mov rax, rbx            ;rax <- dato*

.fin:
    add rsp, 8
    pop r14
    pop r13
    pop rbx
    pop rbp
    ret
;---------------------------------------------------
; void  arraySwap(array_t* a, uint8_t i, uint8_t j) 15 inst
arraySwap:
;rdi<- array*, rsi<- i, rdx <- j
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8
;faltaria preservar el rdi

	;chequeo si son posiciones inválidas
	mov cl, [rdi+4]		;rcx <- size
	cmp sil, cl			;comparo i con size
	jge .fin			
	cmp dl, cl 			;comparo j con size
	jge .fin

	movsx r12, sil		;r12b<- i
	movsx r13, dl 		;r13b<- j
	mov r14, [rdi+8]	;r14<- void**
    mov r15, rdi        ; guardo el rdi para preservarlo despues del primer call

	;son posiciones válidas, obtengo los datos

	;(arrayGet: rdi<-array*, rsi<-pos)

	;obtengo i
	call arrayGet 		;rax<- data* del i
	mov rbx, rax		;rbx<- data* del i

	;obtengo j
	mov sil, r13b 		;rsi<- j
    mov rdi, r15        ;restauro el rdi para el call de abajo
	call arrayGet 		;rax<- data* del j
	mov r15, rax		;r15<- data* del j

	;rdi:array*, r12b:i, r13b:j, rbx:i_dato*, r15:j_dato*
	;r14: void**

	;muevo
	mov [r14+r12*8], r15 ;pos i = void**+i*8
	mov [r14+r13*8], rbx ;pos j = void**+j*8

.fin:
	add rsp,8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
;---------------------------------------------------
; void  arrayDelete(array_t* a) 22 inst
arrayDelete:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14

	mov ebx, [rdi]		;rbx<- type
	mov r12b, [rdi+4]	;r12b<-size
	mov r13, rdi		;r13<- array* a borrar
	
	mov edi, ebx 		;rdi<- type
	call getDeleteFunction 	
	mov r14, rax		;r14 <- funcion* para delete del type

	;rdi<-array*

.ciclo:
	cmp byte r12b, 0	;comparo size con 0
	je .fin 			;sweet home alacama
	mov rdi, r13
	mov byte sil, 0		;rsi seteo el i=0
	call arrayRemove 	;lo borro y tengo dato*
	mov rdi, rax		;rdi<- dato*
	call r14			;borro dato*
	dec r12b
	jmp .ciclo
	
.fin:
	;borro el array* y void**
	mov rdi, [r13+8]	;borro el void** vacio
	call free

	mov rdi, r13
	call free

	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
;---------------------------------------------------
; ** Lista **---------------------------------------------------------------------

; list_t* listNew(type_t t) 10 ints
; type_ t : int -> rdi
listNew:
;StackFrame (armado)
	
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8
	
	mov ebx, edi 		;preservo el type
	mov rdi, 24
	call malloc

	mov [rax], ebx
	mov byte [rax+4], 0 
	mov qword [rax+8], 0
	mov qword [rax+16], 0

	add rsp, 8
	pop rbx
	pop rbp
	ret

	add rsp, 8
	pop rbx
	pop rbp
	ret

;---------------------------------------------------
; uint8_t  listGetSize(list_t* l) 2 inst
;list_t* l : puntero -> rdi
listGetSize:
	mov byte al, [rdi+4]
	ret
;---------------------------------------------------
; void listAddFirst(list_t* l, void* data) 27 ints
; list_t* l : puntero -> rdi
; void* data : puntero ->rsi


listAddFirst:
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    mov rbx, rdi ; rbx<- preservo el *l
    mov r12, rsi ; r12<- preservo el *data original

    mov dword edi, [rdi] 	;rdi<- type
    call getCloneFunction 
    mov rdi, r12 		;rdi<- dato*
    call rax 				;clono
    mov r12, rax 			;r12<- dato* clonado

    mov rdi, 24 			;pido espacio para el nodo elem_t
    call malloc   			;espacio alocado para nodo

    mov [rax], r12 		;seteo el dato*
    mov rdi, [rbx + 8] 	;rdi<- first* de la lista
    mov qword [rax + 16], 0 	;prev: es cero
    mov [rax + 8], rdi  	;next: primer elem* de la lista
    ;si es el único, lo seteo como seteo first* y last* en la lista
    cmp byte [rbx + 4], 0
    je .unicoNodo


    ;rdi<- antiguo first*
    ;agregandolo a la lista
    mov qword [rdi + 16], rax ;apunto el prev del viejo first de la lista al nuevo nodo
    jmp .fin

.unicoNodo:
	;es el unico elemento, su next ya fue seteado 0 
    ;mov qword [rax + 8], 0 	  ;next* <- 0
    mov qword [rbx + 16], rax ; seteo el last de la lista al nodo

.fin:
    inc byte [rbx + 4] 			;incremento el size
    mov qword [rbx +8], rax 	;first* <- dato* nuevo
    
    pop r12
    pop rbx
    pop rbp
    ret
;---------------------------------------------------
; void* listGet(list_t* l, uint8_t i) 13 inst 
;list_t* l : puntero -> rdi
;uint8_t i -> rsi
listGet:
;rdi = *l, sil = uint8_t i
    push rbp
    mov rbp, rsp
    push r12
    push rbx

    mov r12, rdi
    mov byte bl, sil

    call listGetSize; 
    mov byte sil, bl
    cmp byte al, 0			;si el size es 0, no existe
    je .fin
    dec byte al 
    cmp byte bl, al
    jg .notFound
    mov r12, [r12+8] ; r12 = primer nodo
.iterar:
    cmp byte sil, 0
    jle .iesimo
    dec byte sil
    mov r12, [r12+8] ; paso al siguiente nodo
    jmp .iterar

.notFound:
    mov rax, 0
    jmp .fin
.iesimo:
    mov rax, [r12]
.fin:
    pop rbx
    pop r12
    pop rbp
    ret
;---------------------------------------------------
; void* listRemove(list_t* l, uint8_t i) 37 ints
listRemove:
;rdi = *l, rsi = i
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push rbx
    push r15
    sub rsp, 8

    xor rax , rax
    cmp byte [rdi+4], 0 			;comparo size con 0
    je .fin

    mov r14, rdi		;r14 = puntero lista
    mov byte r15b, sil		;r15b = i 
    call listGet 			;rax tiene el puntero dato del iesimo
    cmp rax, 0		;comparo puntero con null
    je .fin ;fuera de rango, termino
    mov rbx, rax 		;rbx tiene el puntero dato del iesimo

    ;buscar el iesimo nodo, se que esta en rango
    mov r12, [r14+8] 		;r12 tiene el primer nodo
    
    ;r14=puntero lista, r15b=iesimo, rbx=puntero dato
    ;r12= primer nodo

.iterar:
    cmp byte r15b, 0		;comparo el iesimo con 0
    je .iesimo				;si es igual ya llegue
    dec byte r15b			;sino sigo avanzando
    mov r12, [r12+8]  ;paso al siguiente nodo
    jmp .iterar				


.iesimo:
    ;ya estoy en el iesimo nodo en r15
    ;me fijo si esta al principio o al final
    cmp qword [r12+16], 0 ;comparo el prev con 0
    je .primero
    cmp qword [r12+8], 0 ;comparo el next con 0
    je .ultimo

    ;cuando esta en el medio
    mov rdi, [r12+8] 	;muevo a rdi el nodo siguiente
    mov r13, [r12+16] 	;muevo a r13 el nodo anterior
    mov [rdi+16], r13 	;prev del nodo siguiente apunta al anterior del nodo a borrar
    mov [r13+8], rdi 	;next del nodo anterior apunta al next del nodo a borrar
    jmp .borrar

.primero:
    ;principio -> su next se convierte en first y el prev de su next apunta a cero
    cmp qword [r12+8], 0 ;comparo el next con 0, si son iguales es que solo hay un unico nodo
    je .unico
    mov rdi, [r12+8] ; rdi tiene el nodo siguiente
    mov qword [rdi+16], 0 ; setea el prev del nodo siguiente en cero
    mov [r14+8], rdi ; el first de la lista es el rdi
    jmp .borrar

.ultimo:
    ;final -> su prev se convierte en last y el next de su prev apunta a cero
    mov rdi, [r12+16] ;rdi tiene el nodo previo
    mov qword [rdi+8], 0 ;setea el sig del nodo previo en cero
    mov [r14+16], rdi ;el last de la lista es rdi
    jmp .borrar

.unico:
    ;unico nodo -> first y last apuntan a cero y borrar
    mov qword [r14+8], 0 ;first apunta a cero
    mov qword [r14+16], 0 ;last apunta a cero

.borrar:
    ;guardar en rax el [data] del nodo a borrar
    ;borrar el nodo usando call free
    mov rax, rbx
    dec byte [r14+4]
    mov rdi, r12
    call free
    mov rax, rbx ;rbx tiene el dato del iesimo nodo a borrar, se tiene que devolver eso
.fin:
	add rsp, 8
	pop r15
    pop rbx
    pop r14
    pop r13
    pop r12
    pop rbp
	ret

;---------------------------------------------------
; void  listSwap(list_t* l, uint8_t i, uint8_t j) 24 inst

listSwap:
;rdi = l, rsi = uint8_t i, rdx = uint8_t j
     push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    ;consigo los void de cada posicion
    ;luego itero hasta llegar a cada uno y cambio 

    ;chequeo que sean posiciones validas
    cmp byte sil, [rdi+4]    ;con i con size
    jge .fin
    cmp dl, [rdi+4]          ;comparo j con size
    jge .fin


    ;preservio lista, i y j
    mov rbx, rdi         ;rbx  <- lista
    mov r12b, sil         ;r12  <- i
    mov r13b, dl         ;r13 <- j

    ;listGet <- rdi: l, sil: i
    call listGet         ;consigo i
    mov r14, rax         ;r14 <- i_void
    ;rdi<-l, sil:j
    mov rdi, rbx
    mov sil, r13b
    call listGet 
    mov r15, rax         ;r15 <- j_void

    xor r8, r8             ;r8<- contador
    mov r9, [rbx+16]     ;r9<- first elem*

    ;rbx:lista, r12<-i, r13<- j
    ;r14: i_void, r15: j_void*
    ;r8: 0, r9<-first*

.ciclo_i:
    cmp r8b, r12b        ;si son iguales, ya llegue al i
    je .fin_i
    inc r8b                ;incremento contador
    mov r9, [r9+8]         ;muevo al siguiente
    jmp .ciclo_i

.fin_i:
    mov [r9], r15 ;swap el i con el dato del j

    xor r8,r8             ;r8 <- contador
    mov r10, [rbx+16]     ;r10<- first elem*

    ;r8: 0, r9<-first*

.ciclo_j:
    cmp r8b, r13b    ;si son iguales, ya llegue al j
    je .fin_j
    inc r8b
    mov r10, [r10+8]
    jmp .ciclo_j

.fin_j:
    mov [r10], r14

.fin:

    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
;---------------------------------------------------
; list_t* listClone(list_t* l), no es necesario implementarla pero puede ser util para clonar la lista de cartas apiladas

listClone:
;rdi -> list_l* l
;void listAddLast(list_t* l, void* data)
; list_t* listNew(type_t t)
 push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8


    mov rbx, rdi ; rbx tiene la lista pasada
    mov dword edi, [rbx] ;le paso el tipo
    call listNew ;rax tiene una lista nueva
    mov r13, rax ;r13 tiene la lista nueva
    cmp byte [rbx+4], 0 ;si esta vacia la lista dada
    je .fin
    ; iterar imsertando cada nodo de la lista dada a la lista nueva
    mov r12, [rbx+8] ;r12 tiene el primer nodo
    mov rsi, [r12] ;rsi tiene el *data
.insert:
    cmp r12, 0  ;si esque es 0 llegue al final, nose si puedo acceder al puntero cero
    je .fin
    mov rdi, r13 ;rdi tiene la lista nueva
    mov rsi, [r12]
    call listAddLast ;listAddLast se encarga de aumentar el size y de poner los punteros a primer y ultimo
    mov r12, [r12+8]
    jmp .insert

.fin:
    mov rax, r13
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
	ret

;---------------------------------------------------
; void listDelete(list_t* l) 28 inst
; list_t* l : puntero ->rdi
listDelete:
	push rbp
    mov rbp, rsp
    push rbx
    push r12

    ;tengo el puntero de la lista en rdi

	mov rbx, rdi				;rbx <- lista*

    ;rbx:lista*
    ;rdi y rsi dejo libres para los calls

    mov dword edi, [rdi] 		;muevo el type a rsi(sil)
    call getDeleteFunction
    mov r12, rax 				;muevo puntero funcion de delete del tipo a r9

    ;r13: funcion* delete
    ;rbx:lista 

.ciclo:
	cmp byte [rbx+4] , 0 		;comparo size con 0
	je .fin 				;ya recorri todo, me voy
	mov rdi, rbx		;rdi<- lista*
    mov byte sil, 0			;rsi<- 0 (borro siempre el iesimo 0)
    call listRemove 		;bborro punteros y decrementa size
    mov rdi, rax 		;rdi<- dato*
    call r12 				;llamo a la funcion delete del dato 
    jmp .ciclo

.fin:
	mov rdi, rbx
	call free

	pop r12
	pop rbx
    pop rbp
    ret
;---------------------------------------------------
; ** Card **------------------------------------------------------------------------------

; card_t* cardNew(char* suit, int32_t* number) 22 inst
cardNew:
;char* suit: puntero -> rdi
;int32_t* number: puntero -> rsi
   	push rbp
    mov rbp,rsp
    push rbx
    push r12
    push r13
    sub rsp, 8

    mov rbx, rdi        ;guardo el puntero del suit
    mov r12, rsi        ;guardo el puntero del number

    mov rdi, rbx        ;muevo el char* a rdi
    call strClone       ;clono el char* a
    mov rbx, rax        ;muevo el char* clonado en rbx

    mov rdi, r12        ;muevo el int32* a rdi
    call intClone       ;copio el int32*
    mov r12, rax        ;muevo el int32* a r12

    ;rbx -> copia del suit 
    ;r12 -> copia del number 

    mov edi, 3    ;carta es type 3, type es de 32bits 
    call listNew        ;creo lista nueva vacia
    mov r13, rax        ;guardo el puntero de la lista

    ;r13 -> puntero a la lista vacia nueva

    mov rdi, 24            ;carta es de 24 bytes
    call malloc            ;llamo a malloc

    mov [rax], rbx        ;muevo el puntero del suit
    mov [rax+8], r12      ;muevo el puntero del number
    mov [rax+16], r13     ;muevo el puntero de la lista

    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
;---------------------------------------------------
; char* cardGetSuit(card_t* c) 2 inst
cardGetSuit:
	mov rax, [rdi]
	ret
;---------------------------------------------------
; int32_t* cardGetNumber(card_t* c) 2 inst
cardGetNumber:
	mov rax, [rdi+8]
	ret
;---------------------------------------------------
; list_t* cardGetStacked(card_t* c) 2 inst
cardGetStacked:
	mov rax, [rdi+16]
	ret
;---------------------------------------------------
; int32_t cardCmp(card_t* a, card_t* b) 11 inst
cardCmp:
;carta a->rdi, carta b->rsi

;int32_t strCmp: char* a -> rdi, char* b -> rsi
;int32_t intCmp: int32_t* a -> rdi, int32_t* b -> rsi
	push rbp
    mov rbp, rsp
    push rbx
    push r12

    mov rbx, rdi        ;guardo carta* a
    mov r12, rsi        ;guardo carta* b

    ;comparo chars, guarda el res en eax
    mov rdi, [rbx]        ;muevo el char de a
    mov rsi, [r12]        ;muevo el char de b
    call strCmp          ;comparo chars y guarda en eax
    cmp dword eax, 0     ;veo si son iguales
    jne .fin             ;no son iguales, me voy

    ;si son iguales continuo
    mov rdi, [rbx+8]    ;muevo el num de a
    mov rsi, [r12+8]    ;muevo el num de b
    call intCmp         ;comparo ints y guarda en eax

.fin:
	pop r12
	pop rbx
    pop rbp
    ret

;---------------------------------------------------
; card_t* cardClone(card_t* c) 21 inst
;rdi-> card_t* c
cardClone:
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    mov rbx, rdi        ;muevo el puntero carta a rcx
    mov rdi, [rbx]      ;muevo el suit de la carta a rdi
    mov rsi, [rbx+8]    ;muevo el number de la carta a rsi

    call cardNew        ;cardNew copia el suit y nombre
    mov r12, rax        ;r12<- carta* nueva
    mov rdi, [r12+16] 	;rdi<- lista* vacia 
    call listDelete 	;borro la nueva vacia

    ;nueva carta ya tiene el suit y number, falta la lista

    mov rdi, [rbx+16]   ;muevo la lista de la carta original a rdi
    call listClone      ;clono la lista
    mov  [r12+16], rax  ;muevo la lista a la carta clonada

    mov rax, r12        ;muevo puntero carta clonada a rax

    pop r12
    pop rbx
    pop rbp
    ret
;---------------------------------------------------
; void cardAddStacked(card_t* c, card_t* card) 2 inst
cardAddStacked:
;card_t c -> rdi, card_t card -> rsi
	mov rdi, [rdi+16] 	;muevo la lista
	jmp listAddFirst	;rdi: lista, rsi: carta

;---------------------------------------------------
; void cardDelete(card_t* c) 11 inst
cardDelete:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp,8

	mov rbx, rdi	;preservo el card*

	;borro la lista
	mov rdi, [rbx+16]	;rdi<- lista*
	call listDelete

	;borro el int number
	mov rdi, [rbx+8]	;rdi<- int*
	call intDelete

	;borro el string suit
	mov rdi, [rbx]		;rdi<- char*
	call strDelete 		

	;borro el espacio alocado
	mov rdi, rbx 		;rdi<- card*
	call free

	add rsp,8
	pop rbx
	pop rbp
	ret
;---------------------------------------------------
; void cardPrint(card_t* c, FILE* pFile) 24 inst

 cardPrint:
    push rbp
    mov rbp, rsp
    push rbx
    push r12

;primera parte fprintf
;rdi <- file
;rsi <- formato_principal
;rdx <- string
;rcx <- numero

;call list print
;rdi <- puntero lista
;rsi<- file

;segunda parte fprintf
;rdi <- file
;rsi <- formato
;eso es todo


    mov rax, 0           ;cantidad de floats    
    mov rbx, rdi         ;rbx: puntero a la carta
    mov r12, rsi         ;rsi: file

    mov r9, [rbx+8]		;puntero int

    mov rdi, r12         ; rdi<- file*
    mov rsi, formato_fprintf_card ;rsi<-formato*
    mov rdx, [rbx]       ;rdx <- string*
    mov ecx, [r9]     	 ;rcx <- numero
    call fprintf         ;escribo

    mov rax, 0
    mov rdi, [rbx+16]    ;rdi: puntero lista
    mov rsi, r12         ;rsi:file 
    call listPrint

    mov rax, 0
    mov rdi, r12         ;rdi: file
    mov rsi, formato_fprintf_llave ;rsi: formato
    call fprintf

    pop r12
    pop rbx
    pop rbp
    ret
;---------------------------------------------------
