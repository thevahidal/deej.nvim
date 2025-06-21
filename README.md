# Deej.nvim

A Neovim plugin that plays DJ beats as you type code, turning your coding session into a rhythmic experience, the name is inspired by a DJ Teej. Vibe-coded using [Grok 3](https://x.ai) from xAI.

## Features
- Plays beats for each keypress (e.g., kick for regular characters, snare for enter).
- Supports themes for different sound profiles (e.g., techno, jazz).
- Optional background loop for a continuous rhythm (requires mpv).
- Configurable beat mappings, loop, and cooldown.
- Toggleable with a command or keymap.
- Supports `mpv` or `aplay` for audio playback.

## Requirements
- Neovim 0.7+
- Audio player: `mpv` (required for loops) or `aplay` (Linux: `alsa-utils`, macOS: `mpv` via Homebrew, Windows: `mpv` or WSL)
- WAV beat samples and optional loop tracks for each theme (e.g., from freesound.org)

## Installation

### Using `lazy.nvim`
```lua
{ 'thevahidal/deej.nvim', config = function() require('deej').setup() end }
```

### Using `packer.nvim`
```lua
use 'thevahidal/deej.nvim'
```

### Using `vim-plug`
```vim
Plug 'thevahidal/deej.nvim'
```

### Post-Installation
1. Install an audio player:
   - Linux: `sudo apt-get install alsa-utils mpv`
   - macOS: `brew install mpv`
   - Windows: Install `mpv` and add to PATH, or use WSL.
2. Download beat samples (e.g., kick.wav, techno_kick.wav) and optional loop tracks (e.g., techno_loop.wav). Place them in `~/.local/share/nvim/site/data/deej/beats/`.

## Configuration
Add to your `init.lua`:
```lua
require('deej').setup({
  beat_dir = vim.fn.stdpath('data') .. '/deej/beats/',
  themes = {
    default = {
      beat_files = {
        default = 'kick.wav',
        enter = 'snare.wav',
        brace = 'hihat.wav',
        semicolon = 'clap.wav',
      },
      loop = nil,
    },
    techno = {
      beat_files = {
        default = 'techno_kick.wav',
        enter = 'techno_snare.wav',
        brace = 'techno_hihat.wav',
        semicolon = 'techno_clap.wav',
      },
      loop = 'techno_loop.wav',
    },
    jazz = {
      beat_files = {
        default = 'jazz_kick.wav',
        enter = 'jazz_snare.wav',
        brace = 'jazz_cymbal.wav',
        semicolon = 'jazz_snap.wav',
      },
      loop = 'jazz_loop.wav',
    },
  },
  active_theme = 'default',
  cooldown = 0.1, -- Time between triggered sounds
  volume = 50,    -- Volume for triggered beats
  loop_volume = 30, -- Volume for loop track
})

vim.keymap.set('n', '<leader>dj', require('deej').toggle, { desc = 'Toggle Deej' })
vim.keymap.set('n', '<leader>dt', ':DeejSetTheme ', { desc = 'Set Deej Theme' })
```

## Commands
- `:DeejToggle`: Toggle the plugin and background loop on/off.
- `:DeejSetTheme <theme_name>`: Switch to a sound theme (e.g., `:DeejSetTheme techno`).

## Usage
- Type code to trigger beats based on the active theme, with an optional background loop.
- Toggle with `<leader>dj` or `:DeejToggle`.
- Switch themes with `<leader>dt` or `:DeejSetTheme <theme_name>`.
- Customize by adding themes or replacing sound files in `beat_dir`.

## License
MIT
