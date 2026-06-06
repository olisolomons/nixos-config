vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- opts
vim.opt.relativenumber = true
vim.opt.hlsearch = false

vim.opt.exrc = true -- run .nvim.lua files

vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/vim/undodir"
vim.opt.undofile = true

vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

-- indent stuff

local only_2_tabs = {
  clojure = true,
  lua = true,
  nix = true
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = { "*" },
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local tabs = 4
    if only_2_tabs[ft] then
      tabs = 2
    end
    vim.bo.tabstop = tabs
    vim.bo.softtabstop = tabs
    vim.bo.shiftwidth = tabs
  end
})
-- Telescope

local builtin = require('telescope.builtin')

require("telescope").setup {
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {}
    }
  }
}

vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})

require("telescope").load_extension("ui-select")

-- colorscheme

vim.cmd("colorscheme rose-pine")

-- LSP

vim.lsp.enable('nil_ls')
vim.lsp.config('nil_ls', {
  settings = {
    ['nil'] = {
      formatting = {
        command = { "nixfmt" },
      },
    },
  },
})

vim.lsp.config('pyright', {})

vim.lsp.config('clojure_lsp', {})

vim.lsp.config('ocamllsp', {})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
        }
      },
    },
  },
})

vim.lsp.config('gopls', {})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, opts)
    vim.keymap.set('n', 'grr', builtin.lsp_references, opts)
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
    vim.keymap.set('n', '<leader>s', builtin.lsp_document_symbols, opts)
    vim.keymap.set('n', '<leader>S', builtin.lsp_dynamic_workspace_symbols, opts)
  end,
})
