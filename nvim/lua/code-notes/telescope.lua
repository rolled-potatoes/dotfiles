local M = {}

function M.preview_lines(note)
  local lines = {
    "상태: " .. note.status,
    "파일: " .. note.relative_path,
    string.format("범위: %d:%d", note.start_line, note.end_line),
    "",
  }
  vim.list_extend(lines, vim.split(note.content, "\n", { plain = true }))
  return lines
end

function M.open(api, options)
  local ok, telescope = pcall(require, "telescope.pickers")
  if not ok then
    vim.notify("Telescope is not available", vim.log.levels.ERROR)
    return
  end
  local finders = require("telescope.finders")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local conf = require("telescope.config").values
  local previewers = require("telescope.previewers")
  local notes = api.filtered_notes(options)

  telescope.new({}, {
    prompt_title = options.title or "Code Notes",
    finder = finders.new_table({
      results = notes,
      entry_maker = function(note)
        return {
          value = note,
          display = string.format("[%s] %s:%d:%d  %s", note.status, note.relative_path, note.start_line, note.end_line, note.content:gsub("\n.*", "")),
          ordinal = (note.relative_path .. " " .. note.content .. " " .. note.status):lower(),
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = "메모 미리보기",
      define_preview = function(self, entry)
        local note = entry.value
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, M.preview_lines(note))
        vim.bo[self.state.bufnr].filetype = "markdown"
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      local function selected()
        local entry = action_state.get_selected_entry()
        return entry and entry.value
      end
      actions.select_default:replace(function()
        local note = selected()
        actions.close(prompt_bufnr)
        if note then
          api.open_note(note)
        end
      end)
      map("i", "<C-e>", function()
        local note = selected()
        actions.close(prompt_bufnr)
        if note then
          api.edit_note(note)
        end
      end)
      map("i", "<C-d>", function()
        local note = selected()
        if note and vim.fn.confirm("이 메모를 삭제할까요?", "&삭제\n&취소", 2) == 1 then
          api.delete_note(note)
          actions.close(prompt_bufnr)
        end
      end)
      map("i", "<C-y>", function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        local selected_notes = picker:get_multi_selection()
        if #selected_notes == 0 and selected() then
          selected_notes = { action_state.get_selected_entry() }
        end
        api.copy_notes(vim.tbl_map(function(entry)
          return entry.value
        end, selected_notes))
      end)
      return true
    end,
  }):find()
end

return M
