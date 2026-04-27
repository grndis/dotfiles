-- Disabled: all WordPress.nvim functionality has been inlined into:
--   none-ls.lua  (phpcbf/phpcs config, intelephense stubs, deprecation fix)
--   astrolsp.lua (LSP format filter, intelephense handler)
--   filetype.lua (php.wp filetype detection, ftplugin tab settings)
if true then return {} end

return {
  "bitpoke/wordpress.nvim",
}