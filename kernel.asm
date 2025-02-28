bits 32 ;наша система будет 32 битной
section .text
        ;multiboot spec
        align 4
        dd 0x1BADB002            
        dd 0x00  
        dd - (0x1BADB002 + 0x00)

global start            ;обьявляем функцию, с которой начнётся выполнение ОС
extern kmain	        ;здесь мы импортируем функцию из другого файла, который мы создадим позже.

start:
  cli 			;блокировка прерываний
  mov esp, stack_space	;указатель стека
  call kmain    ;вызываем импортированную функцию
  hlt		 	;остановка процессора при завершении работы ОС

section .bss
resb 8192
stack_space
