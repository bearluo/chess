--ChesssociatyModuleConstant.lua
--Date 2016.8.26
--棋社模块常量
--endregion

ChesssociatyModuleConstant = {}

ChesssociatyModuleConstant.ROLE_GM = 1
ChesssociatyModuleConstant.ROLE_VP = 2
ChesssociatyModuleConstant.ROLE_MEMBER = 3


ChesssociatyModuleConstant.s_manager_active = 
{
    ["OP_TO_VP"]           = "to_vp",           --转让副会长
    ["OP_ADD_VP"]          = "add_vp",          --添加副会长
    ["OP_DEL_VP"]          = "del_vp",          --删除副会长
    ["OP_DEL_MEMBER"]      = "del_member",      --退出棋社广播
    ["OP_ADD_MEMBER"]      = "add_member",      --加入棋社成功广播
    ["OP_REFUSE_MEMBER"]   = "refuse_member",   --拒绝成员申请
    ["OP_APPLY_MEMBER"]    = "apply_member",    --申请加入
    ["OP_TO_GM"]           = "to_gm",           --转让会长
}

ChesssociatyModuleConstant.role = 
{
    "会长",
    "副会长",
    "社员",
}

ChesssociatyModuleConstant.join_type = 
{
    {icon = "common/background/sociaty_join_bg1.png",text = "不可加入"},
    {icon = "common/background/sociaty_join_bg1.png",text = "申请加入"},
    {icon = "common/background/sociaty_join_bg2.png",text = "直接加入"},
}

ChesssociatyModuleConstant.sociaty_icon = 
{
    {file = "sociaty_about/b_cannon.png",name = "b_cannon",index = 1},
    {file = "sociaty_about/b_car.png",name = "b_car",index = 2},
    {file = "sociaty_about/b_elephant.png",name = "b_elephant",index = 3},
    {file = "sociaty_about/b_horse.png",name = "b_horse",index = 4},
    {file = "sociaty_about/b_scholar.png",name = "b_scholar",index = 5},
    {file = "sociaty_about/r_cannon.png",name = "r_cannon",index = 6},
    {file = "sociaty_about/r_car.png",name = "r_car",index = 7},
    {file = "sociaty_about/r_elephant.png",name = "r_elephant",index = 8},
    {file = "sociaty_about/r_horse.png",name = "r_horse",index = 9},
    {file = "sociaty_about/r_scholar.png",name = "r_scholar",index = 10},
}