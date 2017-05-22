require("core/system")
require("atomAnim/resEx")
require("atomAnim/atomAnimUtils")

AtomAnimTableCreater = class()

AtomAnimTableCreater.ctor = function(self)

end

AtomAnimTableCreater.loadNameMap = {
    ["Color"]               = "AtomAnimColor",
    ["Red"]                 = "AtomAnimRed",         
    ["Green"]               = "AtomAnimGreen",    
    ["Blue"]                = "AtomAnimBlue",   
    ["Alpha"]               = "AtomAnimAlpha",   
    ["Translate"]           = "AtomAnimTranslate",        
    ["TranslateX"]          = "AtomAnimTranslateX",           
    ["TranslateY"]          = "AtomAnimTranslateY",         
    ["Frame"]               = "AtomAnimFrame",          
    ["Rotate"]              = "AtomAnimRotate",  
    ["Scale"]               = "AtomAnimScale",   
    ["ScaleX"]              = "AtomAnimScaleX",      
    ["ScaleY"]              = "AtomAnimScaleY",
    ["Bezier"]              = "AtomAnimBezier",         
    ["BezierX"]             = "AtomAnimBezierX",         
    ["BezierY"]             = "AtomAnimBezierY",  
    ["Ellipse"]             = "AtomAnimEllipse",    
    ["EllipseX"]            = "AtomAnimEllipseX",         
    ["EllipseY"]            = "AtomAnimEllipseY",         
    ["Jump"]                = "AtomAnimJump",        
    ["TranslateSolid"]      = "AtomAnimTranslateSolid", 
    ["PosSolid"]            = "AtomAnimPosSolid",       
    ["ColorSolid"]          = "AtomAnimColorSolid",        
    ["AlphaSolid"]          = "AtomAnimAlphaSolid",    
    ["RotateSolid"]         = "AtomAnimRotateSolid",    
    ["ScaleSolid"]          = "AtomAnimScaleSolid",    
    ["FrameSolid"]          = "AtomAnimFrameSolid"
}

AtomAnimTableCreater.centerTypeMap = {
    ["Origin"]         = kNotCenter;
    ["NodeCenter"]     = kCenterDrawing;
    ["CustomCenter"]   = kCenterXY;
}

AtomAnimTableCreater.parseXml = function(self, xmlFilePath)
    local _xml = self:createXmlParser(xmlFilePath)
    -- here should have some error info, not just return
    if not _xml then 
        return
    end
    local xml = _xml.AnimationDefine
    -- the res in sample xml is not a tree but a forest
    -- we need to add a root to the forest to make its structure as a tree
    local res = xml["Resources"]
    -- hard code root info
    local root = {}
    -- table.insert(xmlInfo, root)
    local anims = xml["Animations"]
    self:createResInfo(res, root)
    self:createAnimInfo(anims, root)
    self:addRootInfo(root)
    local pathTable = AtomAnimUtils.mysplit(xmlFilePath, "/")
    local luaName = pathTable[#pathTable];
    local nameTable = AtomAnimUtils.mysplit(luaName, ".");
    luaName = nameTable[1];
    local path = {};
    local index = -1;
    for i = 1, #pathTable do
        if index == -1 and pathTable[i] == "animation" then
            index = i;
        end
        if index > 0 and i > index and i < #pathTable then
            path[#path + 1] = pathTable[i];
        end
    end
    return self:createLuaTable(path, luaName, root) -- 将内存中表序列化
end

AtomAnimTableCreater.addRootInfo = function(self, root)
    root.name="Aircraft";
    root.typeName="AnimNode";
    root.x=0;
    root.y=0;
    root.width=0;
    root.height=0;
    root.visible=1
    root.fillParentWidth=0;
    root.fillParentHeight=0;
    root.nodeAlign=kAlignTopLeft
end

AtomAnimTableCreater.createLuaTable = function(self, path, luaName, xmlInfo)
    local strInfo = luaName .. " = " .. table2String(xmlInfo)
    local storageScriptPath = sys_get_string("storage_scripts") or ""
    local scriptsPath = (string.sub(storageScriptPath,0,string.find(storageScriptPath, "Resource", 0) + 7)) .. "/scripts/atomAnimTable/"
    for i=1, #path do
        scriptsPath = scriptsPath..path[i].."/";
    end
    local fileFullPath = string.format("%s%s%s",scriptsPath , luaName, ".lua")
    local file = io.open(fileFullPath,"w")
    if file then
        file:write(strInfo)
        file:close()
    end
    return fileFullPath
end

AtomAnimTableCreater.createResInfo = function(self, res, root)
    -- here should have some error info, not just return
    -- level-order traverse the forest
    if not res then 
        return
    end
    -- resName is for sprite anim
    -- local resName = {}
    local index = 1
    while true do
        local resType = res:children()[index]
        if not resType then
            break
        end
        local resTemp = {}
        local name = resType:name();
        if resType:name() == "Node" then -- 空节点
            resTemp.typeName = "";
        elseif resType:name() == "Images" then
            resTemp.typeName = "AnimFrame";
            resTemp.file = self:getImagesFiles(resType);
        else
            resTemp.typeName = "Image";
            resTemp.file = resType["@Path"];
        end
        resTemp.packFile = self:getPackFile(resType);
        resTemp.filter = kFilterLinear;
        resTemp.name = resType["@Name"];
        resTemp.resourceId = resType["@Id"];
        resTemp.x = tonumber(resType["@X"]);
        resTemp.y = tonumber(resType["@Y"]);
        resTemp.width = tonumber(resType["@Width"]);
        resTemp.height = tonumber(resType["@Height"]);
        resTemp.visible = resType["@Visible"];
        resTemp.origVisible = resType["@Visible"] == "true" and true or false;--原始可见性
       
        if resTemp.visible == "true" then
            resTemp.visible = 1
        else
            resTemp.visible = 0
        end

        resTemp.xyScale = resType["@XYScale"] == "true" and true or false;

        resTemp.time = resType["@Time"];
        table.insert(root,resTemp);
        index = index + 1;
        local subRes = resType:children()[1];
        if subRes:name() == "Children" then
            self:createResInfo(subRes, resTemp);
        end
    end
    return root
end

AtomAnimTableCreater.getImagesFiles = function(self, res)
    local ret = {};
    if res ~= nil then
        local files = res:children()[1];
        if files ~= nil then
            local index = 1;
            local file = nil;
            while true do
                file = files:children()[index];
                if file == nil then
                    break;
                end
                ret[index] = {path = file["@Path"], packFile = self:getPackFile(file)};
                index = index + 1;
            end
        end
    end
    return ret;
end

AtomAnimTableCreater.createAnimInfo = function(self, anims, root)
    -- here should have some error info, not just return
    if not anims then
        return
    end
    local animName = {}
    local index = 1
    while true do
        local anim = anims:children()[index]
        if not anim then
            break
        end
        local name = anims:children()[index]:name()
        if animName.name then
            animName.name = animName.name + 1
        else
            animName.name = 1
        end
        -- 检测XML中是单一动画还是含有多个动画
        local animType = anim;
        local animTypeName = AtomAnimTableCreater.loadNameMap[name]
        local animTemp = AtomAnimTableCreater.loadAnimInfoFuncMap[name](self, animType, animTypeName)
        table.insert(root, animTemp)
        index = index + 1
    end
    return root
end

AtomAnimTableCreater.createXmlParser = function(self, xmlFilePath)
    self.m_xmlModule = require("libs/xmlSimple")
    local parser = self.m_xmlModule.newParser()
    return parser:loadFile(xmlFilePath)
end

AtomAnimTableCreater.dtor = function(self)

end

AtomAnimTableCreater.setBaseAnimInfo = function(self, animType, animInfo, name)
    animInfo.type = name
    animInfo.id = animType["@ResourceId"]
    animInfo.delay = tonumber(animType["@StartTime"])
    animInfo.duration = tonumber(animType["@Duration"])
    animInfo.animType = animType["@AnimType"]
    animInfo.easeType = animType["@EaseType"];
    animInfo.period = tonumber(animType["@Period"]);

    if animInfo.animType == "Normal" then
        animInfo.animType = 0
    elseif animInfo.animType == "Repeat" then
        animInfo.animType = 1
    elseif animInfo.animType == "Loop" then
        animInfo.animType = 2
    end
end

AtomAnimTableCreater.getPackFile = function(self, animType)
    local packFile = nil;
    
    if animType ~= nil then
        packFile = animType["@PackFile"];
    end
    
    if packFile == nil or packFile == "" or string.upper(packFile) == "NIL" or string.upper(packFile) == "NULL" then
        packFile = nil;
    end

    return packFile;
end

AtomAnimTableCreater.createTransAnim = function(self, animType, name)
    local animInfo = {}
    self:setBaseAnimInfo(animType, animInfo, name)
    animInfo.startValueX = tonumber(animType["@StartValueX"])
    animInfo.endValueX   = tonumber(animType["@StopValueX"])
    animInfo.startValueY = tonumber(animType["@StartValueY"])
    animInfo.endValueY   = tonumber(animType["@StopValueY"])
    return animInfo
end

AtomAnimTableCreater.createColorAnim = function(self, animType, name)
    local animInfo = {}
    self:setBaseAnimInfo(animType, animInfo, name)
    animInfo.startValueRed      = tonumber(animType["@StartValueRed"])
    animInfo.startValueGreen    = tonumber(animType["@StartValueGreen"])
    animInfo.startValueBlue     = tonumber(animType["@StartValueBlue"])
    animInfo.endValueRed        = tonumber(animType["@StopValueRed"])
    animInfo.endValueGreen      = tonumber(animType["@StopValueGreen"])
    animInfo.endValueBlue       = tonumber(animType["@StopValueBlue"])
    return animInfo
end

AtomAnimTableCreater.createFirstAnim = function(self, animType, name)
    local animInfo = {}
    self:setBaseAnimInfo(animType, animInfo, name)
    animInfo.startValue = tonumber(animType["@StartValue"])
    animInfo.endValue = tonumber(animType["@StopValue"])
    return animInfo
end

AtomAnimTableCreater.createSecondAnim = function(self, animType, name)
    local animInfo = {}
    self:setBaseAnimInfo(animType, animInfo, name)
    animInfo.num = tonumber(animType["@Num"])
    return animInfo
end

AtomAnimTableCreater.createScaleAnim = function(self, animType, name)
    local animInfo = {}
    self:setBaseAnimInfo(animType, animInfo, name)
    animInfo.startValueX = tonumber(animType["@StartValueX"])
    animInfo.endValueX   = tonumber(animType["@StopValueX"])
    animInfo.startValueY = tonumber(animType["@StartValueY"])
    animInfo.endValueY   = tonumber(animType["@StopValueY"])
    animInfo.centerType  = self.centerTypeMap[animType["@CenterType"]];
    animInfo.centerX     = tonumber(animType["@CenterX"])
    animInfo.centerY     = tonumber(animType["@CenterY"])
    return animInfo
end

AtomAnimTableCreater.createThirdAnim = function(self, animType, name)
    local animInfo = {}
    self:setBaseAnimInfo(animType, animInfo, name)
    animInfo.startValue = tonumber(animType["@StartValue"])
    animInfo.endValue = tonumber(animType["@StopValue"])
    animInfo.centerType = self.centerTypeMap[animType["@CenterType"]];
    animInfo.centerX = tonumber(animType["@CenterX"])
    animInfo.centerY = tonumber(animType["@CenterY"])
    return animInfo
end

AtomAnimTableCreater.createBezierAnim = function(self, animType, name)
    local animInfo = {}
    self:setBaseAnimInfo(animType, animInfo, name)
    animInfo.startValueX   = tonumber(animType["@StartValueX"])
    animInfo.endValueX     = tonumber(animType["@StopValueX"]) 
    animInfo.startValueY   = tonumber(animType["@StartValueY"])
    animInfo.endValueY     = tonumber(animType["@StopValueY"]) 
    animInfo.controlValueX = tonumber(animType["@ControlValueX"])
    animInfo.controlValueY = tonumber(animType["@ControlValueY"])
    return animInfo
end

AtomAnimTableCreater.createBezierXAnim = function(self, animType, name)
    local animInfo = {}
    self:setBaseAnimInfo(animType, animInfo, name)
    animInfo.startValue = tonumber(animType["@StartValue"])
    animInfo.endValue = tonumber(animType["@StopValue"]) 
    animInfo.controlValue = tonumber(animType["@ControlValue"])
    return animInfo
end

AtomAnimTableCreater.createBezierYAnim = function(self, animType, name)
    local animInfo = {}
    self:setBaseAnimInfo(animType, animInfo, name)
    animInfo.startValue = tonumber(animType["@StartValue"])
    animInfo.endValue = tonumber(animType["@StopValue"]) 
    animInfo.controlValue = tonumber(animType["@ControlValue"])
    return animInfo
end

AtomAnimTableCreater.createEllipseAnim = function(self, animType, name)
    local animInfo = {}
    self:setBaseAnimInfo(animType, animInfo, name)
    animInfo.centerX = tonumber(animType["@CenterX"])
    animInfo.centerY = tonumber(animType["@CenterY"])
    animInfo.axisX   = tonumber(animType["@AxisX"])
    animInfo.axisY   = tonumber(animType["@AxisY"])
    animInfo.startAngle  = tonumber(animType["@StartAngle"])
    animInfo.endAngle  = tonumber(animType["@StopAngle"])
    return animInfo
end

AtomAnimTableCreater.createEllipseXAnim = function(self, animType, name)
    local animInfo = {}
    self:setBaseAnimInfo(animType, animInfo, name)
    animInfo.center = tonumber(animType["@Center"])
    animInfo.axis = tonumber(animType["@Axis"])
    animInfo.startAngle = tonumber(animType["@StartAngle"])
    animInfo.endAngle = tonumber(animType["@StopAngle"])
    return animInfo
end

AtomAnimTableCreater.createEllipseYAnim = function(self, animType, name)
    local animInfo = {}
    self:setBaseAnimInfo(animType, animInfo, name)
    animInfo.center = tonumber(animType["@Center"])
    animInfo.axis = tonumber(animType["@Axis"])
    animInfo.startAngle = tonumber(animType["@StartAngle"])
    animInfo.endAngle = tonumber(animType["@StopAngle"])
    return animInfo
end

AtomAnimTableCreater.createJumpAnim = function(self, animType, name)
    local animInfo = {}
    self:setBaseAnimInfo(animType, animInfo, name);
    animInfo.startValueX = tonumber(animType["@StartValueX"]);
    animInfo.endValueX = tonumber(animType["@StopValueX"]);
    animInfo.startValueY = tonumber(animType["@StartValueY"]);
    animInfo.endValueY = tonumber(animType["@StopValueY"]);
    animInfo.timesX = tonumber(animType["@TimesX"]);
    animInfo.timesY = tonumber(animType["@TimesY"]);
    animInfo.jumpX = tonumber(animType["@JumpX"]);
    animInfo.jumpY = tonumber(animType["@JumpY"]);
    return animInfo
end

AtomAnimTableCreater.setTranslateSolidInfo = function(self, animType, name)
    local animInfo = {}
    animInfo.type = name;
    animInfo.delay = tonumber(animType["@StartTime"]);
    animInfo.id = animType["@ResourceId"];
    animInfo.tranX = tonumber(animType["@TranX"]);
    animInfo.tranY = tonumber(animType["@TranY"]);
    return animInfo
end

AtomAnimTableCreater.setPosSolidInfo = function(self, animType, name)
    local animInfo = {}
    animInfo.type = name;
    animInfo.delay = tonumber(animType["@StartTime"]);
    animInfo.id = animType["@ResourceId"];
    animInfo.posX = tonumber(animType["@PosX"]);
    animInfo.posY = tonumber(animType["@PosY"]);
    return animInfo
end

AtomAnimTableCreater.setColorSolidInfo = function(self, animType, name)
    local animInfo = {}
    animInfo.type = name;
    animInfo.delay = tonumber(animType["@StartTime"]);
    animInfo.id = animType["@ResourceId"]
    animInfo.colorR = tonumber(animType["@ColorR"])
    animInfo.colorG = tonumber(animType["@ColorG"])
    animInfo.colorB = tonumber(animType["@ColorB"])
    return animInfo;
end

AtomAnimTableCreater.setAlphaSolidInfo = function(self, animType, name)
    local animInfo = {}
    animInfo.type = name;
    animInfo.delay = tonumber(animType["@StartTime"]);
    animInfo.id = animType["@ResourceId"];
    animInfo.transparency = tonumber(animType["@Transparency"]);
    return animInfo;
end

AtomAnimTableCreater.setRotateSolidInfo = function(self, animType, name)
    local animInfo = {}
    animInfo.type = name;
    animInfo.delay = tonumber(animType["@StartTime"]);
    animInfo.id = animType["@ResourceId"];
    animInfo.angleValue = tonumber(animType["@AngleValue"])
    animInfo.centerType = self.centerTypeMap[animType["@CenterType"]];
    animInfo.centerX = tonumber(animType["@CenterX"])
    animInfo.centerY = tonumber(animType["@CenterY"])
    return animInfo
end

AtomAnimTableCreater.setScaleSolidInfo = function(self, animType, name)
    local animInfo = {}
    animInfo.type = name;
    animInfo.delay = tonumber(animType["@StartTime"]);
    animInfo.id = animType["@ResourceId"];
    animInfo.valueX = tonumber(animType["@ValueX"])
    animInfo.valueY = tonumber(animType["@ValueY"])
    animInfo.centerType = self.centerTypeMap[animType["@CenterType"]];
    animInfo.centerX = tonumber(animType["@CenterX"])
    animInfo.centerY = tonumber(animType["@CenterY"])
    return animInfo
end

AtomAnimTableCreater.setFrameSolidInfo = function(self, animType, name)
    local animInfo = {}
    animInfo.type = name;
    animInfo.delay = tonumber(animType["@StartTime"]);
    animInfo.id = animType["@ResourceId"];
    animInfo.iterator = tonumber(animType["@Iterator"])
    return animInfo
end

AtomAnimTableCreater.loadAnimInfoFuncMap = {
    ["Color"]          = AtomAnimTableCreater.createColorAnim, 
    ["Red"]            = AtomAnimTableCreater.createFirstAnim, 
    ["Green"]          = AtomAnimTableCreater.createFirstAnim, 
    ["Blue"]           = AtomAnimTableCreater.createFirstAnim, 
    ["Alpha"]          = AtomAnimTableCreater.createFirstAnim, 
    ["Translate"]      = AtomAnimTableCreater.createTransAnim, 
    ["TranslateX"]     = AtomAnimTableCreater.createFirstAnim, 
    ["TranslateY"]     = AtomAnimTableCreater.createFirstAnim, 
    ["Frame"]          = AtomAnimTableCreater.createSecondAnim, 
    ["Rotate"]         = AtomAnimTableCreater.createThirdAnim,
    ["Scale"]          = AtomAnimTableCreater.createScaleAnim,
    ["ScaleX"]         = AtomAnimTableCreater.createThirdAnim,
    ["ScaleY"]         = AtomAnimTableCreater.createThirdAnim,
    ["Bezier"]         = AtomAnimTableCreater.createBezierAnim,
    ["BezierX"]        = AtomAnimTableCreater.createBezierXAnim,
    ["BezierY"]        = AtomAnimTableCreater.createBezierYAnim,
    ["Ellipse"]        = AtomAnimTableCreater.createEllipseAnim,
    ["EllipseX"]       = AtomAnimTableCreater.createEllipseXAnim,
    ["EllipseY"]       = AtomAnimTableCreater.createEllipseYAnim,
    ["Jump"]           = AtomAnimTableCreater.createJumpAnim,
    ["TranslateSolid"] = AtomAnimTableCreater.setTranslateSolidInfo,
    ["PosSolid"]       = AtomAnimTableCreater.setPosSolidInfo,
    ["ColorSolid"]     = AtomAnimTableCreater.setColorSolidInfo,
    ["AlphaSolid"]     = AtomAnimTableCreater.setAlphaSolidInfo,
    ["RotateSolid"]    = AtomAnimTableCreater.setRotateSolidInfo,
    ["ScaleSolid"]     = AtomAnimTableCreater.setScaleSolidInfo,
    ["FrameSolid"]     = AtomAnimTableCreater.setFrameSolidInfo
}

table2String = function(tab, indent, spacing)
    local s = {}
    spacing = spacing or ""
    indent = indent or "\t"
    table.insert (s, "{\n");
    local numMap = {};
    
    for tname, val in ipairs(tab) do
        numMap[tname] = false;
        changeHander(tname, val, s, spacing, indent);
    end
    
    for tname, val in pairs (tab) do
       if numMap[tname] ~= false then
         changeHander(tname, val, s, spacing, indent);
       end
    end
    table.insert (s, spacing.."}")
    return table.concat (s)
end

changeHander = function(tname, val, s, spacing, indent)
    if tname == "typeName" then
        print(tname);
    end
    table.insert (s, spacing..indent)
    local t = type(tname)
    if t == "string" then
        table.insert (s, string.format ("[%q] = ", tostring (tname)))
    elseif t == "number" or t == "boolean" then
        -- table.insert (s, string.format ("[%s] = ", tostring (tname)))
    else
        table.insert (s, t)
    end
    t = type(val)
    if t == "string" then
        table.insert (s, string.format ("%q", val))
    elseif t == "number" then
        if math.floor(val) < val then
            table.insert (s, string.format ("%.3f", val))
        else
            table.insert (s, string.format ("%d", val))
        end
    elseif t == "boolean" then
            table.insert (s, tostring(val));
    elseif t == "table" then
        table.insert (s, table2String (val, indent, spacing..indent))
    else
        table.insert (s, t)
    end
    table.insert (s, ",\n")
end