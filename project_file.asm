;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                 lIBRARIES 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


include irvine32.inc
include macros.inc
INCLUDELIB user32.lib

;===================================================================================================
;===================================================================================================


VK_left___		EQU		000000025h
VK_uper___		EQU		000000026h
VK_saja___	EQU		000000027h
VK_nicha___		EQU		000000028h
maxCol      EQU     80
maxRow      EQU     25

GetKeyState PROTO, nVirtKey:DWORD


;===================================================================================================
;===================================================================================================

Packman_move STRUCT
    up BYTE 0
    down BYTE 0
    left BYTE 0
    right BYTE 0
Packman_move ENDS


;===================================================================================================
;===================================================================================================


information_of_enemy STRUCT
    col     BYTE 26
    row     BYTE 9
    up      BYTE 0
    down    BYTE 0
    left    BYTE 0
    right   BYTE 1
    delay   WORD 0
    hrow     BYTE 26
    hcol     BYTE 9
information_of_enemy ENDS


;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

.386
.model flat, stdcall
.stack 4096



ExitProcess PROTO, dwExitCode:DWORD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;                                           
;                                         DATA SECTION
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


.data

    map BYTE "-----------------------------------------------------"
        BYTE "| . . . . . .  . . . . . . . . .  .  . . . . . . .  |"
        BYTE "| . +------+ . +------+ . | . +------+ . +------+ . |"
        BYTE "| o |      | . |      | . | . |      | . |      | o |"
        BYTE "| . +------+ . +------+ . | . +------+ . +------+ . |"
        BYTE "| . . . . .  . . . . . . . . . . . . . . . . . . .  |"
        BYTE "| . -------- . | . -------+------- . | . -------- . |"
        BYTE "| . . . . .  . . . . . .  | . . . .  . . . . . . .  |"
        BYTE "+----------+ . +-------   |   -------+ . +-----------"
        BYTE "           | . |                     | . |          +"
        BYTE "~----------+ . |   +*************+   | . +-----------"
        BYTE "  . . . . . .      *    PACMAN   *     . . . . . . . "
        BYTE "~----------+ . |   +*************+   | . +-----------"
        BYTE "           | . |                     | . |          +"
        BYTE "+----------+ . |   -------+-------   | . +-----------"
        BYTE "| . . . . . . . . . . . . | . . . . . . . . . . . . +"
        BYTE "| .      --+ . -------- . | . -------  . +--      . +"
        BYTE "| . . . .  | . . . . . . . . . . . . | . . . . . .  +"
        BYTE "+------- . | . | . -----   -------   | . |   --------"
        BYTE "| . . . . . . .| . . . . . . . . . . | . . . . . .  |"
        BYTE "|  o  ******++++******* .   . *****--+---*****   o  |"
        BYTE "| . . . . . . . . . . . .   . . . . . . . . . . .   |"
        BYTE "-----------------------------------------------------", 0 
        

        ; row and columns of maps
    mapRow EQU 23
    mapCol EQU 53
    
  
;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

    specialPowerLimit BYTE 20  ; total iteration counter for power
    specialPower BYTE ?       ;  
    speed DWORD 75
    pacmanMov Packman_move < 1,0,0,0 >

    
;===================================================================================================
;===================================================================================================

    col     BYTE 26
    row     BYTE 13    
    score    DWORD 0   
    Dots_eaten DWORD 0
    
;===================================================================================================
;===================================================================================================

    
    noOfEnemy EQU 3
    enemy information_of_enemy noOfEnemy DUP(< 26,9,0,0,0,1,26,9 >)
    sizeOfEnemy EQU SIZEOF enemy
    
    tmp DWORD 0
    pacman BYTE '@'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; variables for getting name and storing it in file
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    buffer_size = 20
    name_buffer BYTE buffer_size DUP (?)
    filename    BYTE "player_data.txt", 0
    fileHandle      DWORD ?
    bytesRead       DWORD ?
    buffer_name     BYTE 2 DUP (?)   ; Assuming DWORD score (0 to 4294967295) requires up to 10 digits + null terminator
    ; for file writing the score
    
;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================


     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;
    ; variables for getting name and storing it in file
    ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    input byte ?
    menuPrompt BYTE "MENU", 0
    option1    BYTE "1. Continue Game", 0
    option2    BYTE "2. Show Instructions", 0
    option3    BYTE "3. Exit", 0
    invalidMsg BYTE "Invalid option! Please choose again.", 0

    
;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

.code
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;     functions of packman gme
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


 ;------------------------------------------------------------------
 ;
 ;      function to check wether the position is a hurdle or not 
 ;      and accordingly setting the ah 
 ;
 ;-------------------------------------------------------------------
 
;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

   Current_Value_map PROC, x:BYTE, y:BYTE

    mov al, x          ; Load x into al (row number)
    mov bl, mapCol     ; Load total columns into bl
    imul bl             ; Multiply row on which he is standing by total number of columns and stored result in ax
    movsx bx, y
    add ax, bx         ; Add column number on which he is standing to result stoerd in ax
    
    mov al, map[eax]   ; now load the value of map in al from calculated position
    
    ; Compare al with with hurdles (|,+,-) and set ah to 0 if equal, else ah = 0

    cmp al, '|'
    jz block
    cmp al, '-'
    jz block
    cmp al, '*'
    jz block

    cmp al, '+'
    jz block
    mov ah, 1          ; Walkable if there is no hurdle
    jmp Short NOCHECKING

block:
    mov ah, 0          ; can go on that position

NOCHECKING:
    ret
Current_Value_map ENDP
        

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

 blockage PROC, col_:BYTE, row_:BYTE, col_Add:BYTE, row_Add:BYTE
    mov dl, col_
    mov dh, row_
    
       add dh, row_Add
       add dl, col_Add
      
   
    
    ; call funtion to check the hurdle
    invoke Current_Value_map, dh, dl    ; return character in al and hurdle info in ah 
    cmp ah, 0
    jne NextPosition         ; If ah is not 0,
            
     ret

 NextPosition:
    add dl, col_Add
    ; add dh, rowAdd
    invoke Current_Value_map, dh, dl    ; Check the next position
    
    ret
blockage ENDP
        
;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================


currentItem_dot___ PROC
    ; Calculate the index in the one-dimensional array based on row and column
    mov eax, 0               ; Clear EAX
    mov al, row              ; Load row into AL
    mov bl, mapCol           ; Load the total number of columns into BL
    mul bl                   ; Multiply row by the total number of columns
    movsx bx, col            ; Sign-extend col into BX
    add ax, bx               ; Add col to the result, giving the one-dimensional index
    
    mov bl, map[eax]         ; Load the character at the calculated index into BL
    cmp bl, '.'
    je DotFound              ; If the character is '.', jump to DotFound
    cmp bl, 'o'
    je PowerPelletFound      ; If the character is 'o', jump to PowerPelletFound
    jmp Short Finished       ; Otherwise, jump to Finished

DotFound:
    ; Process when a dot is found
    mov map[eax], ' '        ; Replace the dot with a space
    INC Dots_eaten           ; Increment the count of dots eaten
    INC score                ; Increment the score
    jmp Short Finished       ; Jump to Finished

PowerPelletFound:
    ; Process when a power pellet is found
    mov map[eax], ' '        ; Replace the power pellet with a space
    mov bl, specialPowerLimit; Load the special power limit into BL
    mov specialPower, bl     ; Set the special power to the value in BL

Finished:
    ret                      ; Return from the procedure
currentItem_dot___ ENDP




;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

setPacmanDirection PROC,
      newUpDirection:BYTE, newDownDirection:BYTE, newLeftDirection:BYTE, newRightDirection:BYTE
        ; Set the new up direction for Pacman
        mov al, newUpDirection
        mov pacmanMov.up, al

        ; Set the new down direction for Pacman
        mov al, newDownDirection
        mov pacmanMov.down, al

        ; Set the new left direction for Pacman
        mov al, newLeftDirection
        mov pacmanMov.left, al      
        
        ; Set the new right direction for Pacman
        mov al, newRightDirection
        mov pacmanMov.right, al        
        
        ret
setPacmanDirection ENDP


;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================


keySync PROC
    ; Check Down Arrow Key
    mov ah, 0
    INVOKE GetKeyState, VK_nicha___
    test ah, ah
    jz CheckUp ; If not pressed, check Up key
    cmp row, mapRow - 1
    jge CheckUp ; If row is at bottom, check Up key
    invoke blockage, col, row, 0, 1
    cmp ah, 1
    jne CheckUp
    INC row
    invoke setPacmanDirection, 0, 1, 0, 0

CheckUp:
    ; Check Up Arrow Key
    mov ah, 0
    INVOKE GetKeyState, VK_uper___
    test ah, ah
    jz CheckLeft ; If not pressed, check Left key
    cmp row, 1
    jle CheckLeft ; If row is at top, check Left key
    invoke blockage, col, row, 0, -1
    cmp ah, 1
    jne CheckLeft
    DEC row
    invoke setPacmanDirection, 1, 0, 0, 0

CheckLeft:
    ; Check Left Arrow Key
    mov ah, 0
    INVOKE GetKeyState, VK_left___
    test ah, ah
    jz CheckRight ; If not pressed, check Right key
    cmp col, 1
    jle CheckRight ; If col is at left edge, check Right key
    invoke blockage, col, row, -1, 0
    cmp ah, 1
    jne CheckRight
    DEC col
    invoke setPacmanDirection, 0, 0, 1, 0


CheckRight:
    ; Check Right Arrow Key
    mov ah, 0
    INVOKE GetKeyState, VK_saja___
    test ah, ah
    jz WrapCheck ; If not pressed, proceed to WrapCheck
    cmp col, mapCol
    jge WrapCheck ; If col is at right edge, proceed to WrapCheck
    invoke blockage, col, row, 1, 0
    cmp ah, 1
    jne WrapCheck
    INC col
    invoke setPacmanDirection, 0, 0, 0, 1

WrapCheck:
    ; Wrap-Around Logic
    cmp col, 0
    jne CheckWrapRight
    mov ah, mapCol - 1
    mov col, ah
    jmp EndKeySync

CheckWrapRight:
    cmp col, mapCol - 1
    jne EndKeySync
    mov col, 0

EndKeySync:
    ret
keySync ENDP



MAKE_MAP__ PROC
    mov dl, 0   ; row
    mov dh, 0   ; col

PrintRow:
    cmp dl, mapRow
    je EndPrint ; If all rows are printed, end procedure

PrintCol:
    cmp dh, mapCol
    je NextRow  ; If all columns in the row are printed, go to the next row

    ; Get and print the character
    invoke Current_Value_map, dl, dh  ; return char in al                  
    call WriteChar
    INC dh
    jmp PrintCol  ; Repeat for the next column

NextRow:
    mov dh, 0
    call Crlf  ; New line after each row
    inc dl
    jmp PrintRow  ; Repeat for the next row

EndPrint:
    ret
MAKE_MAP__ ENDP




;===================================================================================================
;===================================================================================================



;===================================================================================================
;===================================================================================================


;===================================================================================================
;===================================================================================================





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;           
;          main function
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main PROC


        ; Open file for writing
    invoke CreateFile, ADDR filename, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
    mov fileHandle, eax



    call ClrScr
    
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;
      ;      First screen
      ;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

       ; Display prompt for user input
    mov edx, OFFSET prompt
    call WriteString

    ; Read user input
    mov edx, OFFSET name_buffer
    mov ecx, buffer_size
    call ReadString
       
       call WaitMsg
        call ClrScr


      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;
      ;      MENU SCREEN
      ;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

         menuLoop:
        ; Display menu
        call DisplayMenu

        ; Read user input for menu option
    ; Read user input for menu option
          call ReadChar
          movzx eax, al  ; Use the character read as menu option

        ; Process user input
        cmp eax, '1'
        je continueGame

        cmp eax, '2'
        call showInstructions

        cmp eax, '3'
        je exitGame

       
        jmp menuLoop


       

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;                                    ;
        ;     MAIN GAME FUNCTIONS CALLING    ;
        ;                                    ;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


         Resume:
        continueGame:

            call ClrScr



         
        ; functions to start the game
         call INITIALIZE_ENEMY___
         call MAKE_MAP__



      
         infinite:   
         
     call loadEnemy
     call COLLISION_CHECK_ENEMY___
    cmp al,1
         je GameOver
     
     call keySync          ; sync keyboard
     call currentItem_dot___      ; Check for . and increase score
     
     mGotoxy col, row

    cmp specialPower,0
    jne ei
         mov al,pacman 
         jmp e
     ei:
         mov al, 1
        DEC specialPower
     e:
     call WriteChar  ; print out pacman
    
     invoke Sleep, speed
             
     call REMOVE_ENEMY
     
     mGotoxy col, row
     mov  al,' '     
     call WriteChar
     
         mGotoxy 60, 9
         mWrite "Your Goal is to Score 150."

     mGotoxy 60, 10
     mWrite "Score:" 
     mov eax, score
     call WriteInt

     mGotoxy 60, 11
     mWrite "Food Eaten:" 
     mov eax, Dots_eaten
     call Writeint
     
     ;;;;;  jump to win the game if food in eaten
  
   cmp Dots_eaten,50
         jae YouWin
     
     ; Check for pause key (let's say 'P')
            call ReadKey  ; Read a key press
            cmp al, 'p'   ; Compare the key with 'P'
            je PauseGame  ; If 'P' is pressed, jump to PauseGame

             call ReadKey  ; Read a key press
            cmp al, 'q'   ; Compare the key with 'q'
            je exitGame
            ; checking if he wants to exit the game or not

 jmp infinite

 ; PauseGame label
PauseGame:
    call ClrScr
    mGotoxy 50, 15
    mWrite "Game Paused: "
    call WaitMsg   ; Wait for any key press to continue

    ; Clear the pause message and resume the game
    mGotoxy 50, 18
    call ClrScr    ; Optional: Clear the screen if necessary
    jmp Resume   ; Jump back to the game loop


 
 GameOver:
     call ClrScr
     mGotoxy 35, 10
     mWrite "Game Over"


       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Writing in the file
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


      ; Write the name to the file
    invoke WriteFile, fileHandle, ADDR name_buffer, SIZEOF name_buffer, ADDR bytesRead, 0

        ; Convert the score to a string
    ;invoke dwtoa, score, ADDR buffer_name

        ; Convert the score to a string
    call ConvertDwordToString
     ; Concatenate the name and score strings
   ; invoke lstrcat, ADDR buffer_name, ADDR score

    ; Write the score to the file
    invoke WriteFile, fileHandle, ADDR buffer_name, SIZEOF buffer_name, ADDR bytesRead, 0


    ; Close the file
    invoke CloseHandle, fileHandle




     ret

 YouWin:
     call ClrScr
     mGotoxy 35, 5
     mWrite "You Win"
     
     mGotoxy 35, 8
     mWrite "Score:" 
     mov eax, score
     call WriteInt

     mGotoxy 35,9
     mWrite "Food Eaten:" 
     mov eax, Dots_eaten
     call Writeint

     mGotoxy 35,10
     mWrite "NAME :"
     mov edx, OFFSET name_buffer
        call WriteString


        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Writing in the file
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


      ; Write the name to the file
    invoke WriteFile, fileHandle, ADDR name_buffer, SIZEOF name_buffer, ADDR bytesRead, 0

        ; Convert the score to a string
    ;invoke dwtoa, score, ADDR buffer_name

        ; Convert the score to a string
    call ConvertDwordToString
     ; Concatenate the name and score strings
   ; invoke lstrcat, ADDR buffer_name, ADDR score

    ; Write the score to the file
    invoke WriteFile, fileHandle, ADDR buffer_name, SIZEOF buffer_name, ADDR bytesRead, 0


    ; Close the file
    invoke CloseHandle, fileHandle

     ret
       exitGame:
       ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;                                   End Main
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
invoke ExitProcess, 0

main ENDP

;===================================================================================================
;===================================================================================================








;===================================================================================================
;===================================================================================================



;===================================================================================================
;===================================================================================================


;===================================================================================================
;===================================================================================================


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;       functions for enemy
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;===================================================================================================
;===================================================================================================


;===================================================================================================
;===================================================================================================


;===================================================================================================
;===================================================================================================

REMOVE_ENEMY PROC
    ; Initialize loop counter (ecx) and index for 'enemy' array (edx)
    mov ecx, 0
    mov edx, 0

EraseLoop:
    ; Compare the loop counter with the total number of enemies
    cmp ecx, noOfEnemy
    jge EndErase  ; If all enemies have been processed, exit the loop

    ; Erase enemy character from the display
    mov al, enemy[edx].col  ; Load enemy's column into AL
    mov ah, enemy[edx].row  ; Load enemy's row into AH
    mGotoxy al, ah          ; Move the cursor to the specified position
    mov al, ' '             ; Set AL to a space character (erase)
    call WriteChar          ; Call a function to write the character

    ; Get the character from the map and redraw it on the display
    invoke Current_Value_map, enemy[edx].row, enemy[edx].col  ; Get character from the map
    call WriteChar          ; Call a function to write the character

    ; Move to the next enemy in the array
    add edx, SIZEOF information_of_enemy  ; Increment the index by the size of the information_of_enemy structure
    inc ecx                   ; Increment the loop counter
    jmp EraseLoop             ; Repeat the loop for the next enemy

EndErase:
    ret                        ; Return from the procedure
REMOVE_ENEMY ENDP


;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================
    MOVEMENT_ENEMY_DIRECTION PROC, up:BYTE,down:BYTE,left:BYTE,right:BYTE
        mov edx, tmp    
        mov al, up
        mov enemy[edx].up, al

        mov al, down
        mov enemy[edx].down, al

        mov al, left
        mov enemy[edx].left, al      
        
        mov al, right
        mov enemy[edx].right, al        
        ret
    MOVEMENT_ENEMY_DIRECTION ENDP    
    
    

COLLISION_CHECK_ENEMY___ PROC
    mov ecx, 0
    mov edx, 0

CheckCollisionLoop:
    cmp ecx, noOfEnemy
    jge EndCollisionCheck  ; If all enemies have been checked, exit

    ; Compare enemy position with Pac-Man's position
    mov al, col
    mov ah, row
    cmp enemy[edx].col, al
    jne NextEnemy
    cmp enemy[edx].row, ah
    jne NextEnemy

    ; Collision detected
    cmp specialPower, 0
    je CollisionNoPower

    ; Collision with power
    add score, 50
    mGotoxy al, ah 
    mov al, ' '     
    call WriteChar
    mov enemy[edx].col, 23
    mov enemy[edx].row, 9
    mov enemy[edx].delay, 45
    invoke MOVEMENT_ENEMY_DIRECTION, 0, 0, 0, 1
    mov al, 0
    ret

CollisionNoPower:
    mov al, 1
    ret

NextEnemy:
    add edx, SIZEOF information_of_enemy
    inc ecx
    jmp CheckCollisionLoop

EndCollisionCheck:
    mov al, 0
    ret
COLLISION_CHECK_ENEMY___ ENDP


;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================


;===================================================================================================
;===================================================================================================



INITIALIZE_ENEMY___ PROC
    ; Initialize loop counter (ecx) and index for 'enemy' array (edx)
    mov ecx, 0
    mov edx, 0

InitLoop:
    ; Compare the loop counter with the total number of enemies
    cmp ecx, noOfEnemy
    jge EndInit  ; If all enemies have been initialized, exit the loop

    ; Initialize randomization and get a random number
    call Randomize
    mov eax, 1
    call RandomRange
    cmp eax, 0
    je SetDirectionLeft  ; If RandomRange does not return 0, set direction right

    ; Set direction right if RandomRange does not return 0
    invoke MOVEMENT_ENEMY_DIRECTION, 0, 0, 0, 1
    jmp NextEnemy  ; Jump to NextEnemy to skip SetDirectionLeft

SetDirectionLeft:
    ; Set direction left if RandomRange returns 0
    invoke MOVEMENT_ENEMY_DIRECTION, 0, 0, 1, 0   ; sending rguments

NextEnemy:
    ; Generate a random delay value for the enemy
    mov edx, tmp
    mov eax, 30
    call RandomRange
    mov enemy[edx].delay, ax

    ; Prepare for the next enemy
    add edx, SIZEOF information_of_enemy  ; Increment the index by the size of the information_of_enemy structure
    mov tmp, edx              ; Update tmp with the new index
    inc ecx                   ; Increment the loop counter
    jmp InitLoop              ; Repeat the loop for the next enemy

EndInit:
    ret                        ; Return from the procedure
INITIALIZE_ENEMY___ ENDP

;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================
loadEnemy PROC
    ; Initialize loop counter (ecx) and index for 'enemy' array (edx)
    mov ecx, 0
    mov edx, 0
    mov tmp, edx

start_while:
    ; Compare the loop counter with the total number of enemies
    cmp ecx, noOfEnemy
    jge end_while  ; If all enemies have been processed, exit the loop

    ; Check if enemy[edx].delay is not 0
    cmp enemy[edx].delay, 0
    je el

    ; Decrement enemy[edx].delay and jump to end if executed
    DEC enemy[edx].delay
    jmp en

    el:
    ; Check Packman_move direction flags
    ; Check if enemy[edx].left is true
    CMP [enemy + edx].left, 0
    JNE left_true

    ; Check if enemy[edx].right is true
    CMP [enemy + edx].right, 0
    JNE right_true

    ; Check if enemy[edx].up is true
    CMP [enemy + edx].up, 0
    JNE up_true

    ; Check if enemy[edx].down is true
    CMP [enemy + edx].down, 0
    JNE down_true

    JMP end_if

    left_true:
        ; Check for hurdles in the left direction
        invoke blockage, enemy[edx].col, enemy[edx].row, -1, 0
        CMP AH, 0
        JNE update_left
        JMP end_left

    update_left:
        ; Update enemy position to the left
        mov edx, tmp
        DEC [enemy + edx].col

    end_left:
        JMP end_if

    right_true:
        ; Check for hurdles in the right direction
        invoke blockage, enemy[edx].col, enemy[edx].row, 1, 0
        CMP AH, 0
        JNE update_right
        JMP end_right

    update_right:
        ; Update enemy position to the right
        mov edx, tmp
        INC [enemy + edx].col

    end_right:
        JMP end_if

    up_true:
        ; Check for hurdles in the up direction
        invoke blockage, enemy[edx].col, enemy[edx].row, 0, -1
        CMP AH, 0
        JNE update_up
        JMP end_up

    update_up:
        ; Update enemy position upwards
        mov edx, tmp
        DEC [enemy + edx].row

    end_up:
        JMP end_if

    down_true:
        ; Check for hurdles in the down direction
        invoke blockage, enemy[edx].col, enemy[edx].row, 0, 1
        CMP AH, 0
        JNE update_down
        JMP end_down

    update_down:
        ; Update enemy position downwards
        mov edx, tmp
        INC [enemy + edx].row

    end_down:
        JMP end_if

    end_if:
    
    ; Check if AH (hurdle info) is not 0
    mov edx, tmp
    CMP AH, 0
    JNE end_if_ah_not_zero  ; Jump to end if AH is not 0

    ; Randomly set Packman_move direction if AH is 0
    call Randomize
    mov  eax, 2
    call RandomRange
    mov edx, tmp

    ; Check Packman_move flags for specific direction
    CMP [enemy + edx].down, 1
    JE down_is_one

    CMP [enemy + edx].up, 1
    JE up_is_one

    CMP [enemy + edx].right, 1
    JE right_is_one

    CMP [enemy + edx].left, 1
    JE left_is_one

    JMP end_if_direction_check

    down_is_one:
        CMP EAX, 0
        JNE invoke_down
        invoke MOVEMENT_ENEMY_DIRECTION, 0, 0, 0, 1
        JMP end_if_direction_check

    invoke_down:
        invoke MOVEMENT_ENEMY_DIRECTION, 0, 0, 1, 0
        JMP end_if_direction_check

    up_is_one:
        CMP EAX, 0
        JNE invoke_up
        invoke MOVEMENT_ENEMY_DIRECTION, 0, 0, 0, 1
        JMP end_if_direction_check

    invoke_up:
        invoke MOVEMENT_ENEMY_DIRECTION, 0, 0, 1, 0
        JMP end_if_direction_check

    right_is_one:
        CMP EAX, 0
        JNE invoke_right
        invoke MOVEMENT_ENEMY_DIRECTION, 0, 1, 0, 0
        JMP end_if_direction_check

    invoke_right:
        invoke MOVEMENT_ENEMY_DIRECTION, 1, 0, 0, 0
        JMP end_if_direction_check

    left_is_one:
        CMP EAX, 0
        JNE invoke_left
        invoke MOVEMENT_ENEMY_DIRECTION, 0, 1, 0, 0
        JMP end_if_direction_check

    invoke_left:
        invoke MOVEMENT_ENEMY_DIRECTION, 1, 0, 0, 0

    end_if_direction_check:
    end_if_ah_not_zero:

    ; End of conditions, display enemy character
    en:
    mov al, enemy[edx].col
    mov ah, enemy[edx].row

    mGotoxy al, ah
    ; Display 'E' if specialPower is 0, otherwise display 'e'
    .IF specialPower == 0
        mWrite "En"
    .ELSE
        mWrite "b"
    .ENDIF

    ; Move to the next enemy
    add edx, SIZEOF information_of_enemy
    mov tmp, edx
    inc ecx
    jmp start_while

end_while:
    ret
loadEnemy ENDP



;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================


;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================





        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;
        ;      function to show options
        ;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DisplayMenu PROC
    ; Display the menu options
    call Clrscr
     mGotoxy 10, 5
    mov edx, OFFSET menuPrompt
    call WriteString
   ; call NewLine

    mGotoxy 10, 6
    mov edx, OFFSET option1
    call WriteString
   ; call NewLine
   mGotoxy 10, 7
    mov edx, OFFSET option2
    call WriteString
   ; call NewLine
   mGotoxy 10, 8
    mov edx, OFFSET option3
    call WriteString
   ; call NewLine

    ret
DisplayMenu ENDP


;===================================================================================================
;===================================================================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   FUNCTION TO SHOW INSTRUCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


showInstructions PROC
    ; Display instructions for Packman game
    call Clrscr

    instructionsLoop:
    mGotoxy 10, 9
        mov edx, OFFSET instructionsHeader
        call WriteString
       ; call NewLine
       mGotoxy 10, 10
        ; Display individual instructions
        mov edx, OFFSET instruction1
        call WriteString
       ; call NewLine
       mGotoxy 10, 11
        mov edx, OFFSET instruction2
        call WriteString
      ;  call NewLine

      mGotoxy 10, 12
        mov edx, OFFSET instruction3
        call WriteString
        ;call NewLine

        mGotoxy 10, 13
        mov edx, OFFSET instruction4
        call WriteString
       ; call NewLine

        ; Read user input for going back to the main menu or exiting
       
          call ReadChar
          movzx eax, al  ; Use the character read as menu option

        ; Process user input
        cmp eax, '1'
        je exitInstructionsLoop

        ;cmp eax, 0
        ;je exitGame

        ; Invalid option
       ; call DisplayInvalidOption
        jmp instructionsLoop

    exitInstructionsLoop:
    ret
showInstructions ENDP


;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

ConvertDwordToString PROC
    ; Convert DWORD to string manually
    mov eax, score
    mov ecx, 10
    mov edi, OFFSET buffer_name + 10
    mov BYTE PTR [edi], 0 ; Null terminator

convertLoop:
    dec edi
    xor edx, edx
    div ecx
    add dl, '0'
    mov BYTE PTR [edi], dl
    test eax, eax
    jnz convertLoop

    ret
ConvertDwordToString ENDP

;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================

;; GLOBAL VARIBLES
prompt BYTE "Please Enter your name: ", 0



;; Instructions variables
instructionsHeader BYTE "PACKMAN INSTRUCTIONS", 0
instruction1 BYTE "1- COLLECT 150 POINTS TO WIN", 0
instruction2 BYTE "2- COLLECT FRUITS TO GET BONUS POINTS", 0
instruction3 BYTE "3- BE SAFE FROM MONSTERS", 0
instruction4 BYTE "4- PRESS 1 TO GO BACK TO MAIN MENU", 0

;===================================================================================================
;===================================================================================================

;===================================================================================================
;===================================================================================================


END main

