#include <stdbool.h>

// Функция, которая будет вызвана загрузчиком
void kmain(void)
{
    const char *str = "Hello, KripOS User!"; // Строка, которую мы выведем на экран при запуске ОС
    char *vidptr = (char*)0xb8000; // Видеопамять начинается здесь
    unsigned int i = 0;
    unsigned int j = 0;

    // Данный цикл очистит экран от системной информации
    while (j < 80 * 25 * 2) {
        vidptr[j] = ' '; // Пустой символ
        vidptr[j + 1] = 0x07; // Атрибут символа (цвет)
        j = j + 2;
    }

    j = 0;

    // В этом цикле строка записывается в видеопамять
    while (str[j] != '\0') {
        // Выводим нашу строку (str) на экран
        vidptr[i] = str[j];
        vidptr[i + 1] = 0x07;
        ++j;
        i = i + 2;
    }

    // Переход на новую строку
    i += 160; // 80 символов * 2 байта (символ + атрибут)

    // Основной цикл командной строки
    char input_buffer[80];
    int buffer_index = 0;

    while (true) {
        // Ожидание ввода команды
        char ch = get_char(); // Функция для получения символа с клавиатуры (нужно реализовать)

        if (ch == '\n') {
            // Обработка команды
            input_buffer[buffer_index] = '\0'; // Завершаем строку
            buffer_index = 0;

            // Проверка команд
            if (strcmp(input_buffer, "help") == 0) {
                // Вывод списка команд
                print_string("Available commands:\n");
                print_string("  help - Show this help message\n");
                print_string("  echo <text> - Print text to the screen\n");
            } else if (strncmp(input_buffer, "echo ", 5) == 0) {
                // Команда echo
                print_string(input_buffer + 5);
                print_string("\n");
            } else if (strlen(input_buffer) > 0) {
                // Неизвестная команда
                print_string("command not found: ");
                print_string(input_buffer);
                print_string("\n");
            }

            // Очистка буфера
            memset(input_buffer, 0, sizeof(input_buffer));
        } else {
            // Добавление символа в буфер
            if (buffer_index < 79) {
                input_buffer[buffer_index] = ch;
                buffer_index++;
            }
        }
    }

    return;
}

// Функция для вывода строки на экран
void print_string(const char *str) {
    char *vidptr = (char*)0xb8000;
    unsigned int i = 0;

    while (str[i] != '\0') {
        vidptr[i] = str[i];
        vidptr[i + 1] = 0x07;
        i += 2;
    }
}

// Функция для получения символа с клавиатуры (заглушка, нужно реализовать)
char get_char() {
    // Здесь должна быть реализация получения символа с клавиатуры
    // Например, через прерывания клавиатуры
    return '\0';
}

// Функция для сравнения строк (аналог strcmp)
int strcmp(const char *s1, const char *s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return *(unsigned char*)s1 - *(unsigned char*)s2;
}

// Функция для получения длины строки (аналог strlen)
int strlen(const char *str) {
    int len = 0;
    while (str[len] != '\0') {
        len++;
    }
    return len;
}

// Функция для очистки памяти (аналог memset)
void memset(void *ptr, int value, size_t num) {
    unsigned char *p = ptr;
    while (num--) {
        *p++ = (unsigned char)value;
    }
}
