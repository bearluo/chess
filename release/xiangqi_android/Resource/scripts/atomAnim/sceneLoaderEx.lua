require("core/sceneLoader")

if SceneLoader then 

SceneLoader.loadAnimFrame = function(t)
    local fileArray = {};
    local file = t.file;
    if type(file) == "table" then
        local num = #file;
        for i = 1, num do
            if file[i].path ~= nil then
                t.packFile = file[i].packFile;
                fileArray[i] = SceneLoader.getResPath(t,file[i].path);
            else
                fileArray[i] = SceneLoader.getResPath(t,file[i]);
            end
        end;
    else
        local num = t.imageNum;
        for i = 1, num do
            fileArray[i] = SceneLoader.getResPath(t,string.format(file, i));
        end;
    end;
	local node = new(Images, fileArray,t.fmt,t.filter,t.gridLeft,t.gridRight,t.gridTop,t.gridBottom);
	SceneLoader.setBaseInfo(node,t);
	return node;
end

SceneLoader.loadFuncMap["AnimFrame"] = SceneLoader.loadAnimFrame;   --帧动画


end