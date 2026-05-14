-- 日期与时间翻译器
-- 输入特定的日期时间缩写，输出对应的日期时间字符串

local function translator(input, seg)
   ---@type (string | osdate)[]
   local datetimes = {}
   if not seg:has_tag("datetime") then
	   return
   end

   table.insert(datetimes, os.date("%Y年-%m月-%d日"))
   table.insert(datetimes, os.date("%Y%m%d"))
   table.insert(datetimes, os.date("%H时%M分%S秒"))
   table.insert(datetimes, os.date("%H:%M:%S"))

   for _, entry in ipairs(datetimes) do
      ---@cast entry string
      yield(Candidate("datetime", seg.start, seg._end, entry, ""))
   end
end

return translator
