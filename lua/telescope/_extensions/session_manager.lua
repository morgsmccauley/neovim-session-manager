local state = require('telescope.actions.state')
local actions = require('telescope.actions')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local telescope = require('telescope')
local session_manager = require('session_manager')

local function load_session(save_current, opts)
  pickers.new(opts, {
    prompt_title = 'Select a session',
    finder = finders.new_table({
      results = session_manager.get_sessions(),
      entry_maker = function(entry)
        return {
          value = entry.filename,
          display = session_manager.session_name_to_path(entry.filename),
          ordinal = entry.filename,
        }
      end,
    }),
    sorter = sorters.get_fzy_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      local source_session = function()
        actions.close(prompt_bufnr)
        session_manager.load_session(state.get_selected_entry().value, save_current)
      end

      actions.select_default:replace(source_session)

      local delete_session = function()
        vim.fn.delete(vim.g.sessions_dir .. state.get_selected_entry().value)
        load_session(save_current, opts)
      end

      map('n', 'd', delete_session, { nowait = true })
      map('i', '<C-x>', delete_session, { nowait = true })
      return true
    end,
  }):find()
end

return telescope.register_extension({
  exports = {
    load = function(opts)
      load_session(true, opts)
    end,
    discard_and_load = function(opts)
      load_session(false, opts)
    end,
  },
})
