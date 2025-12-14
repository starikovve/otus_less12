#!/bin/bash

# Количество итераций  500000
# Для современных CPU нужно около 50-100 млн операций для загрузки на пару секунд
LOOPS=500000

# Функция нагрузки
function cpu_burner() {
    local name=$1
    local nice_val=$2
    local limit=$3      # Принимаем лимит итераций как аргумент
    local start_ts=$(date +%s%3N)
    local res=0

    echo "Старт: $name (Nice: $nice_val)"

    # Нагрузочный цикл (чистая арифметика)
    for (( i=0; i<=limit; i++ )); do
        res=$(( i * 2 ))
    done

    local end_ts=$(date +%s%3N)
    local duration=$(( end_ts - start_ts ))
    echo "ФИНИШ: $name (Nice: $nice_val). Время: ${duration} мс"
}

# Экспортируем функцию, чтобы она была видна в дочерних процессах
export -f cpu_burner

echo "=== Запуск соревнования процессов ==="
echo "Нагрузка: $LOOPS итераций."
echo "Используется одно ядро (CPU 0) для честной конкуренции."
echo "---------------------------------------------------"

# Запускаем на 0-м ядре.
# Важно: $LOOPS передается как третий аргумент внутри строки команды

# 1. Высокий приоритет (Nice 0 - стандартный)
taskset -c 0 nice -n 0 bash -c "cpu_burner 'Process_High' 0 $LOOPS" &
pid1=$!

# 2. Низкий приоритет (Nice 19 - уступает всем)
taskset -c 0 nice -n 19 bash -c "cpu_burner 'Process_Low ' 19 $LOOPS" &
pid2=$!

# Ждем завершения
wait $pid1
wait $pid2

echo "---------------------------------------------------"
echo "=== Соревнование завершено ==="
