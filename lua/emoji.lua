local emoji_db = {}

--------------------------------------------------
-- 加载词典
--------------------------------------------------

local function load_dict()

    local path =
        rime_api.get_user_data_dir()
        .. "/emoji.dict.yaml"

    local f = io.open(path, "r")

    if not f then
        return
    end

    local in_body = false

    for line in f:lines() do

        if line == "..." then
            in_body = true

        elseif in_body then

            if
                line:match("%S")
                and not line:match("^#")
            then

                --------------------------------------------------
                -- 😀	grinning face
                --------------------------------------------------

                local emoji, code =
                    line:match("^(.-)%s+(.+)$")

                if emoji and code then

                    table.insert(emoji_db, {
                        emoji = emoji,
                        code = code:lower()
                    })

                end
            end
        end
    end

    f:close()
end

load_dict()

--------------------------------------------------
-- 分割关键词
--------------------------------------------------

local function split_keywords(input)

    local result = {}

    for raw_word in input:gmatch("[^,]+") do

        local word = raw_word:lower()

        word = word:gsub("^%s+", "")
        word = word:gsub("%s+$", "")

        if word ~= "" then
            table.insert(result, word)
        end
    end

    return result
end

--------------------------------------------------
-- translator
--------------------------------------------------

local function emoji_translator(input, seg)

    --------------------------------------------------
    -- 必须 oo 开头
    --------------------------------------------------

    if not input:match("^oo") then
        return
    end

    --------------------------------------------------
    -- 去掉 oo
    --------------------------------------------------

    local query = input:sub(3)

    if query == "" then
        return
    end

    local keywords =
        split_keywords(query)

    local candidates = {}

    --------------------------------------------------
    -- 搜索
    --------------------------------------------------

    for _, item in ipairs(emoji_db) do

        local ok = true
        local score = 0

        for _, kw in ipairs(keywords) do

            local s =
                item.code:find(
                    kw,
                    1,
                    true
                )

            if not s then
                ok = false
                break
            end

            --------------------------------------------------
            -- 前部优先
            --------------------------------------------------

            score = score + (1000 - s)
        end

        if ok then

            table.insert(candidates, {
                emoji = item.emoji,
                code = item.code,
                score = score
            })

        end
    end

    --------------------------------------------------
    -- 排序
    --------------------------------------------------

    table.sort(candidates, function(a, b)
        return a.score > b.score
    end)

    --------------------------------------------------
    -- 输出
    --------------------------------------------------

    for _, c in ipairs(candidates) do

        yield(
            Candidate(
                "emoji",
                seg.start,
                seg._end,
                c.emoji,
                c.code
            )
        )
    end
end

return emoji_translator
