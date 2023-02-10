local M = {}

local w = vim.w
local a = vim.api
local wo = vim.wo
local fn = vim.fn
local hl = a.nvim_set_hl
local au = a.nvim_create_autocmd
local timer = vim.loop.new_timer()

local DEFAULT_OPTIONS = {
  cursorword = {
    enable = true,
    min_length = 3,
    hl = { underline = true },
  },
}

local function matchadd()
  local cword = vim.fn.expand('<cword>')
  local row, col = unpack(a.nvim_win_get_cursor(0))
  w.ccword = cword

 if cword == w.cursorword and row == w.row and col >= w.cwordStart and col <= w.cwordEnd
   then
   return
 end

  local s, e = a.nvim_get_current_line():find(cword, math.max(1, col-#cword))

  w.cursorword = cword
  w.row = row
  w.cwordStart = s
  w.cwordEnd = e


  if w.cursorword_id then
    vim.call("matchdelete", w.cursorword_id)
    w.cursorword_id = nil
  end

  if
    cword == ""
    or #cword < M.options.cursorword.min_length
    or string.find(cword, "[\192-\255]+") ~= nil
  then
    return
  end

  w.cursorword_id = vim.fn.matchaddpos("CursorWord", {{row, s, #cword}}, -1)
end

function M.setup(options)
  w.cwordStart = -1 
  w.cwordEnd = -1 

  M.options = vim.tbl_deep_extend("force", DEFAULT_OPTIONS, options or {})
  if M.options.cursorword.enable then
    au("VimEnter", {
      callback = function()
        matchadd()
      end,
    })
    au({ "CursorMoved", "CursorMovedI" }, {
      callback = function()
        matchadd()
      end,
    })
  end
end

M.options = nil

return M
