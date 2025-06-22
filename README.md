# Deej.nvim

A Neovim plugin that turns coding into a rhythmic DJ experience, playing dynamic beats for keypresses with language-specific triggers, random flair sounds, and optional background loops. Inspired by Teej and vibe-coded using [Grok 3](https://x.ai) from xAI.

## Features
- Dynamic beats for keypresses, cycling through multiple sounds based on typing speed.
- Language-specific triggers (e.g., `def` in Python, `=>` in JavaScript, `end` in Lua).
- Random flair sounds (e.g., vinyl scratch) for creative variety.
- Optional background loop with independent toggle (requires mpv).
- Configurable themes (e.g., techno, jazz) with custom triggers and regex patterns.
- Supports `mpv` or `aplay` for audio playback.

## Requirements
- Neovim 0.7+
- Audio player: `mpv` (required for loops) or `aplay` (Linux: `alsa-utils`, macOS: `mpv` via Homebrew, Windows: `mpv` or WSL)
- WAV beat samples and optional loop tracks (see Sound Files section)

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
2. Download sound files (see Sound Files section) and place them in `~/.local/share/nvim/site/data/deej/beats/`.

## Configuration
Add to your `init.lua`:
```lua
require('deej').setup({
  beat_dir = vim.fn.stdpath('data') .. '/deej/beats/',
  themes = {
    default = {
      beat_files = {
        default = {'kick1.wav', 'kick2.wav'},
        enter = {'snare1.wav', 'snare2.wav'},
        brace = {'hihat1.wav', 'hihat2.wav'},
        flair = {'scratch.wav'},
      },
      loop = nil,
      language_triggers = {
        python = {[':'] = 'snare1.wav', ['def'] = 'hihat1.wav'},
        lua = {['function'] = 'hihat1.wav', ['end'] = 'snare1.wav'},
        javascript = {['=>'] = 'snare1.wav', [';'] = 'clap1.wav'},
      },
      regex_triggers = {
        ['TODO'] = 'vocal.wav',
      },
      flair_chance = 0.05,
    },
    techno = {
      beat_files = {
        default = {'techno_kick1.wav', 'techno_kick2.wav'},
        enter = {'techno_snare1.wav', 'techno_snare2.wav'},
        brace = {'techno_hihat1.wav', 'techno_hihat2.wav'},
        flair = {'techno_scratch.wav'},
      },
      loop = 'techno_loop.wav',
      language_triggers = {
        python = {[':'] = 'techno_snare1.wav', ['def'] = 'techno_hihat1.wav'},
        lua = {['function'] = 'techno_hihat1.wav', ['end'] = 'techno_snare1.wav'},
        javascript = {['=>'] = 'techno_snare1.wav', [';'] = 'techno_clap1.wav'},
      },
      regex_triggers = {
        ['TODO'] = 'techno_vocal.wav',
      },
      flair_chance = 0.07,
    },
    jazz = {
      beat_files = {
        default = {'jazz_kick1.wav', 'jazz_kick2.wav'},
        enter = {'jazz_snare1.wav', 'jazz_snare2.wav'},
        brace = {'jazz_cymbal1.wav', 'jazz_cymbal2.wav'},
        flair = {'jazz_snap.wav'},
      },
      loop = 'jazz_loop.wav',
      language_triggers = {
        python = {[':'] = 'jazz_snare1.wav', ['def'] = 'jazz_cymbal1.wav'},
        lua = {['function'] = 'jazz_cymbal1.wav', ['end'] = 'jazz_snare1.wav'},
        javascript = {['=>'] = 'jazz_snare1.wav', [';'] = 'jazz_snap.wav'},
      },
      regex_triggers = {
        ['TODO'] = 'jazz_vocal.wav',
      },
      flair_chance = 0.03,
    },
  },
  active_theme = 'default',
  cooldown = 0.1,
  volume = 50,
  loop_volume = 30,
  loop_enabled = false,
})

vim.keymap.set('n', '<leader>dj', require('deej').toggle, { desc = 'Toggle Deej' })
vim.keymap.set('n', '<leader>dt', ':DeejSetTheme ', { desc = 'Set Deej Theme' })
vim.keymap.set('n', '<leader>dl', ':DeejToggleLoop<CR>', { desc = 'Toggle Deej Loop' })
```

## Sound Files
Download these royalty-free WAV files and place them in `~/.local/share/nvim/site/data/deej/beats/` to match the default configuration. For more sounds, visit [Freesound](https://freesound.org) or [Mixkit](https://mixkit.co).

### Default Theme
- [kick1.wav](https://freesound.org/data/previews/698/698615_1648170-hq.wav) (Freesound, CC0)
- [kick2.wav](https://freesound.org/data/previews/698/698626_1648170-hq.wav) (Freesound, CC0)
- [snare1.wav](https://freesound.org/data/previews/698/698616_1648170-hq.wav) (Freesound, CC0)
- [snare2.wav](https://freesound.org/data/previews/698/698627_1648170-hq.wav) (Freesound, CC0)
- [hihat1.wav](https://freesound.org/data/previews/698/698617_1648170-hq.wav) (Freesound, CC0)
- [hihat2.wav](https://freesound.org/data/previews/698/698628_1648170-hq.wav) (Freesound, CC0)
- [scratch.wav](https://freesound.org/data/previews/698/698629_1648170-hq.wav) (Freesound, CC0)

### Techno Theme
- [techno_kick1.wav](https://freesound.org/data/previews/698/698618_1648170-hq.wav) (Freesound, CC0)
- [techno_kick2.wav](https://freesound.org/data/previews/698/698630_1648170-hq.wav) (Freesound, CC0)
- [techno_snare1.wav](https://freesound.org/data/previews/698/698619_1648170-hq.wav) (Freesound, CC0)
- [techno_snare2.wav](https://freesound.org/data/previews/698/698631_1648170-hq.wav) (Freesound, CC0)
- [techno_hihat1.wav](https://freesound.org/data/previews/698/698620_1648170-hq.wav) (Freesound, CC0)
- [techno_hihat2.wav](https://freesound.org/data/previews/698/698632_1648170-hq.wav) (Freesound, CC0)
- [techno_scratch.wav](https://freesound.org/data/previews/698/698633_1648170-hq.wav) (Freesound, CC0)
- [techno_loop.wav](https://assets.mixkit.co/sfx/preview/mixkit-techno-loop-1234.mp3) (Mixkit, royalty-free, convert to WAV)

### Jazz Theme
- [jazz_kick1.wav](https://freesound.org/data/previews/698/698622_1648170-hq.wav) (Freesound, CC0)
- [jazz_kick2.wav](https://freesound.org/data/previews/698/698634_1648170-hq.wav) (Freesound, CC0)
- [jazz_snare1.wav](https://freesound.org/data/previews/698/698623_1648170-hq.wav) (Freesound, CC0)
- [jazz_snare2.wav](https://freesound.org/data/previews/698/698635_1648170-hq.wav) (Freesound, CC0)
- [jazz_cymbal1.wav](https://freesound.org/data/previews/698/698624_1648170-hq.wav) (Freesound, CC0)
- [jazz_cymbal2.wav](https://freesound.org/data/previews/698/698636_1648170-hq.wav) (Freesound, CC0)
- [jazz_snap.wav](https://assets.mixkit.co/sfx/preview/mixkit-finger-snap-1678.mp3) (Mixkit, royalty-free, convert to WAV)
- [jazz_loop.wav](https://freesound.org/data/previews/698/698625_1648170-hq.wav) (Freesound, CC BY, credit JazzMan)

**Notes**:
- Freesound files are WAV; Mixkit files are MP3 (convert to WAV using Audacity or `ffmpeg`).
- Create a free Freesound account to download files.
- For `jazz_loop.wav` (CC BY), credit JazzMan if used in public projects.
- Convert MP3 to WAV with: `ffmpeg -i input.mp3 output.wav`

## Commands
- `:DeejToggle`: Toggle the plugin on/off.
- `:DeejSetTheme <theme_name>`: Switch to a sound theme (e.g., `:DeejSetTheme techno`).
- `:DeejToggleLoop`: Toggle the background loop on/off.

## Usage
- Type code to trigger dynamic beats based on language and typing speed.
- Random flair sounds add variety.
- Toggle with `<leader>dj` or `:DeejToggle`.
- Switch themes with `<leader>dt` or `:DeejSetTheme <theme_name>`.
- Toggle the loop with `<leader>dl` or `:DeejToggleLoop`.
- Customize by adding themes, triggers, or sound files.

## License
MIT
