local M = {}

-- Default configuration
M.config = {
	enabled = true,
	beat_dir = vim.fn.stdpath("data") .. "/deej/beats/",
	themes = {
		default = {
			beat_files = {
				default = "kick.wav",
				enter = "snare.wav",
				brace = "hihat.wav",
				semicolon = "clap.wav",
			},
			loop = nil, -- e.g., 'background_loop.wav'
		},
		techno = {
			beat_files = {
				default = "techno_kick.wav",
				enter = "techno_snare.wav",
				brace = "techno_hihat.wav",
				semicolon = "techno_clap.wav",
			},
			loop = "techno_loop.wav",
		},
		jazz = {
			beat_files = {
				default = "jazz_kick.wav",
				enter = "jazz_snare.wav",
				brace = "jazz_cymbal.wav",
				semicolon = "jazz_snap.wav",
			},
			loop = "jazz_loop.wav",
		},
	},
	active_theme = "default",
	cooldown = 0.1, -- Minimum time (seconds) between triggered sounds
	volume = 50, -- Volume for triggered beats (0-100)
	loop_volume = 30, -- Volume for loop track (0-100)
}

-- State variables
local last_played = 0
local beat_queue = {}
local loop_pid = nil -- Track mpv process for loop

-- Check if audio player is available
local function has_audio_player()
	return vim.fn.executable("mpv") == 1 or vim.fn.executable("aplay") == 1
end

-- Play a triggered sound file
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
	local cmd
	if vim.fn.executable("mpv") == 1 then
		cmd = string.format("mpv --no-video --volume=%d %s &", M.config.volume, beat_path)
	elseif vim.fn.executable("aplay") == 1 then
		cmd = string.format("aplay %s &", beat_path)
	else
		vim.notify("No audio player (mpv or aplay) found", vim.log.levels.ERROR)
		return
	end

	os.execute(cmd)
end

-- Start background loop
local function start_loop()
	if loop_pid then
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
		local cmd = string.format("mpv --no-video --volume=%d --loop %s & echo $!", M.config.loop_volume, loop_path)
		local handle = io.popen(cmd)
		if handle then
			loop_pid = handle:read("*a"):match("%d+")
			handle:close()
		end
	else
		vim.notify("mpv required for loop sound", vim.log.levels.WARN)
	end
end

-- Stop background loop
local function stop_loop()
	if loop_pid then
		os.execute("kill " .. loop_pid .. " 2>/dev/null")
		loop_pid = nil
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

-- Detect typing and map to beats
local function on_text_changed()
	if not M.config.enabled then
		return
	end

	local line = vim.api.nvim_get_current_line()
	local char = line:sub(-1)

	local beat_files = M.config.themes[M.config.active_theme].beat_files
	local beat = beat_files.default
	if char == "\n" then
		beat = beat_files.enter
	elseif char:match("[{}]") then
		beat = beat_files.brace
	elseif char == ";" then
		beat = beat_files.semicolon
	end

	play_sound(beat)
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

	-- Timer to process queued sounds
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
	if M.config.enabled then
		start_loop()
	end
	vim.notify("Deej: Switched to theme " .. theme_name)
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

	-- Ensure beat directory exists
	vim.fn.mkdir(M.config.beat_dir, "p")

	if M.config.enabled then
		start_loop()
	end

	setup_autocmds()

	-- Register command for theme switching
	vim.api.nvim_create_user_command("DeejSetTheme", function(opts)
		M.set_theme(opts.args)
	end, { nargs = 1 })
end

-- Toggle plugin on/off
function M.toggle()
	M.config.enabled = not M.config.enabled
	if M.config.enabled then
		start_loop()
	else
		stop_loop()
	end
	vim.notify("Deej: " .. (M.config.enabled and "Enabled" or "Disabled"))
end

return M
