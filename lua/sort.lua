-- smart_sort.lua
-- 候选项智能排序过滤器（修正版）

local function filter(input, env)
    local cat1 = {}  -- 多字符 + 无注释
    local cat2 = {}  -- 有注释（一般）
    local cat3 = {}  -- 单字符 + 无注释
    local cat4 = {}  -- 注释以 ~ 开头
    local cat5 = {}  -- 其它

    for cand in input:iter() do
        local text = cand.text or ""
        local comment = cand.comment or ""
        local text_len = utf8.len(text)

        -- 先判断注释前缀
        -- 使用 string.sub 避免正则编译，或 string.byte
        local starts_with_tilde = #comment > 0 and string.sub(comment, 1, 1) == "~"

        if starts_with_tilde then
            -- 类别 4：注释以 ~ 开头
            table.insert(cat4, {
                cand = cand,
                comment_len = utf8.len(comment)
            })
        elseif comment == "" then
            -- 无注释：按字符数判断
            if text_len > 1 then
                table.insert(cat1, cand)  -- 类别 1：多字符无注释
            elseif text_len == 1 then
                table.insert(cat3, cand)  -- 类别 3：单字符无注释
            else
                table.insert(cat5, cand)  -- 空文本等异常情况
            end
        else
            -- 有注释但不以 ~ 开头
            table.insert(cat2, {
                cand = cand,
                comment_len = utf8.len(comment)
            })
        end
    end

    -- 对带注释的类别按注释长度排序
    local function sort_wrapped(wrapped_list)
        table.sort(wrapped_list, function(a, b)
            return a.comment_len < b.comment_len
        end)
    end

    sort_wrapped(cat2)
    sort_wrapped(cat4)

    -- 按顺序输出
    local all_cats = {cat1, cat2, cat3, cat4, cat5}
    for _, cat in ipairs(all_cats) do
        for _, item in ipairs(cat) do
            local cand = item.cand or item
            yield(cand)
        end
    end
end

return filter
