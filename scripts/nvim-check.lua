-- Headless verification for the Neovim Lua config.
-- Invoked by `make nvim-check` (see Makefile). Runs without touching the live
-- ~/.config/nvim: it reads the chezmoi source dir from $NVIM_SRC, byte-compiles
-- every .lua with loadfile (syntax check, never executes plugin specs), then
-- loads edgissa.core at runtime — the same check the CI `nvim-health` job runs.
-- Exits non-zero via `cq` on any failure so the Makefile target fails loudly.

local nvim_src = vim.fn.expand("$NVIM_SRC")
if nvim_src == "" or nvim_src == "$NVIM_SRC" then
  io.stderr:write("nvim-check: $NVIM_SRC is not set\n")
  vim.cmd("cq")
  return
end

local files = vim.fn.globpath(nvim_src, "**/*.lua", false, true)
local fail = 0

for _, f in ipairs(files) do
  local ok, err = loadfile(f)
  if not ok then
    fail = fail + 1
    io.stderr:write("SYNTAX ERROR: " .. f .. "\n" .. tostring(err) .. "\n")
  end
end

local ok, err = pcall(require, "edgissa.core")
if not ok then
  fail = fail + 1
  io.stderr:write("LOAD ERROR (edgissa.core): " .. tostring(err) .. "\n")
end

print(("nvim-check: %d files, %d error(s)"):format(#files, fail))

if fail > 0 then
  vim.cmd("cq")
end
