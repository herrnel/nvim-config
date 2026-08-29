vim.api.nvim_create_user_command("ClankerYank", function(opts)
	local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
	local text = table.concat(lines, "\n")
	local abs_file_path = vim.api.nvim_buf_get_name(0)
	local context = {
		file_path = abs_file_path,
		line_start = opts.line1,
		line_end = opts.line2,
		text = text
	}


	local json_context = vim.json.encode(context)
	local result = vim.system(
		{"curl", "-sS", "-X", "POST",
		"-H", "Content-Type: application/json",
		"--data", json_context,
		"http://127.0.0.1:3000/append-block" },
		{text = true}
	):wait() -- <- block so we can inspect
	
	print("exit:", result.code)
	print("stdout:", result.stdout)
	print("stderr:", result.stderr)

end, { range = true})

