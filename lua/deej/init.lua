local M = {}

-- Default configuration
M.config = {
	enabled = true,
	beat_dir = vim.fn.stdpath("data") .. "/deej/beats/",
	beat_files = {
		default = "kick.wav",
		enter = "snare.wav",
		brace = "hihat.wav",
		semicolon = "clap.wav",
	},
	cooldown = 0.1, -- Minimum time (seconds) between sounds
	volume = 50, -- Volume for mpv (0-100)
}

-- State variables
local last_played = 0
local beat_queue = {}

-- Check if audio player is available
local function has_audio_player()
	return vim.fn.executable("aplay") == 1 or vim.fn.executable("mpv") == 1
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

	local beat = M.config.beat_files.default
	if char == "\n" then
		beat = M.config.beat_files.enter
	elseif char:match("[{}]") then
		beat = M.config.beat_files.brace
	elseif char == ";" then
		beat = M.config.beat_files.semicolon
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

	-- Timer to process queued sounds
	vim.loop.new_timer():start(0, 50, vim.schedule_wrap(process_queue))
end

-- Plugin setup function
function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})

	if not has_audio_player() then
		vim.notify("Deej: No audio player (mpv or aplay) found. Please install one.", vim.log.levels.ERROR)
		return
	end

	-- Ensure beat directory exists
	vim.fn.mkdir(M.config.beat_dir, "p")

	setup_autocmds()
end

-- Toggle plugin on/off
function M.toggle()
	M.config.enabled = not M.config.enabled
	vim.notify("Deej: " .. (M.config.enabled and "Enabled" or "Disabled"))
end

return M
