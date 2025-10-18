![](img/image.png)

# Video Wallpaper Selector for Hyprland

Quick video wallpaper selection through wofi with visual previews.

## Features

- Shows thumbnails of all videos in a beautiful menu
- Automatically generates and caches previews
- Launches videos as live wallpapers via mpvpaper
- Optionally updates system colors through pywal

## Dependencies

```bash
# Arch
sudo pacman -S hyprland wofi mpvpaper ffmpeg jq python-pywal
```

- `mpvpaper` - for video wallpapers
- `pywal` - optional, only for color scheme updates

## Installation

1. Copy files to `~/.config/hypr/`:
   - `wallpaper.sh`
   - `wallpaper.conf`
   - `wallpaper.css`

2. **Open `wallpaper.sh` and configure paths:**
```bash
VIDEO_DIR="$HOME/Videos/YourFolder"           # Path to your videos
CACHE_DIR="$HOME/.cache/wallpaper_thumbs"     # Where to store previews
CSS_FILE="$SCRIPT_DIR/wallpaper.css"          # Path to CSS
WOFI_CONF="$SCRIPT_DIR/wallpaper.conf"        # Path to wofi config
```

3. Make the script executable:
```bash
chmod +x ~/.config/hypr/wallpaper.sh
```

4. Add a keybind in `hyprland.conf`:
```conf
bind = $mainMod, W, exec, ~/.config/hypr/wallpaper.sh
```

## How it works

On each run, the script:
1. Checks all videos and creates previews for those that don't have them yet
2. Shows wofi menu with thumbnails
3. Kills old mpvpaper on the active monitor
4. Launches selected video as wallpaper
5. Updates color scheme via pywal (if installed)

Previews are cached in `~/.cache/wallpaper_thumbs/` - created only for new videos.

## Supported formats

`.mp4` `.mkv` `.webm` `.avi` `.mpv`