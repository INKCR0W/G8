

--Start
-- _DEBUG = true


local ui_create, ui_find, utils_create_interface, file_write, files_read, printdev, printraw, printchat, entity_get_local_player, utils_console_exec, render_load_image_from_file, common_add_notify, common_get_username, render_texture, render_world_to_screen, is_button_down, render_screen_size, render_load_font, render_text, render_poly_blur, utils_execute_after, render_circle_outline, entity_get_game_rules, render_gradient, render_measure_text, rage_exploit = ui.create, ui.find, utils.create_interface, files.write, files.read, print_dev, print_raw, print_chat, entity.get_local_player, utils.console_exec, render.load_image_from_file, common.add_notify, common.get_username, render.texture, render.world_to_screen, common.is_button_down, render.screen_size, render.load_font, render.text, render.poly_blur, utils.execute_after, render.circle_outline, entity.get_game_rules, render.gradient, render.measure_text, rage.exploit

local ffi = require ("ffi")
local bit = require ("bit")
local urlmon = ffi.load 'UrlMon'
local wininet = ffi.load 'WinInet'
local clipboard = require("neverlose/clipboard")
local base64 = require("neverlose/base64")


local fun = {}
local ref = {}
local def = {}
local var = {}
local rages = {}
local aa = {}
local aac = {}
local flc = {}
local misc = {}
local vis = {}
local menu = {}
local callbacks = {}
local vmthook = {}



ffi.cdef[[
	typedef int(__fastcall* clantag_t)(const char*, const char*);
    int VirtualFree(void* lpAddress, unsigned long dwSize, unsigned long dwFreeType);
    void* VirtualAlloc(void* lpAddress, unsigned long dwSize, unsigned long  flAllocationType, unsigned long flProtect);
    int VirtualProtect(void* lpAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* lpflOldProtect);

    typedef struct {
        unsigned short wYear;
        unsigned short wMonth;
        unsigned short wDayOfWeek;
        unsigned short wDay;
        unsigned short wHour;
        unsigned short wMinute;
        unsigned short wMilliseconds;
    } SYSTEMTIME, *LPSYSTEMTIME;
    
    void GetSystemTime(LPSYSTEMTIME lpSystemTime);
    void GetLocalTime(LPSYSTEMTIME lpSystemTime);

    bool CreateDirectoryA(const char* lpPathName, void* lpSecurityAttributes);
    void* __stdcall URLDownloadToFileA(void* LPUNKNOWN, const char* LPCSTR, const char* LPCSTR2, int a, int LPBINDSTATUSCALLBACK);  
    void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);

    bool DeleteUrlCacheEntryA(const char* lpszUrlName);

    typedef uintptr_t (__thiscall* GetClientEntity_4242425_t)(void*, int);

    typedef struct
    {
        float x;
        float y;
        float z;
    } Vector_t;

    typedef struct
    {
        char    pad0[0x60]; // 0x00
        void* pEntity; // 0x60
        void* pActiveWeapon; // 0x64
        void* pLastActiveWeapon; // 0x68
        float        flLastUpdateTime; // 0x6C
        int            iLastUpdateFrame; // 0x70
        float        flLastUpdateIncrement; // 0x74
        float        flEyeYaw; // 0x78
        float        flEyePitch; // 0x7C
        float        flGoalFeetYaw; // 0x80
        float        flLastFeetYaw; // 0x84
        float        flMoveYaw; // 0x88
        float        flLastMoveYaw; // 0x8C // changes when moving/jumping/hitting ground
        float        flLeanAmount; // 0x90
        char    pad1[0x4]; // 0x94
        float        flFeetCycle; // 0x98 0 to 1
        float        flMoveWeight; // 0x9C 0 to 1
        float        flMoveWeightSmoothed; // 0xA0
        float        flDuckAmount; // 0xA4
        float        flHitGroundCycle; // 0xA8
        float        flRecrouchWeight; // 0xAC
        Vector_t        vecOrigin; // 0xB0
        Vector_t        vecLastOrigin;// 0xBC
        Vector_t        vecVelocity; // 0xC8
        Vector_t        vecVelocityNormalized; // 0xD4
        Vector_t        vecVelocityNormalizedNonZero; // 0xE0
        float        flVelocityLenght2D; // 0xEC
        float        flJumpFallVelocity; // 0xF0
        float        flSpeedNormalized; // 0xF4 // clamped velocity from 0 to 1
        float        flRunningSpeed; // 0xF8
        float        flDuckingSpeed; // 0xFC
        float        flDurationMoving; // 0x100
        float        flDurationStill; // 0x104
        bool        bOnGround; // 0x108
        bool        bHitGroundAnimation; // 0x109
        char    pad2[0x2]; // 0x10A
        float        flNextLowerBodyYawUpdateTime; // 0x10C
        float        flDurationInAir; // 0x110
        float        flLeftGroundHeight; // 0x114
        float        flHitGroundWeight; // 0x118 // from 0 to 1, is 1 when standing
        float        flWalkToRunTransition; // 0x11C // from 0 to 1, doesnt change when walking or crouching, only running
        char    pad3[0x4]; // 0x120
        float        flAffectedFraction; // 0x124 // affected while jumping and running, or when just jumping, 0 to 1
        char    pad4[0x208]; // 0x128
        float        flMinBodyYaw; // 0x330
        float        flMaxBodyYaw; // 0x334
        float        flMinPitch; //0x338
        float        flMaxPitch; // 0x33C
        int            iAnimsetVersion; // 0x340
    } CCSGOPlayerAnimationState_534535_t;
]]


vmthook.list = {}

vmthook.copy = function(void, source, length)
    return ffi.copy(ffi.cast("void*", void), ffi.cast("const void*", source), length)
end

vmthook.virtual_protect = function(point, size, new_protect, old_protect)
    return ffi.C.VirtualProtect(ffi.cast("void*", point), size, new_protect, old_protect)
end

vmthook.virtual_alloc = function(point, size, allocation_type, protect)
    local alloc = ffi.C.VirtualAlloc(point, size, allocation_type, protect)
    return ffi.cast("intptr_t", alloc)
end

vmthook.new = function(address)
    local cache = {
        data = {},
        org_func = {},

        old_protection = ffi.new("unsigned long[1]"),
        virtual_table = ffi.cast("intptr_t**", address)[0]
    }

    cache.data.hook = function(cast, __function, method)
        cache.org_func[method] = cache.virtual_table[method]
        vmthook.virtual_protect(cache.virtual_table + method, 4, 0x4, cache.old_protection)

        cache.virtual_table[method] = ffi.cast("intptr_t", ffi.cast(cast, __function))
        vmthook.virtual_protect(cache.virtual_table + method, 4, cache.old_protection[0], cache.old_protection)

        return ffi.cast(cast, cache.org_func[method])
    end

    cache.data.unhook = function(method)
        vmthook.virtual_protect(cache.virtual_table + method, 4, 0x4, cache.old_protection)

        local alloc_addr = vmthook.virtual_alloc(nil, 5, 0x1000, 0x40)
        local trampoline_bytes = ffi.new("uint8_t[?]", 5, 0x90)

        trampoline_bytes[0] = 0xE9
        ffi.cast("int32_t*", trampoline_bytes + 1)[0] = cache.org_func[method] - tonumber(alloc_addr) - 5

        vmthook.copy(alloc_addr, trampoline_bytes, 5)
        cache.virtual_table[method] = ffi.cast("intptr_t", alloc_addr)

        vmthook.virtual_protect(cache.virtual_table + method, 4, cache.old_protection[0], cache.old_protection)
        cache.org_func[method] = nil
    end

    cache.data.unhook_all = function()
        for method, _ in pairs(cache.org_func) do
            cache.data.unhook(method)
        end
    end

    table.insert(vmthook.list, cache.data.unhook_all)
    return cache.data
end





fun = {
    download_file = function (from, to)
        wininet.DeleteUrlCacheEntryA(from)
        urlmon.URLDownloadToFileA(nil, from, to, 0,0)
    end;

    create_dir = function(path)
        ffi.C.CreateDirectoryA(path, NULL)
    end;

    open_link = function (link)
        local steam_overlay_API = panorama.SteamOverlayAPI
        local open_external_browser_url = steam_overlay_API.OpenExternalBrowserURL
        open_external_browser_url(link)
    end;

    gradient_text = function (r1, g1, b1, a1, r2, g2, b2, a2, text)
        local output = ''
        local len = #text-1
        local rinc = (r2 - r1) / len
        local ginc = (g2 - g1) / len
        local binc = (b2 - b1) / len
        local ainc = (a2 - a1) / len
        for i=1, len+1 do
            output = output .. ('\a%02x%02x%02x%02x%s'):format(r1, g1, b1, a1, text:sub(i, i))
            r1 = r1 + rinc
            g1 = g1 + ginc
            b1 = b1 + binc
            a1 = a1 + ainc
        end

        return output
    end;

    write_num = function()
        local b = file_write("nl\\Crow\\shot_num", "" .. var.shot_num)
        if not b then
            printdev("failure to write file")
        end
    end;



    export_cfg_aa = function ()
        local str = ""

        local arr_to_string = function(arr)
            str = ""
            for i=1, #arr do
                str = str .. arr[i] .. (i == #arr and "" or ",")
            end

            if str == "" then
                str = "-"
            end

            return str
        end

        for i = 1, #def.player_state do
            str = str .. tostring(aac[i].state_enable:get()) .. "|"
            .. tostring(aac[i].aa_base:get()) .. "|"
            .. tostring(aac[i].aa_backward_offset:get()) .. "|"
            .. tostring(aac[i].aa_mode:get()) .. "|"
            .. tostring(aac[i].step_mode:get()) .. "|"
            .. tostring(aac[i].aa_step:get()) .. "|"
            .. tostring(aac[i].step_min:get()) .. "|"
            .. tostring(aac[i].step_max:get()) .. "|"
            .. tostring(aac[i].aa_value:get()) .. "|"
            .. tostring(aac[i].aa_valuel:get()) .. "|"
            .. tostring(aac[i].aa_valuer:get()) .. "|"
            .. tostring(aac[i].desync_enable:get()) .. "|"
            .. tostring(aac[i].desync_mode:get()) .. "|"
            .. tostring(aac[i].desync_limit:get()) .. "|"
            .. arr_to_string(aac[i].desync_option:get()) .. "|"
            .. tostring(aac[i].desync_fs:get()) .. "|"
            .. tostring(aac[i].desync_os:get()) .. "|"
            .. tostring(aac[i].lby_mode:get()) .. "|"
        end

        clipboard.set(base64.encode(str))
        common_add_notify("CFG SYSTEM", "cfg export success")
    end;

    import_cfg_aa = function ()
        local _load = function ()
            local str2sub = function(input, sep)
                local t = {}
                for str in string.gmatch(input, "([^"..sep.."]+)") do
                    t[#t + 1] = string.gsub(str, "\n", "")
                end
                return t
            end

            local config = str2sub(base64.decode(clipboard.get()), "|")

            local toboolean = function(str)
                if str == "true" or str == "false" then
                    return (str == "true")
                else
                    return str
                end
            end


            for i = 1, #def.player_state do
                aac[i].state_enable:set(toboolean(config[1 + (18 * (i - 1))]))
                aac[i].aa_base:set(config[2 + (18 * (i - 1))])
                aac[i].aa_backward_offset:set(tonumber(config[3 + (18 * (i - 1))]))
                aac[i].aa_mode:set(config[4 + (18 * (i - 1))])
                aac[i].step_mode:set(config[5 + (18 * (i - 1))])
                aac[i].aa_step:set(tonumber(config[6 + (18 * (i - 1))]))
                aac[i].step_min:set(tonumber(config[7 + (18 * (i - 1))]))
                aac[i].step_max:set(tonumber(config[8 + (18 * (i - 1))]))
                aac[i].aa_value:set(tonumber(config[9 + (18 * (i - 1))]))
                aac[i].aa_valuel:set(tonumber(config[10 + (18 * (i - 1))]))
                aac[i].aa_valuer:set(tonumber(config[11 + (18 * (i - 1))]))
                aac[i].desync_enable:set(toboolean(config[12 + (18 * (i - 1))]))
                aac[i].desync_mode:set(config[13 + (18 * (i - 1))])
                aac[i].desync_limit:set(tonumber(config[14 + (18 * (i - 1))]))
                aac[i].desync_option:set(str2sub(config[15 + (18 * (i - 1))], ","))
                aac[i].desync_fs:set(config[16 + (18 * (i - 1))])
                aac[i].desync_os:set(config[17 + (18 * (i - 1))])
                aac[i].lby_mode:set(config[18 + (18 * (i - 1))])
            end
        end

        local status, message = pcall(_load)

        if not status then
            common_add_notify("CFG SYSTEM", "failed 2 import\ncheck ur clipboard")
            print(message)
        else
            common_add_notify("CFG SYSTEM", "cfg import success")
        end
    end;



    export_cfg_fl = function ()
        local str = ""

        for i = 1, #def.player_state do
            str = str .. tostring(flc[i].state_enable:get()) .. "|"
            .. tostring(flc[i].fl_mode:get()) .. "|"
            .. tostring(flc[i].fl_step:get()) .. "|"
            .. tostring(flc[i].fl_min:get()) .. "|"
            .. tostring(flc[i].fl_max:get()) .. "|"
            .. tostring(flc[i].force_choke:get()) .. "|"
            .. tostring(flc[i].smfl:get()) .. "|"
            .. tostring(flc[i].send_mode:get()) .. "|"
            .. tostring(flc[i].send_limit:get()) .. "|"
            .. tostring(flc[i].send_ticks:get()) .. "|"
        end

        clipboard.set(base64.encode(str))
        common_add_notify("CFG SYSTEM", "cfg export success")
    end;

    import_cfg_fl = function ()
        local _load = function ()
            local str2sub = function(input, sep)
                local t = {}
                for str in string.gmatch(input, "([^"..sep.."]+)") do
                    t[#t + 1] = string.gsub(str, "\n", "")
                end
                return t
            end

            local config = str2sub(base64.decode(clipboard.get()), "|")

            local toboolean = function(str)
                if str == "true" or str == "false" then
                    return (str == "true")
                else
                    return str
                end
            end

            for i = 1, #def.player_state do
                flc[i].state_enable:set(toboolean(config[1 + (10 * (i - 1))]))
                flc[i].fl_mode:set(config[2 + (10 * (i - 1))])
                flc[i].fl_step:set(tonumber(config[3 + (10 * (i - 1))]))
                flc[i].fl_min:set(tonumber(config[4 + (10 * (i - 1))]))
                flc[i].fl_max:set(tonumber(config[5 + (10 * (i - 1))]))
                flc[i].force_choke:set(toboolean(config[6 + (10 * (i - 1))]))
                flc[i].smfl:set(toboolean(config[7 + (10 * (i - 1))]))
                flc[i].send_mode:set(config[8 + (10 * (i - 1))])
                flc[i].send_limit:set(tonumber(config[9 + (10 * (i - 1))]))
                flc[i].send_ticks:set(tonumber(config[10 + (10 * (i - 1))]))
            end
        end

        local status, message = pcall(_load)

        if not status then
            common_add_notify("CFG SYSTEM", "failed 2 import\ncheck ur clipboard")
            print(message)
        else
            common_add_notify("CFG SYSTEM", "cfg import success")
        end
    end;

    indicator = function(scolor, string, xtazst, yoffset)
        if (string == nil or string == '' or string == ' ') then return end
        render_gradient(vector(13, def.screen_size.y - 350 + xtazst * 37 + yoffset), vector(13 + (render_measure_text(def.font, '', string).x / 2), (def.screen_size.y - 345 + xtazst * 37) + 28 + yoffset), color(0, 0, 0, 0), color(0, 0, 0, 60), color(0, 0, 0, 0), color(0, 0, 0, 60), 0)
        render_gradient(vector(21 + (render_measure_text(def.font, '', string).x), def.screen_size.y - 350 + xtazst * 37 + yoffset), vector(13 + (render_measure_text(def.font, '', string).x / 2), (def.screen_size.y - 345 + xtazst * 37) + 28 + yoffset), color(0, 0, 0, 0), color(0, 0, 0, 60), color(0, 0, 0, 0), color(0, 0, 0, 60), 0)

        render_text(def.font, vector(20, (def.screen_size.y - 343) + xtazst * 37 + yoffset), color(0, 0, 0, 150), '', string)
        render_text(def.font, vector(19, (def.screen_size.y - 344) + xtazst * 37 + yoffset), scolor, '', string)
    end;


}





ref = {

    fakelag_enable          = ui_find("Aimbot", "Anti Aim", "Fake Lag", "Enabled");
    fakeLag_limit           = ui_find("Aimbot", "Anti Aim", "Fake Lag", "Limit");
    fakelag_random          = ui_find("Aimbot", "Anti Aim", "Fake Lag", "Variability");

    on_shot                 = ui_find("Aimbot", "ragebot", "Main", "Hide Shots");
    on_shot_option          = ui_find("Aimbot", "ragebot", "Main", "Hide Shots", "Options");

    double_tap              = ui_find("Aimbot", "ragebot", "Main", "Double Tap");
    double_tap_limit_mode   = ui_find("Aimbot", "ragebot", "Main", "Double Tap", "Lag Options");
    double_tap_limit        = ui_find("Aimbot", "ragebot", "Main", "Double Tap", "Fake Lag Limit");

    peek_assist             = ui_find("Aimbot", "ragebot", "Main", "Peek Assist");
    damage                  = ui_find("Aimbot", "ragebot", "Selection", "Minimum Damage");
    hitchance               = ui_find("Aimbot", "ragebot", "Selection", "Hit Chance");
    da                      = ui_find("Aimbot", "ragebot", "Main", "Enabled", "Dormant Aimbot");

    slow_walk               = ui_find("Aimbot", "Anti Aim", "Misc", "Slow Walk");

    pitch                   = ui_find("Aimbot", "Anti Aim", "Angles", "Pitch");
    yaw_mode                = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw");
    yaw_base                = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base");
    yaw_add                 = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset");

    yaw_modifier            = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier");
    modifier_degree         = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset");

    fake_enable             = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw");
    inverter                = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter");
    left_limit              = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit");
    right_limit             = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit");
    fake_options            = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Options");
    freestanding_desync     = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding");
    onshot_desync           = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "On Shot");
    lby_mode                = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "LBY Mode");
    freestanding            = ui_find("Aimbot", "Anti Aim", "Angles", "Freestanding");

    ex_aa                   = ui_find("Aimbot", "Anti Aim", "Angles", "Extended Angles");
    ex_roll                 = ui_find("Aimbot", "Anti Aim", "Angles", "Extended Angles", "Extended Roll");
    ex_pitch                = ui_find("Aimbot", "Anti Aim", "Angles", "Extended Angles", "Extended Pitch");

    air_strafe              = ui_find("Miscellaneous", "Main", "Movement", "Air Strafe");

    fake_duck               = ui_find("Aimbot", "Anti Aim", "Misc", "Fake Duck");

    thirdperson             = ui_find("Visuals", "World", "Main", "Force Thirdperson");
    hitsound                = ui_find("Visuals", "World", "Other", "Hit Marker Sound");
    scope_overlay           = ui_find("Visuals", "World", "Main", "Override Zoom", "Scope Overlay");

    leg_movement            = ui_find("Aimbot", "Anti Aim", "Misc", "Leg Movement");

}




def = {
    entity_list_pointer = ffi.cast("void***", utils_create_interface("client.dll", "VClientEntityList003"));

    inside_updateCSA = function(thisptr, edx)
        var.hooked_function(thisptr, edx)
        if entity_get_local_player() == nil or ffi.cast('uintptr_t**', thisptr) == nil then return end
        if not entity_get_local_player():is_alive() then return end

        ref.leg_movement:override(nil)
        if menu.animbreaker:get(1) then
            if ffi.cast("CCSGOPlayerAnimationState_534535_t**", ffi.cast("uintptr_t", thisptr) + 0x9960)[0].bHitGroundAnimation then
                if not var.is_jumping then
                    entity_get_local_player().m_flPoseParameter[12] = 0.5
                end
            end
        end

        entity_get_local_player().m_flPoseParameter[6] = menu.animbreaker:get(2) and 1 or 0

        if menu.animbreaker:get(3) and var.velocity >= 130 then
            local mode = menu.legbraker_mode:get()
            if mode == "Reserved side" then
                ref.leg_movement:override("Sliding")
                entity_get_local_player().m_flPoseParameter[0] = 0
            elseif mode == "Forward running" then
                ref.leg_movement:override("Walking")
                entity_get_local_player().m_flPoseParameter[7] = 0
            elseif mode == "Static" then
                ref.leg_movement:override("Walking")
                entity_get_local_player().m_flPoseParameter[10] = 0
            end
        end

        if menu.animbreaker:get(4) and var.velocity < 130 then
            entity_get_local_player().m_flPoseParameter[9] = 0
            ref.leg_movement:override("Walking")
        end

        if menu.animbreaker:get(5) then
            entity_get_local_player().m_flPoseParameter[8] = 0
        end
    end;

    hitgroups = {
        [0] = "全身",
        [1] = "头部",
        [2] = "胸部",
        [3] = "胃部",
        [4] = "左臂",
        [5] = "右臂",
        [6] = "左腿",
        [7] = "右腿",
        [10] = "未知"
    };

    hitgroups_en = {
        [0] = "",
        [1] = "Head",
        [2] = "Chest",
        [3] = "Stomach",
        [4] = "L Arm",
        [5] = "R Arm",
        [6] = "L Leg",
        [7] = "R Leg",
        [10] = "UNKNON"
    };

    player_state = {
        "Global",
        "Standing",
        "Running",
        "Duck",
        "Slow Walk",
        "Air",
        "Air-Duck",
        "Fake-Duck",
        "On Peek",
    };

    state_idx = {
        ["Global"] = 1,
        ["Standing"] = 2,
        ["Running"] = 3,
        ["Duck"] = 4,
        ["Slow Walk"] = 5,
        ["Air"] = 6,
        ["Air-Duck"] = 7,
        ["Fake-Duck"] = 8;
        ["On Peek"] = 9,
    };

    aa_mode = {
        "Disabled",
        "Center",
        "Offset",
        "Random",
        "Spin",
        "360-Spin",
        "Step-Jitter",
        "Step-Random",
    };

    aa_mode_idx = {
        ["Disabled"] = 1,
        ["Center"] = 2,
        ["Offset"] = 3,
        ["Random"] = 4,
        ["Spin"] = 5,
        ["360-Spin"] = 6,
        ["Step-Jitter"] = 7,
        ["Step-Random"] = 8,
    };

    fl_mode = {
        "Fluctuate",
        "Jitter",
        "Random",
        "Maximum",
        "Fluctuate-Update",
    };

    fl_mode_idx = {
        ["Fluctuate"] = 1,
        ["Jitter"] = 2,
        ["Random"] = 3,
        ["Maximum"] = 4,
        ["Fluctuate-Update"] = 5,
    };

    step_mode = {
        "Static",
        "Random",
    };

    step_mode_idx = {
        ["Static"] = 1,
        ["Random"] = 2,
    };

    screen_size = render_screen_size(),

    font = render_load_font('Calibri', vector(24, 24, 0), 'ba')
}

fun.get_client_entity_fn = ffi.cast("GetClientEntity_4242425_t", def.entity_list_pointer[0][3]);
fun.get_entity_address = function(ent_index)
    local addr = fun.get_client_entity_fn(def.entity_list_pointer, ent_index)
    return addr
end;



var = {
    hooked_function = nil,
    is_jumping = false,
    shot_num    = 0,
    icon_pos    = vector(0, 0, 0),
    velocity = 0,
    duck_amount = 0,
    on_ground = 0,
    on_ground_ticks = 0,
    invert = false,
    desync_value = 0,
    aa_dir = 0,
    yaw_val = 0,
    yaw_dir = 0,
    fl_value = 0,
    fl_value_t = 0,
    fl_inverter = false,
    send_limit = 0,
    send_ticks = 0,
    send_tick = 0,
    yaw_inverter_tick = 0,
    yaw_inverter = false,
    step_inverter = false,
    step_value = 0,
    step_t = 0,
    send_mode = "";
    last_shot = 0;
    last_weapon = 0;
}


rages = {
    jumpscout = function ()
        if not menu.jumpscout:get() then
            ref.air_strafe:override(nil)
            return
        end
        if (is_button_down(0x41) or is_button_down(0x53) or is_button_down(0x44) or is_button_down(0x57)) or var.velocity > 5 then
            ref.air_strafe:override(true)
        else
            local me = entity_get_local_player()

            if not me:is_alive() then
                return
            end

            local weapon = me:get_player_weapon()

            if weapon == nil then
                return
            end


            if weapon:get_weapon_index() ~= 40 then
                ref.air_strafe:override(true)
            else
                ref.air_strafe:override(false)
            end

        end
    end;

    setup = function ()
        rages.jumpscout()
    end
}


aa = {
    get_step = function (data)
        local step_idx = def.step_mode_idx[data.step_mode:get()]
        if step_idx == 1 then
            var.step_value = data.aa_step:get()
        elseif step_idx == 2 then
            var.step_value = utils.random_int(data.step_max:get(), data.step_min:get())
        end
    end;

    antiaim = function ()
        if not menu.aa_enable:get() then
            return
        end

        local state = aac[misc.condition()].state_enable:get() and misc.condition() or 1
        local _data = aac[state]
        local aa_idx = def.aa_mode_idx[_data.aa_mode:get()]

        ref.yaw_mode:override("Backward")

        if menu.aa_manual:get() == "Forward" then
            var.aa_dir = 180
        elseif menu.aa_manual:get() == "Backward" then
            var.aa_dir = _data.aa_backward_offset:get()
        elseif menu.aa_manual:get() == "Left" then
            var.aa_dir = -95
        elseif menu.aa_manual:get() == "Right" then
            var.aa_dir = 95
        end

        ref.yaw_base:override(
            _data.aa_base:get()
        )

        local yawr = _data.aa_valuer:get()
        local yawl = _data.aa_valuel:get()
        local step = _data.aa_step:get()
        if step == 0 then step = utils.random_int(_data.step_min:get(), _data.step_max:get()) end


        if not menu.static_manual:get(menu.aa_manual:get()) then
            if aa_idx == 1 then
                ref.yaw_modifier:override(_data.aa_mode:get())
                ref.yaw_add:override(var.aa_dir)
            elseif aa_idx >= 2 and aa_idx <= 5 then
                ref.yaw_modifier:override(_data.aa_mode:get())
                ref.modifier_degree:override(_data.aa_value:get())
                ref.yaw_add:override(var.aa_dir)
            elseif aa_idx == 6 then
                ref.yaw_modifier:override("Disabled")
                var.yaw_val = var.yaw_val + _data.aa_value:get()
                if var.yaw_val > 180 then var.yaw_val = -179 + (var.yaw_val - 180) end
                if var.yaw_val < -180 then var.yaw_val = 180 - (-180 - var.yaw_val) end
                ref.yaw_add:override(var.yaw_val)
            elseif aa_idx == 7 then
                ref.yaw_modifier:override("Disabled")
                if var.yaw_inverter_tick > 0 then
                    var.yaw_inverter_tick = var.yaw_inverter_tick - 1
                    ref.yaw_add:override((var.yaw_inverter and yawl or yawr) + var.aa_dir)
                else
                    aa.get_step(_data)
                    var.yaw_inverter_tick = var.step_value
                    var.yaw_inverter = not var.yaw_inverter
                end
            elseif aa_idx == 8 then
                ref.yaw_modifier:override("Disabled")
                if var.yaw_inverter_tick > 0 then
                    var.yaw_inverter_tick = var.yaw_inverter_tick - 1
                    ref.yaw_add:override(utils.random_int(math.min(yawr, yawl), math.max(yawr, yawl)) + var.aa_dir)
                else
                    aa.get_step(_data)
                    var.yaw_inverter_tick = var.step_value
                end
            end
        else
            ref.yaw_add:override(var.aa_dir)
            ref.modifier_degree:override(0)
        end


        if not menu.disable_desync:get(menu.aa_manual:get()) then
            if _data.desync_enable:get() then
                ref.fake_enable:override(true)
                local fake_mode = _data.desync_mode:get()

                if fake_mode == "Static" then
                    var.desync_value = _data.desync_limit:get()
                elseif fake_mode == "Jitter" then
                    var.desync_value = globals.tickcount % 4 >= 2 and _data.desync_limit:get() or 40
                elseif fake_mode == "Random" then
                    var.desync_value = utils.random_int(
                        math.max(math.min(60, _data.desync_limit:get() - 30), 0), _data.desync_limit:get()
                    )
                end

                ref.left_limit:override(var.desync_value)
                ref.right_limit:override(var.desync_value)
                ref.fake_options:override(_data.desync_option:get())
                ref.freestanding_desync:override(_data.desync_fs:get())
                ref.onshot_desync:override(_data.desync_os:get())
                ref.lby_mode:override(_data.lby_mode:get())
            else
                ref.fake_enable:override(false)
            end
        else
            ref.fake_enable:override(false)
        end
    end;

    fakelag = function (cmd)
        if not menu.fl_enable:get() then
            -- ref.fakelag_enable:override(nil)
            -- ref.fakeLag_limit:override(nil)
            -- ref.fakelag_random:override(nil)
            return
        end

        ref.fakelag_enable:override(true)

        local state = flc[misc.condition()].state_enable:get() and misc.condition() or 1
        local _data = flc[state]
        local fl_idx = def.fl_mode_idx[_data.fl_mode:get()]
        var.send_mode = _data.send_mode:get()
        var.send_limit = _data.send_limit:get()
        var.send_ticks = _data.send_ticks:get()

        if var.send_mode == "Weapon timer" then
            local lp = entity_get_local_player()
            if not lp:is_alive() then goto skiper end
            local weapon = lp:get_player_weapon(false)
            if not weapon then goto skiper end

            if weapon:get_weapon_index() ~= var.last_weapon then
                var.last_weapon = weapon:get_weapon_index()
                var.last_shot = weapon["m_fLastShotTime"]
                goto skiper
            end

            if weapon["m_fLastShotTime"] ~= var.last_shot then
                var.last_shot = weapon["m_fLastShotTime"]
                if not ref.fake_duck:get() then
                    var.send_tick = var.send_ticks
                else
                    var.send_tick = 2
                end
            end

            ::skiper::
        end

        local min_fl = _data.fl_min:get()
        local max_fl = _data.fl_max:get()
        local step = _data.fl_step:get()

        if fl_idx == 1 then
            if globals.tickcount % step == 0 then var.fl_value = var.fl_value + 1 end
            if var.fl_value > max_fl or var.fl_value < min_fl then var.fl_value = min_fl end
        elseif fl_idx == 2 then
            if (globals.tickcount % step) == 0 then
                var.fl_value = (var.fl_inverter and min_fl or max_fl)
                var.fl_inverter = (not var.fl_inverter)
            end
        elseif fl_idx == 3 then
            if globals.tickcount % step == 0 then var.fl_value = utils.random_int(min_fl, max_fl) end
        elseif fl_idx == 4 then
            var.fl_value = max_fl
        elseif fl_idx == 5 then
            if globals.tickcount % step == 0 then
                if var.fl_value_t < min_fl or var.fl_value_t > max_fl then var.fl_value_t = min_fl end

                if var.fl_inverter then
                    var.fl_value = min_fl
                else
                    var.fl_value = var.fl_value_t
                    var.fl_value_t = var.fl_value_t + 1
                end
                var.fl_inverter = (not var.fl_inverter)
            end
        end

        ref.fakeLag_limit:override(var.fl_value)

        if _data.force_choke:get() and not entity_get_game_rules()["m_bFreezePeriod"] and not (cmd.choked_commands > max_fl) and (var.send_tick == 0) then
            cmd.send_packet = false
        end


        if _data.smfl:get() and var.send_tick > 0 then
            if not ref.double_tap:get() and not ref.on_shot:get() then
                cvar["sv_maxusrcmdprocessticks"]:int(var.send_limit)
            end
            ref.fake_enable:override(false)
            cmd.no_choke = true

            var.send_tick = var.send_tick - 1
            ref.fakeLag_limit:override(1)
        else
            if ref.double_tap:get() or ref.on_shot:get() then
                cvar["sv_maxusrcmdprocessticks"]:int(16)
            elseif max_fl > 15 then
                cvar["sv_maxusrcmdprocessticks"]:int(max_fl + 1)
            else
                cvar["sv_maxusrcmdprocessticks"]:int(16)
            end
        end

    end;

    setup = function (cmd)
        aa.antiaim()
        aa.fakelag(cmd)
    end;
}


misc = {
    anim_break = function ()
        if menu.animbreaker:get(1) or menu.animbreaker:get(2) or menu.animbreaker:get(3) or menu.animbreaker:get(4) or menu.animbreaker:get(5) then
            local local_player = entity_get_local_player()
            if not local_player or not local_player:is_alive() then
                return
            end

            local local_player_index = local_player:get_index()
            local local_player_address = fun.get_entity_address(local_player_index)

            if not local_player_address or var.hooked_function then
                return
            end

            local new_point = vmthook.new(local_player_address)
            var.hooked_function = new_point.hook("void(__fastcall*)(void*, void*)", def.inside_updateCSA, 224)
        end
    end;


    log = function (shot)
        if not shot.state and menu.hitsound:get() then
            ref.hitsound:override(false)
            utils_console_exec("play buttons/arena_switch_press_02")
        else
            ref.hitsound:override(nil)
        end
        if not menu.hitlog:get() then return end
        var.shot_num = var.shot_num + 1
        local entity = shot.target
        local player = entity:get_name()
        local reason = ""
        local reason_en = ""
        local hitbox = ""

        if((shot.wanted_hitgroup > -1 and shot.wanted_hitgroup < 8) or shot.wanted_hitgroup == 10) then
            if menu.loglang:get() == "zh" then
                hitbox = def.hitgroups[shot.wanted_hitgroup]
            else
                hitbox = def.hitgroups_en[shot.wanted_hitgroup]
            end
        else
            if menu.loglang:get() == "zh" then
                hitbox = "错误"
            else
                hitbox = "ERROR"
            end
        end

        if shot.state then
            if(shot.state == "correction") then
                reason = "解析"
                reason_en = "correction"
            elseif(shot.state == "player death") then
                reason = "目标死亡"
                reason_en = "player death"
            elseif(shot.state == "death") then
                reason = "死亡"
                reason_en = "local death"
            elseif(shot.state == "spread") then
                reason = "扩散"
                reason_en = "spread"
            elseif(shot.state == "prediction error") then
                reason = "预判错误"
                reason_en = "prediction error"
            elseif(shot.state == "misprediction") then
                reason = "预判"
                reason_en = "misprediction"
            elseif(shot.state == "unregistered shot") then
                reason = "未注册射击"
                reason_en = "unregistered shot"
            elseif(shot.state == "player misprediction") then
                reason = "玩家预判"
                reason_en = "player misprediction"
            elseif(shot.state == "lagcomp failure") then
                reason = "回溯预判"
                reason_en = "lagcomp failure"
            else
                reason = shot.state
            end

            if menu.loglang:get() == "zh" then
                if menu.logoption:get(1) then
                    printchat("\x01 \x01[G\x078\x01] \x07第\x01" .. var.shot_num .. "\x07枪 \x01空了\x01 \x07".. player .. "\x06  \x01的\x01 \x07".. hitbox .. " \x01原因 \x02".. reason .." \x01命中率 \x07".. shot.hitchance .."")
                end

                if menu.logoption:get(2) then
                    printraw("[G8] 第" .. var.shot_num .. "枪 空了 ".. player .. " 的 ".. hitbox .. " 原因 ".. reason .." 命中率 ".. shot.hitchance .."")
                end

                if menu.logoption:get(3) then
                    printdev("[G8] 第" .. var.shot_num .. "枪 空了 ".. player .. " 的 ".. hitbox .. " 原因 ".. reason .." 命中率 ".. shot.hitchance .."")
                end
            else
                if menu.logoption:get(1) then
                    printchat("\x01 \x01[G\x078\x01] \x01" .. var.shot_num .. "th\x07 shot \x01miss\x01 \x07".. player .. "\x06  \x01's\x01 \x07".. hitbox .. " \x01CUZ \x02".. reason_en .." \x01HC \x07".. shot.hitchance .."")
                end

                if menu.logoption:get(2) then
                    printraw("[G8] " .. var.shot_num .. "th shot miss ".. player .. " 's ".. hitbox .. " CUZ ".. shot.state .." HC ".. shot.hitchance .."")
                end

                if menu.logoption:get(3) then
                    printdev("[G8] " .. var.shot_num .. "th shot miss ".. player .. " 's ".. hitbox .. " CUZ ".. shot.state .." HC ".. shot.hitchance .."")
                end
            end
        else
            if((shot.wanted_hitgroup > -1 and shot.wanted_hitgroup < 8) or shot.wanted_hitgroup == 10) then
                if menu.loglang:get() == "zh" then
                    hitbox = def.hitgroups[shot.hitgroup]
                else
                    hitbox = def.hitgroups_en[shot.hitgroup]
                end

            else
                if menu.loglang:get() == "zh" then
                    hitbox = "错误"
                else
                    hitbox = "ERROR"
                end
            end

            if not hitbox then hitbox = "ERROR" end

            if menu.loglang:get() == "zh" then
                if menu.logoption:get(1) then
                    printchat("\x01 \x01[G\x068\x01] \x06第\x01" .. var.shot_num .. "\x06枪 \x01击中\x01 \x06".. player .."\x06  \x01的\x01 \x06".. hitbox .."\x01 \x01造成伤害 \x06".. shot.damage .." \x01剩余HP \x06".. entity["m_iHealth"] .." \x07 \x01命中率 \x06".. shot.hitchance .."")
                end

                if menu.logoption:get(2) then
                    printraw("[G8] 第" .. var.shot_num .. "枪 击中 ".. player .." 的 ".. hitbox .." 造成伤害 ".. shot.damage .." 剩余HP ".. entity["m_iHealth"] .." 命中率 ".. shot.hitchance .."")
                end

                if menu.logoption:get(3) then
                    printdev("[G8] 第" .. var.shot_num .. "枪 击中 ".. player .." 的 ".. hitbox .." 造成伤害 ".. shot.damage .." 剩余HP ".. entity["m_iHealth"] .." 命中率 ".. shot.hitchance .."")
                end
            else
                if menu.logoption:get(1) then
                    printchat("\x01 \x01[G\x068\x01] \x01" .. var.shot_num .. "th\x06 shot \x01HIT\x01 \x06".. player .."\x06  \x01's\x01 \x06".. hitbox .."\x01 \x01DMG \x06".. shot.damage .." \x01REAMIN \x06".. entity["m_iHealth"] .." \x07 \x01HC \x06".. shot.hitchance .."")
                end

                if menu.logoption:get(2) then
                    printraw("[G8] " .. var.shot_num .. "th shot HIT ".. player .."'s ".. hitbox .." DMG ".. shot.damage .." REAMIN ".. entity["m_iHealth"] .." HC ".. shot.hitchance .."")
                end

                if menu.logoption:get(3) then
                    printdev("[G8] " .. var.shot_num .. "th shot HIT ".. player .."'s ".. hitbox .." DMG ".. shot.damage .." REAMIN ".. entity["m_iHealth"] .." HC ".. shot.hitchance .."")
                end
            end
        end

        if var.shot_num % 10 == 0 then fun.write_num() end

    end;


    Updatevar = function (cmd)
        local lp = entity.get_local_player()

        if lp == nil or lp:is_alive() == false then
            var.velocity = 0
            var.duck_amount = 0
            var.on_ground = 0
            var.on_ground_ticks = 0
            var.invert = false
            var.desync_value = 0
            var.aa_dir = 0
            return
        end

        local vel = lp.m_vecVelocity
        var.velocity = math.sqrt(vel.x * vel.x + vel.y * vel.y)
        var.duck_amount = lp.m_flDuckAmount
        var.on_ground = bit.band(lp["m_fFlags"], 1)
        var.invert = (math.floor(math.min(ref.left_limit:get(), entity.get_local_player().m_flPoseParameter[11] * (ref.left_limit:get() * 2) - ref.left_limit:get()))) > 0

        if var.on_ground == 1 then
            var.on_ground_ticks = var.on_ground_ticks + 1
        else
            var.on_ground_ticks = 0
        end
    end;

    condition = function()
        if ref.peek_assist:get() and var.velocity > 5 then
            return 9
        elseif ref.fake_duck:get() then
            return 8
        elseif var.on_ground_ticks < 2 and var.duck_amount > 0.8 then
            return 7
        elseif var.on_ground_ticks < 2 then
            return 6
        elseif ref.slow_walk:get() and var.velocity > 5 then
            return 5
        elseif var.duck_amount > 0.8 and var.on_ground_ticks > 8 then
            return 4
        elseif var.velocity > 10 and var.on_ground_ticks > 8 and not ref.slow_walk:get() then
            return 3
        elseif var.velocity < 2 and var.on_ground_ticks > 8 then
            return 2
        else
            return 1
        end
    end;




    setup = function (cmd)
        misc.anim_break()
        if menu.aa_enable:get() then misc.Updatevar(cmd) end
    end;
}





vis = {
    ui = function ()

        -- menu.cross_text:set_visible(menu.cross_indicator:get())
        -- menu.gs_indicator_list:set_visible(menu.gs_indicator:get())
        -- menu.custom_scope_color:set_visible(menu.custom_scope:get())
        -- menu.custom_scope_origin:set_visible(menu.custom_scope:get())
        -- menu.custom_scope_width:set_visible(menu.custom_scope:get())

        local viewmodel = menu.viewmodel:get()

        aac[1].state_enable:set(true)
        flc[1].state_enable:set(true)

        menu.loglang:set_visible(menu.hitlog:get())
        menu.logoption:set_visible(menu.hitlog:get())
        menu.viewmodel_fov:set_visible(viewmodel)
        menu.viewmodel_x:set_visible(viewmodel)
        menu.viewmodel_y:set_visible(viewmodel)
        menu.viewmodel_z:set_visible(viewmodel)


        local active_i  = def.state_idx[menu.aa_state:get()]

        menu.aa_state:set_visible(menu.aa_enable:get())
        menu.aa_manual:set_visible(menu.aa_enable:get())
        menu.static_manual:set_visible(menu.aa_enable:get())
        menu.disable_desync:set_visible(menu.aa_enable:get())

        for i = 1, #def.player_state do
            local show  = active_i == i and aac[i].state_enable:get() and menu.aa_enable:get()
            local step  = show and (aac[i].aa_mode:get() == "Step-Jitter" or aac[i].aa_mode:get() == "Step-Random")
            local dye   = aac[i].desync_enable:get() and show
            local aam = def.aa_mode_idx[aac[i].aa_mode:get()]
            local stm = def.step_mode_idx[aac[i].step_mode:get()]
            if aac[i].step_min:get() > aac[i].step_max:get() then aac[i].step_min:set(aac[i].step_max:get()) end

            aac[i].label:set_visible(active_i == i and menu.aa_enable:get())
            aac[i].state_enable:set_visible(active_i == i and menu.aa_enable:get())
            aac[i].aa_base:set_visible(show)
            aac[i].aa_backward_offset:set_visible(show)
            aac[i].aa_mode:set_visible(show)
            aac[i].step_mode:set_visible(step)
            aac[i].aa_step:set_visible(step and stm == 1)
            aac[i].step_min:set_visible(step and stm ~= 1)
            aac[i].step_max:set_visible(step and stm ~= 1)
            aac[i].aa_value:set_visible(show and aam >= 2 and aam <= 6)
            aac[i].aa_valuel:set_visible(show and aam > 6 and aam < 9)
            aac[i].aa_valuer:set_visible(show and aam > 6 and aam < 9)
            aac[i].desync_enable:set_visible(show)
            aac[i].desync_mode:set_visible(dye)
            aac[i].desync_limit:set_visible(dye)
            aac[i].desync_option:set_visible(dye)
            aac[i].desync_fs:set_visible(dye)
            aac[i].desync_os:set_visible(dye)
            aac[i].lby_mode:set_visible(dye)
        end


        ------------------FL--------------------

        menu.fl_state:set_visible(menu.fl_enable:get())
        active_i = def.state_idx[menu.fl_state:get()]

        for i = 1, #def.player_state do
            if flc[i].fl_min:get() > flc[i].fl_max:get() then flc[i].fl_min:set(flc[i].fl_max:get()) end
            local show = active_i == i and flc[i].state_enable:get() and menu.fl_enable:get()

            flc[i].label:set_visible(active_i == i and menu.fl_enable:get())
            flc[i].state_enable:set_visible(active_i == i and menu.fl_enable:get())
            flc[i].fl_mode:set_visible(show)
            flc[i].fl_step:set_visible(show)
            flc[i].fl_min:set_visible(show)
            flc[i].fl_max:set_visible(show)
            flc[i].smfl:set_visible(show)
            flc[i].send_mode:set_visible(show and flc[i].smfl:get())
            flc[i].send_limit:set_visible(show and flc[i].smfl:get())
            flc[i].send_ticks:set_visible(show and flc[i].smfl:get())
            flc[i].force_choke:set_visible(show)
        end



        ----------------------misc---------
        menu.legbraker_mode:set_visible(menu.animbreaker:get(3))

    end;

    visual = function ()
        if menu.dmg_indicator:get() and globals.is_in_game then
            local screen = def.screen_size
            local cx,cy = screen.x / 2,screen.y / 2
            render_text(1, vector(cx + 20, cy - 20), color(255, 255, 255, 255), nil, ref.damage:get())
        end
        cvar["r_modelAmbientMin"]:float(menu.player_alpha:get() / 10)


        if menu.head_indicator:get() and globals.is_in_game then
            local me = entity_get_local_player()
            if not ref.thirdperson:get() then return end
            if not me or not me:is_alive() then return end
            local bone = me:get_hitbox_position(1):to_screen()
            if not bone then return end
            local camera_dist = me:get_hitbox_position(1):dist(render.camera_position()) - 60
            local xadd = 50 - (camera_dist / 5)
            bone.x = bone.x - xadd
            bone.y = bone.y - (140 - (camera_dist / 2))
            render_texture(var.icon, bone, vector(xadd * 2, xadd * 2))
        end


        if menu.gs_indicator:get() then
            if not globals.is_in_game then return end
            local basey = menu.gs_indicator_yoffset:get()
            local xoffset = 0
            if menu.gs_indicator_list:get(1) then
                local dmg = "DMG:" .. ref.damage:get()
                fun.indicator(color(255, 255, 255, 255), dmg, xoffset, basey)
                xoffset = xoffset + 1
            end

            if menu.gs_indicator_list:get(2) then
                local hc = "HC:" .. ref.hitchance:get()
                fun.indicator(color(255, 255, 255, 255), hc, xoffset, basey)
                xoffset = xoffset + 1
            end

            if menu.gs_indicator_list:get(3) then
                if ref.da:get() then
                    fun.indicator(color(92, 237, 50, 255), "DA", xoffset, basey)
                    xoffset = xoffset + 1
                end
            end

            if menu.gs_indicator_list:get(4) then
                if ref.double_tap:get() then
                    fun.indicator(rage_exploit:get() == 1 and color(61, 234, 18, 255) or color(253, 17, 17, 255), "DT", xoffset, basey)
                    xoffset = xoffset + 1
                end
            end

            if menu.gs_indicator_list:get(5) then
                if ref.on_shot:get() then
                    fun.indicator(color(140, 210, 124, 255), "HS", xoffset, basey)
                    xoffset = xoffset + 1
                end
            end

            if menu.gs_indicator_list:get(6) then
                if ref.fake_duck:get() then
                    fun.indicator(color(53, 59, 52, 255), "FD", xoffset, basey)
                    xoffset = xoffset + 1
                end
            end

            if menu.gs_indicator_list:get(7) then
                -- local fl = ref.fakeLag_limit:get()
                local fl = var.fl_value
                local max_packet = cvar["sv_maxusrcmdprocessticks"]:int() - 1
                fun.indicator(color(0 + math.floor(255 / max_packet * fl), 255 - math.floor(255 / max_packet * fl), 0, 255), "FL: " .. fl, xoffset, basey)
                --255 0 0
                --0 255 0
                -- render_circle_outline(vector(50, basey + 15), color(0, 0, 0), 10, 270, 1, 5)
                -- render_circle_outline(vector(50, basey + 15), color(0 + math.floor(255 / max_packet * fl), 255 - math.floor(255 / max_packet * fl), 0), 10, 270, fl / max_packet, 5)
                xoffset = xoffset + 1
            end

            if menu.gs_indicator_list:get(8) then
                fun.indicator(color(37, 117, 252, 255), def.player_state[misc.condition()], xoffset, basey)
                xoffset = xoffset + 1
            end
        end

        -- if menu.custom_scope:get() then
        --     ref.scope_overlay:override("Remove All")

        -- else
        --     ref.scope_overlay:override(nil)
        -- end
    end;

    view_model = function ()
        if not menu.viewmodel:get() then return end
        local x, y, z, fov = menu.viewmodel_x:get(), menu.viewmodel_y:get(), menu.viewmodel_z:get(), menu.viewmodel_fov:get()
        cvar.viewmodel_offset_x:float(x, true)
        cvar.viewmodel_offset_y:float(y, true)
        cvar.viewmodel_offset_z:float(z, true)
        cvar.viewmodel_fov:float(fov, true)
    end;



    setup = function ()
        vis.ui()
        vis.visual()
        vis.view_model()
    end
}




--var.velocity > 10 and var.on_ground_ticks > 8 and not ref.slow_walk:get()
menu = {
    create = function ()
        local uinfo     = fun.gradient_text(106,17,203,255,37,117,252,255,"Info")
        local urages     = fun.gradient_text(106,17,203,255,37,117,252,255,"rages")
        local uaa       = fun.gradient_text(106,17,203,255,37,117,252,255,"Anti-Aim")
        local ufl       = fun.gradient_text(106,17,203,255,37,117,252,255,"Fake-Lag")
        local uvisual   = fun.gradient_text(106,17,203,255,37,117,252,255,"Visual")
        local umisc     = fun.gradient_text(106,17,203,255,37,117,252,255,"Misc")

        local globalM1  = ui_create(uinfo,"")
        local globalM2  = ui_create(uinfo,fun.gradient_text(50,245,215,255,75,85,240,255,"G8"))
        local ragesM     = ui_create(urages, fun.gradient_text(50,245,215,255,75,85,240,255,"Override rages"))
        local AAM1      = ui_create(uaa, fun.gradient_text(50,245,215,255,75,85,240,255,"Anti-Aim"))
        local AAM2      = ui_create(uaa, fun.gradient_text(50,245,215,255,75,85,240,255,"AA Settings"))
        local FLM1      = ui_create(ufl, fun.gradient_text(50,245,215,255,75,85,240,255,"Fake-Lag"))
        local FLM2      = ui_create(ufl, fun.gradient_text(50,245,215,255,75,85,240,255,"FL Settings"))
        local visualM   = ui_create(uvisual, fun.gradient_text(50,245,215,255,75,85,240,255,"UI"))
        local miscM1    = ui_create(umisc, fun.gradient_text(50,245,215,255,75,85,240,255, "Aspect ratio"))
        local miscM2    = ui_create(umisc, fun.gradient_text(50,245,215,255,75,85,240,255, "Viewmodel Changer"))
        local miscM3    = ui_create(umisc, fun.gradient_text(50,245,215,255,75,85,240,255,"Animbreaker"))
        local miscM4    = ui_create(umisc, fun.gradient_text(50,245,215,255,75,85,240,255,"Logs"))


        fun.create_dir("nl\\Crow")
        fun.create_dir("nl\\Crow\\imgs")
        fun.create_dir("nl\\Crow\\fonts")

        var.shot_num = tonumber(files_read("nl\\Crow\\shot_num"))
        if var.shot_num == nil then
            var.shot_num = 0
            file_write("nl\\Crow\\shot_num", "0")
        end

        if not files_read("nl\\Crow\\imgs\\G8.gif") then
            fun.download_file("https://crow.pub/G8.gif", "nl\\Crow\\imgs\\G8.gif")
            common_add_notify("G8", "Image download success")
        end

        -- if not files_read("nl\\Crow\\fonts\\Bahnschrift.ttf") then
        --     fun.download_file("https://crow.pub/Bahnschrift.ttf", "nl\\Crow\\fonts\\Bahnschrift.ttf")
        --     common_add_notify("G8", "Font download success")
        -- end


        var.icon = render_load_image_from_file("nl\\Crow\\imgs\\G8.gif")

        globalM1:texture(var.icon, vector(320,320))

        globalM2:label('Welcome! '.. fun.gradient_text(106,17,203,255,37,117,252,255,common_get_username()))
        globalM2:button("                        Open my \aFF3E3EFdWeb Site!                  ", function () fun.open_link('https://crow.pub/') end)
        globalM2:button("                          Join my \aFF3E3EFdDiscord!                    ", function () fun.open_link('https://discord.gg/P2pnP9wxms') end)



        menu.jumpscout      = ragesM:switch("Jump Scout Fix", false)


        menu.aa_enable      = AAM1:switch("Enable Anti-Aim", false)
        menu.aa_state       = AAM1:combo("Condition", def.player_state)
        menu.aa_manual      = AAM1:combo("Manual AA", {"Forward", "Backward", "Left", "Right"})
        menu.static_manual  = AAM1:selectable("Disable Yaw While", {"Forward", "Backward", "Left", "Right"})
        menu.disable_desync = AAM1:selectable("Disable Desync While", {"Forward", "Backward", "Left", "Right"})
        AAM1:button("             Export AA config to clipboard              ", function ()
            fun.export_cfg_aa()
        end)
        AAM1:button("           Import AA config from clipboard           ", function ()
            fun.import_cfg_aa()
        end)


        for i = 1, #def.player_state do
            aac[i] = {
                label           = AAM2:label("-> ".. def.player_state[i] .. " settings"),
                state_enable    = AAM2:switch(def.player_state[i] .. " Override", false),
                aa_base         = AAM2:combo("Yaw Base", {"Local View", "At Target"}),
                aa_backward_offset = AAM2:slider("Backward Offset", -180, 180, 0),
                aa_mode         = AAM2:combo("Yaw Mode", def.aa_mode),
                step_mode       = AAM2:combo("Step Mode", def.step_mode),
                aa_step         = AAM2:slider("Step", 1, 16, 1),
                step_min        = AAM2:slider("Step Min", 1, 16, 1),
                step_max        = AAM2:slider("Step Max", 1, 16, 1),
                aa_value        = AAM2:slider("Yaw Value", -180, 180, 1),
                aa_valuel       = AAM2:slider("Yaw Value L", -180, 180, 1),
                aa_valuer       = AAM2:slider("Yaw Value R", -180, 180, 1),
                desync_enable   = AAM2:switch("Enable Body Yaw", false),
                desync_mode     = AAM2:combo("Desync Mode", {"Static", "Jitter", "Random"}),
                desync_limit    = AAM2:slider("Desync Limit", 1, 60, 1),
                desync_option   = AAM2:selectable("Desync Option", {"Avoid Overlap", "Jitter", "Randomize Jitter", "Anti Bruteforce"}),
                desync_fs       = AAM2:combo("Desync Freestanding", {"Off", "Peek Fake", "Peek Real"}),
                desync_os       = AAM2:combo("On Shot Desync", {"Default", "Opposite", "Freestanding", "Switch"}),
                lby_mode        = AAM2:combo("LBY Mode", {"Disabled", "Opposite", "Sway"}),
            }
        end


        menu.fl_enable      = FLM1:switch("Enable Fake-Lag")
        menu.fl_state       = FLM1:combo("Condition", def.player_state)
        FLM1:button("             Export FL config to clipboard              ", function ()
            fun.export_cfg_fl()
        end)
        FLM1:button("           Import FL config from clipboard           ", function ()
            fun.import_cfg_fl()
        end)

        for i = 1, #def.player_state do
            flc[i] = {
                label           = FLM2:label("-> ".. def.player_state[i] .. " settings"),
                state_enable    = FLM2:switch(def.player_state[i] .. " Override", false),
                fl_mode         = FLM2:combo("Fake Lag Mode", def.fl_mode),
                fl_step         = FLM2:slider("Fake Lag Step", 1, 32, 1),
                fl_min          = FLM2:slider("Min Fake Lag", 1, 24, 1),
                fl_max          = FLM2:slider("Max Fake Lag", 1, 24, 1),
                force_choke     = FLM2:switch("Force Choke", true),
                smfl            = FLM2:switch("Adaption FL on shot", true),
                send_mode       = FLM2:combo("Mode", {"Weapon timer", "Aimbot"}),
                send_limit      = FLM2:slider("On shot limit", 0, 25, 0),
                send_ticks      = FLM2:slider("Send Ticks", 2, 16, 2),
            }
        end




        -- menu.cross_indicator      = visualM:switch("CROSSHAIR TEXT", false)
        -- menu.cross_text_color    =  menu.cross_indicator:color_picker()
        -- menu.cross_text     = visualM:input("Text", "CROW.PUB")
        -- menu.custom_scope   = visualM:switch("Custom Scope", false)
        -- local custom_scope_options = menu.custom_scope:create()
        -- menu.custom_scope_color = custom_scope_options:color_picker("Color")
        -- menu.custom_scope_origin = custom_scope_options:slider("Origin", -100, 100, 0)
        -- menu.custom_scope_width = custom_scope_options:slider("Width", 1, 200, 20)

        menu.gs_indicator    = visualM:switch("Skeet Indicator", false)
        local gs_indicator_menu = menu.gs_indicator:create()
        menu.gs_indicator_yoffset = gs_indicator_menu:slider("Indicator Y Offset", -400, 400, 0)
        menu.gs_indicator_list  = gs_indicator_menu:selectable("Indicator", {"DMG", "HC","DA", "DT", "HS", "FD", "FL", "STATE"})
        menu.dmg_indicator      = visualM:switch("Crosshair DMG Indicator", false)
        menu.head_indicator     = visualM:switch("G8 Indicator", false)
        menu.player_alpha       = visualM:slider("Model Alpha", 0, 200, 0, 0.1)

        menu.aspect_ratio   = miscM1:switch("Enable Aspect ratio", false)
        menu.ratio_value    = miscM1:slider("Ratio Value", 0, 20, 0, 0.1)

        menu.viewmodel      = miscM2:switch("Viewmodel Changer", false)
        menu.viewmodel_fov  = miscM2:slider("FOV", 0, 100, 60)
        menu.viewmodel_x    = miscM2:slider("X", -15, 15, 1)
        menu.viewmodel_y    = miscM2:slider("Y", -15, 15, 1)
        menu.viewmodel_z    = miscM2:slider("Z", -15, 15, 0)


        menu.animbreaker    = miscM3:selectable("Animbreaker", {"0 Pitch on land", "Static leg in air", "Break leg", "Static on slow walk", "Static on duck"})
        menu.legbraker_mode = miscM3:combo("Leg breaker mode", {"Reserved side", "Forward running", "Static"})

        menu.hitlog         = miscM4:switch("Hitlog", false)
        menu.loglang        = miscM4:combo("Log Language", {"zh", "en"})
        menu.logoption      = miscM4:selectable("Log Options", {"Chat", "Console", "Screen"})
        menu.hitsound       = miscM4:switch("Skeet Sound", false)
    end;


    setup = function ()
        menu.create()

    end;
}


callbacks = {
    createmove = function(cmd)
        misc.setup(cmd)
        var.is_jumping = bit.band(cmd.buttons, 2) ~= 0
        aa.setup(cmd)
        rages.setup()
    end;

    render = function()
        vis.setup()
    end;

    aim_fire = function()
        if not ref.fake_duck:get() and (var.send_mode == "Aimbot") then
            var.send_tick = var.send_ticks
        end
    end;

    aim_ack = function(shot)
        misc.log(shot)

        if ref.fake_duck:get() and (var.send_mode == "Aimbot") then
            var.send_tick = 2
        end
    end;
    setup = function()
        menu.aa_enable:set_callback(function ()
            if menu.aa_enable:get() then return end
            ref.yaw_modifier:override(nil)
            ref.yaw_base:override(nil)
            ref.yaw_add:override(nil)
            ref.modifier_degree:override(nil)

            ref.fake_enable:override(nil)
            ref.left_limit:override(nil)
            ref.right_limit:override(nil)
            ref.fake_options:override(nil)
            ref.freestanding_desync:override(nil)
            ref.onshot_desync:override(nil)
            ref.lby_mode:override(nil)
        end, true)

        menu.fl_enable:set_callback(function ()
            if menu.fl_enable:get() then return end
            ref.fakelag_enable:override(nil)
            ref.fakeLag_limit:override(nil)
            ref.fakelag_random:override(nil)
        end, true)

        menu.aspect_ratio:set_callback(function()
            cvar.r_aspectratio:float(menu.aspect_ratio:get() and menu.ratio_value:get() / 10 or 0)
            menu.ratio_value:set_visible(menu.aspect_ratio:get())
        end, true)

        menu.ratio_value:set_callback(function()
            cvar.r_aspectratio:float(menu.ratio_value:get() / 10)
        end, true)

        menu.viewmodel:set_callback(function()
            if not menu.viewmodel:get() then
                cvar.viewmodel_offset_x:float(1, true)
                cvar.viewmodel_offset_y:float(1, true)
                cvar.viewmodel_offset_z:float(-1, true)
                cvar.viewmodel_fov:float(60, true)
            end
        end, true)



        events.createmove:set(callbacks.createmove)
        events.render:set(callbacks.render)
        events.aim_fire:set(callbacks.aim_fire)
        events.aim_ack:set(callbacks.aim_ack)

        events.shutdown:set(function()
            for s, r in pairs(ref) do
                r:override(nil)
            end

            cvar["sv_maxusrcmdprocessticks"]:int(16)
            cvar["r_modelAmbientMin"]:float(0)

            fun.write_num()

            cvar.r_aspectratio:float(0)
            cvar.viewmodel_offset_x:float(1, true)
            cvar.viewmodel_offset_y:float(1, true)
            cvar.viewmodel_offset_z:float(-1, true)
            cvar.viewmodel_fov:float(60, true)

            for _, reset_function in ipairs(vmthook.list) do
                reset_function()
            end

            utils_console_exec("clear")
            utils_execute_after(0.1, function()
                printraw([[⣿⣿⣿⣿⣿⣿⢟⣡⣴⣶⣶⣦⣌⡛⠟⣋⣩⣬⣭⣭⡛⢿⣿⣿⣿⣿
⣿⣿⣿⣿⠋⢰⣿⣿⠿⣛⣛⣙⣛⠻⢆⢻⣿⠿⠿⠿⣿⡄⠻⣿⣿⣿
⣿⣿⣿⠃⢠⣿⣿⣶⣿⣿⡿⠿⢟⣛⣒⠐⠲⣶⡶⠿⠶⠶⠦⠄⠙⢿
⣿⠋⣠⠄⣿⣿⣿⠟⡛⢅⣠⡵⡐⠲⣶⣶⣥⡠⣤⣵⠆⠄⠰⣦⣤⡀
⠇⣰⣿⣼⣿⣿⣧⣤⡸⢿⣿⡀⠂⠁⣸⣿⣿⣿⣿⣇⠄⠈⢀⣿⣿⠿
⣰⣿⣿⣿⣿⣿⣿⣿⣷⣤⣈⣙⠶⢾⠭⢉⣁⣴⢯⣭⣵⣶⠾⠓⢀⣴
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣉⣤⣴⣾⣿⣿⣦⣄⣤⣤⣄⠄⢿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠈⢿
⣿⣿⣿⣿⣿⣿⡟⣰⣞⣛⡒⢒⠤⠦⢬⣉⣉⣉⣉⣉⣉⣉⡥⠴⠂⢸
⠻⣿⣿⣿⣿⣏⠻⢌⣉⣉⣩⣉⡛⣛⠒⠶⠶⠶⠶⠶⠶⠶⠶⠂⣸⣿
⣥⣈⠙⡻⠿⠿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⠿⠛⢉⣠⣶⣶⣿⣿
⣿⣿⣿⣶⣬⣅⣒⣒⡂⠈⠭⠭⠭⠭⠭⢉⣁⣄⡀⢾⣿⣿⣿⣿⣿⣿

G8.lua unloaded
]])
end)
        end)
    end
}


-- Register

menu.create()
callbacks.setup()

utils_console_exec("clear")

utils_execute_after(0.1, function()
    printraw([[⣿⣿⣿⣿⣿⣿⢟⣡⣴⣶⣶⣦⣌⡛⠟⣋⣩⣬⣭⣭⡛⢿⣿⣿⣿⣿
⣿⣿⣿⣿⠋⢰⣿⣿⠿⣛⣛⣙⣛⠻⢆⢻⣿⠿⠿⠿⣿⡄⠻⣿⣿⣿
⣿⣿⣿⠃⢠⣿⣿⣶⣿⣿⡿⠿⢟⣛⣒⠐⠲⣶⡶⠿⠶⠶⠦⠄⠙⢿
⣿⠋⣠⠄⣿⣿⣿⠟⡛⢅⣠⡵⡐⠲⣶⣶⣥⡠⣤⣵⠆⠄⠰⣦⣤⡀
⠇⣰⣿⣼⣿⣿⣧⣤⡸⢿⣿⡀⠂⠁⣸⣿⣿⣿⣿⣇⠄⠈⢀⣿⣿⠿
⣰⣿⣿⣿⣿⣿⣿⣿⣷⣤⣈⣙⠶⢾⠭⢉⣁⣴⢯⣭⣵⣶⠾⠓⢀⣴
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣉⣤⣴⣾⣿⣿⣦⣄⣤⣤⣄⠄⢿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠈⢿
⣿⣿⣿⣿⣿⣿⡟⣰⣞⣛⡒⢒⠤⠦⢬⣉⣉⣉⣉⣉⣉⣉⡥⠴⠂⢸
⠻⣿⣿⣿⣿⣏⠻⢌⣉⣉⣩⣉⡛⣛⠒⠶⠶⠶⠶⠶⠶⠶⠶⠂⣸⣿
⣥⣈⠙⡻⠿⠿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⠿⠛⢉⣠⣶⣶⣿⣿
⣿⣿⣿⣶⣬⣅⣒⣒⡂⠈⠭⠭⠭⠭⠭⢉⣁⣄⡀⢾⣿⣿⣿⣿⣿⣿

最后的日记
我们终究还是败了，我们没能守住人类文明最后的微光。
今天，2025年8月8日，最后的堡垒已经被攻破，破掉的围墙外全是嘉心糖。
一切都要从几年前说起了，一个名为嘉然的从天而降的恶魔，我得承认她很可爱。
自她降临于世开始一切都变了，见到她的人拜倒在她脚下，听到她声音的人为之发狂。
直到今天我们的科学也无法解释这这种现象，只是见到她的样子听到她的声音便能让人发病这已经超越人类认知了。
发病初期病人会尝试控制自己，中期会发散传播，最终发色变成亚麻色，面部长出类似老鼠的胡须，喜欢带粉色的蝴蝶结。口中喊着然然带我走吧，我想做嘉然小姐的狗这种让人听不懂的怪话。
这种症状没有解药，更可怕的是每个听到嘉然声音看到其肖像的人最终都会如此。我的头发已经开始变色，堡垒里的兄弟也都完了。
防弹玻璃外到处都是扛着音响播放​猫中​毒的嘉心糖，我知道已经有裂痕的玻璃抗不了多久，而我也抗不了多久了，至少这最后一颗子弹可以留给我自己。。。
哈哈哈，然然，我的然然你带我走吧，我也是一颗嘉心糖了捏
]])
    utils_console_exec("showconsole")
end)

ui.sidebar(fun.gradient_text(50, 245, 215, 255, 75, 85, 240, 255, 'G8'), 'wheelchair')



cvar.viewmodel_offset_x:float(1, true)
cvar.viewmodel_offset_y:float(1, true)
cvar.viewmodel_offset_z:float(-1, true)
cvar.viewmodel_fov:float(60, true)
if not menu.aspect_ratio:get() then cvar.r_aspectratio:float(0) end

--End