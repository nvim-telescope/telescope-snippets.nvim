local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  error('This plugins requires nvim-telescope/telescope.nvim')
end

local has_nsip, nsnip = pcall(require, 'snippets')
if not has_nsip then
  error('This plugins requires norcalli/snippets.nvim')
end

local actions       = require('telescope.actions')
local action_state  = require('telescope.actions.state')
local finders       = require('telescope.finders')
local pickers       = require('telescope.pickers')
local previewers    = require('telescope.previewers')
local putils        = require('telescope.previewers.utils')
local entry_display = require('telescope.pickers.entry_display')

local conf = require('telescope.config').values

local snippets = function(opts)
  opts = opts or {}

  local objs = {}
  local max_width = 0
  for k, v in pairs(nsnip.snippets) do
    if #k > max_width then
      max_width = #k
    end
    for n, s in pairs(v) do
      table.insert(objs, { name = n, lang = k, content = s })
    end
  end

  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = max_width },
      { remaining = true },
    }
  }

  local make_display = function(entry)
    return displayer {
      entry.value.lang,
      entry.value.name
    }
  end

  pickers.new(opts, {
    prompt_title = 'snippets',
    finder    = finders.new_table {
      results = objs,
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display,
          ordinal = entry.lang .. ' ' .. entry.name,
        }
      end
    },
    previewer = previewers.new_buffer_previewer {
      define_preview = function(self, entry)
        local output
        if type(entry.value.content) == 'string' then
          output = entry.value.content
        elseif type(entry.value.content) == 'table' then
          for _, e in ipairs(entry.value.content) do
            if type(e) == 'string' then
              output = output and output .. ' ' .. e or e
            else
              local me = tostring(e)
              me = me:gsub('%|?%=?function[^}]*', '')
              if not me:find('${-1}', 1, true) then
                output = output and output .. ' ' .. me or me
              end
            end
          end
        else
          output = vim.inspect(entry.value.content)
        end
        output = vim.split(output, '\n')
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, output)
        putils.highlighter(self.state.bufnr, entry.value.lang)
      end
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function()
      actions.select_default:replace(function(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.api.nvim_put({ selection.value.name }, '', true, true)
        nsnip.expand_at_cursor()
        vim.fn.feedkeys('i') -- :|
      end)
      return true
    end
  }):find()
end

return telescope.register_extension {
  exports = {
    snippets = snippets,
  }
}
