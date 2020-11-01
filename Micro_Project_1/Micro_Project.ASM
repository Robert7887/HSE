format PE console
entry start

include 'win32a.inc'


;__________________________Data reserve section____________________________
section '.data' data readable writable

        formatStr       db '%s', 0
        formatNum       db '%lf', 0

        const_2      dq 2.0     ; константа со значением 2
        cosnt_1      dq 1.0     ; константа со значением 1
        divider1     dq ?       ; первый делитель текущего члена ряда
        divider2     dq ?       ; второй делитель текущего члена ряда
        limit        dq 101.0   ; максимальный по модулю аргумент(не включая)
        n            dq 0       ; индекс члена ряда
        t            dq 1       ; значение текущего члена ряда
        s            dq 0       ; итоговое значение
        X            dq ?       ; значение, вводимое пользователем
        eps          dq 0.0005  ; epsilon(точность 0.05%)

        strInputX       db 'Enter the value of the function ch(x) argument in the range [-100;100] - ', 0
        strAnswer       db 'ch(%lf) = %lf', 0
        strIncorInput   db 'the number %lf is not in the diaozone [-100;100]', 0

;______________________________Code section________________________________
section '.code' code readable executable
start:
        push strInputX  ; Просим пользователя ввести аргумент функции
        call [printf]   ;

        push X          ;
        push formatNum  ; Записываем введенное значение в переменную Х
        call [scanf]    ;

        fld [X]                 ;
        fabs                    ; Сравниваем модуль введенного значения
        fcomp qword [limit]     ; С максимально возможным аргументом
        fstsw ax                ;
        sahf                    ;
        jnb stop                ; Если введенное значение вне диапозона, завершаем программу

        fld [s]          ;
        fadd [cosnt_1]   ; Присваиваем первому члену ряда и итоговому результату
        fst [s]          ; итоговому результату значение 1
        fstp [t]         ;

        calculateRow:
                fld [n]         ;
                fadd [cosnt_1]  ; инкрементируем индекс члена ряда
                fstp [n]        ;

                fld [t]         ;
                fmul [X]        ; умножаем член ряда на X^2
                fmul [X]        ;
                fstp [t]        ;

                fld [n]         ;
                fmul [const_2]  ; получаем первый делитель члена ряда(2n)
                fstp [divider1] ; записываем в divider1

                fld [n]         ;
                fmul [const_2]  ; получаем второй делитель члена ряда(2n-1)
                fsub [cosnt_1]  ;
                fstp [divider2] ; записываем в divider2

                fld [t]         ;
                fdiv [divider1] ; делим член ряда на divider1(2n)
                fdiv [divider2] ; и на divider2(2*n-1)
                fstp [t]        ;

                fld [s]         ; Прибавляем к итоговому результату
                fadd [t]        ; значение члена ряда
                fstp [s]        ;

                fld [t]                 ;
                fabs                    ; сравниваем член ряда по модулю
                fcomp qword [eps]       ; с погрешностью, если член ряда
                fstsw ax                ; больше погрешности продолжаем цикл
                sahf                    ; иначе формируем результат и завершаем программу
                jnb calculateRow        ;

        finish: ; Завершаем программу и выводим результат
                invoke printf, strAnswer, dword[X], dword[X+4], dword[s], dword[s+4]
                call [getch]
                push 0
                call [ExitProcess]

        stop:   ; Завершаем программу по причине некорректных входных данных
                invoke printf, strIncorInput, dword[X], dword[X+4]
                call [getch]
                push 0
                call [ExitProcess]

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