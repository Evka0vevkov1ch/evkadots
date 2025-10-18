#!/bin/bash

VIDEO_DIR=""
CACHE_DIR=""
CSS_FILE=""
WOFI_DIR=""

mkdir -p "$VIDEO_DIR" "$CACHE_DIR"

generate_thumbnails() {
    shopt -s nullglob nocaseglob
    for vid in "$VIDEO_DIR"/*.{mp4,mkv,webm,avi,mpv}; do
        [ -f "$vid" ] || continue
        vidname="$(basename "$vid")"
        thumb="$CACHE_DIR/${vidname}.jpg"
        [ -f "$thumb" ] && [ -s "$thumb" ] && continue

        echo "Создаём превью для: $vidname"
        
        ffmpeg -i "$vid" -ss 00:00:03 -vframes 1 -vf "scale=640:-1" "$thumb" -y >/dev/null 2>&1
        
        if [ ! -s "$thumb" ]; then
            echo "⚠ Не удалось создать превью для $vidname"
            rm -f "$thumb"
        else
            echo "✓ Превью создано: $vidname"
        fi
    done
}

build_menu() {
    for vid in "$VIDEO_DIR"/*.{mp4,mkv,webm,avi,mpv}; do
        [ -f "$vid" ] || continue
        vidname="$(basename "$vid")"
        thumb="$CACHE_DIR/${vidname}.jpg"
        
        [ -s "$thumb" ] || continue
        
        echo "img:$thumb"
    done
}

launch_wallpaper() {
    local video="$1"
    MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true).name')
    [ -z "$MONITOR" ] && { echo "Не удалось определить активный монитор"; exit 1; }

    for pid in $(pgrep -x mpvpaper 2>/dev/null); do
        cmdline=$(ps -p "$pid" -o args=)
        [[ "$cmdline" == *"$MONITOR"* ]] && kill "$pid" >/dev/null 2>&1
    done

    mpvpaper -f -o "no-audio loop --profile=fast --vo=gpu-next --no-osd-bar" "$MONITOR" "$video" &
}

update_colors() {
    local video="$1"
    command -v wal >/dev/null 2>&1 && wal -i "$video" -n --cols16 >/dev/null 2>&1
}

generate_thumbnails

CHOICE=$(build_menu | wofi --show dmenu --conf "$WOFI_DIR" -s "$CSS_FILE")
[ -z "$CHOICE" ] && exit 0

SELECTED_THUMB=$(echo "$CHOICE" | sed 's/^img://')

echo "Выбрано превью: $SELECTED_THUMB"

VIDNAME=$(basename "$SELECTED_THUMB" .jpg)
VIDEO="$VIDEO_DIR/$VIDNAME"

echo "Соответствующее видео: $VIDEO"

[ ! -f "$VIDEO" ] && { echo "Видео не найдено: $VIDEO"; exit 1; }

launch_wallpaper "$VIDEO"
update_colors "$VIDEO"