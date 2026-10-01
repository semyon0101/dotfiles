return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#11140e',
				base01 = '#11140e',
				base02 = '#82887e',
				base03 = '#82887e',
				base04 = '#d4dccf',
				base05 = '#fbfff8',
				base06 = '#fbfff8',
				base07 = '#fbfff8',
				base08 = '#ffb19f',
				base09 = '#ffb19f',
				base0A = '#c2e7a8',
				base0B = '#a9fba3',
				base0C = '#e9ffda',
				base0D = '#c2e7a8',
				base0E = '#ddffc6',
				base0F = '#ddffc6',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#82887e',
				fg = '#fbfff8',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#c2e7a8',
				fg = '#11140e',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#82887e' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#e9ffda', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#ddffc6',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#c2e7a8',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#c2e7a8',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#e9ffda',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#a9fba3',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#d4dccf' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#d4dccf' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#82887e',
				italic = true
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
