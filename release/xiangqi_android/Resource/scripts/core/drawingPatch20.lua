-- drawingPatch20.lua
-- Author: CuiPeng
-- Date: 2015-03-24
-- Last modification :
-- Description: require this file to update engine from 1.x to 2.0

function drawing_set_clip_res ( )
	print_string("ERROR: drawing_set_clip_res not support yet! please contact babestudio");
end

function drawing_set_touch_continue ( )
	print_string("ERROR: drawing_set_touch_continue not support yet! please contact babestudio");
end


function drawing_set_mirror ( drawing_id, mirror_x, mirror_y )
    if mirror_x > 0 and mirror_y < 1 then 
        return drawing_set_program(drawing_id,"mirrorXAxisShader",6);
    elseif mirror_x < 1 and mirror_y > 0 then
        return drawing_set_program(drawing_id,"mirrorYAxisShader",6);
    elseif mirror_x >0 and mirror_y > 0 then
        return drawing_set_program(drawing_id,"mirrorXYAxisShader",6);
    else
        return drawing_set_program(drawing_id,"image2d",6);
    end
   
end

function drawing_set_gray (drawing_id, gray)
    if gray > 0 then
        return drawing_set_program ( drawing_id, "grayScaleShader", 6);
    else
        return drawing_set_program ( drawing_id, "image2d", 6);
    end
end

drawing_create_image2 = drawing_create_image;
anim_set_event2 = anim_set_event;
drawing_set_touchable2 = drawing_set_touchable;
drawing_set_dragable2 = drawing_set_dragable;

res_create_double_array2 = res_create_double_array;
res_create_int_array2 = res_create_int_array;
res_create_ushort_array2 = res_create_ushort_array;
res_set_double_array2 = res_set_double_array;
res_set_int_array2 = res_set_int_array;
res_set_ushort_array2 = res_set_ushort_array;

drawing_set_bounding_circle_visible_test = drawing_set_visible_test;

GL_POINTS = 0x0000;
GL_LINES = 0x0001;
GL_LINE_LOOP = 0x0002;
GL_LINE_STRIP = 0x0003;
GL_TRIANGLES = 0x0004;
GL_TRIANGLE_STRIP = 0x0005;
GL_TRIANGLE_FAN = 0x0006;

TYPE_GL_NULL = 0;
TYPE_GL_POINTS = 1;
TYPE_GL_LINE_STRIP = 2;
TYPE_GL_LINE_LOOP = 3;
TYPE_GL_LINES = 4;
TYPE_GL_TRIANGLE_STRIP = 5;
TYPE_GL_TRIANGLE_FAN = 6;
TYPE_GL_TRIANGLES = 7;

USE_VERTEX_ARRAY = 0x00;
USE_TEXTURE_COORD_ARRAY = 0x10;
USE_COLOR_ARRAY = 0x20;


function drawing_set_color_transform ( drawingId, enable, r,g,b,a, offsetR, offsetG, offsetB, offsetA )  
    local oColorId = res_alloc_id();
    local oColor = {offsetR, offsetG, offsetB, offsetA};

    if enable == 1 then 
             
        res_create_double_array(0,oColorId,oColor);
    
        drawing_set_program(drawingId,"image2dColor",6);
        
        drawing_set_program_data(drawingId,"o_color",oColorId)

        drawing_set_color(drawingId,r*255,g*255,b*255);
        drawing_set_transparency(drawingId,1,a);
        
    else 
        if oColorId ~=nil then
            res_delete(oColorId)
            res_free_id(oColorId)
            oColorId = nil;
        end
        if oColor ~=nil then
           oColor = nil
        end
        drawing_set_program(drawingId,"",0);
        drawing_set_color(drawingId,255,255,255);
        drawing_set_transparency(drawingId,1,1);
    end
    return oColorId;
end


function drawing_set_node_renderable( iDrawingId, iRenderType, iUseData)
    local glType = -1;
    if TYPE_GL_POINTS ==  iRenderType then
        glType = GL_POINTS;
    end

    if TYPE_GL_LINE_STRIP ==  iRenderType then
        glType = GL_LINE_STRIP;
    end

    if TYPE_GL_LINE_LOOP ==  iRenderType then
        glType = GL_LINE_LOOP;
    end

    if TYPE_GL_LINES ==  iRenderType then
        glType = GL_LINES;
    end

    if TYPE_GL_TRIANGLE_STRIP ==  iRenderType then
        glType = GL_TRIANGLE_STRIP;
    end

    if TYPE_GL_TRIANGLE_FAN ==  iRenderType then
        glType = GL_TRIANGLE_FAN;
    end

    if TYPE_GL_TRIANGLES ==  iRenderType then
        glType = GL_TRIANGLES;
    end

    if -1 == glType then
		print_string("ERROR not support render type");
        return;
    end

    local programName = nil;

    if iUseData == 0 then
        programName = "renderable1";
    end

    if iUseData == 0x20 then
        programName = "renderable2";
    end

    if iUseData == 0x10 then
        programName = "renderable3";
    end
	
    if iUseData == 0x30 then
        programName = "renderable4";
    end

    if nil == programName then
		print_string("ERROR not support render data type");
        return;
    end

    drawing_set_program(iDrawingId, programName, glType );
end

function drawing_set_node_texture(iDrawingId,iResIdBitmap, iResDoubleArrayIdTextureCoord )
    drawing_set_program_data ( iDrawingId, "texture0",iResIdBitmap);
    drawing_set_program_data ( iDrawingId, "a_tex_coord",iResDoubleArrayIdTextureCoord);
end

function drawing_set_node_vertex(iDrawingId,iResDoubleArrayIdVertex,iResUShortIdIndices )
	drawing_set_program_data ( iDrawingId, "a_position",iResDoubleArrayIdVertex);
	drawing_set_program_data ( iDrawingId, "index",iResUShortIdIndices);
end

function drawing_set_node_colors(iDrawingId,iResDoubleArrayIdColors )
	drawing_set_program_data ( iDrawingId, "a_color",iResDoubleArrayIdColors);
end


kBlendSrcZero=0;
kBlendSrcOne=1;
kBlendSrcDstColor=2;
kBlendSrcOneMinusDstColor=3;
kBlendSrcSrcAlpha=4;
kBlendSrcOneMinusSrcAlpha=5;
kBlendSrcDstAlpha=6;
kBlendSrcOneMinusDstAlpha=7;
kBlendSrcSrcAlphaSaturate=8;

kBlendDstZero=0;
kBlendDstOne=1;
kBlendDstSrcColor=2;
kBlendDstOneMinusSrcColor=3;
kBlendDstSrcAlpha=4;
kBlendDstOneMinusSrcAlpha=5;
kBlendDstDstAlpha=6;
kBlendDstOneMinusDstAlpha=7;

--
GL_ZERO = 0;
GL_ONE = 1;
GL_SRC_ALPHA = 0x0302;
GL_ONE_MINUS_SRC_ALPHA = 0x0303;
GL_DST_ALPHA = 0x0304;
GL_ONE_MINUS_DST_ALPHA = 0x0305;

--BlendingFactorSrc
GL_DST_COLOR = 0x0306;
GL_ONE_MINUS_DST_COLOR = 0x0307;

--BlendingFactorDest
GL_SRC_COLOR = 0x0300;
GL_ONE_MINUS_SRC_COLOR = 0x0301;

function drawing_set_blend_mode ( iDrawingId, src, dst )

	local s = -1;
	if kBlendSrcZero ==  src then
        s = GL_ZERO;
    end
	if kBlendSrcOne ==  src then
        s = GL_ONE;
    end
	if kBlendSrcDstColor ==  src then
        s = GL_DST_COLOR;
    end
	if kBlendSrcOneMinusDstColor ==  src then
        s = GL_ONE_MINUS_DST_COLOR;
    end
	if kBlendSrcSrcAlpha ==  src then
        s = GL_SRC_ALPHA;
    end
	if kBlendSrcOneMinusSrcAlpha ==  src then
        s = GL_ONE_MINUS_SRC_ALPHA;
    end
	if kBlendSrcDstAlpha ==  src then
        s = GL_DST_ALPHA;
    end
	if kBlendSrcOneMinusDstAlpha ==  src then
        s = GL_ONE_MINUS_DST_ALPHA;
    end

	if -1 == s then
		print_string("ERROR not support blend src factor");
		return;
	end
	
	local d = -1;
	if kBlendDstZero ==  dst then
        d = GL_ZERO;
    end
	if kBlendDstOne ==  dst then
        d = GL_ONE;
    end
	if kBlendDstSrcColor ==  dst then
        d = GL_SRC_COLOR;
    end
	if kBlendDstOneMinusSrcColor ==  dst then
        d = GL_ONE_MINUS_SRC_COLOR;
    end
	if kBlendDstSrcAlpha ==  dst then
        d = GL_SRC_ALPHA;
    end
	if kBlendDstOneMinusSrcAlpha ==  dst then
        d = GL_ONE_MINUS_SRC_ALPHA;
    end
	if kBlendDstDstAlpha ==  dst then
        d = GL_DST_ALPHA;
    end
	if kBlendDstOneMinusDstAlpha ==  dst then
        d = GL_ONE_MINUS_DST_ALPHA;
    end
    
	if -1 == d then
		print_string("ERROR not support blend dst factor");
		return;
	end
	
	drawing_set_blend ( iDrawingId, 1, s, d );
end
