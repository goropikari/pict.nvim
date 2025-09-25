local M = {}

local default_config = {
  path = 'pict',
}
local global_config = {}

local buf_list = {}

local function get_bufnr(filepath)
  local bufnr = buf_list[filepath] and buf_list[filepath].bufnr
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    local win = vim.fn.bufwinid(bufnr)
    if win and not vim.api.nvim_win_is_valid(win) then
      buf_list[filepath].win = vim.api.nvim_open_win(bufnr, false, {
        split = 'right',
      })
    end
    return bufnr
  end

  bufnr = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(bufnr, false, {
    split = 'right',
  })

  buf_list[filepath] = { bufnr = bufnr, win = win }
  return buf_list[filepath].bufnr
end

local function get_current_filepath()
  return vim.fn.expand('%:p')
end

function M.setup(opts)
  global_config = vim.tbl_deep_extend('force', default_config, opts or {})
end

local function pict_path()
  return global_config.path
end

local function parse(json)
  local headers = {}
  for _, p in ipairs(json[1]) do
    table.insert(headers, p.key)
  end

  local rows = {}
  for _, r in ipairs(json) do
    local row = {}
    for _, v in ipairs(r) do
      table.insert(row, v.value)
    end
    table.insert(rows, row)
  end

  return {
    headers = headers,
    rows = rows,
  }
end

---@class PictData
---@field headers string[]
---@field rows string[][]

---@param on_exit fun(data: PictData)
function M.output(on_exit)
  local filepath = get_current_filepath()
  if filepath == '' then
    vim.notify('No file to show', vim.log.levels.ERROR)
    return
  end

  vim.system({ pict_path(), filepath, '/f:json' }, { text = true }, function(obj)
    if obj.code ~= 0 then
      vim.schedule(function()
        vim.notify('Failed to run pict: ' .. (obj.stderr or 'Unknown error'), vim.log.levels.ERROR)
      end)
      return
    end
    local result = obj.stdout
    if result == nil then
      vim.schedule(function()
        vim.notify('pict did not return any data', vim.log.levels.WARN)
      end)
      return
    end
    vim.schedule(function()
      local res = vim.json.decode(result)
      if type(res) ~= 'table' or #res == 0 then
        vim.notify('pict did not return valid data', vim.log.levels.WARN)
        return
      end

      local data = parse(res)
      vim.schedule(function()
        on_exit(data)
      end)
    end)
  end)
end

function M.markdown()
  M.output(function(data)
    local bufnr = get_bufnr(get_current_filepath())
    vim.api.nvim_set_option_value('filetype', 'markdown', { buf = bufnr })

    local lines = {}
    table.insert(lines, '| ' .. table.concat(data.headers, ' | ') .. ' |')
    table.insert(lines, '| ' .. string.rep('--- | ', #data.headers))
    for _, row in ipairs(data.rows) do
      table.insert(lines, '| ' .. table.concat(row, ' | ') .. ' |')
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  end)
end

function M.csv()
  M.output(function(data)
    local bufnr = get_bufnr(get_current_filepath())
    vim.api.nvim_set_option_value('filetype', 'csv', { buf = bufnr })

    local lines = {}
    table.insert(lines, table.concat(data.headers, ','))
    for _, row in ipairs(data.rows) do
      table.insert(lines, table.concat(row, ','))
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  end)
end

function M.debug()
  M.output(vim.print)
end

return M
