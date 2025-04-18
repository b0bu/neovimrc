--- after/plugin/sync.lua
--- sync custom changes in and out of kickstart
local nvrc = vim.fn.stdpath("config")
local git = "~/dev/neovimrc"

local split = function(d)
	local sep = "/"
	local t = {}
	for s in string.gmatch(d, "([^" .. sep .. "]+)") do
		table.insert(t, s)
	end
	return t
end

local indexOf = function(t)
	local length = 0
	local root = 0
	for k, v in pairs(t) do
		length = length + 1
		if v == "nvim" then
			root = k
		end
	end
	return root, length
end

local buildPaths = function(d)
	local directories = split(d)
	-- end is reserved keywork
	local start, last = indexOf(directories)

	local num_paths = last - start
	local subpaths = {}
	local paths = {}
	local base = {}
	local complete_paths = {}

	--- get everything up to nvim
	for _, v in pairs(directories) do
		table.insert(base, v)
		if v == "nvim" then
			break
		end
	end

	--- get everything after stdpath ~/.config/nvim/
	for subpath = start + 1, last do
		table.insert(subpaths, directories[subpath])
	end

	--- build paths x,y to check ~/.config/nvim/x and y and x/y nested
	for complement = 1, num_paths do
		base[start + complement] = subpaths[complement]
		table.insert(paths, { unpack(base) })
	end

	for path, _ in pairs(paths) do
		table.insert(complete_paths, table.concat(paths[path], "/"))
	end

	for path, _ in pairs(complete_paths) do
		complete_paths[path] = "/" .. complete_paths[path]
	end

	return complete_paths
end

local stat = function(d)
	ok = vim.loop.fs_stat(d)
	if not ok then
		print("problem stating, will create " .. d .. "\n")
	end
	return ok
end

local mkdir = function(d)
	return vim.loop.fs_mkdir(d, tonumber("755", 8))
end

local check = function(d)
	local paths = buildPaths(d)

	for _, p in pairs(paths) do
		local ok = stat(p)
		if not ok then
			mkdir(p)
		end
	end
end

function Pull(d)
	local current = vim.fn.getcwd()
	vim.api.nvim_set_current_dir(d)
	vim.fn.system({
		"git",
		"pull",
	})

	vim.api.nvim_set_current_dir(current)
end

local copy = function(s, d)
	check(d)
	--- path join
	local cmd = s .. "/* " .. d
	os.execute("cp -R " .. cmd)
end

local configs = {
	after = "/after/plugin",
	plugins = "/lua/custom/plugins",
	before = "/plugin",
}

function Sync(paths, opts)
	opts = opts or configs
	--- default params if empty
	setmetatable(paths, { __index = { source = vim.fn.getcwd(), destination = nvrc } })
	local source, destination = paths[1] or paths.source, paths[2] or paths.destination

	for _, config in pairs(opts) do
		copy(source .. config, destination .. config)
	end
end

--- "config from git"
vim.keymap.set("n", "<leader>cfg", function()
	Pull(git)
	Sync({ git, nvrc }, configs)
end)

--- "config to git"
vim.keymap.set("n", "<leader>ctg", function()
	Pull(git)
	Sync({ nvrc, git }, configs)
end)
