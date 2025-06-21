# deej.nvim

A Neovim plugin that plays DJ beats as you type code, turning your coding session into a rhythmic experience.

## Features
- Plays beats for each keypress (e.g., kick for regular characters, snare for enter).
- Configurable beat mappings and cooldown.
- Toggleable with a command or keymap.
- Supports `mpv` or `aplay` for audio playback.

## Requirements
- Neovim 0.7+
- Audio player: `mpv` or `aplay` (Linux: `alsa-utils`, macOS: `mpv` via Homebrew, Windows: `mpv` or WSL)
- WAV beat samples (e.g., from freesound.org)

## Installation

### Using `lazy.nvim`
```lua
{ 'thevahidal/deej.nvim', config = function() require('deej').setup() end }
```

Using packer.nvim
```lua
use 'thevahidal/deej.nvim'
```

Using vim-plug
```vim
Plug 'thevahidal/deej.nvim'
```

## Post-Installation

1. Install an audio player:
- Linux: sudo apt-get install alsa-utils mpv
- macOS: brew install mpv
- Windows: Install mpv and add to PATH, or use WSL.
2. Download beat samples (e.g., kick.wav, snare.wav) and place them in ~/.local/share/nvim/site/data/deej/beats/.

## Configuration

Add to your init.lua:

```lua
require('deej').setup({
  beat_dir = vim.fn.stdpath('data') .. '/deej/beats/',
  beat_files = {
    default = 'kick.wav',
    enter = 'snare.wav',
    brace = 'hihat.wav',
    semicolon = 'clap.wav',
  },
  cooldown = 0.1, -- Time between sounds (seconds)
  volume = 50,    -- Volume for mpv (0-100)
})

vim.keymap.set('n', '<leader>dj', require('deej').toggle, { desc = 'Toggle Deej' })
```
## Commands

- :DeejToggle: Toggle the plugin on/off.

## Usage

- Type code to trigger beats.
- Toggle with <leader>dj or :DeejToggle.
- Customize by replacing beat files or updating the configuration.
