--
-- libEffect Version: @@Version@@
-- 
-- This file is a part of libEffect Library and engine.
--
-- Authors:
-- Xiaofeng Yang     
-- Heng Li           
--

local PROGRAM_DATA_TYPE_ATTRIB = 1;
local PROGRAM_DATA_TYPE_UNIFORM = 2;
local PROGRAM_DATA_TYPE_TEXTURE = 3;
local PROGRAM_DATA_TYPE_INDEX = 4;

function createImage2dX ()

    program_create("image2dX");

    local vsImage2dX = [=[
        uniform   mat4 u_mvp_matrix;
        attribute vec3 a_position;
        attribute vec2 a_tex_coord;
        varying   vec2 vtexcoord;

        void main()
        {
            gl_Position = u_mvp_matrix * vec4(a_position, 1.0);
            vtexcoord = a_tex_coord ;
        }
    ]=];

    local fsImage2dX = [=[
        precision mediump float;
        uniform sampler2D texture0;
        uniform sampler2D texture3;
        uniform vec4 u_color;
        varying vec2 vtexcoord;

        void main()
        {   
            vec4 colorDummy = texture2D(texture0, vtexcoord);
            vec4 color = texture2D(texture3, vtexcoord);           
            gl_FragColor = color * u_color  + colorDummy * vec4(0.0,0.0,0.0,1.0);
        }
    ]=];

    program_set_shader_source("image2dX", vsImage2dX, fsImage2dX);

    program_add_parameter("image2dX", PROGRAM_DATA_TYPE_UNIFORM, 44, "u_mvp_matrix");
    program_add_parameter("image2dX", PROGRAM_DATA_TYPE_ATTRIB, 3, "a_position");
    program_add_parameter("image2dX", PROGRAM_DATA_TYPE_TEXTURE, 0, "texture0");
    program_add_parameter("image2dX", PROGRAM_DATA_TYPE_TEXTURE, 0, "texture3");
    program_add_parameter("image2dX", PROGRAM_DATA_TYPE_ATTRIB, 2, "a_tex_coord");
    program_add_parameter("image2dX", PROGRAM_DATA_TYPE_UNIFORM, 4, "u_color");
    program_add_parameter("image2dX", PROGRAM_DATA_TYPE_INDEX, 2, "index");
end

function createMirrorYAxisShader ()

    program_create("mirrorYAxisShader");

    local vsMirrorYAxis = [=[
        uniform   mat4 u_mvp_matrix;
        attribute vec3 a_position;
        attribute vec2 a_tex_coord;
        varying   vec2 vtexcoord;

        void main()
        {
            gl_Position = u_mvp_matrix * vec4(a_position, 1.0);
            vtexcoord = a_tex_coord ;
        }
    ]=];

    local fsMirrorYAxis = [=[
        precision mediump float;
        uniform sampler2D texture0;
        uniform vec4 u_color;
        varying vec2 vtexcoord;

        void main()
        {
            vec4 color = texture2D(texture0, vec2(vtexcoord.x, 1.0 - vtexcoord.y));
            gl_FragColor = color * u_color;
        }
    ]=];

    program_set_shader_source("mirrorYAxisShader", vsMirrorYAxis, fsMirrorYAxis);

    program_add_parameter("mirrorYAxisShader", PROGRAM_DATA_TYPE_UNIFORM, 44, "u_mvp_matrix");
    program_add_parameter("mirrorYAxisShader", PROGRAM_DATA_TYPE_ATTRIB, 3, "a_position");
    program_add_parameter("mirrorYAxisShader", PROGRAM_DATA_TYPE_TEXTURE, 0, "texture0");
    program_add_parameter("mirrorYAxisShader", PROGRAM_DATA_TYPE_ATTRIB, 2, "a_tex_coord");
    program_add_parameter("mirrorYAxisShader", PROGRAM_DATA_TYPE_UNIFORM, 4, "u_color");
    program_add_parameter("mirrorYAxisShader", PROGRAM_DATA_TYPE_INDEX, 2, "index");
end


function createMirrorXAxisShader ()

    program_create("mirrorXAxisShader");

    local vsMirrorXAxis = [=[
        uniform   mat4 u_mvp_matrix;
        attribute vec3 a_position;
        attribute vec2 a_tex_coord;
        varying   vec2 vtexcoord;

        void main()
        {
            gl_Position = u_mvp_matrix * vec4(a_position, 1.0);
            vtexcoord = a_tex_coord ;
        }
    ]=];

    local fsMirrorXAxis = [=[
        precision mediump float;
        uniform sampler2D texture0;
        uniform vec4 u_color;
        varying vec2 vtexcoord;

        void main()
        {
            vec4 color = texture2D(texture0, vec2(1.0 - vtexcoord.x, vtexcoord.y));
            gl_FragColor = color * u_color;
        }
    ]=];

    program_set_shader_source("mirrorXAxisShader", vsMirrorXAxis, fsMirrorXAxis);

    program_add_parameter("mirrorXAxisShader", PROGRAM_DATA_TYPE_UNIFORM, 44, "u_mvp_matrix");
    program_add_parameter("mirrorXAxisShader", PROGRAM_DATA_TYPE_ATTRIB, 3, "a_position");
    program_add_parameter("mirrorXAxisShader", PROGRAM_DATA_TYPE_TEXTURE, 0, "texture0");
    program_add_parameter("mirrorXAxisShader", PROGRAM_DATA_TYPE_ATTRIB, 2, "a_tex_coord");
    program_add_parameter("mirrorXAxisShader", PROGRAM_DATA_TYPE_UNIFORM, 4, "u_color");
    program_add_parameter("mirrorXAxisShader", PROGRAM_DATA_TYPE_INDEX, 2, "index");
end

function createMirrorXYAxisShader ()

    program_create("mirrorXYAxisShader");

    local vsMirrorXYAxis = [=[
        uniform   mat4 u_mvp_matrix;
        attribute vec3 a_position;
        attribute vec2 a_tex_coord;
        varying   vec2 vtexcoord;

        void main()
        {
           gl_Position = u_mvp_matrix * vec4(a_position, 1.0);
           vtexcoord = a_tex_coord ;
        }
    ]=];

    local fsMirrorXYAxis = [=[
        precision mediump float;
        uniform sampler2D texture0;
        uniform vec4 u_color;
        uniform vec2 sum;
        varying vec2 vtexcoord;

        void main()
        {
            vec4 color = texture2D(texture0, vec2(1.0, 1.0) - vtexcoord);
            gl_FragColor = color * u_color;
        }
    ]=];

    program_set_shader_source("mirrorXYAxisShader", vsMirrorXYAxis, fsMirrorXYAxis);

    program_add_parameter("mirrorXYAxisShader", PROGRAM_DATA_TYPE_UNIFORM, 44, "u_mvp_matrix");
    program_add_parameter("mirrorXYAxisShader", PROGRAM_DATA_TYPE_ATTRIB, 3, "a_position");
    program_add_parameter("mirrorXYAxisShader", PROGRAM_DATA_TYPE_TEXTURE, 0, "texture0");
    program_add_parameter("mirrorXYAxisShader", PROGRAM_DATA_TYPE_ATTRIB, 2, "a_tex_coord");
    program_add_parameter("mirrorXYAxisShader", PROGRAM_DATA_TYPE_UNIFORM, 4, "u_color");
    program_add_parameter("mirrorXYAxisShader", PROGRAM_DATA_TYPE_INDEX, 2, "index");

end

function createGrayScaleShader ()

    program_create("grayScaleShader");
    local vsGrayScale = [=[
        uniform   mat4 u_mvp_matrix;
        attribute vec3 a_position;
        attribute vec2 a_tex_coord;
        varying   vec2 vtexcoord;

        void main()
        {
            gl_Position = u_mvp_matrix * vec4(a_position, 1.0);
            vtexcoord = a_tex_coord ;
        }
    ]=];

    local fsGrayScale = [=[
        precision mediump float;
        uniform sampler2D texture0;
        uniform vec4 u_color;
        varying vec2 vtexcoord;

        void main()
        {
            vec4 color = texture2D(texture0, vtexcoord);
            float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
            gl_FragColor = vec4(gray, gray, gray, color.a) * u_color;
        }
    ]=];

    program_set_shader_source("grayScaleShader", vsGrayScale, fsGrayScale);

    program_add_parameter("grayScaleShader", PROGRAM_DATA_TYPE_UNIFORM, 44, "u_mvp_matrix");
    program_add_parameter("grayScaleShader", PROGRAM_DATA_TYPE_ATTRIB, 3, "a_position");
    program_add_parameter("grayScaleShader", PROGRAM_DATA_TYPE_TEXTURE, 0, "texture0");
    program_add_parameter("grayScaleShader", PROGRAM_DATA_TYPE_ATTRIB, 2, "a_tex_coord");
    program_add_parameter("grayScaleShader", PROGRAM_DATA_TYPE_UNIFORM, 4, "u_color");
    program_add_parameter("grayScaleShader", PROGRAM_DATA_TYPE_INDEX, 2, "index");
end


function createBlurShaderVertical ()

    program_create("blurShaderVertical");

    local vsBlur = [=[
        uniform   mat4  u_mvp_matrix;
        uniform   float ratio;
        uniform   float height;
        attribute vec3  a_position;
        attribute vec2  a_tex_coord;
        varying   vec2  vtexcoord;
        varying   vec2  vblurtexcoord[9];

        void main()
        {
            gl_Position = u_mvp_matrix * vec4(a_position, 1.0);
            vtexcoord = a_tex_coord;
            vblurtexcoord[0] =  vtexcoord + vec2(0.0, -4.0/height) * ratio;
            vblurtexcoord[1] =  vtexcoord + vec2(0.0, -3.0/height) * ratio;
            vblurtexcoord[2] =  vtexcoord + vec2(0.0, -2.0/height) * ratio;
            vblurtexcoord[3] =  vtexcoord + vec2(0.0, -1.0/height) * ratio;
            vblurtexcoord[4] =  vtexcoord;
            vblurtexcoord[5] =  vtexcoord + vec2(0.0, 1.0/height) * ratio;
            vblurtexcoord[6] =  vtexcoord + vec2(0.0, 2.0/height) * ratio;
            vblurtexcoord[7] =  vtexcoord + vec2(0.0, 3.0/height) * ratio;
            vblurtexcoord[8] =  vtexcoord + vec2(0.0, 4.0/height) * ratio;
        }
    ]=];

    local fsBlur = [=[
        precision mediump float;
        uniform sampler2D texture0;
        uniform sampler2D texture2;
        uniform vec4 u_color;
        varying vec2 vtexcoord;
        varying vec2 vblurtexcoord[9];

        void main()
        {   vec4 colorDummy = texture2D(texture0, vtexcoord);
            vec4 sample = vec4(0.0, 0.0, 0.0, 0.0);
            sample += texture2D(texture2, vblurtexcoord[0]) * u_color * 0.05;
            sample += texture2D(texture2, vblurtexcoord[1]) * u_color * 0.09;
            sample += texture2D(texture2, vblurtexcoord[2]) * u_color * 0.12;
            sample += texture2D(texture2, vblurtexcoord[3]) * u_color * 0.15;
            sample += texture2D(texture2, vblurtexcoord[4]) * u_color * 0.18;
            sample += texture2D(texture2, vblurtexcoord[5]) * u_color * 0.15;
            sample += texture2D(texture2, vblurtexcoord[6]) * u_color * 0.12;
            sample += texture2D(texture2, vblurtexcoord[7]) * u_color * 0.09;
            sample += texture2D(texture2, vblurtexcoord[8]) * u_color * 0.05;
            gl_FragColor = sample * u_color  + colorDummy * vec4(0.0,0.0,0.0,1.0);
        }
    ]=];

    program_set_shader_source("blurShaderVertical", vsBlur, fsBlur);

    program_add_parameter("blurShaderVertical", PROGRAM_DATA_TYPE_UNIFORM, 44, "u_mvp_matrix");
    program_add_parameter("blurShaderVertical", PROGRAM_DATA_TYPE_ATTRIB, 3, "a_position");
    program_add_parameter("blurShaderVertical", PROGRAM_DATA_TYPE_ATTRIB, 2, "a_tex_coord");
    program_add_parameter("blurShaderVertical", PROGRAM_DATA_TYPE_UNIFORM, 4, "u_color");
    program_add_parameter("blurShaderVertical", PROGRAM_DATA_TYPE_INDEX, 2, "index");
    program_add_parameter("blurShaderVertical", PROGRAM_DATA_TYPE_TEXTURE, 0, "texture0");
    program_add_parameter("blurShaderVertical", PROGRAM_DATA_TYPE_TEXTURE, 0, "texture2");
    program_add_parameter("blurShaderVertical", PROGRAM_DATA_TYPE_UNIFORM, 1, "ratio");
    program_add_parameter("blurShaderVertical", PROGRAM_DATA_TYPE_UNIFORM, 1, "height");

end


function createBlurShaderHorizontal ()

    program_create("blurShaderHorizontal");

    local vsBlur = [=[
        uniform   mat4 u_mvp_matrix;
        uniform float ratio;
        uniform float width;
        attribute vec3 a_position;
        attribute vec2 a_tex_coord;
        varying   vec2 vtexcoord;
        varying   vec2 vblurtexcoord[5];

        void main()
        {
            gl_Position =  u_mvp_matrix * vec4(a_position, 1.0);
            vtexcoord =  a_tex_coord ;
            vblurtexcoord[0] =  vtexcoord + vec2( -3.230769/width, 0.0) * ratio;
            vblurtexcoord[1] =  vtexcoord + vec2( -1.384615/width, 0.0) * ratio;
            vblurtexcoord[2] =  vtexcoord;
            vblurtexcoord[3] =  vtexcoord + vec2( 1.384615/width, 0.0) * ratio;
            vblurtexcoord[4] =  vtexcoord + vec2( 3.230769/width, 0.0) * ratio;
        }
    ]=];

    local fsBlur = [=[
        precision mediump float;
        uniform sampler2D texture1;
        uniform sampler2D texture0;
        uniform vec4 u_color;
        varying vec2 vtexcoord;
        varying vec2 vblurtexcoord[5];

        void main()
        {   
            vec4 colorDummy = texture2D(texture0, vtexcoord);
            lowp vec4 sample = vec4(0.0, 0.0, 0.0, 0.0);
            sample += texture2D(texture1, vblurtexcoord[0]) * 0.07027;
            sample += texture2D(texture1, vblurtexcoord[1]) * 0.316216;
            sample += texture2D(texture1, vblurtexcoord[2]) * 0.227027;
            sample += texture2D(texture1, vblurtexcoord[3]) * 0.316216;
            sample += texture2D(texture1, vblurtexcoord[4]) * 0.07027;
            gl_FragColor = sample * u_color  + colorDummy * vec4(0.0,0.0,0.0,1.0);
        }
    ]=];

    program_set_shader_source("blurShaderHorizontal", vsBlur, fsBlur);

    program_add_parameter("blurShaderHorizontal", PROGRAM_DATA_TYPE_UNIFORM, 44, "u_mvp_matrix");
    program_add_parameter("blurShaderHorizontal", PROGRAM_DATA_TYPE_ATTRIB, 3, "a_position");
    program_add_parameter("blurShaderHorizontal", PROGRAM_DATA_TYPE_ATTRIB, 2, "a_tex_coord");
    program_add_parameter("blurShaderHorizontal", PROGRAM_DATA_TYPE_UNIFORM, 4, "u_color");
    program_add_parameter("blurShaderHorizontal", PROGRAM_DATA_TYPE_INDEX, 2, "index");
    program_add_parameter("blurShaderHorizontal", PROGRAM_DATA_TYPE_UNIFORM, 1, "ratio");
    program_add_parameter("blurShaderHorizontal", PROGRAM_DATA_TYPE_UNIFORM, 1, "width");
    program_add_parameter("blurShaderHorizontal", PROGRAM_DATA_TYPE_TEXTURE, 0, "texture1");
    program_add_parameter("blurShaderHorizontal", PROGRAM_DATA_TYPE_TEXTURE, 0, "texture0");

end


function createMirrorYAtlasShader ()

    program_create("mirrorYAtlasShader");

    local vsMirrorYAtlas = [=[
        uniform   mat4 u_mvp_matrix;
        attribute vec3 a_position;
        attribute vec2 a_tex_coord;
        varying   vec2 vtexcoord;

        void main()
        {
            gl_Position = u_mvp_matrix * vec4(a_position, 1.0);
            vtexcoord = a_tex_coord;
        }
    ]=];

    local fsMirrorYAtlas = [=[
        precision mediump float;
        uniform sampler2D texture0;
        uniform vec4 u_color;
        uniform float sum;
        varying vec2 vtexcoord;

        void main()
        {
            vec4 color = texture2D(texture0, vec2(vtexcoord.x, sum - vtexcoord.y));
            gl_FragColor= color * u_color;
        }
    ]=];

    program_set_shader_source("mirrorYAtlasShader", vsMirrorYAtlas, fsMirrorYAtlas);

    program_add_parameter("mirrorYAtlasShader", PROGRAM_DATA_TYPE_UNIFORM, 44, "u_mvp_matrix");
    program_add_parameter("mirrorYAtlasShader", PROGRAM_DATA_TYPE_ATTRIB, 3, "a_position");
    program_add_parameter("mirrorYAtlasShader", PROGRAM_DATA_TYPE_TEXTURE, 0, "texture0");
    program_add_parameter("mirrorYAtlasShader", PROGRAM_DATA_TYPE_ATTRIB, 2, "a_tex_coord");
    program_add_parameter("mirrorYAtlasShader", PROGRAM_DATA_TYPE_UNIFORM, 4, "u_color");
    program_add_parameter("mirrorYAtlasShader", PROGRAM_DATA_TYPE_INDEX, 2, "index");
    program_add_parameter("mirrorYAtlasShader", PROGRAM_DATA_TYPE_UNIFORM, 1, "sum");
end


function createMirrorXAtlasShader ()

    program_create("mirrorXAtlasShader");

    local vsMirrorXAtlas = [=[
        uniform   mat4 u_mvp_matrix;
        attribute vec3 a_position;
        attribute vec2 a_tex_coord;
        varying   vec2 vtexcoord;

        void main()
        {
            gl_Position = u_mvp_matrix * vec4(a_position, 1.0);
            vtexcoord = a_tex_coord ;
        }
    ]=];

    local fsMirrorXAtlas = [=[
        precision mediump float;
        uniform sampler2D texture0;
        uniform vec4 u_color;
        uniform float sum;
        varying vec2 vtexcoord;

        void main()
        {
            vec4 color = texture2D(texture0, vec2(sum - vtexcoord.x, vtexcoord.y));
            gl_FragColor = color * u_color;
        }
    ]=];

    program_set_shader_source("mirrorXAtlasShader", vsMirrorXAtlas, fsMirrorXAtlas);

    program_add_parameter("mirrorXAtlasShader", PROGRAM_DATA_TYPE_UNIFORM, 44, "u_mvp_matrix");
    program_add_parameter("mirrorXAtlasShader", PROGRAM_DATA_TYPE_ATTRIB, 3, "a_position");
    program_add_parameter("mirrorXAtlasShader", PROGRAM_DATA_TYPE_TEXTURE, 0, "texture0");
    program_add_parameter("mirrorXAtlasShader", PROGRAM_DATA_TYPE_ATTRIB, 2, "a_tex_coord");
    program_add_parameter("mirrorXAtlasShader", PROGRAM_DATA_TYPE_UNIFORM, 4, "u_color");
    program_add_parameter("mirrorXAtlasShader", PROGRAM_DATA_TYPE_INDEX, 2, "index");
    program_add_parameter("mirrorXAtlasShader", PROGRAM_DATA_TYPE_UNIFORM, 1, "sum");
end

function createMirrorXYAtlasShader ()

    program_create("mirrorXYAtlasShader");

    local vsMirrorXYAtlas = [=[
        uniform   mat4 u_mvp_matrix;
        attribute vec3 a_position;
        attribute vec2 a_tex_coord;
        varying   vec2 vtexcoord;

        void main()
        {
            gl_Position = u_mvp_matrix * vec4(a_position, 1.0);
            vtexcoord = a_tex_coord;
        }
    ]=];

    local fsMirrorXYAtlas = [=[
        precision mediump float;
        uniform sampler2D texture0;
        uniform vec4 u_color;
        uniform vec2 sum;
        varying vec2 vtexcoord;

        void main()
        {
            vec4 color = texture2D(texture0, sum - vtexcoord);
            gl_FragColor = color * u_color;
        }
    ]=];

    program_set_shader_source("mirrorXYAtlasShader", vsMirrorXYAtlas, fsMirrorXYAtlas);

    program_add_parameter("mirrorXYAtlasShader", PROGRAM_DATA_TYPE_UNIFORM, 44, "u_mvp_matrix");
    program_add_parameter("mirrorXYAtlasShader", PROGRAM_DATA_TYPE_ATTRIB, 3, "a_position");
    program_add_parameter("mirrorXYAtlasShader", PROGRAM_DATA_TYPE_TEXTURE, 0, "texture0");
    program_add_parameter("mirrorXYAtlasShader", PROGRAM_DATA_TYPE_ATTRIB, 2, "a_tex_coord");
    program_add_parameter("mirrorXYAtlasShader", PROGRAM_DATA_TYPE_UNIFORM, 4, "u_color");
    program_add_parameter("mirrorXYAtlasShader", PROGRAM_DATA_TYPE_INDEX, 2, "index");
    program_add_parameter("mirrorXYAtlasShader", PROGRAM_DATA_TYPE_UNIFORM, 2, "sum");
end


function createFrostShader()
    program_create("frostShader");

    local vsFrost = [=[
        uniform   mat4 u_mvp_matrix;
        attribute vec3 a_position;
        attribute vec2 a_tex_coord;
        varying   vec2 vtexcoord;

        void main()
        {
            gl_Position = u_mvp_matrix * vec4(a_position,1.0);
            vtexcoord = a_tex_coord;
        }
    ]=];


   local fsFrost=[=[
       precision mediump float;
       uniform sampler2D texture0;
       uniform sampler2D texture1;
       uniform vec4 u_color;
       uniform float offset;
       uniform vec2 screenSize;
       varying vec2 vtexcoord;
       

       vec4 spline(float x, vec4 c1, vec4 c2, vec4 c3, vec4 c4, vec4 c5, vec4 c6, vec4 c7, vec4 c8, vec4 c9)
       {
           float w1, w2, w3, w4, w5, w6, w7, w8, w9;
           w1 = 0.0;
           w2 = 0.0;
           w3 = 0.0;
           w4 = 0.0;
           w5 = 0.0;
           w6 = 0.0;
           w7 = 0.0;
           w8 = 0.0;
           w9 = 0.0;
           float tmp = x * 8.0;
           if (tmp<=1.0) {
           w1 = 1.0 - tmp;
           w2 = tmp;
           }
           else if (tmp<=2.0) {
           tmp = tmp - 1.0;
           w2 = 1.0 - tmp;
           w3 = tmp;
           }
           else if (tmp<=3.0) {
           tmp = tmp - 2.0;
           w3 = 1.0-tmp;
           w4 = tmp;
           }
           else if (tmp<=4.0) {
           tmp = tmp - 3.0;
           w4 = 1.0-tmp;
           w5 = tmp;
           }
           else if (tmp<=5.0) {
           tmp = tmp - 4.0;
           w5 = 1.0-tmp;
           w6 = tmp;
           }
           else if (tmp<=6.0) {
           tmp = tmp - 5.0;
           w6 = 1.0-tmp;
           w7 = tmp;
           }
           else if (tmp<=7.0) {
           tmp = tmp - 6.0;
           w7 = 1.0 - tmp;
           w8 = tmp;
           }
            else
           {

           tmp = clamp(tmp - 7.0, 0.0, 1.0);
           w8 = 1.0-tmp;
           w9 = tmp;
           }
           return w1*c1 + w2*c2 + w3*c3 + w4*c4 + w5*c5 + w6*c6 + w7*c7 + w8*c8 + w9*c9;
        }

        vec3 noise(vec2 p)
        {
             return texture2D(texture1,p).xyz;
        }

        void main()
        {
             vec2 uv = vtexcoord.xy;
             vec3 tc = vec3(1.0, 0.0, 0.0);

             float DeltaX = 4.0 /screenSize.x;
             float DeltaY = 4.0 /screenSize.y;
             vec2 ox = vec2(DeltaX,0.0);
             vec2 oy = vec2(0.0,DeltaY);
             vec2 PP = uv - oy;
             vec4 C00 = texture2D(texture0,PP - ox);
             vec4 C01 = texture2D(texture0,PP);
             vec4 C02 = texture2D(texture0,PP + ox);
             PP = uv;
             vec4 C10 = texture2D(texture0,PP - ox);
             vec4 C11 = texture2D(texture0,PP);
             vec4 C12 = texture2D(texture0,PP + ox);
             PP = uv + oy;
             vec4 C20 = texture2D(texture0,PP - ox);
             vec4 C21 = texture2D(texture0,PP);
             vec4 C22 = texture2D(texture0,PP + ox);

             float n = noise(1.0*uv).x*abs(offset);
             n = mod(n, 0.111111)/0.111111;
             vec4 result = spline(n,C00,C01,C02,C10,C11,C12,C20,C21,C22);
             tc = result.rgb;

             gl_FragColor = vec4(tc*C11.a,C11.a)*u_color;
        }
    ]=];

    program_set_shader_source("frostShader", vsFrost, fsFrost );
    program_add_parameter("frostShader", PROGRAM_DATA_TYPE_UNIFORM, 44,"u_mvp_matrix");
    program_add_parameter("frostShader", PROGRAM_DATA_TYPE_ATTRIB, 3,"a_position");
    program_add_parameter("frostShader", PROGRAM_DATA_TYPE_TEXTURE, 0,"texture0");
    program_add_parameter("frostShader", PROGRAM_DATA_TYPE_TEXTURE, 0,"texture1");
    program_add_parameter("frostShader", PROGRAM_DATA_TYPE_ATTRIB, 2,"a_tex_coord");
    program_add_parameter("frostShader", PROGRAM_DATA_TYPE_UNIFORM, 4,"u_color");
    program_add_parameter("frostShader", PROGRAM_DATA_TYPE_INDEX, 2,"index");
    program_add_parameter("frostShader", PROGRAM_DATA_TYPE_UNIFORM,1,"offset");
    program_add_parameter("frostShader", PROGRAM_DATA_TYPE_UNIFORM,2,"screenSize");

end

function createFlashShader()
    program_create("flashShader");

    local vsFlash=[=[
        uniform   mat4 u_mvp_matrix;
        attribute vec3 a_position;
        attribute vec2 a_tex_coord;
        varying vec2 vtexcoord;

        void main()
        {
            gl_Position = u_mvp_matrix * vec4(a_position,1.0);
            vtexcoord = a_tex_coord ;
        }
    ]=];

    local fsFlash=[=[
        precision mediump float;
        uniform sampler2D texture0;
        uniform sampler2D texture1;
        uniform vec4 u_color;
        uniform float offset;
        uniform vec3 direction;
        uniform vec4 color;
        uniform float scale;
        uniform vec2 pos;
        varying vec2 vtexcoord;

        void main()
        {   
              //float angle = atan(direction.y/direction.x);
            //mat2 mat; 
            //mat[0][0] = cos(angle); 
            //mat[0][1] = sin(angle);
            //mat[1][0] = -sin(angle);
            //mat[1][1] = cos(angle);
            
            vec3 dir = normalize(vec3(-direction.x,direction.y,0.0));
            dir = dir * 1.7 * scale;
            //dir.xy = dir.xy * mat;
             
            vec2 flashUV = ((vtexcoord-pos)/direction.xy*2.0-1.0) * scale * 0.9;
           // flashUV = flashUV * mat;
            flashUV = flashUV + dir.xy * offset;
            vec4 colorSampler = texture2D(texture1,(flashUV*0.5+0.5))*color;
            vec4 colorBack = texture2D(texture0,vtexcoord);
            gl_FragColor = vec4((colorBack.xyz+sin(((offset+1.0)*1.57)*color.xyz*colorBack.a)*0.1)*u_color.xyz+(colorSampler.xyz*colorBack.a),colorBack.a);
        }
    ]=];

    program_set_shader_source("flashShader", vsFlash, fsFlash );
    program_add_parameter("flashShader", PROGRAM_DATA_TYPE_UNIFORM, 44,"u_mvp_matrix");
    program_add_parameter("flashShader", PROGRAM_DATA_TYPE_ATTRIB, 3,"a_position");
    program_add_parameter("flashShader", PROGRAM_DATA_TYPE_TEXTURE, 0,"texture0");
    program_add_parameter("flashShader", PROGRAM_DATA_TYPE_TEXTURE, 0,"texture1");
    program_add_parameter("flashShader", PROGRAM_DATA_TYPE_ATTRIB, 2,"a_tex_coord");
    program_add_parameter("flashShader", PROGRAM_DATA_TYPE_UNIFORM, 4,"u_color");
    program_add_parameter("flashShader", PROGRAM_DATA_TYPE_INDEX, 2,"index");
    program_add_parameter("flashShader", PROGRAM_DATA_TYPE_UNIFORM, 1,"offset");
    program_add_parameter("flashShader", PROGRAM_DATA_TYPE_UNIFORM, 3,"direction");
    program_add_parameter("flashShader", PROGRAM_DATA_TYPE_UNIFORM, 4,"color");
    program_add_parameter("flashShader", PROGRAM_DATA_TYPE_UNIFORM, 1,"scale");
    program_add_parameter("flashShader", PROGRAM_DATA_TYPE_UNIFORM, 2,"pos");
end


function createVortexShader()
    program_create("vortexShader");

    local vsVortex= [=[
        uniform   mat4 u_mvp_matrix;
        attribute vec3 a_position;
        attribute highp vec2 a_tex_coord;
        varying highp vec2 vtexcoord;

        void main()
        {
            gl_Position = u_mvp_matrix* vec4(a_position,1.0);
            vtexcoord = a_tex_coord;
        }
    ]=];

    local fsVortex=[=[
        precision mediump float;
        uniform sampler2D texture0;
        uniform vec4 u_color;
        uniform float time;
        uniform highp float angle;
        uniform highp float radius;
        varying highp vec2 vtexcoord;

        void main()
        {
            highp vec2 textureCoordinateToUse = vtexcoord;
            highp float dist = distance(vec2(0.5,0.5), vtexcoord);
            textureCoordinateToUse -= vec2(0.5,0.5);
            if (dist < radius)
            {
                highp float percent = (radius - dist) / radius;
                highp float theta = percent * percent * angle * 8.0;
                highp float s = sin(theta);
                highp float c = cos(theta);
                textureCoordinateToUse = vec2(dot(textureCoordinateToUse, vec2(c, -s)), dot(textureCoordinateToUse, vec2(s, c)));
            }
            textureCoordinateToUse += vec2(0.5,0.5);
            vec4 color = texture2D(texture0,textureCoordinateToUse);

            gl_FragColor = color*u_color;
        }
    ]=];

    program_set_shader_source("vortexShader", vsVortex, fsVortex );
    program_add_parameter("vortexShader", PROGRAM_DATA_TYPE_UNIFORM, 44,"u_mvp_matrix");
    program_add_parameter("vortexShader", PROGRAM_DATA_TYPE_ATTRIB, 3,"a_position");
    program_add_parameter("vortexShader", PROGRAM_DATA_TYPE_TEXTURE, 0,"texture0");
    program_add_parameter("vortexShader", PROGRAM_DATA_TYPE_ATTRIB, 2,"a_tex_coord");
    program_add_parameter("vortexShader", PROGRAM_DATA_TYPE_UNIFORM, 4,"u_color");
    program_add_parameter("vortexShader", PROGRAM_DATA_TYPE_INDEX, 2,"index");
    program_add_parameter("vortexShader", PROGRAM_DATA_TYPE_UNIFORM,1,"angle");
    program_add_parameter("vortexShader", PROGRAM_DATA_TYPE_UNIFORM,1,"radius");

end

function createGlowShader()
    program_create("glowShader");

    local vsGlow=[=[
        uniform   mat4 u_mvp_matrix;
        attribute vec3 a_position;
        attribute vec2 a_tex_coord;
        varying vec2 vtexcoord;

        void main()
        {
            gl_Position = u_mvp_matrix * vec4(a_position,1.0);
            vtexcoord = a_tex_coord;
        }
    ]=];

    local fsGlow=[=[
        precision mediump float;
        uniform sampler2D texture0;
        uniform vec4 u_color;
        uniform float time;
        varying vec2 vtexcoord;

        float lookup(vec2 p, float dx, float dy)
        {
             float d = sin(time * 5.0)*0.5 + 1.5;
             vec2 uv = (p.xy + vec2(dx * d/640.0, dy * d/400.0));
             vec4 c = texture2D(texture0, uv.xy);
             return 0.2126*c.r + 0.7152*c.g + 0.0722*c.b;
        }

        void main()
        {
             vec2 p = vtexcoord.xy;

             float gx = 0.0;
             gx += -1.0 * lookup(p, -1.0, -1.0);
             gx += -2.0 * lookup(p, -1.0,  0.0);
             gx +=  1.0 * lookup(p,  1.0, -1.0);
             gx +=  2.0 * lookup(p,  1.0,  0.0);
             gx +=  1.0 * lookup(p,  1.0,  1.0);

             float gy = 0.0;
             gy += -1.0 * lookup(p, -1.0, -1.0);
             gy += -2.0 * lookup(p,  0.0, -1.0);
             gy += -1.0 * lookup(p,  1.0, -1.0);
             gy +=  1.0 * lookup(p, -1.0,  1.0);
             gy +=  2.0 * lookup(p,  0.0,  1.0);
             gy +=  1.0 * lookup(p,  1.0,  1.0);

             float g = (gx*gx + gy*gy)*abs(sin(time));
             //float g2 = g * (sin(time) / 2.0 + 0.5);

             vec4 col = texture2D(texture0, p);
             col += vec4(g, 0.0, 0.0, 1.0);
             gl_FragColor = col*u_color;
        }
    ]=];

    program_set_shader_source("glowShader", vsGlow, fsGlow );
    program_add_parameter("glowShader", PROGRAM_DATA_TYPE_UNIFORM, 44,"u_mvp_matrix");
    program_add_parameter("glowShader", PROGRAM_DATA_TYPE_ATTRIB, 3,"a_position");
    program_add_parameter("glowShader", PROGRAM_DATA_TYPE_TEXTURE, 0,"texture0");
    program_add_parameter("glowShader", PROGRAM_DATA_TYPE_ATTRIB, 2,"a_tex_coord");
    program_add_parameter("glowShader", PROGRAM_DATA_TYPE_UNIFORM, 4,"u_color");
    program_add_parameter("glowShader", PROGRAM_DATA_TYPE_INDEX, 2,"index");
    program_add_parameter("glowShader", PROGRAM_DATA_TYPE_UNIFORM,1,"time");
end


function createMosaicShader()
    program_create("mosaicShader");

    local vsMosaic=[=[
        uniform   mat4 u_mvp_matrix;
        attribute vec3 a_position;
        attribute vec2 a_tex_coord;
        varying vec2 vtexcoord;

        void main()
        {

            gl_Position = u_mvp_matrix * vec4(a_position,1.0);
            vtexcoord = a_tex_coord;
        }
        ]=];

    local fsMosaic=[=[
        precision mediump float;
        uniform sampler2D texture0;
        uniform vec4 u_color;
        uniform float scale;
        varying vec2 vtexcoord;

        void main()
        {
            vec2 uv = vtexcoord;
            vec3 tc = vec3(1.0, 0.0, 0.0);
            float dx = 15.0*(1.0/1280.0)*abs(sin(scale));
            float dy = 10.0*(1.0/800.0)*abs(sin(scale));
            vec2 coord = vec2(dx*floor(uv.x/dx),dy*floor(uv.y/dy));
            tc = texture2D(texture0, coord).rgb;
            gl_FragColor = vec4(tc,1.0)*u_color;
        }
        ]=];

    program_set_shader_source("mosaicShader", vsMosaic, fsMosaic );
    program_add_parameter("mosaicShader", PROGRAM_DATA_TYPE_UNIFORM, 44,"u_mvp_matrix");
    program_add_parameter("mosaicShader", PROGRAM_DATA_TYPE_ATTRIB, 3,"a_position");
    program_add_parameter("mosaicShader", PROGRAM_DATA_TYPE_TEXTURE, 0,"texture0");
    program_add_parameter("mosaicShader", PROGRAM_DATA_TYPE_ATTRIB, 2,"a_tex_coord");
    program_add_parameter("mosaicShader", PROGRAM_DATA_TYPE_UNIFORM, 4,"u_color");
    program_add_parameter("mosaicShader", PROGRAM_DATA_TYPE_INDEX, 2,"index");
end

function createFisheyeShader()
    program_create("fisheyeShader");

    local vsFisheye=[=[
        uniform   mat4 u_mvp_matrix;
        attribute vec3 a_position;
        attribute vec2 a_tex_coord;
        varying vec2 vtexcoord;

        void main()
        {
            gl_Position = u_mvp_matrix * vec4(a_position,1.0);
            vtexcoord =  a_tex_coord ;
        }
    ]=];

    local fsFisheye=[=[
        precision mediump float;
        uniform sampler2D texture0;
        uniform vec4 u_color;
        varying vec2 vtexcoord;

        void main()
        {
            float aperture = 178.0;
            float apertureHalf = 0.5 * aperture * (3.1416 / 180.0);
            float maxFactor = sin(apertureHalf);

            vec2 uv;
            //vec2 xy = 2.0 * (vtexcoord-vec2(0.5,0.5))/0.5 - 1.0;
            vec2 xy = 2.0 * vtexcoord - 1.0;
            float d = length(xy);
            if (d < (2.0-maxFactor))
            {
                d = length(xy * maxFactor);
                float z = sqrt(1.0 - d * d);
                float r = atan(d, z) / 3.1416;
                float phi = atan(xy.y, xy.x);
                //uv.x = r * 0.5 * cos(phi) +0.75;
                //uv.y = r * 0.5 * sin(phi) +0.75;
                uv.x = r * cos(phi) + 0.5;
                uv.y = r * sin(phi) + 0.5;
            }
            else
            {
                uv = vtexcoord;
            }
            vec4 c = texture2D(texture0, uv);
            gl_FragColor = c*u_color;
        }
    ]=];

    program_set_shader_source("fisheyeShader", vsFisheye, fsFisheye );
    program_add_parameter("fisheyeShader", PROGRAM_DATA_TYPE_UNIFORM, 44,"u_mvp_matrix");
    program_add_parameter("fisheyeShader", PROGRAM_DATA_TYPE_ATTRIB, 3,"a_position");
    program_add_parameter("fisheyeShader", PROGRAM_DATA_TYPE_TEXTURE, 0,"texture0");
    program_add_parameter("fisheyeShader", PROGRAM_DATA_TYPE_ATTRIB, 2,"a_tex_coord");
    program_add_parameter("fisheyeShader", PROGRAM_DATA_TYPE_UNIFORM, 4,"u_color");
    program_add_parameter("fisheyeShader", PROGRAM_DATA_TYPE_INDEX, 2,"index");
end

function create_program ()
    createImage2dX();
    createFisheyeShader();
    createMosaicShader();
    createGlowShader();
    createVortexShader();
    createFlashShader();
    createFrostShader();
    createGrayScaleShader();
    createMirrorXAxisShader();
    createMirrorYAxisShader();
    createMirrorXYAxisShader();
    createBlurShaderVertical();
    createBlurShaderHorizontal();
    createMirrorXAtlasShader();
    createMirrorYAtlasShader();
    createMirrorXYAtlasShader();
end


create_program();