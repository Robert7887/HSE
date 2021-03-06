format PE console
entry start

include 'win32a.inc'


;__________________________Data reserve section____________________________
section '.data' data readable writable

        formatStr       db '%s', 0
        formatNum       db '%lf', 0

        const_2      dq 2.0     ; ��������� �� ��������� 2
        cosnt_1      dq 1.0     ; ��������� �� ��������� 1
        divider1     dq ?       ; ������ �������� �������� ����� ����
        divider2     dq ?       ; ������ �������� �������� ����� ����
        limit        dq 101.0   ; ������������ �� ������ ��������(�� �������)
        n            dq 0       ; ������ ����� ����
        t            dq 1       ; �������� �������� ����� ����
        s            dq 0       ; �������� ��������
        X            dq ?       ; ��������, �������� �������������
        eps          dq 0.0005  ; epsilon(�������� 0.05%)

        strInputX       db 'Enter the value of the function ch(x) argument in the range [-100;100] - ', 0
        strAnswer       db 'ch(%lf) = %lf', 0
        strIncorInput   db 'the number %lf is not in the diaozone [-100;100]', 0

;______________________________Code section________________________________
section '.code' code readable executable
start:
        push strInputX  ; ������ ������������ ������ �������� �������
        call [printf]   ;

        push X          ;
        push formatNum  ; ���������� ��������� �������� � ���������� �
        call [scanf]    ;

        fld [X]                 ;
        fabs                    ; ���������� ������ ���������� ��������
        fcomp qword [limit]     ; � ����������� ��������� ����������
        fstsw ax                ;
        sahf                    ;
        jnb stop                ; ���� ��������� �������� ��� ���������, ��������� ���������

        fld [s]          ;
        fadd [cosnt_1]   ; ����������� ������� ����� ���� � ��������� ����������
        fst [s]          ; ��������� ���������� �������� 1
        fstp [t]         ;

        calculateRow:
                fld [n]         ;
                fadd [cosnt_1]  ; �������������� ������ ����� ����
                fstp [n]        ;

                fld [t]         ;
                fmul [X]        ; �������� ���� ���� �� X^2
                fmul [X]        ;
                fstp [t]        ;

                fld [n]         ;
                fmul [const_2]  ; �������� ������ �������� ����� ����(2n)
                fstp [divider1] ; ���������� � divider1

                fld [n]         ;
                fmul [const_2]  ; �������� ������ �������� ����� ����(2n-1)
                fsub [cosnt_1]  ;
                fstp [divider2] ; ���������� � divider2

                fld [t]         ;
                fdiv [divider1] ; ����� ���� ���� �� divider1(2n)
                fdiv [divider2] ; � �� divider2(2*n-1)
                fstp [t]        ;

                fld [s]         ; ���������� � ��������� ����������
                fadd [t]        ; �������� ����� ����
                fstp [s]        ;

                fld [t]                 ;
                fabs                    ; ���������� ���� ���� �� ������
                fcomp qword [eps]       ; � ������������, ���� ���� ����
                fstsw ax                ; ������ ����������� ���������� ����
                sahf                    ; ����� ��������� ��������� � ��������� ���������
                jnb calculateRow        ;

        finish: ; ��������� ��������� � ������� ���������
                invoke printf, strAnswer, dword[X], dword[X+4], dword[s], dword[s+4]
                call [getch]
                push 0
                call [ExitProcess]

        stop:   ; ��������� ��������� �� ������� ������������ ������� ������
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