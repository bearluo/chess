require("core/object")
require("ui/node")
require("atomAnim/atomAnimUtils")
require("atomAnim/atomAnimTableCreater")

gAnimNode = nil;
gAnimInstance = nil; --全局实例防止在播放动画时，被垃圾回收系统回收
function event_load ( width, height )
end

function playDebugAnim()
    local xmlPath = "";

    local storageScriptPath = sys_get_string("storage_scripts") or ""
    local scriptsPath = (string.sub(storageScriptPath,0,string.find(storageScriptPath, "Resource", 0) + 7)) .. "/animation/"
    xmlPath = scriptsPath .. "/Test1.xml";
   
    local luaPath = creatLuaCode(xmlPath);  -- 获取指定xml文件，将xml文件转换成lua表
    if AtomAnimUtils.checkPath(luaPath) == ATOM_ANIM_PATH_ERROR then return; end
    dict_set_string("animLua", "animLuaPath", luaPath);

    -- 设置文件是否生成成功的 flag。空为正常，其他情况抛出错误字符串
    dict_set_string("animXml", "flag", " ");
    event_anim_play(); 
end

function event_get_xml_path ()
    local xmlPath = dict_get_string("animXml", "animXmlPath"); --从前端获取XML文件的路径
    if AtomAnimUtils.checkPath(xmlPath) == ATOM_ANIM_PATH_ERROR then return; end
    
    local luaPath = creatLuaCode(xmlPath);  -- 获取指定xml文件，将xml文件转换成lua表
    if AtomAnimUtils.checkPath(luaPath) == ATOM_ANIM_PATH_ERROR then return; end
    dict_set_string("animLua", "animLuaPath", luaPath);

    -- 设置文件是否生成成功的 flag。空为正常，其他情况抛出错误字符串
    dict_set_string("animXml", "flag", " ");
end


function event_anim_play()
    local luaPath = dict_get_string("animLua", "animLuaPath");
    if gAnimNode == nil then
        gAnimNode = new(Node);
        gAnimNode:addToRoot();
    end
    playAtomAnim(luaPath,gAnimNode);
end


--播放指定路径动画
function playAtomAnim(luaPath,parent,x,y)
    require("atomAnim/atomAnimManager");
    if gAnimInstance ~= nil then
        if gAnimInstance.m_startCallBack ~= nil then
            gAnimInstance.m_startCallBack:dtor();
            gAnimInstance.m_startCallBack = nil;
        end
        gAnimInstance:release();
    end
    gAnimInstance = AtomAnimManager.getInstance():playAnim(luaPath, parent, x, y, false);
end

-- 将xml表转换成Lua表
function creatLuaCode(xmlPath) 
    atomAnimTableCreater = new(AtomAnimTableCreater);
    local luaPath = atomAnimTableCreater:parseXml(xmlPath);
    return AtomAnimUtils.genRelativePath(luaPath)
end

if drawing_create_image ~= drawing_create_image2 then
    drawing_create_image2 = drawing_create_image;

    DrawingImage.ctor = function(self, res, leftWidth, rightWidth, topWidth, bottomWidth)
        self.m_resID = res:getID();
        self.m_width = res:getWidth();
        self.m_height = res:getHeight();

        self.m_isGrid9 = (leftWidth and rightWidth and bottomWidth and topWidth) and true or false;
        
        local realWidth,realHeight = DrawingImage.getRealSize(self);

        leftWidth = leftWidth or 0;
        rightWidth = rightWidth or 0;
        bottomWidth = bottomWidth or 0;
        topWidth = topWidth or 0;
        local scale = System.getLayoutScale();
        drawing_create_image2(0, self.m_drawingID, self.m_resID,
                                self.m_x, self.m_y, realWidth, realHeight, 
                                self.m_isGrid9  and kTrue or kFalse, leftWidth,rightWidth,bottomWidth,topWidth, 
                                leftWidth * scale,rightWidth * scale,bottomWidth * scale,topWidth * scale, 
                                self.m_level);

		DrawingImage.setResRect(self,0,res);
	end	
end

if anim_set_event ~= anim_set_event2 then
    anim_set_event2 = anim_set_event;
end
