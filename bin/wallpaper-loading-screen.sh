#!/bin/bash

# 1. Запускаем kitty в фоне, добавив & в конец
kitty +kitten panel --edge=background /usr/local/bin/sand_wallpaper &

# 2. Сохраняем PID (идентификатор) только что запущенного фонового процесса
KITTY_PID=$!

# 3. Выполняем другие задачи или просто ждем 5 секунд
sleep 10

# 4. Убиваем процесс kitty по его сохраненному PID
kill $KITTY_PID
