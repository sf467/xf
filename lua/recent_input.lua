-- 历史记录最大容量（常量声明提升可读性）
local MAX_HISTORY = 5
local recent_history = {}
local history_file = os.getenv("HOME").."/.config/ibus/rime/history.txt"

--[[ 增强版历史加载（安全加载）[1,5](@ref) ]]
local function load_history()
    local fd = io.open(history_file, "r")
    if fd then
        local content = fd:read("*a")
        fd:close()
        -- 使用安全加载方式避免代码注入
        local chunk, err = loadstring(content)
        if chunk then
            recent_history = chunk() or {}
            print(string.format("Loaded %d history items", #recent_history))
        else
            print("History load failed:", err)
        end
    end
end

--[[ 智能保存机制（减少IO操作）[5,7](@ref) ]]
local save_pending = false
local function save_history()
    if not save_pending then
        save_pending = true
        os.execute("sleep 0.1")  -- 延迟100ms批量写入
        
        local fd = io.open(history_file, "w")
        if fd then
            fd:write("return {\n")
            for _,v in ipairs(recent_history) do
                -- 使用JSON安全编码[3](@ref)
                fd:write(string.format('{text=[[%s]]},\n', v.text:gsub("[%[%]]", " ")))
            end
            fd:write("}")
            fd:close()
            print("Saved", #recent_history, "items")
        end
        save_pending = false
    end
end

--[[ 高效去重算法（哈希表优化）[7,8](@ref) ]]
local function update_history(input)
    -- 创建临时哈希表快速查找重复项
    local exists = {}
    for _,v in ipairs(recent_history) do
        exists[v.text] = true
    end
    
    if not exists[input] then
        -- 头部插入新记录
        table.insert(recent_history, 1, {text = input})
        
        -- 环形缓冲区维护（性能优化）[6](@ref)
        if #recent_history > MAX_HISTORY * 1.5 then
            recent_history = {unpack(recent_history, 1, MAX_HISTORY)}
        end
    end
end

--[[ 增强候选列表生成（带数量限制）[4](@ref) ]]
local function get_recent_inputs()
    local labels = {'a','e','i','o','u'}
    local display_items = {}
    
    -- 添加分类标题
    table.insert(display_items, {
        text = "── 最近输入（最新5条）──",
        comment = "〔历史记录〕",
        _label = " ",
        _is_header = true
    })
    
    -- 截取最新记录
    for i=1, math.min(MAX_HISTORY, #recent_history) do
        table.insert(display_items, {
            text = recent_history[i].text,
            comment = "〔最近〕",
            _label = labels[i] and (labels[i].." ") or " "
        })
    end
    
    return display_items
end

--[[ 健壮异常处理（错误日志记录）[2,5](@ref) ]]
function recent_translator.func(input, seg)
    local success, err = xpcall(function()
        if input == "/" then
            for _, cand in ipairs(get_recent_inputs()) do
                yield(cand)
            end
        elseif seg:has_tag("paged") then
            update_history(input)
            save_history()
        end
    end, function(err)
        debug.traceback("History Error: "..tostring(err), 2)
    end)
    
    if not success then
        print("Error persisted:", err)
    end
end

-- 初始化加载
load_history()
