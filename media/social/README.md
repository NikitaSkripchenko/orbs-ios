# ThinkingOrbsKit — social videos

Три готовых вертикальных ролика: **1080×1920, 9:16, 18 секунд, 30 fps**, H.264 + AAC stereo.

- `thinking-orbs-noir.mp4` — чёрный фон, крупные сферы, спокойные переходы; музыка 80 BPM.
- `thinking-orbs-editorial.mp4` — тёплый светлый фон, графичные формы; музыка 100 BPM.
- `thinking-orbs-pulse.mp4` — ритмичная смена состояний и светлого/тёмного фона; музыка 120 BPM.

После обратной связи убраны рекламные заголовки, код и названия отдельных состояний. Остались название проекта, «9 состояний», ссылка и компактный credit в финале. Все три варианта показывают девять анимаций.

Геометрия рассчитывается существующими Swift-движками, используя `.points64` и preset speed, затем увеличивается для видеокомпозиции. Это motion-презентация, а не запись интерфейса приложения. Публичный SwiftUI-компонент остаётся iOS-only.

Звук синтезирован локально без сторонних семплов: аккорды, короткие ноты, мягкий kick и ticks. Музыка встроена в MP4. Отдельные WAV сохранены для дальнейшего монтажа. Обложки: `*-cover.png`.

Original animation design and engine mathematics: © 2026 Jakub Antalik, MIT. See the repository `LICENSE` and `Upstream/UPSTREAM.md`. Pinned engine sources and license were not changed.

## Повторная сборка

Требования только для экспорта: macOS, установленный Swift/Xcode и FFmpeg в `/opt/homebrew/bin/ffmpeg`. Зависимости пакета не меняются.

Из корня репозитория:

```sh
bash media/social/render.sh                 # Все три MP4, WAV и обложки
bash media/social/render.sh --preview       # По пять пробных кадров
python3 media/social/verify.py              # Формат, длительность, 540 кадров, декодирование и звук
```

`storyboard.jpg` содержит кадры финальных MP4 на 1.5, 5, 9.5, 12 и 16 секундах; строки: Noir, Editorial, Pulse.

Встроенная проверка экспорта не заменяет iOS-тесты приложения. Исходники пакета и демо не изменялись.
