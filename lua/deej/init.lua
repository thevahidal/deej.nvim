local M = {}

-- Default configuration
M.config = {
	enabled = true,
	beat_dir = vim.fn.stdpath("data") .. "/deej/beats/",
	themes = {
		default = {
			beat_files = {
				default = { "kick1.wav", "kick2.wav" }, -- Cycle through multiple sounds
				enter = { "snare1.wav", "snare2.wav" },
				brace = { "hihat1.wav", "hihat2.wav" },
				flair = { "scratch.wav" }, -- Random flair sounds
			},
			loop = nil,
			language_triggers = {
				python = { [":"] = "snare1.wav", ["def"] = "hihat1.wav" },
				lua = { ["function"] = "hihat1.wav", ["end"] = "snare1.wav" },
				javascript = { ["=>"] = "snare1.wav", [";"] = "clap1.wav" },
			},
			regex_triggers = {
				["TODO"] = "vocal.wav",
			},
			flair_chance = 0.05, -- 5% chance for flair sound
		},
		techno = {
			beat_files = {
				default = { "techno_kick1.wav", "techno_kick2.wav" },
				enter = { "techno_snare1.wav", "techno_snare2.wav" },
				brace = { "techno_hihat1.wav", "techno_hihat2.wav" },
				flair = { "techno_scratch.wav" },
			},
			loop = "techno_loop.wav",
			language_triggers = {
				python = { [":"] = "techno_snare1.wav", ["def"] = "techno_hihat1.wav" },
				lua = { ["function"] = "techno_hihat1.wav", ["end"] = "techno_snare1.wav" },
				javascript = { ["=>"] = "techno_snare1.wav", [";"] = "techno_clap1.wav" },
			},
			regex_triggers = {
				["TODO"] = "techno_vocal.wav",
			},
			flair_chance = 0.07,
		},
		jazz = {
			beat_files = {
				default = { "jazz_kick1.wav", "jazz_kick2.wav" },
				enter = { "jazz_snare1.wav", "jazz_snare2.wav" },
				brace = { "jazz_cymbal1.wav", "jazz_cymbal2.wav" },
				flair = { "jazz_snap.wav" },
			},
			loop = "jazz_loop.wav",
			language_triggers = {
				python = { [":"] = "jazz_snare1.wav", ["def"] = "jazz_cymbal1.wav" },
				lua = { ["function"] = "jazz_cymbal1.wav", ["end"] = "jazz_snare1.wav" },
				javascript = { ["=>"] = "jazz_snare1.wav", [";"] = "jazz_snap.wav" },
			},
			regex_triggers = {
				["TODO"] = "jazz_vocal.wav",
			},
			flair_chance = 0.03,
		},
	},
	active_theme = "default",
	cooldown = 0.1, -- Minimum time (seconds) between triggered sounds
	volume = 50, -- Volume for triggered beats (0-100)
	loop_volume = 30, -- Volume for loop track (0-100)
	loop_enabled = false, -- Separate loop toggle
}

-- State variables
local last_played = 0
local beat_queue = {}
local loop_job_id = nil -- Track loop process
local sound_counter = {} -- Track sound cycling
local typing_timestamps = {} -- Track typing speed
local max_timestamps = 10 -- For calculating typing speed

-- Check if audio player is available
local function has_audio_player()
	return vim.fn.executable("mpv") == 1 or vim.fn.executable("aplay") == 1
end

-- Play a sound file
local function play_sound(beat)
	local beat_path = M.config.beat_dir .. beat
	if vim.fn.filereadable(beat_path) == 0 then
		vim.notify("Beat file not found: " .. beat_path, vim.log.levels.WARN)
		return
	end

	local current_time = vim.loop.now() / 1000
	if current_time - last_played < M.config.cooldown then
		table.insert(beat_queue, beat)
		return
	end

	last_played = current_time
	if vim.fn.executable("mpv") == 1 then
		vim.fn.jobstart({ "mpv", "--no-video", "--volume=" .. M.config.volume, beat_path }, {
			detach = true,
			stdout_buffered = false,
			stderr_buffered = false,
			on_stdout = function() end, -- Suppress output
			on_stderr = function() end,
		})
	elseif vim.fn.executable("aplay") == 1 then
		vim.fn.jobstart({ "aplay", beat_path }, {
			detach = true,
			stdout_buffered = false,
			stderr_buffered = false,
			on_stdout = function() end,
			on_stderr = function() end,
		})
	else
		vim.notify("No audio player (mpv or aplay) found", vim.log.levels.ERROR)
	end
end

-- Start background loop
local function start_loop()
	if not M.config.loop_enabled or loop_job_id then
		return
	end
	local loop_file = M.config.themes[M.config.active_theme].loop
	if not loop_file then
		return
	end
	local loop_path = M.config.beat_dir .. loop_file
	if vim.fn.filereadable(loop_path) == 0 then
		vim.notify("Loop file not found: " .. loop_path, vim.log.levels.WARN)
		return
	end

	if vim.fn.executable("mpv") == 1 then
		loop_job_id = vim.fn.jobstart(
			{ "mpv", "--no-video", "--volume=" .. M.config.loop_volume, "--loop", loop_path },
			{
				detach = true,
				stdout_buffered = false,
				stderr_buffered = false,
				on_stdout = function() end,
				on_stderr = function() end,
			}
		)
	else
		vim.notify("mpv required for loop sound", vim.log.levels.WARN)
	end
end

-- Stop background loop
local function stop_loop()
	if loop_job_id then
		vim.fn.jobstop(loop_job_id)
		loop_job_id = nil
	end
end

-- Process queued sounds
local function process_queue()
	if #beat_queue > 0 then
		local current_time = vim.loop.now() / 1000
		if current_time - last_played >= M.config.cooldown then
			local beat = table.remove(beat_queue, 1)
			play_sound(beat)
		end
	end
end

-- Get typing speed (keystrokes per second)
local function get_typing_speed()
	local now = vim.loop.now() / 1000
	table.insert(typing_timestamps, now)
	if #typing_timestamps > max_timestamps then
		table.remove(typing_timestamps, 1)
	end
	if #typing_timestamps < 2 then
		return 0
	end
	local duration = now - typing_timestamps[1]
	return #typing_timestamps / (duration > 0 and duration or 1)
end

-- Select sound from a list based on counter and typing speed
local function select_sound(sounds, trigger_type)
	sound_counter[trigger_type] = (sound_counter[trigger_type] or 0) % #sounds + 1
	local speed = get_typing_speed()
	-- Faster typing (>5 kps) picks the last sound in the list (assumed heavier)
	if speed > 5 and #sounds > 1 then
		return sounds[#sounds]
	end
	return sounds[sound_counter[trigger_type]]
end

-- Detect typing and map to beats
local function on_text_changed()
	if not M.config.enabled then
		return
	end

	local theme = M.config.themes[M.config.active_theme]
	local beat_files = theme.beat_files
	local filetype = vim.bo.filetype
	local language_triggers = theme.language_triggers[filetype] or {}
	local regex_triggers = theme.regex_triggers
	local line = vim.api.nvim_get_current_line()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local char = line:sub(cursor[2], cursor[2])

	-- Check for flair sound
	if math.random() < theme.flair_chance then
		play_sound(select_sound(beat_files.flair, "flair"))
		return
	end

	-- Check regex triggers (e.g., TODO)
	for pattern, sound in pairs(regex_triggers) do
		if line:match(pattern) then
			play_sound(sound)
			return
		end
	end

	-- Check language-specific triggers
	if language_triggers[char] then
		play_sound(language_triggers[char])
		return
	elseif char == "\n" then
		play_sound(select_sound(beat_files.enter, "enter"))
		return
	elseif char:match("[{}]") then
		play_sound(select_sound(beat_files.brace, "brace"))
		return
	end

	-- Default sound for other characters
	play_sound(select_sound(beat_files.default, "default"))
end

-- Setup autocommands
local function setup_autocmds()
	local group = vim.api.nvim_create_augroup("Deej", { clear = true })
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		group = group,
		callback = on_text_changed,
	})

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = stop_loop,
	})

	vim.loop.new_timer():start(0, 50, vim.schedule_wrap(process_queue))
end

-- Set active theme
function M.set_theme(theme_name)
	if not M.config.themes[theme_name] then
		vim.notify("Theme not found: " .. theme_name, vim.log.levels.ERROR)
		return
	end
	stop_loop()
	M.config.active_theme = theme_name
	sound_counter = {} -- Reset sound cycling
	if M.config.enabled and M.config.loop_enabled then
		start_loop()
	end
	vim.notify("Deej: Switched to theme " .. theme_name)
end

-- Toggle loop independently
function M.toggle_loop()
	M.config.loop_enabled = not M.config.loop_enabled
	if M.config.loop_enabled then
		start_loop()
	else
		stop_loop()
	end
	vim.notify("Deej: Loop " .. (M.config.loop_enabled and "Enabled" or "Disabled"))
end

-- Plugin setup function
function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

	if not has_audio_player() then
		vim.notify("Deej: No audio player (mpv or aplay) found. Please install one.", vim.log.levels.ERROR)
		return
	end

	if not M.config.themes[M.config.active_theme] then
		vim.notify("Active theme not found: " .. M.config.active_theme, vim.log.levels.ERROR)
		M.config.active_theme = "default"
	end

	vim.fn.mkdir(M.config.beat_dir, "p")

	if M.config.enabled and M.config.loop_enabled then
		start_loop()
	end

	setup_autocmds()

	vim.api.nvim_create_user_command("DeejSetTheme", function(opts)
		M.set_theme(opts.args)
	end, { nargs = 1 })

	vim.api.nvim_create_user_command("DeejToggleLoop", function()
		M.toggle_loop()
	end, { nargs = 0 })
end

-- Toggle plugin on/off
function M.toggle()
	M.config.enabled = not M.config.enabled
	if not M.config.enabled then
		stop_loop()
	elseif M.config.loop_enabled then
		start_loop()
	end
	vim.notify("Deej: " .. (M.config.enabled and "Enabled" or "Disabled"))
end

return M
