local M = {}

function M.setup(opts)
    opts = opts or {}
end

function M.find(input_string)
    local result = {}
    local start_pos = nil

    for i = 1, #input_string do
        local char = input_string:sub(i, i)

        if char == "$" then
            if start_pos then
                table.insert(result, { start_pos, i })
                start_pos = nil
            else
                start_pos = i
            end
        end
    end

    return result
end

function M.convert()
    local current_line = vim.fn.line "."
    if current_line then
        local line_content = vim.fn.getline(current_line)
        for pre_expression in line_content:gmatch "%$([^%$]+)%$" do
            local math_expression = "$" .. pre_expression .. "$"
            local res = vim.fn.system("echo " .. "'" .. math_expression .. "'" .. " | pandoc -f typst -t markdown")
            -- print(res)
            if res then
                local ans = res:gsub("\n$", "")
                local pos = M.find(line_content)
                for _, dot in pairs(pos) do
                    local x, y = dot[1] - 1, dot[2]
                    vim.api.nvim_buf_set_text(0, current_line - 1, x, current_line - 1, y, { ans })
                    print(x, y, current_line)
                end
            end
        end
    end
end

return M
