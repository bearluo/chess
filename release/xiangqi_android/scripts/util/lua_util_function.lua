



-------------------------------------------------------
-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function lua_string_split(str, split_char)
    local sub_str_tab = {};
    
    while (str) do
        local pos = string.find(str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end
    
    return sub_str_tab;
end

-------------------------------------------------------
-- 参数:测试的秒数
-- 返回:子串表.(含有空串)
function lua_multi_click( t )
    local time = os.time();
    print_string(LUA_MULTI_CLICK_TIME);
    if LUA_MULTI_CLICK_TIME == 0 or time - LUA_MULTI_CLICK_TIME > t then
        LUA_MULTI_CLICK_TIME = time;
        return false;
    end

    return true;
end

-------------------------------------------------------
---作用：截取指定长度的字符串，如果过长，后面加上 传出后缀
-- 参数: 要截取的字符串，长度，后缀
-- 返回: 字符串
function lua_string_sub(str,len,postfix)
    postfix = postfix or "...";

    if not str or str == "" or len <= 0 then
        return postfix;
    end

    local utflen = string.lenutf8(str);
    local sub_str = str;
    if utflen > len then
        sub_str = string.subutf8(str,1,len) .. postfix;
    end 

    return sub_str;   
end




--max_num : 从1到max_num的值
--num_count: 返回值的个数
--返回一串随机值
function lua_get_random_table(max_num,num_count)

    math.randomseed(os.time());
    math.random(max_num); --在很短时间内，第一个值变化不大

    local rt = {}
    for index = 1,num_count do
        rt[index] = math.random(max_num);
    end
    return rt
end

--给出一个概率分布表，和一个随机值，算出在哪个区间
--概率分布表，随机数
--return 区间的索引
function lua_get_region_by_random_num(pro_table,random_num)
    local max = 1;
    for index,value in pairs(pro_table) do
        max = max + value;
        if random_num < max then
            return index;
        end
    end

    return 0;
end

--事件统计
function on_event_stat( str )

    sys_set_int("win32_console_color",10);
    print_string("on_event_stat = " .. str);
    sys_set_int("win32_console_color",9);

    dict_set_string(ON_EVENT_STAT , ON_EVENT_STAT .. kparmPostfix , str);
    call_native(ON_EVENT_STAT);
end

function share_text_msg( str )
    print_string("share_text_msg = " .. str);
    dict_set_string(SHARE_TEXT_MSG , SHARE_TEXT_MSG .. kparmPostfix , str);
    call_native(SHARE_TEXT_MSG);
end

function share_img_msg( str )
    print_string("share_img_msg = " .. str);
    dict_set_string(SHARE_IMG_MSG , SHARE_IMG_MSG .. kparmPostfix , str);
    call_native(SHARE_IMG_MSG);
end

--截屏
function take_screen_shot( str )
    print_string("take_screen_shot = " .. str);
    dict_set_string(TAKE_SCREEN_SHOT , TAKE_SCREEN_SHOT .. kparmPostfix , str);
    call_native(TAKE_SCREEN_SHOT);
end

function to_web_page( url )
    print_string("to_web_page = " .. url);
    dict_set_string(TO_WEB_PAGE , TO_WEB_PAGE .. kparmPostfix , url);
    call_native(TO_WEB_PAGE);
end