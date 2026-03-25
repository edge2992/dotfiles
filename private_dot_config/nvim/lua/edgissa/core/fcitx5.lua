-- Fcitx5 IME auto-switching for normal/insert mode
local M = {}

local ime_was_active = false

local function fcitx5_available()
  return vim.fn.executable("fcitx5-remote") == 1
end

local function get_ime_status()
  local result = vim.fn.system("fcitx5-remote")
  return tonumber(vim.trim(result)) or 0
end

function M.setup()
  if not fcitx5_available() then
    return
  end

  local group = vim.api.nvim_create_augroup("Fcitx5IME", { clear = true })

  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      ime_was_active = get_ime_status() == 2
      vim.fn.system("fcitx5-remote -c")
    end,
  })

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
      if ime_was_active then
        vim.fn.system("fcitx5-remote -o")
      end
    end,
  })
end

function M.lualine_component()
  if not fcitx5_available() then
    return ""
  end
  if get_ime_status() == 2 then
    return "[JP]"
  end
  return ""
end

return M
