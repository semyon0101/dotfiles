if status is-interactive
# 1. Clear the default greeting
set -U fish_greeting ""

# Автозапуск Niri при логине на TTY1
if status is-login
    # Проверяем, что мы на первой консоли и графика еще не запущена
    if test (tty) = "/dev/tty1"
        # Переменные для корректной работы Wayland
        set -gx XDG_SESSION_TYPE wayland
        set -gx XDG_CURRENT_DESKTOP niri
        
        # exec wallpaper-loading-screen.sh &
        # Запуск через dbus-run-session лечит ошибки с шиной данных
        exec niri-session
        # sleep 10
    end
end

# 2. Initialize Oh My Posh with a highly visual built-in theme
# 'amro' and 'paradox' are great out-of-the-box themes with pretty characters
if test "$TERM" = "linux"
    # We are in the raw TTY. Use a simple, clean prompt without icons.
    function fish_prompt
        set_color green
        echo -n $USER
        set_color normal
        echo -n "@arch "
        set_color white
        echo -n (prompt_pwd)
        set_color normal
        echo -n " > "
    end
else
    # We are in Kitty/Niri. Load the beautiful Oh My Posh theme!
    oh-my-posh init fish --config ~/.config/oh-my-posh/my_theme.omp.json | source
    alias icat="kitty +kitten icat"
    fastfetch
end
# 3. Initialize Zoxide (Smart CD)
zoxide init fish | source

# 4. Modern visually-rich aliases
alias ls="eza --icons --group-directories-first"
alias ll="eza --icons --group-directories-first --long --header --git --all --all"
alias tree="eza --icons --tree"
alias cat="bat"
export DEBUGINFOD_URLS="https://debuginfod.archlinux.org"


# == Pager Colors (Tab Completion Menu) ==
# This makes the selected item have a subtle dark background and bright text
set -g fish_pager_color_selected_background --background=555555
set -g fish_color_search_match --background=8f7e21
#set -g fish_pager_color_selected_prefix cyan
#set -g fish_pager_color_selected_completion white
# set -g fish_pager_color_selected_description brblack

function fish_user_key_bindings
    # Ctrl+Backspace: удалить слово слева от курсора (backward-kill-word)
    # Чаще всего терминалы отправляют \b или \cH
    bind \b backward-kill-word
    bind \cH backward-kill-word

    # Ctrl+Delete: удалить слово справа от курсора (kill-word)
    bind \e\[3\;5~ kill-word

    # Ctrl+Стрелка Влево: перепрыгнуть на слово назад
    bind \e\[1\;5D backward-word

    # Ctrl+Стрелка Вправо: перепрыгнуть на слово вперед
    bind \e\[1\;5C forward-word
end

end
