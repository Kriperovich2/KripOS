[BITS 16]        ; Режим 16-бит (режим реальных адресов)
[ORG 0x7C00]     ; Адрес загрузки BIOS

start:
    cli          ; Отключить прерывания
    xor ax, ax   ; Обнулить регистры
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00 ; Установить стек

    call set_video_mode ; Установить видеорежим
    call print_interface ; Вывести интерфейс
    call shell          ; Запустить оболочку

    hlt          ; Остановить процессор

; Установка видеорежима (текстовый режим 80x25)
set_video_mode:
    mov ax, 0x03 ; Видеорежим 80x25
    int 0x10     ; Вызов BIOS
    ret

; Вывод строки на экран
print_string:
    mov ah, 0x0E ; Функция BIOS для вывода символа
.print_char:
    lodsb        ; Загрузить следующий символ из строки
    cmp al, 0    ; Проверить конец строки
    je .done
    int 0x10     ; Вывести символ
    jmp .print_char
.done:
    ret

; Вывод новой строки
print_newline:
    mov ah, 0x0E
    mov al, 0x0D ; Возврат каретки
    int 0x10
    mov al, 0x0A ; Перевод строки
    int 0x10
    ret

; Вывод интерфейса
print_interface:
    mov si, header
    call print_string
    mov si, menu
    call print_string
    call print_newline
    ret

; Оболочка (shell)
shell:
    mov si, prompt
    call print_string
    call read_command
    call print_newline
    call execute_command
    jmp shell

; Чтение команды с клавиатуры
read_command:
    mov di, command_buffer
    xor cx, cx
.read_loop:
    mov ah, 0x00 ; Ожидание ввода символа
    int 0x16
    cmp al, 0x0D ; Enter
    je .done_read
    cmp al, 0x08 ; Backspace
    je .handle_backspace
    cmp cx, 255  ; Проверка на переполнение буфера
    jge .done_read
    stosb        ; Сохранить символ в буфер
    mov ah, 0x0E ; Вывести символ на экран
    int 0x10
    inc cx       ; Увеличить счетчик символов
    jmp .read_loop

.handle_backspace:
    cmp di, command_buffer ; Проверка, есть ли что удалять
    je .read_loop
    dec di       ; Удалить символ из буфера
    dec cx
    mov ah, 0x0E ; Удалить символ с экрана
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .read_loop

.done_read:
    mov byte [di], 0 ; Завершить строку нулем
    ret

; Выполнение команды
execute_command:
    mov si, command_buffer
    ; Проверка команды "help"
    mov di, help_str
    call compare_strings
    je do_help

    ; Проверка команды "cls"
    mov di, cls_str
    call compare_strings
    je do_cls

    ; Проверка команды "shut"
    mov di, shut_str
    call compare_strings
    je do_shutdown

    ; Неизвестная команда
    call unknown_command
    ret

; Сравнение строк
compare_strings:
    xor cx, cx
.next_char:
    lodsb        ; Загрузить символ из команды пользователя
    cmp al, [di] ; Сравнить с символом из команды
    jne .not_equal
    cmp al, 0    ; Проверить конец строки
    je .equal
    inc di
    jmp .next_char
.not_equal:
    ret
.equal:
    ret

; Команда "help"
do_help:
    mov si, menu
    call print_string
    call print_newline
    ret

; Команда "cls" (очистка экрана)
do_cls:
    mov ax, 0x03 ; Видеорежим 80x25
    int 0x10
    ret

; Команда "shut" (выключение компьютера)
do_shutdown:
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    ret

; Неизвестная команда
unknown_command:
    mov si, unknown_msg
    call print_string
    call print_newline
    ret

; Данные
header db '============================= UnderCore ====================================', 0
menu db 'Commands:', 10, 13
     db '  help - get list of the commands', 10, 13
     db '  cls - clear terminal', 10, 13
     db '  shut - shutdown PC', 10, 13, 0
unknown_msg db 'Unknown command.', 0
prompt db '[UnderCore] > ', 0
help_str db 'help', 0
cls_str db 'cls', 0
shut_str db 'shut', 0
command_buffer db 256 dup(0)

; Заполнение оставшейся части сектора нулями
times 510-($-$$) db 0
; Сигнатура загрузочного сектора
dw 0xAA55
