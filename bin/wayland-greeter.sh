#!/bin/bash
rm -f /tmp/greeter_auth_success

# Временное окружение для труб (под рутом)
export XDG_RUNTIME_DIR=/run/user/0
mkdir -p $XDG_RUNTIME_DIR
chmod 0700 $XDG_RUNTIME_DIR

# Запуск труб
cage -s -- foot -F -f "monospace:size=16" -e /usr/local/bin/my-greeter

# Если пароль верный
if [ -f /tmp/greeter_auth_success ]; then
    rm -f /tmp/greeter_auth_success
    
    # ОЧИСТКА: Удаляем переменные рута, чтобы они не испортили сессию semyon
    unset XDG_RUNTIME_DIR
    unset XDG_SESSION_ID
    unset XDG_SESSION_TYPE
    
    # Даем видеокарте 0.5 сек, чтобы "отдохнуть" после cage
    # sleep 0.5
    
    # Просто логинимся. Чисто и официально.
    exec /bin/login -p -f semyon
    # exec /bin/login -p -f semyon #SHELL=/bin/bash dbus-run-session niri-session
    # exec SHELL=/bin/bash dbus-run-session niri-session
fi
