
local M = {}

local current_drawings = {}

local enabled = false

M.enable = function ()
    if enabled then 
        return 
    end 


    -- hack 
    local orig_drawing_create_image = drawing_create_image
    drawing_create_image = function (iGroup, iDrawingId, ...)
	    current_drawings[iDrawingId] = true
        --print_string('creating drawing: ' .. iDrawingId)
	    return orig_drawing_create_image(iGroup, iDrawingId, ...)
    end

    -- hack 
    local orig_drawing_create_node = drawing_create_node
    drawing_create_node = function (iGroup, iDrawingId, ...)
	    current_drawings[iDrawingId] = true 
        --print_string('creating drawing: ' .. iDrawingId)
	    return orig_drawing_create_node(iGroup, iDrawingId, ...)
    end 

    -- hack
    local orig_drawing_delete = drawing_delete
    drawing_delete = function (iDrawingId)
	    current_drawings[iDrawingId] = nil
       -- print_string('removing drawing: ' .. iDrawingId)
	    return orig_drawing_delete(iDrawingId)
    end 

    -- hack 
    local orig_drawing_delete_all = drawing_delete_all 
    drawing_delete_all = function ()
	    current_drawings = {}
        --print_string('removing all drawings')
	    return orig_drawing_delete_all ()	
    end 

    enabled = true
end

M.printAllDrawings = function ()
    local count = 0
    for k,v in pairs(current_drawings) do 
        count = count + 1
        --print_string(tostring(k))
    end
    --print_string('total: ' .. tostring(count))
end


M.isDrawingExists = function (drawing_id)
	return current_drawings[drawing_id]
end

return M