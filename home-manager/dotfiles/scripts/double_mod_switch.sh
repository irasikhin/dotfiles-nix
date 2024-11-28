#!/usr/bin/env bash

# Файл для хранения времени последнего нажатия
LAST_PRESS_FILE="/tmp/last_mod_press"

# Время ожидания для двойного нажатия (в секундах)
DOUBLE_PRESS_TIME=0.1

# Проверяем наличие файла и считываем последнее время нажатия
if [ -f "$LAST_PRESS_FILE" ]; then
  last_time=$(cat "$LAST_PRESS_FILE")
  current_time=$(date +%s.%N)
  diff=$(echo "$current_time - $last_time" | bc)

  # Если нажатие произошло в интервале времени, выполняем переключение
  if (($(echo "$diff < $DOUBLE_PRESS_TIME" | bc -l))); then
    i3-msg workspace terminal
  fi
fi

# Обновляем время последнего нажатия
date +%s.%N >"$LAST_PRESS_FILE"
