local M = {}

local function define_signs()
	-- Define letter signs only
	for _, c in ipairs(vim.split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", "")) do
		vim.fn.sign_define("MarkSign_" .. c, {
			text = c,
			texthl = "Identifier",
			numhl = "",
		})
	end

	-- Number marks removed
end

function M.refresh()
	local buf = vim.api.nvim_get_current_buf()
	vim.fn.sign_unplace("MarkSignsGroup", { buffer = buf })

	-- Get both buffer-specific and global marks
	local all_marks = vim.fn.getmarklist()
	local buffer_marks = vim.fn.getmarklist(buf)

	-- Combine the lists (buffer marks first as they're more relevant)
	for _, mark in ipairs(all_marks) do
		table.insert(buffer_marks, mark)
	end

	for _, mark in ipairs(buffer_marks) do
		local name = mark.mark:sub(2) -- Remove the ' prefix
		local pos = mark.pos

		-- Handle only letter marks (no numbers)
		if (name:match("^[a-zA-Z]$")) and pos and pos[1] == buf and pos[2] > 0 then
			vim.fn.sign_place(0, "MarkSignsGroup", "MarkSign_" .. name, buf, {
				lnum = pos[2],
				priority = 10,
			})
		end
	end
end

function M.setup()
	define_signs()
	vim.o.signcolumn = "yes"

	-- Create an autocmd group for our commands
	local augroup = vim.api.nvim_create_augroup("VisualMarks", { clear = true })

	vim.api.nvim_create_autocmd({
		"BufEnter",
		"CursorHold",
		"InsertLeave",
		"BufWritePost",
		"TextChanged",
		"TextChangedI",
	}, {
		group = augroup,
		callback = function()
			vim.defer_fn(M.refresh, 20)
		end,
	})

	-- Initial refresh
	vim.defer_fn(M.refresh, 100)
end

return M
