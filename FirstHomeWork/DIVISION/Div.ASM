format PE console    ; оепеохяюмн я бхдеспнйю 3 мю йюмюке BYTE++ х мелмнцн оепедекюмн врнаш ашк ббнд я йнмянкх

entry start

include 'win32a.inc'

section '.data' data readable writable

        resStr db 'Result: %d', 0
        emptyStr db '%d', 0
        point db ',', 0

        A dd ?
        B dd ?
        C dd ?

        NULL = 0





section '.code' code readable executable

        start:
                push A
                push emptyStr
                call [scanf]

                push B
                push emptyStr
                call [scanf]
                ;mov [A], 11
                ;mov [B], 3

                mov eax, [A]
                mov ecx, [B]
                mov edx, 0

                div ecx
                mov [C], edx

                push eax
                push resStr
                call [printf]

                push point
                call [printf]

                mov ebx, 0
                lp:

                        mov eax, [C]
                        mov ecx, [B]
                        imul eax, 10

                        mov edx, 0
                        div ecx
                        mov [C], edx

                        push eax
                        push emptyStr
                        call [printf]

                        inc ebx
                        cmp ebx, 3
                jne lp


                call [getch]

                push NULL
                call [ExitProcess]




section '.idata' import data readable

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess'

        import msvcrt,\
               printf, 'printf',\
               getch, '_getch',\
               scanf, 'scanf'
