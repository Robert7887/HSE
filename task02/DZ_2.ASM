; �������� ������
; ��� ��� 194
; ������� 12
; ����������� ���������, ������� ������ ���������� ������ A[N], ��������� �� ��������� ������� A ����� ������ B
; � ������� ������ ���� ������ ��������� ������������� ������� � ������� ���. ������ ��� ������� ����� ���������� ��� ����������, ��� � ����������� �� ������ ������������.
format PE console
entry start

include 'win32a.inc'


;__________________________Data reserve section____________________________
section '.data' data readable writable

        formatStr       db '%s', 0
        formatNum       db '%d', 0

        lenght          dd 0
        lenght2         dd 0
        element         dd ?    ; ������� ������� array1
        index           dd ?    ; ������-������� array1
        lastNegative    dd -1   ; ������ ���������� �������������� �������� � array1
        index2          dd ?    ; ������-������� array2
        tmp             dd ?
        tmp2            dd ?
        tmpStack        dd ?
        array           rd 100  ; ������, ����������� �������� �������������
        array2          rd 100  ; ������-���������

        strInjected             db 'Injected array - ', 0
        strRes                  db 'Result array - ', 0
        bracket                 db '[',0
        bracket2                db ']',10, 0
        strExit                 db 'Program finish...', 0
        srtArraySize            db 'Enter array lenght(0-100) - ', 0
        strArrayElement         db 'Enter %d array element - ', 0
        strVecElemOut           db ' %d,', 0 ;10, 0
        strLastVecElemOut       db ' %d ', 0
        strIncorSize            db 'Incorrect array size!',10, 0
        ;point                   db ', ', 0

        NULL = 0
;______________________________Code section________________________________
section '.code' code readable executable
start:
; 1) vector input
        call ArrayInput

        call SearchIndex

        call FillArray2
; 4) vectors out
; ������� ��������� ������������� ������
        push strInjected
        call [printf]
        push bracket
        call [printf]

        call VectorOut  ; �������� ��������� ������� ������� �� ����� ������, ��������� �������������

        push bracket2
        call [printf]
; ������� ���������
        push strRes
        call [printf]
        push bracket
        call [printf]

        call Vector2Out ; �������� ��������� ������� ������� �� ����� ������, ��� ���������� �������������� ��������

        push bracket2
        call [printf]
finish:
        call [getch]

        push 0
        call [ExitProcess]

;-------------------------- Array input method -----------------------------
ArrayInput:
        push srtArraySize  ;
        call [printf]      ; ���������� ����� ������� array1
        add esp, 4         ;

        push lenght        ;
        push formatNum     ; ���������� ����� � lenght
        call [scanf]       ;
        add esp, 8         ;

        mov eax, [lenght]   ;
        mov [lenght2], eax  ;                                                    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cmp eax, 0          ; ���������� ����� � 0
        jg getVector
; ���� ������ ������� ������ 0
        push strIncorSize
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]
;-------------------------- Array1 fill method -------------------------------
getVector:
        cmp eax, 100
        jle continue
; ���� ������ ������� ������ 100
        push strIncorSize
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]
; ���� ���������� ������ ��������� � ��������� �� 0 �� 100 �� ����� ��������� array1
        continue:
        xor ecx, ecx
        mov ebx, array
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [lenght]
        jge endInputVector

        ; input element
        mov [index], ecx
        inc ecx                 ; �������������� ��� ��������� ������
        push ecx
        dec ecx
        push strArrayElement    ; ���������� ��������� ������� �������
        call [printf]           ;
        add esp, 8

        push ebx                ;
        push formatNum          ; �������� ��������� ������� �������
        call [scanf]            ;
        add esp, 8

        mov ecx, [index]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret

;_________________________________Search index method______________________________________
SearchIndex:
        xor ecx, ecx
        mov ebx, 0
searchIndexLoop:
        cmp ecx, [lenght]
        je endLoop
        mov [index], ecx

        cmp [array + ebx], 0            ;
        jge contt                       ; ���� ������� ������ ���� �������������� ������ ���������� �������������� ��������
        mov eax, [index]                ;
        mov [lastNegative], eax         ;
        mov edx, [lenght]
        dec edx
        mov [lenght2], edx

        contt:
        mov ecx, [index]
        inc ecx
        add ebx, 4
        jmp searchIndexLoop
endLoop:
        ret
;___________
FillArray2:
        xor ecx, ecx
        xor edx, edx
        mov ebx, 0
        mov eax, 0
fillArray2Loop:
        cmp ecx, [lenght]
        je endfillLoop
        mov [index], ecx
        mov [index2], edx
        cmp [lastNegative], ecx   ; ���� ������ ���������� �������� ����� lastNegIndex �� ���������� ��� � array2
        jne contt2                ;
        mov ecx, [index]
        inc ecx
        add ebx, 4
        jmp fillArray2Loop


        contt2:
        mov ebp, [array + ebx]
        mov [array2 + eax], ebp
        mov edx, [index2]
        inc edx
        add eax, 4
        mov ecx, [index]
        inc ecx
        add ebx, 4
        jmp fillArray2Loop
endfillLoop:
        ret


;_________________________ Array2 output method _____________________________
Vector2Out:
        mov eax, 0
        mov [tmpStack], esp
        xor ecx, ecx
        mov ebx, array2
putVecLoop:
        mov [tmp2], ebx
        cmp ecx, [lenght2]
        je endOutputVector
        mov [index2], ecx

        mov eax, [lenght2]
        dec eax
        cmp ecx, eax
        jl outContinue
        push dword [ebx]
        push strLastVecElemOut
        call [printf]

        mov ecx, [index2]
        inc ecx
        mov ebx, [tmp2]
        add ebx, 4
        jmp putVecLoop

        outContinue:
        push dword [ebx]
        push strVecElemOut
        call [printf]

        mov ecx, [index2]
        inc ecx
        mov ebx, [tmp2]
        add ebx, 4
        jmp putVecLoop
endOutputVector:
        mov esp, [tmpStack]
        ret
;_________________________ Array output method _____________________________
VectorOut:
        mov eax, 0
        mov [tmpStack], esp
        xor ecx, ecx
        mov ebx, array
putVecLoop22:
        mov [tmp], ebx
        cmp ecx, [lenght]
        je endOutputVector22
        mov [index], ecx

        mov eax, [lenght]
        dec eax
        cmp ecx, eax
        jl outContinue22
        push dword [ebx]
        ;push ecx
        push strLastVecElemOut
        call [printf]

        mov ecx, [index]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop22

        outContinue22:
        push dword [ebx]
        push strVecElemOut
        call [printf]

        mov ecx, [index]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop22
endOutputVector22:
        mov esp, [tmpStack]
        ret



;___________________________Data import section_____________________________
section '.idata' import data readable

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess'

        import msvcrt,\
               printf, 'printf',\
               getch, '_getch',\
               scanf, 'scanf'