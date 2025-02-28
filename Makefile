#define LINES 25
#define COLUMNS_IN_LINE 80
#define BYTES_FOR_EACH_ELEMENT 2
#define SCREENSIZE (BYTES_FOR_EACH_ELEMENT * COLUMNS_IN_LINE * LINES)

unsigned int current_loc = 0;
char *vidptr = (char*)0xb8000;
unsigned int lines = 0; // Переменная для отслеживания количества строк

void clear_screen(void) {
    unsigned int i = 0;
    while (i < SCREENSIZE) {
        vidptr[i++] = ' ';
        vidptr[i++] = 0x07;
    }
    current_loc = 0;
    lines = 0; // Сбрасываем количество строк
}

void print(const char *str) {
    unsigned int i = 0;
    while (str[i] != '\0') {
        if (str[i] == '\n') {
            current_loc += 80 - (current_loc % 80);
            lines++; // Увеличиваем количество строк
        } else {
            vidptr[current_loc * 2] = str[i];
            vidptr[current_loc * 2 + 1] = 0x07;
            current_loc++;
        }

        if (current_loc >= 80 * 25) {
            current_loc = 0;
        }
        i++;
    }

    // Проверяем количество строк
    if (lines >= LINES) {
        clear_screen(); // Очищаем экран когда экран заполнится
        lines = 0; // Сбрасываем счетчик строк
    }
}

void printn(int num) {
    char buffer[32]; 
    int i = 0, isNegative = 0;

    if (num < 0) {
        isNegative = 1;
        num = -num;
    }

    do {
        buffer[i++] = (num % 10) + '0';
        num /= 10;
    } while (num > 0);

    if (isNegative) {
        buffer[i++] = '-';
    }

    // Обратный порядок
    for (int j = i - 1; j >= 0; j--) {
        vidptr[current_loc * 2] = buffer[j];
        vidptr[current_loc * 2 + 1] = 0x07;
        current_loc++;

        if (current_loc >= 80 * 25) {
            current_loc = 0;
        }
    }
    
    // Проверяем количество строк
    if (lines >= LINES) {
        clear_screen(); // Очищаем экран когда экран заполнится
        lines = 0; // Сбрасываем счетчик строк
    }
}

void kmain(void) {
    const char *str = "Hello,world!";
    int number = 10 + 1; //переменная для тестирования функции printn
    clear_screen();
    print("Hello,world!\n"); //выводим строку
    printn(number); //выводим число
    return;
}
