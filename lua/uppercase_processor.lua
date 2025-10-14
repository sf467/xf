-- 保存为 final_commit_processor.lua
local function processor(key, env)
local engine = env.engine
local context = engine.context
local input = context.input
local ch = key:repr()

-- 增强条件检测函数
local function check_conditions()
-- 条件0：输入长度≥4时才可能触发（因为要处理第5位及之后）
if #input < 4 then return false end

    -- 条件1：前三码有且仅有一个大写字母
    local first_three = input:sub(1,3)
    local uppercase_count = 0
    for c in first_three:gmatch("[A-Z]") do
        uppercase_count = uppercase_count + 1
        end
        if uppercase_count ~= 1 then return false end

            -- 条件2：当前按键是非元音或标点
            local is_alpha = ch:match("^%a$")
            local is_punctuation = ch:match("^%p$")
            if not (is_alpha or is_punctuation) then return false end

                if is_alpha and ch:match("[aeiouAEIOU]") then
                    return false -- 排除元音
                    end
                    return true
                    end

                    if check_conditions() then
                        -- 提交当前输入内容（不含新按键）
                        engine:commit_text(context:get_commit_text())

                        -- 处理新字符
                        if ch:match("%p") then
                            engine:commit_text(ch) -- 标点直接提交
                            context:clear()
                            else
                                context:clear()
                                context.input = ch -- 保留原始大小写
                                end

                                return 1 -- 拦截按键
                                end

                                return 2 -- 放行其他情况
                                end

                                return processor
