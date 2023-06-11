local status, hop = pcall(require, "hop")

if not status then
  return
end

local directions = hop.HintDirection

hop.setup({
  keys = "etovxqdygblzhckisuran"
})


