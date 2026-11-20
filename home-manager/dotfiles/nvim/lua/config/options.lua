-- Own options win over LazyVim's defaults.
local opt = vim.opt

-- System clipboard. Without a compositor (ssh into this host, plain tty) there
-- is no wl-copy target and yanking fails with "clipboard: No provider", so let
-- the terminal own the clipboard through the builtin OSC 52 provider.
opt.clipboard = "unnamedplus"
if not (vim.env.WAYLAND_DISPLAY or vim.env.DISPLAY) then
  vim.g.clipboard = "osc52"
end
