; *******************************************************
; GPA Calculator in x86 Assembly
; Developed by IJ Baig
; GitHub: https://github.com/IJBaig/GPA-Calculator-Assembly-emu8086
; Instruction : https://github.com/IJBaig/GPA-Calculator-Assembly-emu8086/readme.md
; For 8086 DOS interrupt-based environment
; *******************************************************
TITLE "GPA Calculator"

.MODEL small
.STACK 256
.DATA

; ----- Data Section -----
newline      DB 0DH, 0AH, "$"                     ; Carriage return + line feed
welcome      DB "********** Welcome to the GPA Calculator ***********$"
thanks       DB 0DH,0AH,0DH,0AH,"Thanks for using our program. See you again... $"
ask          DB 0DH,0AH,"Now What you want to do?",0DH,0AH
             DB "1- GPA ",0DH,0AH
             DB "2- Exit ",0DH,0AH,"$"
invalid_     DB 0DH,0AH,"Invalid input. Please enter 1 or 2$"
subject      DB 0DH,0AH,"How many subjects do you have? $"
grade        DB 0DH,0AH,"Enter grade for subject $"
invalidG     DB 0DH,0AH,"Invalid grade. Please re-enter. $"
invalid      DB 0DH,0AH,"Invalid input. Please enter number 1-4: $"
creditHour   DB 0DH,0AH,"Enter credit hours for that subject: $"
show         DB 0DH,0AH,"Your GPA is: $"

; GPA values for grades in fixed-point (e.g., A+ = 4.0 ? 4,0)
gradePoints  DB 4,0, 4,0, 3,7, 3,3, 3,0, 2,7, 2,3, 2,0, 1,7, 1,3, 1,0, 0,0, 0,0

; ----- Variables -----
nSub         DB 0         ; Number of subjects
i            DB 0         ; Loop counter
total        DB 0,0       ; Sum of grade points * credit hours
tch          DB 0         ; Total credit hours
result       DB 0,0       ; Final GPA result (int, decimal)
gradeLetter  DB 0         ; Grade letter part (e.g., 'A')
gradeMod     DB 0         ; Grade modifier (e.g., '+', '-')
var          DB 0,0       ; Temporary value for calculations

.CODE

; ----- Program Entry -----
main PROC
    .startup
    lea dx, welcome
    call displayString

repeat:
    lea dx, ask
    call displayString
    call input
    call clearBuffer
    cmp al, '1'
    JE do_gpa
    cmp al, '2'
    JE exitProgram
    lea dx, invalid_
    call displayString
    jmp repeat

; ----- GPA Calculation Logic -----
do_gpa:
    call cls
    jmp main_loop

main_loop:
    ; Reset variables
    mov i, 0
    mov total, 0
    mov total+1, 0
    mov tch, 0
    mov result, 0
    mov result+1, 0

    lea dx, subject
    call displayString

getSubjects:
    call input
    call clearBuffer
    call asciiToNum
    cmp al, 1
    JB invalid_input
    cmp al, 9
    JA invalid_input
    mov nSub, al
    jmp startGPA

invalid_input:
    lea dx, invalid
    call displayString
    jmp getSubjects

; ----- Loop Through Subjects -----
startGPA:
    mov cl, nSub
    mov i, 0
nextSubject:
    lea dx, grade
    call displayString
    mov dl, i
    add dl, 31h           ; Convert subject index to ASCII
    call displayChr
    lea dx, newline
    call displayString

getGrade:
    call input
    call clearBuffer
    mov gradeLetter, al
    call peekInput
    call input
    call clearBuffer
    mov gradeMod, al
    call compute           ; Convert grade to fixed-point GPA

    lea dx, creditHour
    call displayString

getCredit:
    call input
    call clearBuffer
    call asciiToNum
    cmp al, 1
    JB invalid_credit
    cmp al, 4
    JA invalid_credit
    add tch, al
    mov bl, al
    call multiply
    call sum
    inc i
    cmp i, cl
    jl nextSubject
    jmp showResult

invalid_credit:
    lea dx, invalid
    call displayString
    jmp getCredit

; ----- Show GPA -----
showResult:
    call ComputeResult
    lea dx, show
    call displayString
    mov dl, [result]
    add dl, 30h
    call displayChr
    mov dl, '.'
    call displayChr
    mov dl, [result+1]
    add dl, 30h
    call displayChr
    jmp repeat

; ----- Exit Program -----
exitProgram:
    lea dx, thanks
    call displayString
    .EXIT
main ENDP

; ----- Utility Procedures -----
displayChr PROC
    mov ah, 02h
    int 21h
    ret
displayChr ENDP

displayString PROC
    mov ah, 09h
    int 21h
    ret
displayString ENDP

input PROC
    mov ah, 01h
    int 21h
    ret
input ENDP

asciiToNum PROC
    sub al, 30h
    ret
asciiToNum ENDP

peekInput PROC
    mov ah, 01h
    int 16h         ; BIOS peek input
    mov ah, 0
    ret
peekInput ENDP

clearBuffer PROC
.clear_loop:
    mov ah, 01h
    int 16h         ; Check for key
    jz .done
    mov ah, 00h
    int 16h         ; Discard input
    jmp .clear_loop
.done:
    ret
clearBuffer ENDP

; ----- Grade Conversion Logic -----
compute PROC
    mov bl, gradeLetter
    mov bh, gradeMod

    cmp bl, 'A'
    JE A_Label
    cmp bl, 'B'
    JE B_Label
    cmp bl, 'C'
    JE C_Label
    cmp bl, 'D'
    JE D_Label
    cmp bl, 'F'
    JE F_Label
    jmp invalid_grade

A_Label: mov si, 0
    jmp ModCheck
B_Label: mov si, 6
    jmp ModCheck
C_Label: mov si, 12
    jmp ModCheck
D_Label: mov si, 18
    jmp ModCheck
F_Label: mov si, 24
    jmp ModCheck

ModCheck:
    cmp bh, '+'
    JE plus
    cmp bh, '-'
    JE minus
    cmp bh, 0DH
    JE normal
    jmp invalid_grade

plus:
    jmp fetchGrade
normal:
    add si, 2
    jmp fetchGrade
minus:
    add si, 4
    jmp fetchGrade

invalid_grade:
    lea dx, invalidG
    call displayString
    lea dx, newline
    call displayString
    jmp getGrade

fetchGrade:
    mov al, gradePoints[si]
    mov var, al
    mov al, gradePoints[si+1]
    mov var+1, al
    ret
compute ENDP

; ----- Arithmetic Procedures -----
multiply PROC
    mov al, var
    mul bl
    mov var, al
    mov al, var+1
    mul bl
    mov var+1, al
    call normalizeVar
    ret
multiply ENDP

normalizeVar PROC
    mov al, var+1
    mov ah, 0
    mov bl, 10
    div bl
    cmp al, 0
    JE no_carry
    add var, al
    mov var+1, ah
no_carry:
    ret
normalizeVar ENDP

sum PROC
    mov al, var
    add total, al
    mov al, var+1
    add total+1, al
    call normalizeTotal
    ret
sum ENDP

normalizeTotal PROC
    mov al, total+1
    mov ah, 0
    mov bl, 10
    div bl
    cmp al, 0
    JE no_carry2
    add total, al
    mov total+1, ah
no_carry2:
    ret
normalizeTotal ENDP

ComputeResult PROC
    ; Compute integer GPA part
    mov al, total
    mov ah, 0
    mov bl, tch
    div bl
    mov result, al

    ; Compute fractional part (tenths)
    mov al, total+1
    mov ah, 0
    mov cl, 10
    mul cl
    div bl
    mov result+1, al

    ; Limit to 0-9
    cmp result+1, 10
    JL valid_decimal
    mov result+1, 9

valid_decimal:
    ret
ComputeResult ENDP

; ----- Screen Clear Procedure -----
cls PROC
    mov ax, 0600h       ; Scroll window up
    mov bh, 1Eh         ; Attribute (background red, text yellow)
    mov cx, 0           ; Start at top-left
    mov dx, 184Fh       ; End at bottom-right
    int 10h             ; BIOS call to clear screen
    mov ah, 02h
    mov bh, 0
    mov dx, 0000h       ; Move cursor to top-left
    int 10h
    ret
cls ENDP

END main
