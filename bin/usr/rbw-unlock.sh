#!/bin/bash

# Сюда вписываешь свой мастер-пароль
PASSWORD="$(cat ../../.env/bitwarden.key)"

# 1. Прибиваем зависшего агента на всякий случай
rbw stop-agent 2>/dev/null

# 2. Жестко задаем консольный режим
rbw config set pinentry pinentry-tty

# 3. Запускаем rbw unlock в скрытой (detached) tmux-сессии. 
# tmux создаст идеальную иллюзию реального терминала, и pinentry-tty ничего не заподозрит.
tmux new-session -d -s rbw_hack 'rbw unlock'

# 4. Даем полсекунды, чтобы агент поднялся и отрисовал запрос пароля
sleep 0.5

# 5. Имитируем нажатия клавиш: отправляем пароль в сессию и жмем Enter
tmux send-keys -t rbw_hack "$PASSWORD" Enter

# 6. Даем долю секунды на расшифровку базы
sleep 0.5

# 7. Подчищаем за собой: если сессия еще жива (например, пароль не подошел), убиваем её
tmux kill-session -t rbw_hack 2>/dev/null

# (Опционально) Возвращаем графический интерфейс, если он нужен тебе для других скриптов
# rbw config set pinentry pinentry-gnome3
