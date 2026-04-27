-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
vim.filetype.add {
  -- extension = {
  --   foo = "fooscript",
  -- },
  -- filename = {
  --   ["Foofile"] = "fooscript",
  -- },
  -- pattern = {
  --   ["~/%.config/foo/.*"] = "fooscript",
  -- },
  pattern = {
    [".*%.blade%.php"] = "blade",
    -- WordPress PHP filetypes (inlined from wordpress.nvim)
    [".*/wp%-includes/*.php"] = "php.wp",
    [".*/wp%-admin/*.php"] = "php.wp",
    [".*/wp%-content/*.php"] = "php.wp",
    [".*/wp%-.*.php"] = "php.wp",
    [".*/class%-.*.php"] = "php.wp",
    [".*/interface%-.*.php"] = "php.wp",
  },
  filename = {
    -- WordPress cache drop-ins
    ["object-cache.php"] = "php.wp",
    ["advanced-cache.php"] = "php.wp",
  },
  extension = {
    ["http"] = "http",
  },
}

-- WordPress ftplugin: use tabs (inlined from wordpress.nvim ftplugin/wp.lua)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "php.wp",
  callback = function()
    local opt = vim.opt_local
    opt.expandtab = false
    opt.copyindent = true
    opt.preserveindent = true
    opt.softtabstop = 0
  end,
})