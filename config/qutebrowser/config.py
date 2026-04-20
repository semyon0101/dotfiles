config.load_autoconfig(False)

config.set('content.cookies.accept', 'all', 'chrome-devtools://*')
config.set('content.cookies.accept', 'all', 'devtools://*')

config.set('content.headers.accept_language', '', 'https://matchmaker.krunker.io/*')

config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}; rv:145.0) Gecko/20100101 Firefox/145.0', 'https://accounts.google.com/*')
# config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}) AppleWebKit/{webkit_version} (KHTML, like Gecko) {qt_key}/{qt_version} {upstream_browser_key}/{upstream_browser_version_short} Safari/{webkit_version}', 'https://gitlab.gnome.org/*')
# config.set('content.headers.user_agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36', 'https://*')
# config.set('content.headers.user_agent', 'Mozilla/5.0 (X11; Linux x86_64; rv:145.0) Gecko/20100101 Firefox/145.0', 'https://accounts.google.com/*')

config.set('content.images', True, 'chrome-devtools://*')
config.set('content.images', True, 'devtools://*')

config.set('content.javascript.enabled', True, 'chrome-devtools://*')
config.set('content.javascript.enabled', True, 'devtools://*')
config.set('content.javascript.enabled', True, 'chrome://*/*')
config.set('content.javascript.enabled', True, 'qute://*/*')

config.set('content.local_content_can_access_remote_urls', True, 'file:///home/semyon/.local/share/qutebrowser/userscripts/*')

config.set('content.local_content_can_access_file_urls', False, 'file:///home/semyon/.local/share/qutebrowser/userscripts/*')

c.url.searchengines = {
    'DEFAULT': 'https://google.com/search?q={}',
    'aw': 'https://wiki.archlinux.org/title/Special:Search?search={}',
    'ddg': 'https://duckduckgo.com/?q={}', 
    'yt': 'https://www.youtube.com/results?search_query={}'
}

c.editor.command = ['kitty', '-e', 'nvim', '{file}']


#config.set('colors.webpage.darkmode.enabled', False, 'https://*.google.com/*')
#c.colors.webpage.darkmode.enabled = True
c.colors.webpage.preferred_color_scheme = 'dark'

# Enable smooth scrolling
c.scrolling.smooth = True

# Hide the window decoration (title bar) for a cleaner look in tiling window managers
c.window.hide_decoration = False

c.url.start_pages = ['file:///home/semyon/.config/qutebrowser/startpage/index.html']
c.url.default_page = 'file:///home/semyon/.config/qutebrowser/startpage/index.html'

c.qt.args = [
    'enable-gpu-rasterization',
    'ignore-gpu-blocklist',
    'enable-zero-copy',
    'enable-features=vaapiignoredriverchecks,vaapivideodecoder,acceleratedvideodecoder,acceleratedvideodecodelinuxgl,acceleratedvideoencoder,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE,FluentOverlayScrollbar,MiddleClickAutoscroll',
   'enable-experimental-web-platform-features',
   'disable-gpu-memory-buffer-video-frames=false',
#    'enable-features=VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization, Vulkan',
    'disable-features=UseChromeOSDirectVideoDecoder',

]
c.qt.environ = {"QTWEBENGINE_FORCE_USE_GBM": "0" }

c.auto_save.session = True

import os
os.environ["QT_QPA_PLATFORM"] = "wayland"

c.content.webgl = True 
c.content.canvas_reading = True
c.content.autoplay = True 

c.content.javascript.clipboard= "access" # не совсем про это, но полезно
c.input.insert_mode.auto_load = False


c.session.lazy_restore = True

import subprocess

# Запускаем bash-скрипт в фоновом режиме, чтобы он не тормозил запуск браузера
subprocess.Popen(['/bin/bash', '/usr/local/bin/rbw-unlock.sh'])

c.content.pdfjs = True

c.qt.chromium.process_model = 'process-per-site'

# Ограничиваем размер дискового кеша (например, 100 МБ)
c.content.cache.size = 104857600 

# Очищать RAM от неиспользуемых ресурсов (доступно в новых версиях Qt)
c.qt.chromium.low_end_device_mode = 'auto'

# --- styles -----
import catppuccin
config.load_autoconfig(False)#
catppuccin.setup(c, 'mocha', True) # 'latte', 'frappe', 'macchiato', 'mocha'

c.tabs.padding = {'bottom': 5, 'left': 5, 'right': 5, 'top': 5}
c.statusbar.padding = {'bottom': 5, 'left': 5, 'right': 5, 'top': 5}

c.fonts.default_family = 'JetBrains Mono' # Твой любимый моноширинный шрифт
c.fonts.default_size = '10pt'

# Шрифты для веба (чтобы сайты выглядели чисто)
c.fonts.web.family.standard = 'Inter'
c.fonts.web.family.sans_serif = 'Inter'
c.fonts.web.family.fixed = 'JetBrains Mono'


# ---- binds ----

config.unbind('.')
config.unbind('<Ctrl+v>')
config.bind('I', "mode-enter passthrough")

config.unbind('J')
config.unbind('K')
config.bind('J', 'tab-prev')
config.bind('K', 'tab-next')

config.unbind('gJ')
config.unbind('gK')
config.bind('gJ', 'tab-move -')
config.bind('gK', 'tab-move +')

# k - мгновенный скролл вниз (без инерции)
config.bind('k', 'cmd-run-with-count 2 scroll up')

# j - мгновенный скролл вверх (без инерции)
config.bind('j', 'cmd-run-with-count 2 scroll down')

#config.unbind('j', mode='normal')
#config.unbind('k', mode='normal')



config.bind('<Escape>', 'fake-key <Escape> ;; jseval -q document.activeElement.blur()')
# config.bind('<Escape>', 'jseval -q document.activeElement.blur()', mode='normal')

config.bind('zl', 'spawn --userscript bw-fill')
config.bind('zs', 'spawn --userscript bw-save')
config.bind('zr', 'spawn --userscript bw-reload')

# 1. Основные буквы (йцукен -> qwerty)
russian = 'йцукенгшщзфывапролдячсмить'
english = 'qwertyuiopasdfghjklzxcvbnm'

# 2. Спецсимволы Shift + Цифры (на RU раскладке они другие)
# RU: ! " № ; % : ? * ( ) _ +
# EN: ! @ # $ % ^ & * ( ) _ +
ru_shift_alt = '!"№;%:?хъХЪжЖэЭбБюЮ.,ёЁ'
en_shift_alt = '!@#$%^&[]{};:\'",<.>/?`~'

# Заполняем словарь маппингов
for r, e in zip(russian, english):
    c.bindings.key_mappings[r] = e
    c.bindings.key_mappings[r.upper()] = e.upper()

for r, e in zip(ru_shift_alt, en_shift_alt):
    c.bindings.key_mappings[r] = e

# 3. Фикс для запятой и точки (в RU они на одной клавише рядом с Shift)
# Это позволит Ctrl+. и Ctrl+, работать корректно
# c.bindings.key_mappings['/'] = '.'
# c.bindings.key_mappings['?'] = ','


# ---- add block ----

# Использовать оба метода блокировки
#c.content.blocking.method = 'both'

# Расширенные списки фильтров
#c.content.blocking.adblock.lists = [
#    "https://easylist.to/easylist/easylist.txt",
#    "https://easylist.to/easylist/easyprivacy.txt",
#    "https://easylist-downloads.adblockplus.org/ruadlist+easylist.txt",
#    "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt",
#    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt",
#    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/annoyances.txt",
#    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/resource-abuse.txt",
#    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt",
#    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt",
####]

c.content.blocking.method = 'adblock' # 'both' тратит ресурсы на парсинг hosts файлов, adblock справляется лучше
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://easylist-downloads.adblockplus.org/ruadlist+easylist.txt",
    "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt"
]
