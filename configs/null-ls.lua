local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require('null-ls')

local opts = {
  sources = {
    null_ls.builtins.formatting.black,
null_ls.builtins.diagnostics.mypy.with({
      condition = function(utils) return vim.fn.filereadable(vim.fn.expand('%:p')) == 1  end,
  args = function(params)
    local virtual = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX") or "/usr"
    local python_path = virtual .. (package.config:sub(1,1) == '/' and "/bin/python" or "\\python.exe")
    return {
      "--python-executable=" .. python_path, 
      "--hide-error-codes",
      "--hide-error-context",
      "--no-color-output",
      "--show-absolute-path",
      "--show-column-numbers",
      "--show-error-codes",
      "--no-error-summary",
      "--no-pretty",
      "--shadow-file",
      params.bufname,
      params.temp_path,
      params.bufname,
    }
  end,
}),
    null_ls.builtins.diagnostics.ruff,
  },




  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({
        group = augroup,
        buffer = bufnr,
      })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end,
      })
    end
  end,
}
return opts
