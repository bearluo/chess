--region analysisNotice.lua
--Date 2016.12.22
--endregion

AnalysisNotice = {}

function AnalysisNotice.getAnalysisData(data)
    local tab = {}
    local tempTab = data.content or {}
    local str = tempTab.horn_msg or ""
    tab = AnalysisNotice.splitToTable(str)
    return tab
end

function AnalysisNotice.getAnalysisText(data)
    local tab = {}
    local str = data.horn_msg or ""
    tab = AnalysisNotice.splitToTable(str)
    local msg = ""
    local name = ""
    local itype = 0
    for k,v in pairs(tab) do
        if v then
           if v.ctrl == "t" then
                itype = tonumber(v.text) or 0
                break
            end 
        end
    end

    for k,v in pairs(tab) do
        if v then
            if v.ctrl == "d" then
                if itype == 11 then
                    name = v.text or ""
                end
            end
        end
        if v then
            if v.ctrl == "w" then
                msg = v.text or ""
                break
            end
        end
    end
    return msg,name
end

function AnalysisNotice.splitToTable(str)
    local strSequence = {}
    -- 分割 #
    for token in string.gfind(str, "#?([^#]+)#?") do
		if string.find(str, "#"..SpecialCharSafe2Str(token)) then
			local keyCtrl = string.sub(token, 1, 1)
			if keyCtrl == "t" then
				-- 喇叭类型: #txxtext --> #pxx #dtext
				table.insert(strSequence, {ctrl="t", text=string.sub(token, 2, 3)})
				local sub_str = string.sub(token, 4, #token)
				if sub_str ~= "" then
                    --图片文字
					table.insert(strSequence, {ctrl="d", text=sub_str})
				end
			elseif keyCtrl == "j" then
				-- 场景跳转
                local sub_str = string.sub(token, 2, #token)
                table.insert(strSequence, {ctrl="j", text=sub_str})
            elseif keyCtrl == "i" then
				-- 用户id
                local id_str = string.sub(token, 2, #token)
                table.insert(strSequence, {ctrl="i", text=id_str})
			elseif keyCtrl == "w" then
                --richText 文本
                local _,j = string.find(str, "#w")
				local richStr = string.sub(str, j+1,#str)
                table.insert(strSequence, {ctrl="w", text=richStr})
                break
			end
		end
	end
    return strSequence
end