-- EXTERN START

local ui_create, ui_find, utils_create_interface, files_write, files_read, printdev, printraw, printchat, entity_get_local_player, utils_console_exec, render_load_image_from_file, common_add_notify, common_get_username, render_texture, render_world_to_ , is_button_down, render_screen_size, render_load_font, render_text, render_poly_blur, utils_execute_after, render_circle_outline, entity_get_game_rules, render_gradient, render_measure_text, rage_exploit, ui_get_icon, files_get_crc32, ui_get_alpha, common_reload_script, files_create_folder, math_sqrt, string_sub, utils_random_int, entity_get_players, utils_net_channel, utils_get_vfunc, bit_band, bit_lshift, entity_get, entity_get_entities, render_camera_angles, common_get_unixtime, network_get, common_get_system_time = ui.create, ui.find, utils.create_interface, files.write, files.read, print_dev, print_raw, print_chat, entity.get_local_player, utils.console_exec, render.load_image_from_file, common.add_notify, common.get_username, render.texture, render.world_to_screen, common.is_button_down, render.screen_size, render.load_font, render.text, render.poly_blur, utils.execute_after, render.circle_outline, entity.get_game_rules, render.gradient, render.measure_text, rage.exploit, ui.get_icon, files.get_crc32, ui.get_alpha, common.reload_script, files.create_folder, math.sqrt, string.sub, utils.random_int, entity.get_players, utils.net_channel, utils.get_vfunc, bit.band, bit.lshift, entity.get, entity.get_entities, render.camera_angles, common.get_unixtime, network.get, common.get_system_time

local ffi = require ("ffi")
local bit = require ("bit")
local urlmon = ffi.load "UrlMon"
local wininet = ffi.load "WinInet"
local clipboard = require("neverlose/clipboard")
local base64 = require("neverlose/base64")
-- local drag = require("neverlose/drag")
-- local smoothy = require("neverlose/smoothy")
local get_lc = require("neverlose/get_lc")
local json = require("neverlose/better_json")
local G8 = {}


local UI = { list = {} }


UI.new = function (element, index, flag, conditions, callback, tooltip)
    assert(element, "Element is nil, index -> " .. (index or "nil"))
    assert(index, "Index is nil, element -> " .. (element:get_name() or "nil"))
    assert(type(index) == "string", "Invalid type of index, index -> " .. index)
    assert((callback == nil) or (callback.func and callback.setup ~= nil), "Invalid callback, index -> " .. (index or "nil"))
    assert(function ()
        for _, e in pairs(UI.list) do
            if e.index == index then
                return false
            end
        end
        return true
    end, "Defined index, index -> " .. (index or "nil"))

    UI.list[index] = {}
    UI.list[index].element = element
    UI.list[index].flag = flag or ""
    UI.list[index].visible_state = function ()
        if not conditions then return true end
        for _, func in pairs(conditions) do
            if not func() then
                return false
            end
        end
        return true
    end

    if callback then
        UI.list[index].element:set_callback(function ()
            UI.visibility_handle()
            callback.func()
        end, callback.setup)
    else
        UI.list[index].element:set_callback(function ()
            UI.visibility_handle()
        end)
    end

    UI.visibility_handle()

    if tooltip and tooltip ~= "" then
        UI.list[index].element:set_tooltip(tooltip)
    end
end

UI.get = function(idx)
    return UI.list[idx] and UI.list[idx].element:get()
end;

UI.set = function(idx, val)
    return UI.list[idx] and UI.list[idx].element:set(val)
end;

UI.get_element = function(idx)
    return UI.list[idx] and UI.list[idx].element
end;

UI.delete = function(idx)
    UI.get_element(idx):destroy()
    UI.list[idx] = nil
end;

UI.contains = function(idx, val)
    local obj = UI.get(idx)
    if type(obj) ~= "table" then
        return false
    end

    for h = 1, #obj do
        if obj[h] == val then
            return true
        end
    end
    return false
end;

UI.visibility_handle = function()
    if ui_get_alpha() > 0 then
        for _, obj in pairs(UI.list) do
            obj.element:set_visible(obj.visible_state())
        end
    end
end

UI.refresh_visibility = function ()
    for _, obj in pairs(UI.list) do
        obj.element:set_visible(obj.visible_state())
    end
end

UI.__call = function ()
    for idx, _ in pairs(UI.list) do
        print(idx)
    end
end


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


local vmthook = { list = {} }

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

-- EXTERN END

G8 = {
    defs = {},
    vars = {},
    funs = {},
    refs = {},
    feat = {},
    regs = {},
}



-- FUNS START

G8.funs = {
    download_file = function (from, to)
        assert(type(from) == "string", "Invalid type of download url")
        assert(type(to) == "string", "Invalid type of file path")
        wininet.DeleteUrlCacheEntryA(from)
        urlmon.URLDownloadToFileA(nil, from, to, 0,0)
    end;

    check_file = function (path, crc32)
        assert(type(path) == "string", "Invalid type of file path")
        assert(type(crc32) == "number", "Invalid type of crc32")
        return files_get_crc32(path) == crc32
    end;

    open_link = function (link)
        assert(type(link) == "string", "Invalid type of link")
        panorama.SteamOverlayAPI.OpenExternalBrowserURL(link)
    end;

    get_dist = function (start, to, target)
        local dista = target:dist(start)
        local distb = target:dist(to)
        local dist = target:dist(target:closest_ray_point(start, to))

        if dist > dista or dist > distb then
            dist = distb
        end

        return dist
    end;

    str2sub = function(input, sep)
        local t = {}
        for str in string.gmatch(input, "([^"..sep.."]+)") do
            t[#t + 1] = string.gsub(str, "\n", "")
        end
        return t
    end;

    reload_attacked_str = function ()
        if not files_read("nl\\Crow\\attacked_say.txt") then
            files_write("nl\\Crow\\attacked_say.txt", "OOP, {attacker} tried to attack me, his bullet went by {dist}u close to my head\n{attacker}的子弹从我头附近{dist}的距离飞过去了")
        end
        G8.vars.attacked_str = G8.funs.str2sub(files_read("nl\\Crow\\attacked_say.txt"), "\n")

        for i, str in pairs(G8.vars.attacked_str) do
            printraw(i .. "  " .. str)
        end
    end;

    gradient_text = function (r1, g1, b1, a1, r2, g2, b2, a2, text)
        local output = ""
        local len = #text-1
        local rinc = (r2 - r1) / len
        local ginc = (g2 - g1) / len
        local binc = (b2 - b1) / len
        local ainc = (a2 - a1) / len
        for i = 1, len + 1 do
            output = output .. ("\a%02x%02x%02x%02x%s"):format(r1, g1, b1, a1, text:sub(i, i))
            r1 = r1 + rinc
            g1 = g1 + ginc
            b1 = b1 + binc
            a1 = a1 + ainc
        end

        return output
    end;

    write_num = function(file_path, val)
        local state = files_write(file_path, "" .. val)
        if not state then
            G8.funs.log("failure to write file")
        end
    end;

    indicator = function(scolor, string, xtazst, yoffset)
        if (string == nil or string == "" or string == " ") then return end
        render_gradient(vector(20 + (render_measure_text(G8.defs.fonts.calibriba, nil, string).x / 2), G8.defs.screen_size.y - 548 + xtazst * 37 + yoffset), vector(15 , (G8.defs.screen_size.y - 548 + xtazst * 37) + 28 + yoffset), color(0, 0, 0, 60), color(0, 0, 0, 0), color(0, 0, 0, 60), color(0, 0, 0, 0), 0)
        render_gradient(vector(20 + (render_measure_text(G8.defs.fonts.calibriba, nil, string).x / 2), G8.defs.screen_size.y - 548 + xtazst * 37 + yoffset), vector(25 + (render_measure_text(G8.defs.fonts.calibriba, nil, string).x), (G8.defs.screen_size.y - 548 + xtazst * 37) + 28 + yoffset), color(0, 0, 0, 60), color(0, 0, 0, 0), color(0, 0, 0, 60), color(0, 0, 0, 0), 0)

        render_text(G8.defs.fonts.calibriba, vector(21, (G8.defs.screen_size.y - 543) + xtazst * 37 + yoffset), color(0, 0, 0, (scolor.a - 105) >=0 and (scolor.a - 105) or 0), "", string)
        render_text(G8.defs.fonts.calibriba, vector(20, (G8.defs.screen_size.y - 544) + xtazst * 37 + yoffset), scolor, "", string)
    end;

    log = function(string)
        printraw("\aDD63E7[G8] \a868686» \aD5D5D5" .. string)
        printdev(string)
    end;

    get_weapon_group = function(weapon_name)
        if not globals.is_connected then
            return "None"
        end
        if (weapon_name == "weapon_glock") or (weapon_name == "weapon_tec9") or (weapon_name == "weapon_elite") or (weapon_name == "weapon_p250") or (weapon_name == "weapon_hkp2000") or (weapon_name == "weapon_fiveseven") then
            return "Pistols"
        elseif (weapon_name == "weapon_deagle") then
            return "Heavy Pistols"
        elseif (weapon_name == "weapon_ssg08") then
            return "Scout"
        elseif (weapon_name == "weapon_awp") then
            return "AWP"
        elseif (weapon_name == "weapon_g3sg1") or (weapon_name == "weapon_scar20") then
            return "Auto"
        elseif (weapon_name == "weapon_taser") then
            return "Zeus"
        else
            return "Global"
        end
    end;

    playsound = function (sound_name, volume)
		local name = sound_name:lower():find(".wav") and sound_name or ("%s.wav"):format(sound_name)
		pcall(G8.defs.ffi_helper.PlaySound, name, tonumber(volume) / 100, 100, 0, 0)
    end;

    addway_aa = function ()
        local state = UI.get("antiaim_playercondition")

        if UI.get("antiaim_xway_value_" .. state) == 64 then
            common_add_notify("Anti-Aim", "Not more than 64!")
            return
        end

        UI.set("antiaim_xway_value_" .. state, UI.get("antiaim_xway_value_" .. state) + 1)
        local ways = UI.get("antiaim_xway_value_" .. state)

        UI.new(G8.defs.groups.antiaim.xwaybuilder:slider("[" .. string_sub(state, 1, 1) .. "] Way " .. ways, -180, 180, 0), "antiaim_xway_" .. state .. "_" .. ways, "i", {
            function () return UI.get("antiaim_switch") end;
            function () return UI.get("antiaim_playercondition") == state end;
            function () return UI.get("antiaim_override_" .. state) end;
            function () return UI.get("antiaim_yawmode_" .. state) == "X-Way" end;
        }, nil, nil)
    end;

    deleteway_aa = function ()
        local state = UI.get("antiaim_playercondition")

        if UI.get("antiaim_xway_value_" .. state) == 2 then
            common_add_notify("Anti-Aim", "Not less than 2!")
            return
        end

        UI.delete("antiaim_xway_" .. state .. "_" .. UI.get("antiaim_xway_value_" .. state))

        UI.set("antiaim_xway_value_" .. state, UI.get("antiaim_xway_value_" .. state) - 1)
    end;


    random_bf = function ()
        local state = UI.get("antiaim_playercondition")

        local ways = UI.get("antiaim_bf_value_" .. state)

        for i = 1, ways do
            UI.set("antiaim_bf_way_" .. state .. "_" .. i, utils_random_int(0, 60))
        end

        common_add_notify("Anti-Bruteforce", "Done")
    end;


    prepare_func = function ()
        ::starter::
        files_create_folder("nl\\Crow")
        files_create_folder("nl\\Crow\\imgs")

        G8.vars.shot_num = tonumber(files_read("nl\\Crow\\shot_num"))
        if G8.vars.shot_num == nil then
            G8.vars.shot_num = 0
            files_write("nl\\Crow\\shot_num", "0")
        end

        G8.vars.prepare_timer = tonumber(files_read("nl\\Crow\\prepare_timer"))
        if G8.vars.prepare_timer == nil then
            G8.vars.prepare_timer = 1
            files_write("nl\\Crow\\prepare_timer", "1")
        end

        if G8.vars.prepare_timer >= 6 then
            G8.vars.prepare_timer = 0
            files_write("nl\\Crow\\prepare_timer", "1")
            return
        end

        if not (files_get_crc32("nl\\Crow\\imgs\\G8.gif") == G8.defs.gif_crc32) then
            G8.funs.download_file("https://crow.pub/G8.gif", "nl\\Crow\\imgs\\G8.gif")
            G8.vars.prepare_timer = G8.vars.prepare_timer + 1
            files_write("nl\\Crow\\prepare_timer", "" .. G8.vars.prepare_timer)
            goto starter
        end

        if not (files_get_crc32("csgo\\sound\\[G8]LOAD.wav") == G8.defs.loadwav_crc32) then
            G8.funs.download_file("https://crow.pub/[G8]LOAD.wav", "csgo\\sound\\[G8]LOAD.wav")
            G8.vars.prepare_timer = G8.vars.prepare_timer + 1
            files_write("nl\\Crow\\prepare_timer", "" .. G8.vars.prepare_timer)
            goto starter
        end

        if not (files_get_crc32("csgo\\sound\\[G8]attacked.wav") == G8.defs.attackedwav_crc32) then
            G8.funs.download_file("https://crow.pub/[G8]attacked.wav", "csgo\\sound\\[G8]attacked.wav")
            G8.vars.prepare_timer = G8.vars.prepare_timer + 1
            files_write("nl\\Crow\\prepare_timer", "" .. G8.vars.prepare_timer)
            goto starter
        end

        if not files_get_crc32("nl\\Crow\\Fonts\\smallest_pixel-7.ttf") then
            G8.funs.download_file("https://crow.pub/smallest_pixel-7.ttf", "nl\\Crow\\Fonts\\smallest_pixel-7.ttf")
        end

        G8.defs.gif = render_load_image_from_file("nl\\Crow\\imgs\\G8.gif")
        G8.funs.reload_attacked_str()
    end;

    get_average = function (tab)
        local sum = 0
        for _, val in pairs(tab) do
            sum = sum + val;
        end
        return sum / #tab;
    end;

    clr_lerp = function (time, color1, color2)
        return color(color1.r * (1 - time) + color2.r * time, color1.b * (1 - time) + color2.b * time, color1.g * (1 - time) + color2.g * time, color1.a * (1 - time) + color2.a * time)
    end;

    export_global = function ()
        local cfg = {}

        for idx, obj in pairs(UI.list) do
            if obj.flag ~= "-" then
                cfg[idx] = obj.element:get()
            end
        end

        clipboard.set(base64.encode(json.stringify(cfg)))
        common_add_notify("CFG SYSTEM", "CFG Export Success")
    end;

    export_aa = function ()
        local cfg = {}

        for idx, obj in pairs(UI.list) do
            if obj.flag ~= "-" and string.find(idx, "antiaim_") then
                cfg[idx] = obj.element:get()
            end
        end

        clipboard.set(base64.encode(json.stringify(cfg)))
        common_add_notify("CFG SYSTEM", "CFG Export Success")
    end;

    export_fl = function ()
        local cfg = {}

        for idx, obj in pairs(UI.list) do
            if obj.flag ~= "-" and string.find(idx, "fakelag_") then
                cfg[idx] = obj.element:get()
            end
        end

        clipboard.set(base64.encode(json.stringify(cfg)))
        common_add_notify("CFG SYSTEM", "CFG Export Success")
    end;

    import_cfg = function (cfg)
        local status, message = pcall(function ()
            local data = json.parse(base64.decode(cfg))
            for idx, val in pairs(data) do
                if UI.list[idx].flag == "c" then
                    UI.get_element(idx):set(color(val[1], val[2], val[3], val[4]))
                else
                    UI.get_element(idx):set(val)
                end
            end
            UI.visibility_handle()
        end)

        if not status then
            common_add_notify("CFG SYSTEM", "failed to import\ncheck ur clipboard")
            G8.funs.log(message)
        else
            common_add_notify("CFG SYSTEM", "CFG Import Success")
        end
    end;

    entity_list_pointer = ffi.cast("void***", utils_create_interface("client.dll", "VClientEntityList003"));
    inside_updateCSA = function(thisptr, edx)
        G8.vars.hooked_function(thisptr, edx)
        if entity_get_local_player() == nil or ffi.cast('uintptr_t**', thisptr) == nil then return end
        if not entity_get_local_player():is_alive() then return end

        G8.refs.antiaim.misc.leg_movement:override()

        if UI.contains("animbreaker_list", "Pitch Onground") then
            if ffi.cast("CCSGOPlayerAnimationState_534535_t**", ffi.cast("uintptr_t", thisptr) + 0x9960)[0].bHitGroundAnimation then
                if not G8.vars.is_jumping then
                    entity_get_local_player().m_flPoseParameter[12] = 0.5
                end
            end
        end


        entity_get_local_player().m_flPoseParameter[6] = UI.contains("animbreaker_list", "In Air") and 1 or 0

        if UI.contains("animbreaker_list", "Leg Fucker") and G8.vars.velocity >= 130 then
            if UI.get("animbreaker_legfucker_style") == "Reserved side" then
                G8.refs.antiaim.misc.leg_movement:override("Sliding")
                entity_get_local_player().m_flPoseParameter[0] = 0
            elseif UI.get("animbreaker_legfucker_style") == "Moon Walk" then
                G8.refs.antiaim.misc.leg_movement:override("Walking")
                entity_get_local_player().m_flPoseParameter[7] = 0
            elseif UI.get("animbreaker_legfucker_style") == "Static" then
                G8.refs.antiaim.misc.leg_movement:override("Walking")
                entity_get_local_player().m_flPoseParameter[10] = 0
            end
        end

        if UI.contains("animbreaker_list", "Slow Walk") and G8.vars.velocity < 130 then
            G8.refs.antiaim.misc.leg_movement:override("Walking")
            entity_get_local_player().m_flPoseParameter[9] = 0
        end

        if UI.contains("animbreaker_list", "Duck") then
            entity_get_local_player().m_flPoseParameter[8] = 0
        end
    end;

    create_menu = function ()
        UI.new(G8.defs.groups.main.main:label("Welcome, " .. G8.funs.gradient_text(255, 8, 68, 255, 255, 177, 153, 255, G8.defs.username)), "main_label", "-", nil, nil, nil)
        UI.new(G8.defs.groups.main.main:switch("Loaded Music", false), "main_loaded_sound", "b", nil, nil, nil)
        UI.new(G8.defs.groups.main.main:switch("Enable G8 GIF", false), "main_gif_switch", "b", nil, nil, "FFYOU SURE???")
        UI.new(G8.defs.groups.main.texture:texture(G8.defs.gif, vector(338,338)), "main_gif", "-", {function () return UI.get("main_gif_switch") end,}, nil, nil)

        UI.new(G8.defs.groups.rage.ragebot:switch("Weapon Builder", false), "ragebot_switch", "b", nil, nil, nil)
        UI.new(G8.defs.groups.rage.ragebot:switch("Override Key", false), "ragebot_override_key", "b", {function () return UI.get("ragebot_switch") end}, nil, "Bind a key")
        UI.new(G8.defs.groups.rage.ragebot:combo("Weapons", G8.defs.weapon_names), "ragebot_weapon_list", "s", {function () return UI.get("ragebot_switch") end}, nil, nil)
        for _, name in pairs(G8.defs.weapon_names) do
            UI.new(G8.defs.groups.rage.ragebot:switch("Override " .. name), "ragebot_override_switch_" .. name, "b", {
                function () return UI.get("ragebot_switch") end;
                function () return UI.get("ragebot_weapon_list") == name end;
            }, nil, nil)
            UI.new(G8.defs.groups.rage.ragebot:selectable("Override List", {"Override", "Air", "No-Scope"}), "ragebot_override_list_" .. name, "s", {
                function () return UI.get("ragebot_switch") end;
                function () return UI.get("ragebot_weapon_list") == name end;
                function () return UI.get("ragebot_override_switch_" .. name) end;
            }, nil, nil)
            for _, state in pairs({"Default", "Override", "Air", "No-Scope"}) do
                UI.new(G8.defs.groups.rage.ragebot:slider(state .. " Damage", 0, 130, 0, 1, function (val)
                    if val == 0 then
                        return "Auto"
                    elseif val > 100 then
                        return "+" .. (val - 100)
                    else
                        return val
                    end
                end), "ragebot_" .. state .. "_dmg_" .. name, "i", {
                    function () return UI.get("ragebot_switch") end;
                    function () return UI.get("ragebot_weapon_list") == name end;
                    function () return UI.get("ragebot_override_switch_" .. name) end;
                    function () return UI.contains("ragebot_override_list_" .. name, state) end;
                }, nil, nil)
                UI.new(G8.defs.groups.rage.ragebot:slider(state .. " Hit-Chance", 0, 100, 0), "ragebot_" .. state .. "_hc_" .. name, "i", {
                    function () return UI.get("ragebot_switch") end;
                    function () return UI.get("ragebot_weapon_list") == name end;
                    function () return UI.get("ragebot_override_switch_" .. name) end;
                    function () return UI.contains("ragebot_override_list_" .. name, state) end;
                }, nil, nil)
            end
        end

        UI.new(G8.defs.groups.rage.doubletap:switch("Double-Tap Builder", false), "ragebot_doubletap", "b", nil, nil, nil)
        UI.new(G8.defs.groups.rage.doubletap:switch("Teleport On Key", false), "ragebot_doubletap_tp", "b", {
            function () return UI.get("ragebot_doubletap") end;
        }, nil, "Bind a key\nNot practical, but I'm lazy to delete")
        UI.new(G8.defs.groups.rage.doubletap:switch("Disable Clock Correction", false), "ragebot_clock_correction", "b", {
            function () return UI.get("ragebot_doubletap") end;
        }, nil, nil)
        UI.new(G8.defs.groups.rage.doubletap:switch("Defensive Double-Tap", false), "ragebot_defensive", "b", {
            function () return UI.get("ragebot_doubletap") end;
        }, nil, "Not practical, but I'm lazy to delete")
        UI.new(UI.get_element("ragebot_defensive"):create():slider("Maximum Speed", 5, 260, 20), "ragebot_defensive_velocity", "i", {
            function () return UI.get("ragebot_doubletap") end;
            function () return UI.get("ragebot_defensive") end;
        }, nil, nil)
        UI.new(G8.defs.groups.rage.doubletap:switch("Custom Double-Tap Tick Base", false), "ragebot_tickbase", "b", {
            function () return UI.get("ragebot_doubletap") end;
        }, nil, nil)
        UI.new(UI.get_element("ragebot_tickbase"):create():slider("Tick Base", 16, 22, 16), "ragebot_tickbase_value", "i", {
            function () return UI.get("ragebot_doubletap") end;
            function () return UI.get("ragebot_tickbase") end;
        }, nil, nil)
        UI.new(G8.defs.groups.rage.doubletap:switch("Scout Auto Teleport", false), "ragebot_autotp", "b", {
            function () return UI.get("ragebot_doubletap") end;
        }, nil, nil)
        UI.new(G8.defs.groups.rage.misc:switch("Jump Scout Fix", false), "ragebot_jumpscout", "b", nil, nil, nil)
        UI.new(G8.defs.groups.rage.misc:switch("Adaptive Extended Backtrack", false), "ragebot_adaptive", "b", nil, nil, nil)
--flag1
        UI.new(G8.defs.groups.antiaim.main:switch("Anti-Aim Builder", false), "antiaim_switch", "b", nil, nil, nil)
        UI.new(G8.defs.groups.antiaim.main:combo("Manual Anti-Aim", G8.defs.aa_manuals), "antiaim_manual", "s", {function () return UI.get("antiaim_switch") end;}, nil, nil)
        -- local aa_manual = UI.get_element("antiaim_manual"):create()
        -- UI.new(aa_manual:selectable("Disable Yaw", G8.defs.aa_manuals), "antiaim_disable_yaw", "t", {function () return UI.get("antiaim_switch") end;}, nil, nil)
        -- UI.new(aa_manual:selectable("Disable Desync", G8.defs.aa_manuals), "antiaim_disable_desync", "t", {function () return UI.get("antiaim_switch") end;}, nil, nil)
        -- UI.new(aa_manual:selectable("Disable At-Target", G8.defs.aa_manuals), "antiaim_disable_attarget", "t", {function () return UI.get("antiaim_switch") end;}, nil, nil)
        -- UI.new(G8.defs.groups.antiaim.main:switch("Fix Using AA", false), "antiaim_fixaa", "b", {function () return UI.get("antiaim_switch") end;}, nil, nil)


        UI.new(G8.defs.groups.antiaim.builder:combo("Player Condition", G8.defs.player_states_aa), "antiaim_playercondition", "s", {function () return UI.get("antiaim_switch") end;}, nil, nil)

        UI.new(G8.defs.groups.antiaim.main:switch("Invert Body Yaw Key", false), "antiaim_bodyyaw_invert", "b", {
            function () return UI.get("antiaim_switch") end;
        }, {
            func = function ()
                if UI.get("antiaim_bodyyaw_invert") then
                    G8.refs.antiaim.body_yaw.inverter:set(not G8.refs.antiaim.body_yaw.inverter:get())
                    utils_execute_after(0.3, function ()
                        UI.set("antiaim_bodyyaw_invert", false)
                    end)
                end
            end;
            setup = false,
        }, "Bind a key")

        UI.new(G8.defs.groups.antiaim.bfbuilder:button("Random BF", G8.funs.random_bf), "antiaim_bf_random", "b", {
            function () return UI.get("antiaim_switch") end;
            function () return UI.get("antiaim_override_" .. UI.get("antiaim_playercondition")) end;
            function () return UI.get("antiaim_bodyyaw_" .. UI.get("antiaim_playercondition")) end;
            function () return UI.get("antiaim_bodyyaw_mode_" .. UI.get("antiaim_playercondition")) == "Anti-Bruteforce" end;
        }, nil, nil)

        for _, state in pairs(G8.defs.player_states_aa) do
            UI.new(G8.defs.groups.antiaim.builder:switch("Override -> " .. state, false), "antiaim_override_" .. state, "b", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
            }, {
                func = function ()
                    if state == "Global" then
                        UI.set("antiaim_override_Global", true)
                    end
                    UI.visibility_handle()
                end;
                setup = true
            }, nil)
            if state == "Manual-AA" then
                UI.new(G8.defs.groups.antiaim.builder:selectable("Override Manuals", G8.defs.aa_manuals), "antiaim_override_manuals", "t", {
                    function () return UI.get("antiaim_switch") end;
                    function () return UI.get("antiaim_playercondition") == state end;
                    function () return UI.get("antiaim_override_" .. state) end;
                    }, nil, nil)
            end
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string_sub(state, 1, 1) .. "] Backward Offset", -20, 20, 0, 1, "°"), "antiaim_backward_offset_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string_sub(state, 1, 1) .. "] Pitch Mode", {"Default", "Jitter", "Random"}), "antiaim_pitchmode_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string_sub(state, 1, 1) .. "] Pitch", {"Disabled", "Down", "Fake Down", "Fake Up"}), "antiaim_pitch_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_pitchmode_" .. state) == "Default" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string_sub(state, 1, 1) .. "] Pitch Step", 1, 32, 1, 1, "T"), "antiaim_pitchstep_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_pitchmode_" .. state) ~= "Default" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string_sub(state, 1, 1) .. "] Pitch 1", {"Disabled", "Down", "Fake Down", "Fake Up"}), "antiaim_pitch1_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_pitchmode_" .. state) == "Jitter" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string_sub(state, 1, 1) .. "] Pitch 2", {"Disabled", "Down", "Fake Down", "Fake Up"}), "antiaim_pitch2_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_pitchmode_" .. state) == "Jitter" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:selectable("[" .. string_sub(state, 1, 1) .. "] Random Pitchs", {"Disabled", "Down", "Fake Down", "Fake Up"}), "antiaim_randompitchs_" .. state, "t", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_pitchmode_" .. state) == "Random" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string_sub(state, 1, 1) .. "] Yaw Base", {"Local View", "At Target"}), "antiaim_yawbase_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string_sub(state, 1, 1) .. "] Yaw Mode", G8.defs.yaw_modes), "antiaim_yawmode_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string_sub(state, 1, 1) .. "] Yaw Step", 1, 64, 1, 1, "T"), "antiaim_yawstep_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_yawmode_" .. state) == "Jitter" or UI.get("antiaim_yawmode_" .. state) == "Random" or UI.get("antiaim_yawmode_" .. state) == "X-Way" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string_sub(state, 1, 1) .. "] Yaw Left", 0, 180, 0, 1, "°"), "antiaim_yawleft_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_yawmode_" .. state) == "Jitter" or UI.get("antiaim_yawmode_" .. state) == "Random" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string_sub(state, 1, 1) .. "] Yaw Right", 0, 180, 0, 1, "°"), "antiaim_yawright_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_yawmode_" .. state) == "Jitter" or UI.get("antiaim_yawmode_" .. state) == "Random" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string_sub(state, 1, 1) .. "] Spin Offset", -180, 180, 0, 1, "°"), "antiaim_spinoffset_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_yawmode_" .. state) == "Spin" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string_sub(state, 1, 1) .. "] Yaw Modifier", {"Disabled", "Center", "Offset", "Random", "Spin"}), "antiaim_yawmodifier_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
            }, nil, nil)
            UI.new(UI.get_element("antiaim_yawmodifier_" .. state):create():slider("[" .. string_sub(state, 1, 1) .. "] Offset", -180, 180, 0, 1, "°"), "antiaim_yawmodifier_offset_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_yawmodifier_" .. state) ~= "Disabled" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:switch("[" .. string_sub(state, 1, 1) .. "] Body Yaw", false), "antiaim_bodyyaw_" .. state, "b", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string_sub(state, 1, 1) .. "] Body Yaw Mode", {"Static", "Jitter", "Random", "Fluctuate", "Anti-Bruteforce"}), "antiaim_bodyyaw_mode_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string_sub(state, 1, 1) .. "] Body Yaw Left", 1, 60, 1, 1, "°"), "antiaim_bodyyaw_leftlimit_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) == "Static" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string_sub(state, 1, 1) .. "] Body Yaw Right", 1, 60, 1, 1, "°"), "antiaim_bodyyaw_rightlimit_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) == "Static" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string_sub(state, 1, 1) .. "] Body Yaw Step", 1, 64, 1, 1, "T"), "antiaim_bodyyaw_step_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Static" and UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Anti-Bruteforce" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string_sub(state, 1, 1) .. "] Body Yaw Left Min", 1, 60, 1, 1, "°"), "antiaim_bodyyaw_leftlimitmin_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Static" and UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Anti-Bruteforce" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string_sub(state, 1, 1) .. "] Body Yaw Left Max", 1, 60, 1, 1, "°"), "antiaim_bodyyaw_leftlimitmax_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Static" and UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Anti-Bruteforce" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string_sub(state, 1, 1) .. "] Body Yaw Right Min", 1, 60, 1, 1, "°"), "antiaim_bodyyaw_rightlimitmin_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Static" and UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Anti-Bruteforce" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string_sub(state, 1, 1) .. "] Body Yaw Right Max", 1, 60, 1, 1, "°"), "antiaim_bodyyaw_rightlimitmax_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Static" and UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Anti-Bruteforce" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:selectable("[" .. string_sub(state, 1, 1) .. "] Body Yaw Options", {"Avoid Overlap", "Jitter", "Randomize Jitter", "Anti Bruteforce"}), "antiaim_bodyyaw_option_" .. state, "t", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string_sub(state, 1, 1) .. "] LBY Option", {"Disabled", "Opposite", "Sway"}), "antiaim_lby_option_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.xwaybuilder:slider("[" .. string_sub(state, 1, 1) .. "] X-ways", 2, 20, 2), "antiaim_xway_value_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_yawmode_" .. state) == "X-Way" end;
            }, nil, nil)

            for i = 1, 20 do
                UI.new(G8.defs.groups.antiaim.xwaybuilder:slider("[" .. string_sub(state, 1, 1) .. "] Way " .. i, -180, 180, 0), "antiaim_xway_" .. state .. "_" .. i, "i", {
                    function () return UI.get("antiaim_switch") end;
                    function () return UI.get("antiaim_playercondition") == state end;
                    function () return UI.get("antiaim_override_" .. state) end;
                    function () return UI.get("antiaim_yawmode_" .. state) == "X-Way" end;
                    function () return UI.get("antiaim_xway_value_" .. state) >= i end;
                }, nil, nil)
            end

            UI.new(G8.defs.groups.antiaim.bfbuilder:slider("Anti-BF Ways", 2, 20, 2), "antiaim_bf_value_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) == "Anti-Bruteforce" end;
            }, nil, nil)

            for i = 1, 20 do
                UI.new(G8.defs.groups.antiaim.bfbuilder:slider("[" .. string_sub(state, 1, 1) .. "] Limit " .. i, 0, 60, 0), "antiaim_bf_way_" .. state .. "_" .. i, "i", {
                    function () return UI.get("antiaim_switch") end;
                    function () return UI.get("antiaim_playercondition") == state end;
                    function () return UI.get("antiaim_override_" .. UI.get("antiaim_playercondition")) end;
                    function () return UI.get("antiaim_bodyyaw_" .. UI.get("antiaim_playercondition")) end;
                    function () return UI.get("antiaim_bodyyaw_mode_" .. UI.get("antiaim_playercondition")) == "Anti-Bruteforce" end;
                    function () return UI.get("antiaim_bf_value_" .. state) >= i end;
                }, nil, nil)
            end

        end


        -- UI.new(G8.defs.groups.antiaim.exploit:combo("Exploit AA", {"Disabled", "Fake Flick", "Defensive AA"}), "antiaim_exploit_list", "s", {function () return UI.get("antiaim_switch") end;}, nil, "\aA6C0FEFFWill Override Normail AA")
        -- UI.new(G8.defs.groups.antiaim.exploit:slider("Flick Speed", 0, 30, 20, 1, function ()
        --     if UI.get("antiaim_flick_speed") == 0 then
        --         return "RND."
        --     else
        --         return UI.get("antiaim_flick_speed") .. "°"
        --     end
        -- end), "antiaim_flick_speed", "i", {
        --     function () return UI.get("antiaim_switch") end;
        --     function () return UI.get("antiaim_exploit_list") == "Fake Flick" end;
        -- }, nil, "\a6E96F0FF0 -> Random")
        -- UI.new(G8.defs.groups.antiaim.exploit:slider("Flick Yaw", 20, 100, 75, 1, "°"), "antiaim_flick_yaw", "i", {
        --     function () return UI.get("antiaim_switch") end;
        --     function () return UI.get("antiaim_exploit_list") == "Fake Flick" end;
        -- }, nil, nil)
        -- UI.new(G8.defs.groups.antiaim.exploit:switch("Flick Invert", false), "antiaim_flick_invert", "b", {
        --     function () return UI.get("antiaim_switch") end;
        --     function () return UI.get("antiaim_exploit_list") == "Fake Flick" end;
        -- }, {
        --     function ()
        --         if UI.get("antiaim_flick_invert") then
        --             G8.vars.flick_invert = not G8.vars.flick_invert
        --             utils_execute_after(0.3, function ()
        --                 UI.set("antiaim_flick_invert", false)
        --             end)
        --         end
        --     end;
        -- }, "Bind Any Key")
        -- UI.new(G8.defs.groups.antiaim.exploit:slider("Yaw Offset", 0, 180, 27, 1, "°"), "antiaim_defensive_offset", "i", {function () return UI.get("antiaim_exploit_list") == "Defensive AA" end;}, nil, nil)

        UI.new(G8.defs.groups.fakelag.main:switch("Fake-Lag Builder", false), "fakelag_switch", "b", nil, nil, nil)
        UI.new(G8.defs.groups.fakelag.main:switch("On-Shot Fix", false), "fakelag_fix_switch", "b", {function () return UI.get("fakelag_switch") end;}, nil, "\a2EF333FFSafer to fire")
        UI.new(G8.defs.groups.fakelag.main:switch("Fix While Fake-Duck", false), "fakelag_fix_fakeduck", "b", {
            function () return UI.get("fakelag_switch") end;
            function () return UI.get("fakelag_fix_switch") end;
        }, nil, nil)
        UI.new(G8.defs.groups.fakelag.main:combo("Fix Style", {"Aimbot", "Weapon Timer", "Weapon Fire", "Weapon Swtich"}), "fakelag_fix_style", "s", {
            function () return UI.get("fakelag_switch") end;
            function () return UI.get("fakelag_fix_switch") end;
        }, nil, nil)
        UI.new(G8.defs.groups.fakelag.builder:combo("Player Condition", G8.defs.player_states_fl), "fakelag_playercondition", "s", {function () return UI.get("fakelag_switch") end;}, nil, nil)
        for _, state in pairs(G8.defs.player_states_fl) do
            UI.new(G8.defs.groups.fakelag.builder:switch("Override -> " .. state, false), "fakelag_override_" .. state, "b", {
                function () return UI.get("fakelag_switch") end;
                function () return UI.get("fakelag_playercondition") == state end;
            }, {
                func = function ()
                    if state == "Global" then
                        UI.set("fakelag_override_Global", true)
                    end
                    UI.visibility_handle()
                end;
                setup = true
            }, nil)
            UI.new(G8.defs.groups.fakelag.builder:combo("[" .. string_sub(state, 1, 1) .. "] Fake-Lag Mode", G8.defs.fl_modes), "fakelag_mode_" .. state, "s", {
                function () return UI.get("fakelag_switch") end;
                function () return UI.get("fakelag_playercondition") == state end;
                function () return UI.get("fakelag_override_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.fakelag.builder:slider("[" .. string_sub(state, 1, 1) .. "] Fake-Lag Limit", 1, 24, 1), "fakelag_limit_" .. state, "i", {
                function () return UI.get("fakelag_switch") end;
                function () return UI.get("fakelag_playercondition") == state end;
                function () return UI.get("fakelag_override_" .. state) end;
                function () return UI.get("fakelag_mode_" .. state) == "Static" end;
            }, nil, nil)
            UI.new(G8.defs.groups.fakelag.builder:slider("[" .. string_sub(state, 1, 1) .. "] Fake-Lag Variability", 0, 24, 0), "fakelag_variability_" .. state, "i", {
                function () return UI.get("fakelag_switch") end;
                function () return UI.get("fakelag_playercondition") == state end;
                function () return UI.get("fakelag_override_" .. state) end;
                function () return UI.get("fakelag_mode_" .. state) == "Static" end;
            }, nil, nil)
            UI.new(G8.defs.groups.fakelag.builder:slider("[" .. string_sub(state, 1, 1) .. "] Fake-Lag Step", 1, 64, 0, 1, "T"), "fakelag_step_" .. state, "i", {
                function () return UI.get("fakelag_switch") end;
                function () return UI.get("fakelag_playercondition") == state end;
                function () return UI.get("fakelag_override_" .. state) end;
                function () return UI.get("fakelag_mode_" .. state) ~= "Static" and  UI.get("fakelag_mode_" .. state) ~= "Custom-Builder" and UI.get("fakelag_mode_" .. state) ~= "Always-Choke" end;
            }, nil, nil)
            UI.new(G8.defs.groups.fakelag.builder:slider("[" .. string_sub(state, 1, 1) .. "] Fake-Lag Limit Min", 1, 24, 0), "fakelag_limitmin_" .. state, "i", {
                function () return UI.get("fakelag_switch") end;
                function () return UI.get("fakelag_playercondition") == state end;
                function () return UI.get("fakelag_override_" .. state) end;
                function () return UI.get("fakelag_mode_" .. state) ~= "Static" and  UI.get("fakelag_mode_" .. state) ~= "Custom-Builder" and UI.get("fakelag_mode_" .. state) ~= "Always-Choke" end;
            }, {
                func = function ()
                    if UI.get("fakelag_limitmin_" .. state) > UI.get("fakelag_limitmax_" .. state) then
                        UI.set("fakelag_limitmin_" .. state, UI.get("fakelag_limitmax_" .. state))
                    end
                end;
                setup = false
            }, nil)
            UI.new(G8.defs.groups.fakelag.builder:slider("[" .. string_sub(state, 1, 1) .. "] Fake-Lag Limit Max", 1, 24, 0), "fakelag_limitmax_" .. state, "i", {
                function () return UI.get("fakelag_switch") end;
                function () return UI.get("fakelag_playercondition") == state end;
                function () return UI.get("fakelag_override_" .. state) end;
                function () return UI.get("fakelag_mode_" .. state) ~= "Static" and  UI.get("fakelag_mode_" .. state) ~= "Custom-Builder" and UI.get("fakelag_mode_" .. state) ~= "Always-Choke" end;
            }, {
                func = function ()
                    if UI.get("fakelag_limitmin_" .. state) > UI.get("fakelag_limitmax_" .. state) then
                        UI.set("fakelag_limitmin_" .. state, UI.get("fakelag_limitmax_" .. state))
                    end
                end;
                setup = false
            }, nil)
            UI.new(G8.defs.groups.fakelag.builder:slider("[" .. string_sub(state, 1, 1) .. "] Fake-Lag Limit", 15, 24, 15), "fakelag_maxlimit_" .. state, "i", {
                function () return UI.get("fakelag_switch") end;
                function () return UI.get("fakelag_playercondition") == state end;
                function () return UI.get("fakelag_override_" .. state) end;
                function () return UI.get("fakelag_mode_" .. state) == "Always-Choke" end;
            }, nil, nil)
            UI.new(G8.defs.groups.fakelag.custom_builder:slider("Fake-Lag Custom", 2, 20, 2), "fakelag_custom_value_" .. state, "i", {
                function () return UI.get("fakelag_switch") end;
                function () return UI.get("fakelag_playercondition") == state end;
                function () return UI.get("fakelag_override_" .. state) end;
                function () return UI.get("fakelag_mode_" .. state) == "Custom-Builder" end;
            }, nil, nil)

            for i = 1, 20 do
                UI.new(G8.defs.groups.fakelag.custom_builder:slider("[" .. string_sub(state, 1, 1) .. "] Tick " .. i , 1, 64, 0, 1, "T"), "fakelag_customtick_" .. state .. "_" .. i, "i", {
                    function () return UI.get("fakelag_switch") end;
                    function () return UI.get("fakelag_playercondition") == state end;
                    function () return UI.get("fakelag_override_" .. state) end;
                    function () return UI.get("fakelag_mode_" .. state) == "Custom-Builder" end;
                    function () return UI.get("fakelag_custom_value_" .. state) >= i end;
                }, nil, nil)
                UI.new(G8.defs.groups.fakelag.custom_builder:slider("[" .. string_sub(state, 1, 1) .. "] Limit " .. i, 1, 24, 1), "fakelag_customlimit_" .. state .. "_" .. i, "i", {
                    function () return UI.get("fakelag_switch") end;
                    function () return UI.get("fakelag_playercondition") == state end;
                    function () return UI.get("fakelag_override_" .. state) end;
                    function () return UI.get("fakelag_mode_" .. state) == "Custom-Builder" end;
                    function () return UI.get("fakelag_custom_value_" .. state) >= i end;
                }, nil, nil)
            end
        end

        UI.new(G8.defs.groups.visual.aspect_ratio:switch("Aspect Ratio", false), "visual_aspect_ratio", "i", nil, {
            func = function ()
                cvar.r_aspectratio:float(UI.get("visual_aspect_ratio") and UI.get("visual_aspect_value") / 10 or 0)
            end;
            setup = false
        }, nil)
        UI.new(UI.get_element("visual_aspect_ratio"):create():slider("Ratio Value", 0, 20, 0, 0.1), "visual_aspect_value", "i", {function () return UI.get("visual_aspect_ratio") end;}, {
            func = function ()
                cvar.r_aspectratio:float(UI.get("visual_aspect_ratio") and UI.get("visual_aspect_value") / 10 or 0)
            end;
            setup = false
        }, nil)

        UI.new(G8.defs.groups.visual.view_model:switch("View Model Changer", false), "visual_viewmodel_changer", "b", nil, nil, nil)
        local viewmodel_changer = UI.get_element("visual_viewmodel_changer"):create()
        UI.new(viewmodel_changer:slider("FOV", 0, 100, 60), "viewmodel_fov", "i", {
            function () return UI.get("visual_viewmodel_changer") end;
        }, nil, nil)
        UI.new(viewmodel_changer:slider("X", -15, 15, 1), "viewmodel_x", "i", {
            function () return UI.get("visual_viewmodel_changer") end;
        }, nil, nil)
        UI.new(viewmodel_changer:slider("Y", -15, 15, 1), "viewmodel_y", "i", {
            function () return UI.get("visual_viewmodel_changer") end;
        }, nil, nil)
        UI.new(viewmodel_changer:slider("Z", -15, 15, 0), "viewmodel_z", "i", {
            function () return UI.get("visual_viewmodel_changer") end;
        }, nil, nil)
--, "Spectators", "Keybinds"
        UI.new(G8.defs.groups.visual.solus_ui:selectable("Solus UI", {"Watermark"}), "visual_solusui", "t", nil, nil, nil)

        UI.new(G8.defs.groups.visual.crosshair_indicator:switch("Crosshair Indicators", false), "visual_crosshair", "b", nil, nil, nil)
        UI.new(G8.defs.groups.visual.crosshair_indicator:switch("Crosshair Damage", false), "visual_crosshair_dmg", "b", nil, nil, nil)

        UI.new(G8.defs.groups.visual.skeet_indicator:switch("Skeet Indicator", false), "visual_skeet", "b", nil, nil, nil)
        UI.new(UI.get_element("visual_skeet"):create():selectable("Indicators", {"G8", "Weapon State", "DMG", "HC", "FL", "DT", "HS", "FD", "DA", "LC"}), "visual_skeet_list", "t", { function () return UI.get("visual_skeet") end; }, nil, nil)
        UI.new(UI.get_element("visual_skeet"):create():slider("Y Offset", -500, 500, 0), "visual_skeet_offset", "i", { function () return UI.get("visual_skeet") end; }, nil, nil)

        UI.new(G8.defs.groups.misc.logs:switch("Hit/Mis log", false), "log_hitmiss", "b", nil, nil, nil)
        local tlog = UI.get_element("log_hitmiss"):create()
        UI.new(tlog:combo("Language", {"zh_CN", "en_US"}), "log_language", "s", { function () return UI.get("log_hitmiss") end; }, nil, nil)
        UI.new(tlog:selectable("Log Style", {"Chat", "Console", "Screen"}), " log_style", "t", { function () return UI.get("log_hitmiss") end; }, nil, nil)

        UI.new(G8.defs.groups.misc.unsafe_feature:selectable("Animbreaker", {"Pitch Onground", "In Air", "Leg Fucker", "Slow Walk", "Duck"}), "animbreaker_list", "t", nil, nil, "Unsafe: Red Trust Factor")
        -- UI.new(G8.defs.groups.misc.unsafe_feature:combo("In Air Style", {"Static", "Moon Walk"}), "animbreaker_inair_style", "s", {function () return UI.contains("animbreaker_list", "In Air") end;}, nil, nil)
        UI.new(G8.defs.groups.misc.unsafe_feature:combo("Leg Fucker Style", {"Reserved side", "Moon Walk", "Static"}), "animbreaker_legfucker_style", "s", {function () return UI.contains("animbreaker_list", "Leg Fucker") end;}, nil, nil)

        UI.new(G8.defs.groups.misc.logs:switch("Be Attacked Sound", false), "log_attacked_sound", "b", nil, nil, nil)
        UI.new(G8.defs.groups.misc.logs:switch("Be Attacked Talk Shit", false), "log_attacked_say", "b", nil, nil, nil)
        UI.new(UI.get_element("log_attacked_say"):create():slider("Cooling time", 0, 30, 2, 1, "S"), "log_attacked_say_cooltime", "i", {function () return UI.get("log_attacked_say") end;}, nil, nil)
        UI.new(UI.get_element("log_attacked_say"):create():button("Reload Talk Strings", function ()
            G8.funs.reload_attacked_str()
        end), "log_sttacked_reload", "-", {function () return UI.get("log_attacked_say") end;}, nil, "nl\\Crow\\attacked_say.txt")

        UI.new(G8.defs.groups.config.global:button("Export Global Config To Clipboard", function ()
            G8.funs.export_global()
        end), "config_export_global", "-", nil, nil, nil)
        UI.new(G8.defs.groups.config.global:button("Import Config From Clipboard", function ()
            G8.funs.import_cfg(clipboard.get())
        end), "config_import_global", "-", nil, nil, "This button is universal")
        UI.new(G8.defs.groups.config.global:button("Load Default Global Config", function ()
            G8.funs.import_cfg(G8.defs.default_cfg)
        end), "config_load_default", "-", nil, nil, nil)

        UI.new(G8.defs.groups.config.antiaim:button("Export Anti-Aim Config To Clipboard", function ()
            G8.funs.export_aa()
        end), "config_export_aa", "-", nil, nil, nil)

        UI.new(G8.defs.groups.config.fakelag:button("Export Fake-Lag Config To Clipboard", function ()
            G8.funs.export_fl()
        end), "config_export_fl", "-", nil, nil, nil)
    end;



    --[[
    visual = {
        aspect_ratio = ui_create(G8.defs.tabs.visual, ui_get_icon("glasses") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Aspect Ratio")),
        view_model = ui_create(G8.defs.tabs.visual, ui_get_icon("street-view") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " View Model Changer")),
        solus_ui = ui_create(G8.defs.tabs.visual, ui_get_icon("window-restore") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Solus UI")),
        crosshair_indicator = ui_create(G8.defs.tabs.visual, ui_get_icon("crosshairs") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Crosshair Indicator")),
        skeet_indicator = ui_create(G8.defs.tabs.visual, ui_get_icon("window-maximize") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Skeet Indicator")),
        scope_overlay = ui_create(G8.defs.tabs.visual, ui_get_icon("camera-retro") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Scope Overlay")),
    },

    misc = {
        logs = ui_create(G8.defs.tabs.misc, ui_get_icon("video") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Logs")),
        camera_changer = ui_create(G8.defs.tabs.misc, ui_get_icon("camera") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Camera Changer")),
        unsafe_feature = ui_create(G8.defs.tabs.misc, ui_get_icon("exclamation-triangle") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Unsafe Features")),
    },

    config = {
        global = ui_create(G8.defs.tabs.config, ui_get_icon("globe-asia") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Global Config")),
        antiaim = ui_create(G8.defs.tabs.config, ui_get_icon("user-shield") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Anti-Aim Config")),
        fakelag = ui_create(G8.defs.tabs.config, ui_get_icon("walking") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Fake-Lag Config")),
        visual = ui_create(G8.defs.tabs.config, ui_get_icon("eye") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Visuals Config")),
    },
    ]]
}


G8.funs.get_client_entity_fn = ffi.cast("GetClientEntity_4242425_t", G8.funs.entity_list_pointer[0][3]);
G8.funs.get_entity_address = function(ent_index)
    local addr = G8.funs.get_client_entity_fn(G8.funs.entity_list_pointer, ent_index)
    return addr
end;

-- FUNS END


-- DEFS START

G8.defs = {
    default_cfg = "eyJhbnRpYWltX3NwaW5vZmZzZXRfT24tUGVlayI6MCwgImFudGlhaW1fcGl0Y2htb2RlX09uLVBlZWsiOiJEZWZhdWx0IiwgImFudGlhaW1feWF3bW9kaWZpZXJfT24tUGVlayI6IlNwaW4iLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzE0IjowLCAiYW50aWFpbV9waXRjaF9Pbi1QZWVrIjoiRG93biIsICJhbnRpYWltX3lhd21vZGlmaWVyX29mZnNldF9Pbi1QZWVrIjoxNSwgImFudGlhaW1feHdheV9BaXItRHVja18xNSI6MCwgImFudGlhaW1fcGl0Y2hzdGVwX09uLVBlZWsiOjEsICJhbnRpYWltX2JvZHl5YXdfT24tUGVlayI6ZmFsc2UsICJhbnRpYWltX3h3YXlfT24tUGVla180IjowLCAiYW50aWFpbV9waXRjaDFfT24tUGVlayI6IkRpc2FibGVkIiwgImFudGlhaW1fYm9keXlhd19tb2RlX09uLVBlZWsiOiJTdGF0aWMiLCAiYW50aWFpbV94d2F5X09uLVBlZWtfNSI6MCwgImFudGlhaW1feHdheV9BaXItRHVja18xNyI6MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRfT24tUGVlayI6MSwgImFudGlhaW1feHdheV9Pbi1QZWVrXzYiOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMTgiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdF9Pbi1QZWVrIjoxLCAiYW50aWFpbV9iYWNrd2FyZF9vZmZzZXRfTWFudWFsLUFBIjowLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzE5IjowLCAiYW50aWFpbV9ib2R5eWF3X3N0ZXBfT24tUGVlayI6MSwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtaW5fT24tUGVlayI6MSwgImFudGlhaW1fYmZfdmFsdWVfQWlyLUR1Y2siOjIsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1pbl9Pbi1QZWVrIjoxLCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfMSI6MCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWF4X09uLVBlZWsiOjEsICJhbnRpYWltX2JmX3dheV9BaXItRHVja18yIjowLCAiYW50aWFpbV9waXRjaF9HbG9iYWwiOiJEb3duIiwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzMiOjAsICJhbnRpYWltX2xieV9vcHRpb25fT24tUGVlayI6IkRpc2FibGVkIiwgImFudGlhaW1fcGl0Y2hzdGVwX0dsb2JhbCI6MSwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzQiOjAsICJhbnRpYWltX3h3YXlfdmFsdWVfT24tUGVlayI6MiwgImFudGlhaW1fcGl0Y2gxX0dsb2JhbCI6IkRpc2FibGVkIiwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzUiOjAsICJhbnRpYWltX3h3YXlfT24tUGVla18xIjowLCAiYW50aWFpbV9waXRjaDJfR2xvYmFsIjoiRGlzYWJsZWQiLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMiI6MCwgImFudGlhaW1fcmFuZG9tcGl0Y2hzX0dsb2JhbCI6e30sICJhbnRpYWltX3h3YXlfT24tUGVla18zIjowLCAiYW50aWFpbV9vdmVycmlkZV9BaXItRHVjayI6dHJ1ZSwgImFudGlhaW1feWF3YmFzZV9HbG9iYWwiOiJBdCBUYXJnZXQiLCAiYW50aWFpbV9iYWNrd2FyZF9vZmZzZXRfQWlyLUR1Y2siOjAsICJhbnRpYWltX3lhd21vZGVfR2xvYmFsIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9waXRjaG1vZGVfQWlyLUR1Y2siOiJEZWZhdWx0IiwgImFudGlhaW1feWF3c3RlcF9HbG9iYWwiOjEsICJhbnRpYWltX3BpdGNoMV9SdW5uaW5nIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9waXRjaF9BaXItRHVjayI6IkRvd24iLCAiYW50aWFpbV9tYW51YWwiOiJCYWNrd2FyZCIsICJhbnRpYWltX3BpdGNoMl9SdW5uaW5nIjoiRmFrZSBEb3duIiwgImFudGlhaW1fYm9keXlhd19pbnZlcnQiOmZhbHNlLCAiYW50aWFpbV9waXRjaHN0ZXBfQWlyLUR1Y2siOjEsICJhbnRpYWltX3JhbmRvbXBpdGNoc19SdW5uaW5nIjpbIkRpc2FibGVkIiwgIkZha2UgRG93biJdLCAiYW50aWFpbV95YXdiYXNlX1J1bm5pbmciOiJBdCBUYXJnZXQiLCAiYW50aWFpbV9vdmVycmlkZV9HbG9iYWwiOnRydWUsICJhbnRpYWltX292ZXJyaWRlX21hbnVhbHMiOlsiTGVmdCIsICJSaWdodCJdLCAiYW50aWFpbV95YXdtb2RlX1J1bm5pbmciOiJKaXR0ZXIiLCAiYW50aWFpbV9waXRjaDJfQWlyLUR1Y2siOiJEaXNhYmxlZCIsICJhbnRpYWltX3lhd3N0ZXBfUnVubmluZyI6MiwgImFudGlhaW1fcmFuZG9tcGl0Y2hzX0Fpci1EdWNrIjp7fSwgImFudGlhaW1feWF3bGVmdF9SdW5uaW5nIjoyMiwgImFudGlhaW1feWF3YmFzZV9BaXItRHVjayI6IkF0IFRhcmdldCIsICJhbnRpYWltX3lhd3JpZ2h0X1J1bm5pbmciOjIyLCAiYW50aWFpbV95YXdtb2RlX0Fpci1EdWNrIjoiSml0dGVyIiwgImFudGlhaW1fc3Bpbm9mZnNldF9SdW5uaW5nIjo1OCwgImFudGlhaW1feWF3c3RlcF9BaXItRHVjayI6MiwgImFudGlhaW1feWF3bW9kaWZpZXJfUnVubmluZyI6IkRpc2FibGVkIiwgImFudGlhaW1feWF3bW9kaWZpZXJfb2Zmc2V0X1J1bm5pbmciOjYyLCAiYW50aWFpbV9ib2R5eWF3X1J1bm5pbmciOmZhbHNlLCAiYW50aWFpbV95YXdyaWdodF9BaXItRHVjayI6MzEsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTMiOjAsICJhbnRpYWltX2JvZHl5YXdfbW9kZV9SdW5uaW5nIjoiU3RhdGljIiwgImFudGlhaW1fc3Bpbm9mZnNldF9BaXItRHVjayI6MCwgImFudGlhaW1fYmZfd2F5X0Nyb3VjaGluZ18xNCI6MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRfUnVubmluZyI6NjAsICJhbnRpYWltX3lhd21vZGlmaWVyX0Fpci1EdWNrIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzE1IjowLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRfUnVubmluZyI6NjAsICJhbnRpYWltX3lhd21vZGlmaWVyX29mZnNldF9BaXItRHVjayI6MCwgImFudGlhaW1fYmZfd2F5X0Nyb3VjaGluZ18xNiI6MCwgImFudGlhaW1fYm9keXlhd19zdGVwX1J1bm5pbmciOjUsICJhbnRpYWltX2JvZHl5YXdfQWlyLUR1Y2siOmZhbHNlLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzE3IjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1pbl9SdW5uaW5nIjoxLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzE4IjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1heF9SdW5uaW5nIjo2MCwgImFudGlhaW1fYmZfd2F5X0Nyb3VjaGluZ18xOSI6MCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWluX1J1bm5pbmciOjEsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMjAiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1heF9SdW5uaW5nIjo2MCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0X0Fpci1EdWNrIjoxLCAiYW50aWFpbV9vdmVycmlkZV9TbG93LVdhbGsiOnRydWUsICJhbnRpYWltX2JvZHl5YXdfb3B0aW9uX1J1bm5pbmciOlsiSml0dGVyIl0sICJhbnRpYWltX2JhY2t3YXJkX29mZnNldF9TbG93LVdhbGsiOjAsICJhbnRpYWltX2xieV9vcHRpb25fUnVubmluZyI6IkRpc2FibGVkIiwgImFudGlhaW1fcGl0Y2htb2RlX1Nsb3ctV2FsayI6IkRlZmF1bHQiLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfMSI6LTgsICJhbnRpYWltX3BpdGNoX1Nsb3ctV2FsayI6IkRvd24iLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfMiI6OCwgImFudGlhaW1fcGl0Y2hzdGVwX1Nsb3ctV2FsayI6MSwgImFudGlhaW1feHdheV9SdW5uaW5nXzMiOi00LCAiYW50aWFpbV9waXRjaDFfU2xvdy1XYWxrIjoiRGlzYWJsZWQiLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfNCI6NCwgImFudGlhaW1fcGl0Y2gyX1Nsb3ctV2FsayI6IkRpc2FibGVkIiwgImFudGlhaW1feHdheV9SdW5uaW5nXzUiOi0zNiwgImFudGlhaW1fcmFuZG9tcGl0Y2hzX1Nsb3ctV2FsayI6e30sICJhbnRpYWltX3h3YXlfUnVubmluZ182Ijo2NSwgImFudGlhaW1feHdheV9SdW5uaW5nXzciOi01MCwgImFudGlhaW1feHdheV9SdW5uaW5nXzgiOjM5LCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzUiOjAsICJhbnRpYWltX3h3YXlfT24tUGVla183IjowLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfOSI6LTUwLCAiYW50aWFpbV9ib2R5eWF3X1Nsb3ctV2FsayI6ZmFsc2UsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfNiI6MCwgImFudGlhaW1fcGl0Y2hfQ3JvdWNoaW5nIjoiRG93biIsICJhbnRpYWltX3h3YXlfUnVubmluZ18xMCI6NjksICJhbnRpYWltX2JvZHl5YXdfbW9kZV9TbG93LVdhbGsiOiJTdGF0aWMiLCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzciOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMSI6MCwgImFudGlhaW1feHdheV9SdW5uaW5nXzExIjotNTgsICJhbnRpYWltX2JvZHl5YXdfc3RlcF9FeHBsb2l0LURlZmVuc2l2ZSI6MSwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRfU2xvdy1XYWxrIjoxLCAiYW50aWFpbV9waXRjaDFfQ3JvdWNoaW5nIjoiRGlzYWJsZWQiLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfMTIiOjY0LCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1pbl9FeHBsb2l0LURlZmVuc2l2ZSI6MSwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0X1Nsb3ctV2FsayI6MSwgImFudGlhaW1fcGl0Y2gyX0Nyb3VjaGluZyI6IkRpc2FibGVkIiwgImFudGlhaW1feHdheV9SdW5uaW5nXzEzIjotNTcsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWF4X0V4cGxvaXQtRGVmZW5zaXZlIjoxLCAiYW50aWFpbV9ib2R5eWF3X3N0ZXBfU2xvdy1XYWxrIjoxLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfMTQiOjY1LCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtaW5fRXhwbG9pdC1EZWZlbnNpdmUiOjEsICJhbnRpYWltX3lhd2Jhc2VfQ3JvdWNoaW5nIjoiQXQgVGFyZ2V0IiwgImFudGlhaW1feHdheV9SdW5uaW5nXzE1IjotNTQsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1heF9FeHBsb2l0LURlZmVuc2l2ZSI6MSwgImFudGlhaW1feWF3bW9kaWZpZXJfb2Zmc2V0X1Nsb3ctV2FsayI6MTIsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMTEiOjAsICJhbnRpYWltX3lhd21vZGVfQ3JvdWNoaW5nIjoiRGlzYWJsZWQiLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfMTYiOjQzLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1heF9TbG93LVdhbGsiOjEsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMTIiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMTIiOjAsICJhbnRpYWltX3lhd3N0ZXBfQ3JvdWNoaW5nIjoyLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfMTciOi0zOSwgImFudGlhaW1feWF3YmFzZV9TdGFuZGluZyI6IkF0IFRhcmdldCIsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1pbl9TbG93LVdhbGsiOjEsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMTMiOjAsICJhbnRpYWltX3lhd2xlZnRfQ3JvdWNoaW5nIjo3LCAiYW50aWFpbV94d2F5X1J1bm5pbmdfMTgiOjUwLCAiYW50aWFpbV95YXdtb2RlX1N0YW5kaW5nIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfU2xvdy1XYWxrIjoxLCAiYW50aWFpbV95YXdyaWdodF9Dcm91Y2hpbmciOjcsICJhbnRpYWltX3h3YXlfUnVubmluZ18xOSI6LTU4LCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzEiOjAsICJhbnRpYWltX3lhd3N0ZXBfU3RhbmRpbmciOjEsICJhbnRpYWltX2JvZHl5YXdfb3B0aW9uX1Nsb3ctV2FsayI6e30sICJhbnRpYWltX3NwaW5vZmZzZXRfQ3JvdWNoaW5nIjowLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzE1IjowLCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzE1IjowLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzIiOjAsICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzE5IjowLCAiYW50aWFpbV95YXdsZWZ0X1N0YW5kaW5nIjowLCAiYW50aWFpbV9sYnlfb3B0aW9uX1Nsb3ctV2FsayI6IkRpc2FibGVkIiwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF8xNiI6MCwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV8zIjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18yMCI6MCwgImFudGlhaW1feWF3cmlnaHRfU3RhbmRpbmciOjAsICJhbnRpYWltX3h3YXlfdmFsdWVfU2xvdy1XYWxrIjoxMCwgImFudGlhaW1fYmZfdmFsdWVfQ3JvdWNoaW5nIjoyLCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzE3IjowLCAiYW50aWFpbV9ib2R5eWF3X0Nyb3VjaGluZyI6ZmFsc2UsICJhbnRpYWltX3NwaW5vZmZzZXRfU3RhbmRpbmciOjAsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzEiOi0xMiwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV81IjowLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzEiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMTgiOjAsICJhbnRpYWltX2JvZHl5YXdfbW9kZV9Dcm91Y2hpbmciOiJTdGF0aWMiLCAiYW50aWFpbV95YXdtb2RpZmllcl9TdGFuZGluZyI6IkNlbnRlciIsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzIiOjEyLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzIiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMTkiOjAsICJhbnRpYWltX3BsYXllcmNvbmRpdGlvbiI6IlNsb3ctV2FsayIsICJhbnRpYWltX3lhd21vZGlmaWVyX29mZnNldF9TdGFuZGluZyI6MzYsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzMiOi02LCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRfQ3JvdWNoaW5nIjoxLCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzIwIjowLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzgiOjAsICJhbnRpYWltX2JvZHl5YXdfU3RhbmRpbmciOmZhbHNlLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa180Ijo2LCAiYW50aWFpbV9ib2R5eWF3X3N0ZXBfQ3JvdWNoaW5nIjoxLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzkiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfNSI6MCwgImFudGlhaW1fYm9keXlhd19tb2RlX1N0YW5kaW5nIjoiU3RhdGljIiwgImFudGlhaW1feHdheV9TbG93LVdhbGtfNSI6MCwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV8xMCI6MCwgImFudGlhaW1fYmZfd2F5X0Nyb3VjaGluZ182IjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1heF9Dcm91Y2hpbmciOjEsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTEiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfNyI6MCwgImFudGlhaW1feWF3bW9kaWZpZXJfR2xvYmFsIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtaW5fQ3JvdWNoaW5nIjoxLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRfU3RhbmRpbmciOjYwLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzEyIjowLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzgiOjAsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTUiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1heF9Dcm91Y2hpbmciOjEsICJhbnRpYWltX2JvZHl5YXdfc3RlcF9TdGFuZGluZyI6MzksICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTMiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfOSI6MCwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV8xNiI6MCwgImFudGlhaW1fYm9keXlhd19vcHRpb25fQ3JvdWNoaW5nIjp7fSwgImFudGlhaW1fYm9keXlhd19HbG9iYWwiOmZhbHNlLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE0IjowLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzEwIjowLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE3IjowLCAiYW50aWFpbV9sYnlfb3B0aW9uX0Nyb3VjaGluZyI6IkRpc2FibGVkIiwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfOSI6MCwgImFudGlhaW1fYm9keXlhd19tb2RlX0dsb2JhbCI6IlN0YXRpYyIsICJhbnRpYWltX3BpdGNoMl9BaXIiOiJEaXNhYmxlZCIsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWF4X1N0YW5kaW5nIjo2MCwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV8xOCI6MCwgImFudGlhaW1feHdheV92YWx1ZV9Dcm91Y2hpbmciOjIsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzEwIjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdF9HbG9iYWwiOjEsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTIiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1pbl9TdGFuZGluZyI6MSwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMSI6MCwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMTEiOjAsICJhbnRpYWltX3lhd2Jhc2VfQWlyIjoiQXQgVGFyZ2V0IiwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0X0dsb2JhbCI6MSwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV8yMCI6MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMiI6MCwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMTIiOjAsICJhbnRpYWltX3lhd21vZGVfQWlyIjoiSml0dGVyIiwgImFudGlhaW1fYmZfdmFsdWVfRXhwbG9pdC1EZWZlbnNpdmUiOjIsICJhbnRpYWltX2JvZHl5YXdfc3RlcF9HbG9iYWwiOjEsICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzMiOjAsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzEzIjowLCAiYW50aWFpbV9iYWNrd2FyZF9vZmZzZXRfR2xvYmFsIjowLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMSI6MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfNCI6MCwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMTQiOjAsICJhbnRpYWltX2xieV9vcHRpb25fU3RhbmRpbmciOiJTd2F5IiwgImFudGlhaW1feWF3bGVmdF9BaXIiOjgsICJhbnRpYWltX3BpdGNobW9kZV9HbG9iYWwiOiJEZWZhdWx0IiwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzIiOjAsICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzUiOjAsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzE1IjowLCAiYW50aWFpbV94d2F5X3ZhbHVlX1N0YW5kaW5nIjoyLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMyI6MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfNiI6MCwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMTYiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1pbl9HbG9iYWwiOjEsICJhbnRpYWltX3NwaW5vZmZzZXRfQWlyIjowLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzEiOjAsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV80IjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ183IjowLCAiYW50aWFpbV94d2F5X0Zha2UtRHVja18xNyI6MCwgImFudGlhaW1feWF3bW9kaWZpZXJfQWlyIjoiRGlzYWJsZWQiLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzIiOjAsICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzgiOjAsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzE4IjowLCAiYW50aWFpbV95YXdtb2RpZmllcl9vZmZzZXRfQWlyIjowLCAiYW50aWFpbV9ib2R5eWF3X29wdGlvbl9HbG9iYWwiOnt9LCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfNiI6MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfOSI6MCwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMTkiOjAsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV83IjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18xMCI6MCwgImFudGlhaW1feHdheV9TdGFuZGluZ180IjowLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfOCI6MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMTEiOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfNSI6MCwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzkiOjAsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzE0IjowLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzEiOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfNiI6MCwgImFudGlhaW1feHdheV9NYW51YWwtQUFfMTYiOjAsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV8xMCI6MCwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMTUiOjAsICJhbnRpYWltX3h3YXlfUnVubmluZ18yMCI6MjQsICJhbnRpYWltX3h3YXlfR2xvYmFsXzIiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMiI6MCwgImFudGlhaW1feHdheV9TdGFuZGluZ183IjowLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTEiOjAsICJhbnRpYWltX3h3YXlfT24tUGVla184IjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18xNCI6MCwgImFudGlhaW1fYmZfd2F5X01hbnVhbC1BQV8xMCI6MCwgImFudGlhaW1feHdheV9HbG9iYWxfMyI6MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtaW5fU2xvdy1XYWxrIjoxLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTIiOjAsICJhbnRpYWltX3h3YXlfT24tUGVla185IjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18xNSI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMSI6MCwgImFudGlhaW1fYm9keXlhd19vcHRpb25fRXhwbG9pdC1EZWZlbnNpdmUiOnt9LCAiYW50aWFpbV94d2F5X0dsb2JhbF80IjowLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTMiOjAsICJhbnRpYWltX3h3YXlfT24tUGVla18xMCI6MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMTYiOjAsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzIiOjAsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMTciOjAsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfNyI6MCwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE0IjowLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMTEiOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfMTAiOjAsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzMiOjAsICJhbnRpYWltX3BpdGNoMV9TdGFuZGluZyI6IkRpc2FibGVkIiwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV82IjowLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTUiOjAsICJhbnRpYWltX3h3YXlfR2xvYmFsXzYiOjAsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfNyI6MCwgImFudGlhaW1feHdheV9TdGFuZGluZ18xMSI6MCwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV80IjowLCAiYW50aWFpbV94d2F5X3ZhbHVlX0V4cGxvaXQtRGVmZW5zaXZlIjoyLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTYiOjAsICJhbnRpYWltX3h3YXlfT24tUGVla18xMyI6MCwgImFudGlhaW1feHdheV9HbG9iYWxfNyI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfNSI6MCwgImFudGlhaW1fbGJ5X29wdGlvbl9FeHBsb2l0LURlZmVuc2l2ZSI6Ik9wcG9zaXRlIiwgImFudGlhaW1fcGl0Y2hzdGVwX1N0YW5kaW5nIjoxLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTciOjAsICJhbnRpYWltX3h3YXlfT24tUGVla18xNCI6MCwgImFudGlhaW1fYm9keXlhd19vcHRpb25fU3RhbmRpbmciOlsiQXZvaWQgT3ZlcmxhcCJdLCAiYW50aWFpbV94d2F5X0dsb2JhbF84IjowLCAiYW50aWFpbV9sYnlfb3B0aW9uX0dsb2JhbCI6IkRpc2FibGVkIiwgImFudGlhaW1fYmZfd2F5X01hbnVhbC1BQV8xMyI6MCwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE4IjowLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMTUiOjAsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfMTIiOjAsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfMTEiOjAsICJhbnRpYWltX3h3YXlfR2xvYmFsXzkiOjAsICJhbnRpYWltX3BpdGNoX1N0YW5kaW5nIjoiRG93biIsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV8xOSI6MCwgImFudGlhaW1feHdheV9Pbi1QZWVrXzE2IjowLCAiYW50aWFpbV9iZl93YXlfTWFudWFsLUFBXzkiOjAsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWluX0Zha2UtRHVjayI6MSwgImFudGlhaW1feHdheV9HbG9iYWxfNSI6MCwgImFudGlhaW1feHdheV9HbG9iYWxfMTAiOjAsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV8yMCI6MCwgImFudGlhaW1feHdheV9Pbi1QZWVrXzE3IjowLCAiYW50aWFpbV94d2F5X01hbnVhbC1BQV8xOSI6MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtYXhfRmFrZS1EdWNrIjoxLCAiYW50aWFpbV94d2F5X01hbnVhbC1BQV8xNyI6MCwgImFudGlhaW1fcGl0Y2htb2RlX1N0YW5kaW5nIjoiRGVmYXVsdCIsICJhbnRpYWltX3h3YXlfR2xvYmFsXzExIjowLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMTgiOjAsICJhbnRpYWltX3lhd2xlZnRfQWlyLUR1Y2siOjMxLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtaW5fRmFrZS1EdWNrIjoxLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtaW5fTWFudWFsLUFBIjozMCwgImFudGlhaW1fYm9keXlhd19zdGVwX01hbnVhbC1BQSI6MSwgImFudGlhaW1fbGJ5X29wdGlvbl9BaXIiOiJEaXNhYmxlZCIsICJhbnRpYWltX3h3YXlfR2xvYmFsXzEyIjowLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzIwIjowLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfRmFrZS1EdWNrIjoxLCAiYW50aWFpbV9iYWNrd2FyZF9vZmZzZXRfU3RhbmRpbmciOjAsICJhbnRpYWltX2JvZHl5YXdfc3RlcF9BaXIiOjQsICJhbnRpYWltX3h3YXlfR2xvYmFsXzIwIjowLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMjAiOjAsICJhbnRpYWltX3h3YXlfR2xvYmFsXzEzIjowLCAiYW50aWFpbV9ib2R5eWF3X29wdGlvbl9GYWtlLUR1Y2siOnt9LCAiYW50aWFpbV9waXRjaG1vZGVfTWFudWFsLUFBIjoiRGVmYXVsdCIsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfMjAiOjAsICJhbnRpYWltX2JmX3ZhbHVlX09uLVBlZWsiOjIsICJhbnRpYWltX292ZXJyaWRlX1N0YW5kaW5nIjp0cnVlLCAiYW50aWFpbV9iZl93YXlfT24tUGVla18xNiI6MCwgImFudGlhaW1feHdheV9HbG9iYWxfMTQiOjAsICJhbnRpYWltX2xieV9vcHRpb25fRmFrZS1EdWNrIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9waXRjaHN0ZXBfQ3JvdWNoaW5nIjoxLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfTWFudWFsLUFBIjo2MCwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMSI6MCwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfNCI6MCwgImFudGlhaW1fYmZfd2F5X0Fpcl8xIjowLCAiYW50aWFpbV94d2F5X3ZhbHVlX0Zha2UtRHVjayI6MiwgImFudGlhaW1feHdheV9TdGFuZGluZ18xMiI6MCwgImFudGlhaW1fYm9keXlhd19vcHRpb25fTWFudWFsLUFBIjp7fSwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMiI6MCwgImFudGlhaW1fYm9keXlhd19tb2RlX0FpciI6IlN0YXRpYyIsICJhbnRpYWltX3h3YXlfT24tUGVla18xOSI6MCwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMSI6MCwgImFudGlhaW1feHdheV9Pbi1QZWVrXzEyIjowLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzEzIjowLCAiYW50aWFpbV9iZl93YXlfT24tUGVla18zIjowLCAiYW50aWFpbV9waXRjaG1vZGVfRXhwbG9pdC1EZWZlbnNpdmUiOiJSYW5kb20iLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdF9BaXIiOjYwLCAiYW50aWFpbV94d2F5X0Zha2UtRHVja18yIjowLCAiYW50aWFpbV94d2F5X0Fpcl8xIjotNDIsICJhbnRpYWltX3h3YXlfdmFsdWVfTWFudWFsLUFBIjoyLCAiYW50aWFpbV94d2F5X0dsb2JhbF8xNyI6MCwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF8yIjowLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRfQWlyIjo2MCwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMyI6MCwgImFudGlhaW1fYmZfd2F5X0Fpcl8zIjowLCAiYW50aWFpbV94d2F5X01hbnVhbC1BQV8xIjowLCAiYW50aWFpbV9iZl93YXlfT24tUGVla181IjowLCAiYW50aWFpbV94d2F5X0dsb2JhbF8xOCI6MCwgImFudGlhaW1fb3ZlcnJpZGVfRXhwbG9pdC1EZWZlbnNpdmUiOnRydWUsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzQiOjAsICJhbnRpYWltX292ZXJyaWRlX01hbnVhbC1BQSI6dHJ1ZSwgImFudGlhaW1feHdheV9NYW51YWwtQUFfMiI6MCwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfNiI6MCwgImFudGlhaW1feHdheV9BaXJfMiI6NDIsICJhbnRpYWltX3h3YXlfR2xvYmFsXzE5IjowLCAiYW50aWFpbV94d2F5X0Zha2UtRHVja181IjowLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzE5IjowLCAiYW50aWFpbV94d2F5X01hbnVhbC1BQV8zIjowLCAiYW50aWFpbV9iZl93YXlfT24tUGVla183IjowLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfR2xvYmFsIjoxLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1heF9BaXIiOjIzLCAiYW50aWFpbV94d2F5X0Zha2UtRHVja182IjowLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzUiOjAsICJhbnRpYWltX3h3YXlfTWFudWFsLUFBXzQiOjAsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzgiOjAsICJhbnRpYWltX3h3YXlfQWlyXzMiOi0yNCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWluX0FpciI6MSwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfNyI6MCwgImFudGlhaW1feHdheV9TdGFuZGluZ18xOCI6MCwgImFudGlhaW1feHdheV9BaXJfNCI6MjQsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzkiOjAsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfNiI6MCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWF4X0FpciI6MjMsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzgiOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfMTkiOjAsICJhbnRpYWltX3h3YXlfQWlyXzUiOjAsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzEwIjowLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzE4IjowLCAiYW50aWFpbV9ib2R5eWF3X29wdGlvbl9BaXIiOlsiQXZvaWQgT3ZlcmxhcCJdLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfNiI6MCwgImFudGlhaW1feHdheV9TdGFuZGluZ18yMCI6MCwgImFudGlhaW1feHdheV9BaXJfNiI6MCwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMTEiOjAsICJhbnRpYWltX3h3YXlfQWlyXzEzIjowLCAiYW50aWFpbV94d2F5X01hbnVhbC1BQV83IjowLCAiYW50aWFpbV9iZl92YWx1ZV9TdGFuZGluZyI6NSwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzciOjAsICJhbnRpYWltX3h3YXlfQWlyXzciOjAsICJhbnRpYWltX2JmX3ZhbHVlX1Nsb3ctV2FsayI6MiwgImFudGlhaW1feHdheV9BaXJfMTQiOjAsICJhbnRpYWltX3h3YXlfTWFudWFsLUFBXzgiOjAsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfMTgiOjAsICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ18xIjo0OCwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzkiOjAsICJhbnRpYWltX2JmX3dheV9BaXJfMiI6MCwgImFudGlhaW1feHdheV9BaXJfMTUiOjAsICJhbnRpYWltX3h3YXlfTWFudWFsLUFBXzkiOjAsICJhbnRpYWltX3BpdGNobW9kZV9Dcm91Y2hpbmciOiJEZWZhdWx0IiwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzIiOjMyLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzEzIjowLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMTAiOjAsICJhbnRpYWltX3h3YXlfQWlyXzE2IjowLCAiYW50aWFpbV94d2F5X01hbnVhbC1BQV8xMCI6MCwgImFudGlhaW1fYmFja3dhcmRfb2Zmc2V0X0V4cGxvaXQtRGVmZW5zaXZlIjowLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMyI6NDQsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWF4X01hbnVhbC1BQSI6NjAsICJhbnRpYWltX3h3YXlfQWlyXzEwIjowLCAiYW50aWFpbV94d2F5X0Fpcl8xNyI6MCwgImFudGlhaW1feHdheV9NYW51YWwtQUFfMTEiOjAsICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ18xMSI6MCwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzQiOjYwLCAiYW50aWFpbV9waXRjaF9FeHBsb2l0LURlZmVuc2l2ZSI6IkRpc2FibGVkIiwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa184IjowLCAiYW50aWFpbV94d2F5X0Fpcl8xOCI6MCwgImFudGlhaW1feHdheV9NYW51YWwtQUFfMTIiOjAsICJhbnRpYWltX3N3aXRjaCI6dHJ1ZSwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzUiOjQ0LCAiYW50aWFpbV9waXRjaHN0ZXBfRXhwbG9pdC1EZWZlbnNpdmUiOjIsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfNiI6MCwgImFudGlhaW1feHdheV9BaXJfMTkiOjAsICJhbnRpYWltX3h3YXlfTWFudWFsLUFBXzEzIjowLCAiYW50aWFpbV94d2F5X0Fpcl8xMiI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMTciOjAsICJhbnRpYWltX3BpdGNoMV9FeHBsb2l0LURlZmVuc2l2ZSI6IkZha2UgVXAiLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMTMiOjAsICJhbnRpYWltX3BpdGNoMl9Pbi1QZWVrIjoiRGlzYWJsZWQiLCAiYW50aWFpbV94d2F5X01hbnVhbC1BQV8xNCI6MCwgImFudGlhaW1fYmZfd2F5X01hbnVhbC1BQV8xOSI6MCwgImFudGlhaW1feWF3bW9kZV9TbG93LVdhbGsiOiJKaXR0ZXIiLCAiYW50aWFpbV9waXRjaDJfRXhwbG9pdC1EZWZlbnNpdmUiOiJEb3duIiwgImFudGlhaW1fYmZfdmFsdWVfQWlyIjoyLCAiYW50aWFpbV9yYW5kb21waXRjaHNfT24tUGVlayI6e30sICJhbnRpYWltX3h3YXlfTWFudWFsLUFBXzE1IjowLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMTQiOjAsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzE2IjowLCAiYW50aWFpbV9yYW5kb21waXRjaHNfRXhwbG9pdC1EZWZlbnNpdmUiOlsiRG93biIsICJGYWtlIFVwIl0sICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ18xNSI6MCwgImFudGlhaW1feWF3YmFzZV9Pbi1QZWVrIjoiTG9jYWwgVmlldyIsICJhbnRpYWltX3h3YXlfQWlyXzgiOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMTMiOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfNCI6MCwgImFudGlhaW1feWF3YmFzZV9FeHBsb2l0LURlZmVuc2l2ZSI6IkF0IFRhcmdldCIsICJhbnRpYWltX3BpdGNoX01hbnVhbC1BQSI6IkRvd24iLCAiYW50aWFpbV95YXdtb2RlX09uLVBlZWsiOiJEaXNhYmxlZCIsICJhbnRpYWltX3h3YXlfQWlyXzkiOjAsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfMTciOjAsICJhbnRpYWltX2JmX3ZhbHVlX0dsb2JhbCI6MiwgImFudGlhaW1feWF3bW9kZV9FeHBsb2l0LURlZmVuc2l2ZSI6IkRpc2FibGVkIiwgImFudGlhaW1feHdheV9BaXItRHVja18yMCI6MCwgImFudGlhaW1feWF3c3RlcF9Pbi1QZWVrIjoxLCAiYW50aWFpbV94d2F5X01hbnVhbC1BQV8xOCI6MCwgImFudGlhaW1fcGl0Y2hzdGVwX01hbnVhbC1BQSI6MSwgImFudGlhaW1fcGl0Y2gyX01hbnVhbC1BQSI6IkRpc2FibGVkIiwgImFudGlhaW1feWF3c3RlcF9FeHBsb2l0LURlZmVuc2l2ZSI6MiwgImFudGlhaW1fYmZfd2F5X01hbnVhbC1BQV8xNiI6MCwgImFudGlhaW1feWF3bGVmdF9Pbi1QZWVrIjowLCAiYW50aWFpbV94d2F5X0Fpcl8xMSI6MCwgImFudGlhaW1fYmZfd2F5X0Fpcl81IjowLCAiYW50aWFpbV9iZl93YXlfQWlyXzE4IjowLCAiYW50aWFpbV95YXdsZWZ0X0V4cGxvaXQtRGVmZW5zaXZlIjo5MCwgImFudGlhaW1fYmZfd2F5X0Fpcl8xNCI6MCwgImFudGlhaW1feWF3cmlnaHRfT24tUGVlayI6MCwgImFudGlhaW1feHdheV9NYW51YWwtQUFfMjAiOjAsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfMTUiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX29mZnNldF9NYW51YWwtQUEiOjAsICJhbnRpYWltX3lhd3JpZ2h0X0V4cGxvaXQtRGVmZW5zaXZlIjo5MCwgImFudGlhaW1fc3Bpbm9mZnNldF9HbG9iYWwiOjAsICJhbnRpYWltX2JmX3dheV9BaXJfNiI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfNCI6MCwgImFudGlhaW1feHdheV9BaXItRHVja18xNiI6MCwgImFudGlhaW1fYmZfd2F5X01hbnVhbC1BQV8xNCI6MCwgImFudGlhaW1fc3Bpbm9mZnNldF9FeHBsb2l0LURlZmVuc2l2ZSI6MzIsICJhbnRpYWltX3lhd21vZGlmaWVyX01hbnVhbC1BQSI6IkRpc2FibGVkIiwgImFudGlhaW1fYmZfd2F5X0Fpcl83IjowLCAiYW50aWFpbV9iZl93YXlfTWFudWFsLUFBXzEiOjAsICJhbnRpYWltX3JhbmRvbXBpdGNoc19GYWtlLUR1Y2siOnt9LCAiYW50aWFpbV94d2F5X0dsb2JhbF8xNiI6MCwgImFudGlhaW1feWF3bW9kaWZpZXJfRXhwbG9pdC1EZWZlbnNpdmUiOiJDZW50ZXIiLCAiYW50aWFpbV94d2F5X01hbnVhbC1BQV81IjowLCAiYW50aWFpbV9iZl93YXlfQWlyXzgiOjAsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfMiI6MCwgImFudGlhaW1feWF3YmFzZV9GYWtlLUR1Y2siOiJMb2NhbCBWaWV3IiwgImFudGlhaW1fYmZfd2F5X0Fpcl8xOSI6MCwgImFudGlhaW1feWF3bW9kaWZpZXJfb2Zmc2V0X0V4cGxvaXQtRGVmZW5zaXZlIjotMTIwLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMTYiOjAsICJhbnRpYWltX2JmX3dheV9BaXJfOSI6MCwgImFudGlhaW1fYmZfd2F5X01hbnVhbC1BQV8zIjowLCAiYW50aWFpbV95YXdtb2RlX0Zha2UtRHVjayI6IkRpc2FibGVkIiwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMTkiOjAsICJhbnRpYWltX2JvZHl5YXdfRXhwbG9pdC1EZWZlbnNpdmUiOmZhbHNlLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMTciOjAsICJhbnRpYWltX2JmX3dheV9BaXJfMTAiOjAsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfNCI6MCwgImFudGlhaW1feWF3c3RlcF9GYWtlLUR1Y2siOjEsICJhbnRpYWltX3JhbmRvbXBpdGNoc19NYW51YWwtQUEiOnt9LCAiYW50aWFpbV9waXRjaDFfTWFudWFsLUFBIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMTgiOjAsICJhbnRpYWltX2JmX3dheV9BaXJfMTEiOjAsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfNSI6MCwgImFudGlhaW1feWF3bGVmdF9GYWtlLUR1Y2siOjAsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMTAiOjAsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0X0V4cGxvaXQtRGVmZW5zaXZlIjo2MCwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzE5IjowLCAiYW50aWFpbV9iZl93YXlfQWlyXzEyIjowLCAiYW50aWFpbV9iZl93YXlfTWFudWFsLUFBXzYiOjAsICJhbnRpYWltX3lhd3JpZ2h0X0Zha2UtRHVjayI6MCwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18yIjowLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRfRXhwbG9pdC1EZWZlbnNpdmUiOjYwLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMjAiOjAsICJhbnRpYWltX2JmX3dheV9BaXJfMTMiOjAsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfNyI6MCwgImFudGlhaW1fc3Bpbm9mZnNldF9GYWtlLUR1Y2siOjAsICJhbnRpYWltX3lhd2xlZnRfU2xvdy1XYWxrIjozNiwgImFudGlhaW1feWF3YmFzZV9NYW51YWwtQUEiOiJMb2NhbCBWaWV3IiwgImFudGlhaW1fb3ZlcnJpZGVfUnVubmluZyI6dHJ1ZSwgImFudGlhaW1feHdheV9TbG93LVdhbGtfNyI6LTEyLCAiYW50aWFpbV9iZl93YXlfTWFudWFsLUFBXzgiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX0Zha2UtRHVjayI6IkRpc2FibGVkIiwgImFudGlhaW1fYmZfd2F5X0Fpcl8xNyI6MCwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMjAiOjAsICJhbnRpYWltX3lhd21vZGVfTWFudWFsLUFBIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9iYWNrd2FyZF9vZmZzZXRfUnVubmluZyI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfOCI6MCwgImFudGlhaW1feWF3bW9kaWZpZXJfb2Zmc2V0X0Zha2UtRHVjayI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfOSI6LTYsICJhbnRpYWltX2JmX3dheV9BaXJfMTYiOjAsICJhbnRpYWltX3lhd3N0ZXBfTWFudWFsLUFBIjoxLCAiYW50aWFpbV9waXRjaG1vZGVfUnVubmluZyI6IkRlZmF1bHQiLCAiYW50aWFpbV9iZl93YXlfUnVubmluZ185IjowLCAiYW50aWFpbV9ib2R5eWF3X0Zha2UtRHVjayI6ZmFsc2UsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfNCI6MCwgImFudGlhaW1fYmZfd2F5X0Fpcl8xNSI6MCwgImFudGlhaW1feWF3bGVmdF9NYW51YWwtQUEiOjAsICJhbnRpYWltX3BpdGNoX1J1bm5pbmciOiJEb3duIiwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMTAiOjAsICJhbnRpYWltX2JvZHl5YXdfbW9kZV9GYWtlLUR1Y2siOiJTdGF0aWMiLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa18xMCI6MCwgImFudGlhaW1feHdheV9HbG9iYWxfMTUiOjAsICJhbnRpYWltX3lhd3JpZ2h0X01hbnVhbC1BQSI6MCwgImFudGlhaW1fcGl0Y2hzdGVwX1J1bm5pbmciOjIsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzExIjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdF9GYWtlLUR1Y2siOjEsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzYiOjEyLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa18xMSI6MCwgImFudGlhaW1feWF3bGVmdF9HbG9iYWwiOjAsICJhbnRpYWltX3NwaW5vZmZzZXRfTWFudWFsLUFBIjowLCAiYW50aWFpbV9iZl93YXlfUnVubmluZ18xMiI6MCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0X0Zha2UtRHVjayI6MSwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMTgiOjAsICJhbnRpYWltX2JmX3dheV9BaXJfNCI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMTIiOjAsICJhbnRpYWltX2JmX3dheV9BaXJfMjAiOjAsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzEzIjowLCAiYW50aWFpbV9ib2R5eWF3X3N0ZXBfRmFrZS1EdWNrIjoxLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfU3RhbmRpbmciOjYwLCAiYW50aWFpbV95YXdzdGVwX1Nsb3ctV2FsayI6MSwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzgiOjAsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzEzIjowLCAiYW50aWFpbV9iZl93YXlfUnVubmluZ18xNCI6MCwgImFudGlhaW1fYmZfdmFsdWVfTWFudWFsLUFBIjoyLCAiYW50aWFpbV94d2F5X0Fpcl8yMCI6MCwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF83IjowLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzE0IjowLCAiYW50aWFpbV9ib2R5eWF3X01hbnVhbC1BQSI6ZmFsc2UsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzE1IjowLCAiYW50aWFpbV95YXdtb2RpZmllcl9vZmZzZXRfR2xvYmFsIjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1heF9Pbi1QZWVrIjoxLCAiYW50aWFpbV94d2F5X3ZhbHVlX0FpciI6NCwgImFudGlhaW1feHdheV9TdGFuZGluZ18xNCI6MCwgImFudGlhaW1fYm9keXlhd19tb2RlX01hbnVhbC1BQSI6IlJhbmRvbSIsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzE2IjowLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa18xNSI6MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRfQ3JvdWNoaW5nIjoxLCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfNiI6MCwgImFudGlhaW1fcmFuZG9tcGl0Y2hzX1N0YW5kaW5nIjp7fSwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRfTWFudWFsLUFBIjo2MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMTciOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfOCI6MCwgImFudGlhaW1fYm9keXlhd19zdGVwX0Fpci1EdWNrIjoxLCAiYW50aWFpbV9yYW5kb21waXRjaHNfQWlyIjp7fSwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzciOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdF9NYW51YWwtQUEiOjYwLCAiYW50aWFpbV9iZl93YXlfUnVubmluZ18xOCI6MCwgImFudGlhaW1fc3Bpbm9mZnNldF9TbG93LVdhbGsiOjAsICJhbnRpYWltX2JmX3dheV9BaXItRHVja185IjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1pbl9BaXItRHVjayI6MSwgImFudGlhaW1feWF3bW9kaWZpZXJfU2xvdy1XYWxrIjoiU3BpbiIsICJhbnRpYWltX2JmX3dheV9BaXItRHVja184IjowLCAiYW50aWFpbV9iZl93YXlfUnVubmluZ18xOSI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMTQiOjAsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfOSI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzEwIjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1heF9BaXItRHVjayI6MSwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtaW5fTWFudWFsLUFBIjozMCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMjAiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMTMiOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfMTYiOjAsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfOCI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzExIjowLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtaW5fQWlyLUR1Y2siOjEsICJhbnRpYWltX292ZXJyaWRlX0Nyb3VjaGluZyI6dHJ1ZSwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF8zIjowLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzE1IjowLCAiYW50aWFpbV94d2F5X01hbnVhbC1BQV82IjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18xMiI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzEyIjowLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa18yMCI6MCwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF80IjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1pbl9BaXIiOjEsICJhbnRpYWltX292ZXJyaWRlX09uLVBlZWsiOmZhbHNlLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzEiOjAsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMTEiOjAsICJhbnRpYWltX2JmX3dheV9BaXItRHVja18xMyI6MCwgImFudGlhaW1fYm9keXlhd19vcHRpb25fQWlyLUR1Y2siOnt9LCAiYW50aWFpbV9sYnlfb3B0aW9uX01hbnVhbC1BQSI6IkRpc2FibGVkIiwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRfU3RhbmRpbmciOjYwLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1pbl9TdGFuZGluZyI6MSwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfNyI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfNiI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzE0IjowLCAiYW50aWFpbV9sYnlfb3B0aW9uX0Fpci1EdWNrIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1pbl9HbG9iYWwiOjEsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzIwIjowLCAiYW50aWFpbV9iZl93YXlfT24tUGVla18xOSI6MCwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja181IjowLCAiYW50aWFpbV9iZl93YXlfT24tUGVla18xOCI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzE1IjowLCAiYW50aWFpbV94d2F5X3ZhbHVlX0Fpci1EdWNrIjoyLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzE3IjowLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzQiOjAsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzE3IjowLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzgiOjAsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfMyI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzE2IjowLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzEiOjAsICJhbnRpYWltX2JmX3ZhbHVlX1J1bm5pbmciOjIsICJhbnRpYWltX2JmX3ZhbHVlX0Zha2UtRHVjayI6MiwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja185IjowLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfNSI6MCwgImFudGlhaW1feHdheV92YWx1ZV9SdW5uaW5nIjo0LCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfMTciOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMiI6MCwgImFudGlhaW1feWF3cmlnaHRfQWlyIjoxMCwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18xMCI6MCwgImFudGlhaW1feWF3YmFzZV9TbG93LVdhbGsiOiJBdCBUYXJnZXQiLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1heF9HbG9iYWwiOjEsICJhbnRpYWltX3JhbmRvbXBpdGNoc19Dcm91Y2hpbmciOnt9LCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfMTgiOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMyI6MCwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18xMSI6MCwgImFudGlhaW1feWF3c3RlcF9BaXIiOjEsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1heF9BaXItRHVjayI6MSwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa18xNCI6MCwgImFudGlhaW1feWF3bW9kaWZpZXJfb2Zmc2V0X0Nyb3VjaGluZyI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzE5IjowLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzEyIjowLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE5IjowLCAiYW50aWFpbV9ib2R5eWF3X0FpciI6ZmFsc2UsICJhbnRpYWltX2JhY2t3YXJkX29mZnNldF9Dcm91Y2hpbmciOjAsICJhbnRpYWltX2JhY2t3YXJkX29mZnNldF9BaXIiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTEiOjAsICJhbnRpYWltX2JmX3dheV9BaXItRHVja18yMCI6MCwgImFudGlhaW1feHdheV9BaXItRHVja181IjowLCAiYW50aWFpbV9waXRjaDFfQWlyIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9waXRjaHN0ZXBfQWlyIjoxLCAiYW50aWFpbV9waXRjaF9BaXIiOiJEb3duIiwgImFudGlhaW1fcGl0Y2htb2RlX0FpciI6IkRlZmF1bHQiLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzE0IjowLCAiYW50aWFpbV9vdmVycmlkZV9GYWtlLUR1Y2siOmZhbHNlLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzYiOjAsICJhbnRpYWltX3lhd3JpZ2h0X0dsb2JhbCI6MCwgImFudGlhaW1fYmZfd2F5X0Nyb3VjaGluZ180IjowLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzMiOjAsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfMTUiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMTYiOjAsICJhbnRpYWltX2JhY2t3YXJkX29mZnNldF9GYWtlLUR1Y2siOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfNyI6MCwgImFudGlhaW1feWF3bW9kaWZpZXJfQ3JvdWNoaW5nIjoiRGlzYWJsZWQiLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18xOCI6MCwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18xNiI6MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMTciOjAsICJhbnRpYWltX3BpdGNobW9kZV9GYWtlLUR1Y2siOiJEZWZhdWx0IiwgImFudGlhaW1fcGl0Y2gyX1N0YW5kaW5nIjoiRGlzYWJsZWQiLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzgiOjAsICJhbnRpYWltX292ZXJyaWRlX0FpciI6dHJ1ZSwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18xNyI6MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRfQWlyLUR1Y2siOjEsICJhbnRpYWltX3BpdGNoX0Zha2UtRHVjayI6IkRpc2FibGVkIiwgImFudGlhaW1feHdheV9TdGFuZGluZ185IjowLCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzEwIjowLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzkiOjAsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfMTgiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfOSI6MCwgImFudGlhaW1fcGl0Y2hzdGVwX0Zha2UtRHVjayI6MSwgImFudGlhaW1feWF3cmlnaHRfU2xvdy1XYWxrIjozNiwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa18zIjowLCAiYW50aWFpbV9waXRjaDFfQWlyLUR1Y2siOiJEaXNhYmxlZCIsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMTAiOjAsICJhbnRpYWltX2JvZHl5YXdfbW9kZV9FeHBsb2l0LURlZmVuc2l2ZSI6IlN0YXRpYyIsICJhbnRpYWltX3BpdGNoMV9GYWtlLUR1Y2siOiJEaXNhYmxlZCIsICJhbnRpYWltX2JvZHl5YXdfbW9kZV9BaXItRHVjayI6IlN0YXRpYyIsICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ18xMiI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfOCI6NiwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18yMCI6MCwgImFudGlhaW1feHdheV9BaXItRHVja18xMSI6MCwgImFudGlhaW1fcGl0Y2gyX0Zha2UtRHVjayI6IkRpc2FibGVkIiwgImFudGlhaW1fYm9keXlhd19vcHRpb25fT24tUGVlayI6e30sICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWluX0Nyb3VjaGluZyI6MSwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMTMiOjAsICJhbnRpYWltX3h3YXlfdmFsdWVfR2xvYmFsIjozLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzE5IjowLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzEyIjowLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzMiOjAsICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzEzIjowLCAiYW50aWFpbV94d2F5X0dsb2JhbF8xIjowLCAiYW50aWFpbV9iYWNrd2FyZF9vZmZzZXRfT24tUGVlayI6MCwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMTIiOjB9=",
    username = common_get_username(),
    useravatar = render.load_image(network_get("https://en.neverlose.cc/static/avatars/" .. common_get_username() .. ".png"), vector(18, 18)),
    screen_size = render_screen_size(),

    fonts = {
        calibriba = render_load_font("Calibri", 24, "ba") or error('Fonts Error: Calibri Not Found'),
        pixel14odu = render_load_font("nl\\Crow\\Fonts\\smallest_pixel-7.ttf", 14, "odu") or error('Fonts Error: Smallest Pixel-7 Not Found'),
    },

    gif_crc32 = -763495444,
    loadwav_crc32 = 1086899440,
    attackedwav_crc32 = 2039641075,

    gif = nil,

    ffi_helper = {
        PlaySound = utils_get_vfunc("engine.dll", "IEngineSoundClient003", 12, "void*(__thiscall*)(void*, const char*, float, int, int, float)"),
    },

    hitgroups = {
        ["zh_CN"] = {
            [0] = "全身",
            [1] = "头部",
            [2] = "胸部",
            [3] = "胃部",
            [4] = "左臂",
            [5] = "右臂",
            [6] = "左腿",
            [7] = "右腿",
            [10] = "未知",
        },

        ["en_US"] = {
            [0] = "Systemic",
            [1] = "Head",
            [2] = "Chest",
            [3] = "Stomach",
            [4] = "L Arm",
            [5] = "R Arm",
            [6] = "L Leg",
            [7] = "R Leg",
            [10] = "UNKNON"
        },
    },

    hitlogstr = {
        ["zh_CN"] = {
            ["Chat"] = {
                ["hit"] = "\x01 \x06[G8]\x01 击中\x01 \x06%s\x01 的\x01 \x06%s\x01 伤害\x01 \x06%i(%i)\x01 剩余\x01 \x06%i\x01 命中率\x01 \x06%i\x01",
                ["miss"] = "\x01 \x07[G8]\x01 空了\x01 \x07%s\x01 的\x01 \x07%s\x01 原因\x01 \x07%s\x01 命中率\x01 \x07%i\x01 回溯\x01 \x07%i\x01",
            },

            ["Console"] = {
                ["hit"] = "\a90ED89[G8]\aFFFFFF 击中 \a90ED89%s\aFFFFFF 的 \a90ED89%s\aFFFFFF 伤害 \a90ED89%i(%i)\aFFFFFF 剩余 \a90ED89%i\aFFFFFF 命中率 \a90ED89%i\aFFFFFF 回溯 \a90ED89%i",
                ["miss"] = "\aFF0000[G8]\aFFFFFF 空了 \aFF0000%s\aFFFFFF 的 \aFF0000%s\aFFFFFF 原因 \aFF0000%s\aFFFFFF 命中率 \aFF0000%i\aFFFFFF 回溯 \aFF0000%i",
            },

            ["Screen"] = {
                ["hit"] = "击中 %s 的 %s 伤害 %i(%i) 剩余 %i 命中率 %i",
                ["miss"] = "空了 %s 的 %s 原因 %s 命中率 %i 回溯 %i",
            },
        },

        ["en_US"] = {
            ["Chat"] = {
                ["hit"] = "\x01 \x06[G8]\x01 Fired at\x01 \x06%s\x01's\x01 \x06%s\x01 dmg\x01 \x06%i(%i)\x01 remaining\x01 \x06%i\x01 hc\x01 \x06%i\x01",
                ["miss"] = "\x01 \x07[G8]\x01 Miss\x01 \x07%s\x01's\x01 \x07%s\x01 due to\x01 \x07%s\x01 hc\x01 \x07%i\x01 bt\x01 \x07%i\x01",
            },

            ["Console"] = {
                ["hit"] = "\a90ED89[G8]\aFFFFFF Fired at \a90ED89%s\aFFFFFF's \a90ED89%s\aFFFFFF dmg \a90ED89%i(%i)\aFFFFFF remaining \a90ED89%i\aFFFFFF hc \a90ED89%i\aFFFFFF bt \a90ED89%i",
                ["miss"] = "\aFF0000[G8]\aFFFFFF Miss \aFF0000%s\aFFFFFF's \aFF0000%s\aFFFFFF due to \aFF0000%s\aFFFFFF hc \aFF0000%i\aFFFFFF bt \aFF0000%i\aFFFFFF",
            },

            ["Screen"] = {
                ["hit"] = "Fired at %s's %s dmg %i(%i) remaining %i hc %i",
                ["miss"] = "Miss %s's %s due to %s hc %i bt %i",
            },
        },
    },

    missreason = {
        ["spread"] = "扩散",
        ["correction"] = "解析",
        ["misprediction"] = "预判错误",
        ["prediction error"] = "预判失败",
        ["lagcomp failure"] = "回溯失败",
        ["unregistered shot"] = "未注册射击",
        ["player death"] = "目标死亡",
        ["death"] = "死亡",
    },

	weapon_names = {
	    "Global",
	    "Scout",
	    "Auto",
	    "AWP",
	    "Heavy Pistols",
	    "Pistols",
	    "Zeus"
	},


    player_states_aa = {
        "Global",
        "Standing",
        "Running",
        "Crouching",
        "Slow-Walk",
        "Air",
        "Air-Duck",
        "Fake-Duck",
        "On-Peek",
        "Manual-AA",
        "Exploit-Defensive",
    },

    player_states_fl = {
        "Global",
        "Standing",
        "Running",
        "Crouching",
        "Slow-Walk",
        "Air",
        "Air-Duck",
        "Fake-Duck",
        "On-Peek",
    },

    aa_manuals = {
        "Forward",
        "Backward",
        "Left",
        "Right",
    },


    yaw_modes = {
        "Disabled",
        "Jitter",
        "Random",
        "Spin",
        "X-Way",
    },

    aa_modes = {
        "Disabled",
        "Center",
        "Offset",
        "Random",
        "Spin",
    },


    fl_modes = {
        "Static",
        "Jitter",
        "Random",
        "Fluctuate",
        "Fluctuate-Update",
        "Always-Choke",
        "Custom-Builder",
    },


    tabs = {
        main = ui_get_icon("home") .. G8.funs.gradient_text(48, 207, 208, 255, 51, 8, 103, 255, " Main"),
        ragebot = ui_get_icon("fist-raised") .. G8.funs.gradient_text(48, 207, 208, 255, 51, 8, 103, 255, " Ragebot"),
        antiaim = ui_get_icon("shield-alt") .. G8.funs.gradient_text(48, 207, 208, 255, 51, 8, 103, 255, " Anti-Aim"),
        fakelag = ui_get_icon("walking") .. G8.funs.gradient_text(48, 207, 208, 255, 51, 8, 103, 255, " Fake-Lag"),
        visual = ui_get_icon("eye") .. G8.funs.gradient_text(48, 207, 208, 255, 51, 8, 103, 255, " Visual"),
        misc = ui_get_icon("wrench") .. G8.funs.gradient_text(48, 207, 208, 255, 51, 8, 103, 255, " Misc"),
        config = ui_get_icon("save") .. G8.funs.gradient_text(48, 207, 208, 255, 51, 8, 103, 255, " Config"),
    },

}

G8.defs.groups = {
    main = {
        main = ui_create(G8.defs.tabs.main, ui_get_icon("house-user") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Main")),
        texture = ui_create(G8.defs.tabs.main, ui_get_icon("image") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " G8")),
    },

    rage = {
        ragebot = ui_create(G8.defs.tabs.ragebot, ui_get_icon("user-ninja") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Weapon Builder")),
        doubletap = ui_create(G8.defs.tabs.ragebot, ui_get_icon("battery-three-quarters") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Double-Tap Builder")),
        misc = ui_create(G8.defs.tabs.ragebot, ui_get_icon("dove") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Misc")),
    },

    antiaim = {
        main =  ui_create(G8.defs.tabs.antiaim, ui_get_icon("user-shield") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Main")),
        builder = ui_create(G8.defs.tabs.antiaim, ui_get_icon("hdd") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Anti-Aim Builder")),
        xwaybuilder = ui_create(G8.defs.tabs.antiaim, ui_get_icon("otter") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " X-Way Builder")),
        bfbuilder = ui_create(G8.defs.tabs.antiaim, ui_get_icon("otter") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Anti-Bruteforce Builder")),
        -- exploit = ui_create(G8.defs.tabs.antiaim, ui_get_icon("bug") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Exploit Anti-Aim")),
    },

    fakelag = {
        main = ui_create(G8.defs.tabs.fakelag, ui_get_icon("snowboarding") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Main")),
        builder = ui_create(G8.defs.tabs.fakelag, ui_get_icon("hdd") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Fake-Lag Builder")),
        custom_builder = ui_create(G8.defs.tabs.fakelag, ui_get_icon("otter") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Custom Builder")),
    },

    visual = {
        aspect_ratio = ui_create(G8.defs.tabs.visual, ui_get_icon("glasses") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Aspect Ratio")),
        view_model = ui_create(G8.defs.tabs.visual, ui_get_icon("street-view") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " View Model Changer")),
        solus_ui = ui_create(G8.defs.tabs.visual, ui_get_icon("window-restore") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Solus UI")),
        crosshair_indicator = ui_create(G8.defs.tabs.visual, ui_get_icon("crosshairs") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Crosshair Indicator")),
        skeet_indicator = ui_create(G8.defs.tabs.visual, ui_get_icon("window-maximize") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Skeet Indicator")),
        scope_overlay = ui_create(G8.defs.tabs.visual, ui_get_icon("camera-retro") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Scope Overlay")),
    },

    misc = {
        logs = ui_create(G8.defs.tabs.misc, ui_get_icon("video") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Logs")),
        camera_changer = ui_create(G8.defs.tabs.misc, ui_get_icon("camera") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Camera Changer")),
        unsafe_feature = ui_create(G8.defs.tabs.misc, ui_get_icon("exclamation-triangle") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Unsafe Features")),
    },

    config = {
        global = ui_create(G8.defs.tabs.config, ui_get_icon("globe-asia") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Global Config")),
        antiaim = ui_create(G8.defs.tabs.config, ui_get_icon("user-shield") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Anti-Aim Config")),
        fakelag = ui_create(G8.defs.tabs.config, ui_get_icon("walking") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Fake-Lag Config")),
        visual = ui_create(G8.defs.tabs.config, ui_get_icon("eye") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Visuals Config")),
    },
}


-- DEFS END








-- VARS START

G8.vars = {
    prepare_timer = 0,
    shot_num = 0,
    flick_invert = false,
    velocity = 0,
    duck_amount = 0,
    on_ground = 0,
    on_ground_ticks = 0,
    invert = false,
    desync_value = 0,
    aa_dir = 0,
    player_state = "",
    last_player_state = "",
    teleported = true,
    speeds = {},
    last_origin = 0,
    breaking_lc = 0,
    yaw_way = 1,
    bf_way = 1,
    fl_way = 1,
    fl_tick = 0,
    be_attacked = false,
    defensive_tick = 0,
    temp_fl = 1,
    fl_limit = 1,
    block_charge = 0,
    send_tick = 0,
    last_weapon = 0,
    last_value = 0,
    weapon_state = "Default",
    load_timer = 0,
    log_list = {},
    hooked_function = nil,
    is_jumping = false,
    attacked_str = {},
    attacked_say_time = 0,
    crosshair_list = {G8.defs.screen_size.x / 2, G8.defs.screen_size.x / 2, G8.defs.screen_size.x / 2},
    choked_history = {0,0,0,0,0},
}

-- VARS END





-- REFS START

G8.refs = {
    ragebot = {
        weapon = {
            minimum_damage      = ui_find("Aimbot", "ragebot", "Selection", "Minimum Damage"),
            hit_chance          = ui_find("Aimbot", "ragebot", "Selection", "Hit Chance"),
        },

        hide_shot = {
            switch              = ui_find("Aimbot", "ragebot", "Main", "Hide Shots"),
            options             = ui_find("Aimbot", "ragebot", "Main", "Hide Shots", "Options"),
        },

        double_tap = {
            switch              = ui_find("Aimbot", "ragebot", "Main", "Double Tap"),
            fakelag_options     = ui_find("Aimbot", "ragebot", "Main", "Double Tap", "Leg Options"),
            fakelag_limit       = ui_find("Aimbot", "ragebot", "Main", "Double Tap", "Fake Lag Limit"),
        },

        misc = {
            peek_assist         = ui_find("Aimbot", "ragebot", "Main", "Peek Assist"),
            dormant_aimbot      = ui_find("Aimbot", "ragebot", "Main", "Enabled", "Dormant Aimbot"),
        },
    },

    antiaim = {
        pitch                   = ui_find("Aimbot", "Anti Aim", "Angles", "Pitch"),

        yaw = {
            mode                = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw"),
            base                = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"),
            offset              = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"),
            modifier            = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier"),
            modifier_degree     = ui_find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset"),
            freestanding        = ui_find("Aimbot", "Anti Aim", "Angles", "Freestanding"),
        },

        body_yaw = {
            switch              = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw"),
            inverter            = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter"),
            left_limit          = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit"),
            right_limit         = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit"),
            options             = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Options"),
            freestanding        = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding"),
            onshot              = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "On Shot"),
            lby_mode            = ui_find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "LBY Mode"),
        },

        fakelag = {
            switch              = ui_find("Aimbot", "Anti Aim", "Fake Lag", "Enabled"),
            limit               = ui_find("Aimbot", "Anti Aim", "Fake Lag", "Limit"),
            variability         = ui_find("Aimbot", "Anti Aim", "Fake Lag", "Variability"),
        },

        misc = {
            fake_duck           = ui_find("Aimbot", "Anti Aim", "Misc", "Fake Duck"),
            slow_walk           = ui_find("Aimbot", "Anti Aim", "Misc", "Slow Walk"),
            leg_movement        = ui_find("Aimbot", "Anti Aim", "Misc", "Leg Movement"),
            ex_switch           = ui_find("Aimbot", "Anti Aim", "Angles", "Extended Angles"),
            ex_roll             = ui_find("Aimbot", "Anti Aim", "Angles", "Extended Angles", "Extended Roll"),
            ex_pitch            = ui_find("Aimbot", "Anti Aim", "Angles", "Extended Angles", "Extended Pitch"),
        },
    },

    visual = {
        thirdperson             = ui_find("Visuals", "World", "Main", "Force Thirdperson"),
        hitsound                = ui_find("Visuals", "World", "Other", "Hit Marker Sound"),
        scope_overlay           = ui_find("Visuals", "World", "Main", "Override Zoom", "Scope Overlay"),
    },

    misc = {
        air_strafe              = ui_find("Miscellaneous", "Main", "Movement", "Air Strafe"),
        fake_latency            = ui_find("Miscellaneous", "Main", "Other", "Fake Latency"),
    },
}

-- REFS END

-- FEAT START

G8.feat.updatevar = function (cmd)
    local lp = entity_get_local_player()

    if not lp or not lp:is_alive() then
        G8.vars.velocity = 0
        G8.vars.duck_amount = 0
        G8.vars.on_ground = 0
        G8.vars.on_ground_ticks = 0
        G8.vars.invert = false
        G8.vars.desync_value = 0
        G8.vars.aa_dir = 0
        return
    end

    G8.vars.is_jumping = bit.band(cmd.buttons, 2) ~= 0

    local vel = lp.m_vecVelocity
    G8.vars.velocity = math.sqrt(vel.x * vel.x + vel.y * vel.y)
    G8.vars.duck_amount = lp.m_flDuckAmount
    G8.vars.on_ground = bit.band(lp["m_fFlags"], 1)
    G8.vars.invert = (math.floor(math.min(G8.refs.antiaim.body_yaw.left_limit:get(), lp.m_flPoseParameter[11] * (G8.refs.antiaim.body_yaw.left_limit:get() * 2) - G8.refs.antiaim.body_yaw.left_limit:get()))) > 0
    G8.vars.desync_value = lp.m_flPoseParameter[11] * 120 - 60

    if G8.vars.on_ground == 1 then
        G8.vars.on_ground_ticks = G8.vars.on_ground_ticks + 1
    else
        G8.vars.on_ground_ticks = 0
    end

    if G8.refs.ragebot.misc.peek_assist:get() and G8.vars.velocity > 5 and G8.vars.on_ground_ticks > 8 and not G8.refs.antiaim.misc.slow_walk:get() then
        G8.vars.player_state = "On-Peek"
    elseif G8.refs.antiaim.misc.fake_duck:get() and G8.vars.on_ground_ticks > 8 then
        G8.vars.player_state = "Fake-Duck"
    elseif G8.vars.on_ground_ticks < 2 and G8.vars.duck_amount > 0.8 then
        G8.vars.player_state = "Air-Duck"
    elseif G8.vars.on_ground_ticks < 2 then
        G8.vars.player_state = "Air"
    elseif G8.refs.antiaim.misc.slow_walk:get() and G8.vars.velocity > 5 then
        G8.vars.player_state = "Slow-Walk"
    elseif G8.vars.duck_amount > 0.8 and G8.vars.on_ground_ticks > 8 then
        G8.vars.player_state = "Crouching"
    elseif G8.vars.velocity > 5 and not G8.vars.is_jumping and not G8.refs.antiaim.misc.slow_walk:get() then
        G8.vars.player_state = "Running"
    elseif G8.vars.velocity <= 5 and not G8.vars.is_jumping then
        G8.vars.player_state = "Standing"
    else
        G8.vars.player_state = "Global"
    end



    if cmd.choked_commands == 0 then
        if not globals.is_in_game or not globals.is_connected or lp == nil then return end
        if globals.choked_commands == 0 then
            local origin = lp.m_vecOrigin
            local teleport = 0

            if G8.vars.last_origin ~= nil then
                teleport = (origin - G8.vars.last_origin):length2d()
                table.insert(G8.vars.speeds, #G8.vars.speeds, teleport)
            end

            G8.vars.last_origin = origin
        end
    end

    if #G8.vars.speeds > 3 then
        table.remove(G8.vars.speeds, 1)
    end

    G8.breaking_lc = G8.funs.get_average(G8.vars.speeds) > 65 and 1 or (rage_exploit:get() > 0.7 and 2 or 0)
end


G8.feat.weapon_builder = function ()
    if not UI.get("ragebot_switch") then return end

    local me = entity_get_local_player()
    if not me or not me:is_alive() then
        return
    end

    local weapon = me:get_player_weapon()

    if weapon == nil then
        return
    end

    local weapon_name = weapon:get_weapon_info().weapon_name
    weapon_name = G8.funs.get_weapon_group(weapon_name)

    if not UI.get("ragebot_override_switch_" .. weapon_name) then
        G8.refs.ragebot.weapon.minimum_damage:override()
        G8.refs.ragebot.weapon.hit_chance:override()
        G8.vars.weapon_state = "Default"
        return
    end

    local override_mode = ""

    if UI.get("ragebot_override_key") then
        override_mode = "Override"
    elseif G8.vars.player_state == "Air" or G8.vars.player_state == "Air-Duck" then
        override_mode = "Air"
    elseif not me.m_bIsScoped then
        override_mode = "No-Scope"
    end

    if UI.contains("ragebot_override_list_" .. weapon_name, override_mode) then
        G8.refs.ragebot.weapon.minimum_damage:override(UI.get("ragebot_" .. override_mode .. "_dmg_" .. weapon_name))
        G8.refs.ragebot.weapon.hit_chance:override(UI.get("ragebot_" .. override_mode .. "_hc_" .. weapon_name))
        G8.vars.weapon_state = override_mode
    else
        G8.refs.ragebot.weapon.minimum_damage:override()
        G8.refs.ragebot.weapon.hit_chance:override()
        G8.vars.weapon_state = "Default"
    end
end

G8.feat.tp_onkey = function ()
    if not G8.refs.ragebot.double_tap.switch:get() then return end

    if not UI.get("ragebot_doubletap") or not UI.get("ragebot_doubletap_tp") then return end


    rage_exploit:force_teleport()
    utils_execute_after(0.1, function()
        UI.set("ragebot_doubletap_tp", false)
    end)
end

G8.feat.clock_correction = function ()
    if not G8.refs.ragebot.double_tap.switch:get() then
        cvar.cl_clock_correction:int(1)
        return
    end

    if not UI.get("ragebot_doubletap") or not UI.get("ragebot_clock_correction") then
        return
    end

    cvar.cl_clock_correction:int(0)
end

G8.feat.dt_defensive = function (cmd)
    if not G8.refs.ragebot.double_tap.switch:get() then return end

    if not UI.get("ragebot_doubletap") or not UI.get("ragebot_defensive") then
        return
    end

    local me = entity_get_local_player()
    if not me or not me:is_alive() then return end

    if (G8.vars.velocity <= UI.get("ragebot_defensive_velocity")) then
        rage_exploit:allow_defensive(true)
        cmd.force_defensive = true
    else
        rage_exploit:allow_defensive(false)
    end
end

G8.feat.dt_tickbase = function ()
    if not G8.refs.ragebot.double_tap.switch:get() then return end

    if not UI.get("ragebot_doubletap") or not UI.get("ragebot_tickbase") then
        return
    end

    if not entity_get_local_player() then return end

    cvar.sv_maxusrcmdprocessticks:int(UI.get("ragebot_tickbase_value"))
end

G8.feat.auto_tp = function ()
    if not G8.refs.ragebot.double_tap.switch:get() then return end

    if not UI.get("ragebot_doubletap") or not UI.get("ragebot_autotp") then
        return
    end

    local me = entity_get_local_player()
    if not me or not me:is_alive() then return end
    if not me:get_player_weapon() then return end
    local weapon_index = me:get_player_weapon():get_weapon_index()

    entity_get_players(true, false, function(ent)
        if me["m_fFlags"] ~= 256 or me["m_fFlags"] ~= 262 and weapon_index ~= 40 then return end
        if ent:is_visible() and ent:is_alive() then
            if G8.vars.teleported then
                rage_exploit:force_teleport()
                G8.vars.teleported = false
            end
        else
            G8.vars.teleported = true
        end
    end)
end

G8.feat.jump_scout = function ()
    if not UI.get("ragebot_jumpscout") then
        G8.refs.misc.air_strafe:override()
    end

    local me = entity_get_local_player()

    if not me:is_alive() then
        return
    end

    local weapon = me:get_player_weapon()

    if weapon == nil then
        return
    end

    if (is_button_down(0x41) or is_button_down(0x53) or is_button_down(0x44) or is_button_down(0x57)) or G8.vars.velocity > 5 then
        G8.refs.misc.air_strafe:override(true)
    else
        if weapon:get_weapon_index() ~= 40 then
            G8.refs.misc.air_strafe:override()
        else
            G8.refs.misc.air_strafe:override(false)
        end
    end
end

-- G8.feat.fix_aa = function (cmd)
--     local me = entity_get_local_player()

--     if not me or not me:is_alive() then return end

--     local active_weapon = me:get_player_weapon(false)

--     local is_bomb_in_hand = false

--     if active_weapon then
--         is_bomb_in_hand = active_weapon:get_classname() == "CC4"
--     end

--     local is_in_bombzone = me.m_bInBombZone
--     local is_planting = is_in_bombzone and is_bomb_in_hand

--     local planted_c4_table = entity_get_entities("CPlantedC4")
--     local is_c4_planted = #planted_c4_table > 0
--     local bomb_distance = 0

--     if is_c4_planted then
--         local c4_entity = planted_c4_table[#planted_c4_table]

--         local c4_origin = c4_entity:get_origin()
--         local my_origin = me:get_origin()

--         bomb_distance = my_origin:dist(c4_origin)
--     end

--     local is_defusing = bomb_distance < 62 and me.m_iTeamNum == 3

--     if is_defusing then
--         return
--     end

--     -- local camera_angles = render_camera_angles()

--     -- local eye_position = me:get_eye_position()

--     -- local forward_vector = cheat_AngleToForward(camera_angles)

--     -- local trace_end = eye_position + forward_vector * 8192

--     -- local trace = EngineTrace_TraceRay(eye_position, trace_end, me, 0x4600400B)

--     -- local is_using = is_holding_use

--     -- if trace and trace.fraction < 1 and trace.hit_entity then
--     --     local class_name = trace.hit_entity:GetClassName()
--     --     is_using = class_name ~= "CWorld" and class_name ~= "CFuncBrush" and class_name ~= "CCSPlayer"
--     -- end

--     if not is_planting then
--         cmd.in_use = false
--     end
-- end

G8.feat.adaptive_backtrack = function ()
    if not UI.get("ragebot_adaptive") then return end

    local me = entity_get_local_player()
    if not me or not me:is_alive() then return end
    if not me:get_player_weapon() then return end
    local weapon_index = me:get_player_weapon():get_weapon_index()

    if weapon_index and weapon_index == 40 or weapon_index == 9 then
        G8.refs.misc.fake_latency:set(150)
    else
        G8.refs.misc.fake_latency:set(math.min(math.max(0, 200 - math.floor(math.max(0, utils_net_channel().latency[0] * 1000))), 200))
    end
end

G8.feat.anti_aim = function (cmd)
    if not UI.get("antiaim_switch") then return end
    if not entity_get_local_player() then return end


    local function setvalues(tab)
        G8.refs.antiaim.pitch:set(tab.pitch)
        G8.refs.antiaim.yaw.mode:set(tab.yawmode)
        G8.refs.antiaim.yaw.base:set(tab.yawbase)
        G8.refs.antiaim.yaw.offset:set(tab.yawoffset)
        G8.refs.antiaim.yaw.modifier:set(tab.yawmodifier)
        G8.refs.antiaim.yaw.modifier_degree:set(tab.yawmodifier_offset)
        G8.refs.antiaim.body_yaw.switch:set(tab.bodyyaw)
        G8.refs.antiaim.body_yaw.left_limit:set(tab.bodyyaw_left)
        G8.refs.antiaim.body_yaw.right_limit:set(tab.bodyyaw_right)
        G8.refs.antiaim.body_yaw.options:set(tab.bodyyaw_options)
        G8.refs.antiaim.body_yaw.lby_mode:set(tab.bodyyaw_lby)
    end



    local _data = {
        pitch = G8.refs.antiaim.pitch:get(),
        yawmode = "Backward",
        yawbase = "Local View",
        yawoffset = G8.refs.antiaim.yaw.offset:get(),
        yawmodifier = "Disabled",
        yawmodifier_offset = 0,
        bodyyaw = false,
        bodyyaw_left = G8.refs.antiaim.body_yaw.left_limit:get(),
        bodyyaw_right = G8.refs.antiaim.body_yaw.right_limit:get(),
        bodyyaw_options = {},
        bodyyaw_lby = "Disabled",
    }

    local state = G8.vars.player_state
    if state == "On-Peek" and not UI.get("antiaim_override_On-Peek") then state = "Running" end
    state = UI.get("antiaim_override_" .. state) and state or "Global"

    if G8.refs.ragebot.double_tap.switch:get() and rage_exploit:get() ~= 1 and UI.get("antiaim_override_Exploit-Defensive") and not G8.refs.antiaim.misc.fake_duck:get() and G8.vars.defensive_tick > 0 then
        state = "Exploit-Defensive"
        G8.vars.defensive_tick = G8.vars.defensive_tick - 1
    end

    local offset = 0

    local manual
    if state ~= "Exploit-Defensive" then
        manual = UI.get("antiaim_manual")
        if manual == "Forward" then
            offset = 180
        elseif manual == "Backward" then
            offset = UI.get("antiaim_backward_offset_" .. state)
        elseif manual == "Left" then
            offset = -93
        elseif manual == "Right" then
            offset = 92
        end
    end

    if UI.get("antiaim_override_Manual-AA") and UI.contains("antiaim_override_manuals", manual) then
        state = "Manual-AA"
    end

    if UI.get("antiaim_pitchmode_" .. state) == "Default" then
        _data.pitch = UI.get("antiaim_pitch_" .. state)
    elseif UI.get("antiaim_pitchmode_" .. state) == "Jitter" then
        if cmd.tickcount % UI.get("antiaim_pitchstep_" .. state) == 0 then
            _data.pitch = G8.refs.antiaim.pitch:get()
            if _data.pitch == UI.get("antiaim_pitch1_" .. state) then
                _data.pitch = UI.get("antiaim_pitch2_" .. state)
            else
                _data.pitch = UI.get("antiaim_pitch1_" .. state)
            end
        end
    elseif UI.get("antiaim_pitchmode_" .. state) == "Random" then
        local tab = UI.get("antiaim_randompitchs_" .. state)
        if #tab == 0 then
            _data.pitch = "Down"
        elseif cmd.tickcount % UI.get("antiaim_pitchstep_" .. state) == 0 then
            _data.pitch = tab[utils_random_int(1, #tab)]
        end
    end

    _data.yawmode = "Backward"
    _data.yawbase = UI.get("antiaim_yawbase_" .. state)

    local yawmode = UI.get("antiaim_yawmode_" .. state)

    if yawmode == "Disabled" then
        _data.yawoffset = offset
    elseif yawmode == "Jitter" then
        if cmd.tickcount % UI.get("antiaim_yawstep_" .. state) == 0 then
            if G8.refs.antiaim.yaw.offset:get() == UI.get("antiaim_yawright_" .. state) + offset then
                _data.yawoffset = -UI.get("antiaim_yawleft_" .. state) + offset
            else
                _data.yawoffset = UI.get("antiaim_yawright_" .. state) + offset
            end
        end
    elseif yawmode == "Random" then
        if cmd.tickcount % UI.get("antiaim_yawstep_" .. state) == 0 then
            _data.yawoffset = utils_random_int(-UI.get("antiaim_yawleft_" .. state), UI.get("antiaim_yawright_" .. state)) + offset
        end
    elseif yawmode == "Spin" then
        if cmd.tickcount % UI.get("antiaim_yawstep_" .. state) == 0 then
            _data.yawoffset = G8.refs.antiaim.yaw.offset:get() + UI.get("antiaim_spinoffset_" .. state)
        end
    elseif yawmode == "X-Way" then
        if cmd.tickcount % UI.get("antiaim_yawstep_" .. state) == 0 then
            G8.vars.yaw_way = G8.vars.yaw_way + 1
            if G8.vars.yaw_way > UI.get("antiaim_xway_value_" .. state) then G8.vars.yaw_way = 1 end
            _data.yawoffset = UI.get("antiaim_xway_" .. state .. "_" .. G8.vars.yaw_way) + offset
        end
    end

    _data.yawmodifier = UI.get("antiaim_yawmodifier_" .. state)
    _data.yawmodifier_offset = UI.get("antiaim_yawmodifier_offset_" .. state)


    if _data.yawoffset > 180 then
        _data.yawoffset = _data.yawoffset - 360
    end

    if _data.yawoffset < -180 then
        _data.yawoffset = _data.yawoffset + 360
    end

    if UI.contains("antiaim_disable_yaw", manual) then
        _data.yawoffset = offset
        _data.yawmodifier = "Disabled"
    end

    if UI.contains("antiaim_disable_attarget", manual) then
        _data.yawbase = "Local View"
    end

    _data.bodyyaw = UI.get("antiaim_bodyyaw_" .. state)

    local bodyyawmode = UI.get("antiaim_bodyyaw_mode_" .. state)
    if bodyyawmode == "Static" then
        _data.bodyyaw_left = UI.get("antiaim_bodyyaw_leftlimit_" .. state)
        _data.bodyyaw_right = UI.get("antiaim_bodyyaw_rightlimit_" .. state)
    elseif bodyyawmode == "Jitter" then
        if cmd.tickcount % UI.get("antiaim_bodyyaw_step_" .. state) == 0 then
            if G8.refs.antiaim.body_yaw.left_limit:get() == UI.get("antiaim_bodyyaw_leftlimitmin_" .. state) then
                _data.bodyyaw_left = UI.get("antiaim_bodyyaw_leftlimitmax_" .. state)
                _data.bodyyaw_right = UI.get("antiaim_bodyyaw_rightlimitmax_" .. state)
            else
                _data.bodyyaw_left = UI.get("antiaim_bodyyaw_leftlimitmin_" .. state)
                _data.bodyyaw_right = UI.get("antiaim_bodyyaw_rightlimitmin_" .. state)
            end
        end
    elseif bodyyawmode == "Fluctuate" then
        if cmd.tickcount % UI.get("antiaim_bodyyaw_step_" .. state) == 0 then
            if G8.refs.antiaim.body_yaw.left_limit:get() >= UI.get("antiaim_bodyyaw_leftlimitmax_" .. state) then
                _data.bodyyaw_left = UI.get("antiaim_bodyyaw_leftlimitmin_" .. state)
            else
                _data.bodyyaw_left = G8.refs.antiaim.body_yaw.left_limit:get() + 1
            end

            if G8.refs.antiaim.body_yaw.right_limit:get() >= UI.get("antiaim_bodyyaw_rightlimitmax_" .. state) then
                _data.bodyyaw_right = UI.get("antiaim_bodyyaw_rightlimitmin_" .. state)
            else
                _data.bodyyaw_right = G8.refs.antiaim.body_yaw.right_limit:get() + 1
            end
        end
    elseif bodyyawmode == "Anti-Bruteforce" then
        if G8.vars.be_attacked then
            G8.vars.bf_way = G8.vars.bf_way + 1
            G8.vars.be_attacked = false
        end
        if G8.vars.bf_way > UI.get("antiaim_bf_value_" .. state) then G8.vars.bf_way = 1 end
        _data.bodyyaw_left = UI.get("antiaim_bf_way_" .. state .. "_" .. G8.vars.bf_way) or 0
        _data.bodyyaw_right = UI.get("antiaim_bf_way_" .. state .. "_" .. G8.vars.bf_way) or 0
    end

    if UI.contains("antiaim_disable_desync", manual) then
        _data.bodyyaw = false
    end

    _data.bodyyaw_options = UI.get("antiaim_bodyyaw_option_" .. state)
    _data.bodyyaw_lby = UI.get("antiaim_lby_option_" .. state)

    setvalues(_data)
end

G8.feat.aa_defensive_weaponfire = function (info)
    if info.userid ~= entity_get_local_player():get_player_info().userid then return end
    if G8.refs.ragebot.double_tap.switch:get() then
        G8.vars.defensive_tick = 32
    end
end

G8.feat.attacked = function (info)
    local me = entity_get_local_player()
    if not me or not me:is_alive() then return end
    if info.userid == me:get_player_info().userid then return end
    if not entity_get(info.userid, true) then return end
    if me.m_iTeamNum == entity_get(info.userid, true).m_iTeamNum then return end
    local shoter_position = entity_get(info.userid, true):get_eye_position()
    local dist = G8.funs.get_dist(shoter_position, vector(info.x, info.y, info.z), me:get_hitbox_position(0))
    local bullet_trace = utils.trace_line(vector(info.x, info.y, info.z), shoter_position)
    local hit_me = false

    if bullet_trace.entity and bullet_trace.entity:is_player() then
        hit_me = (bullet_trace.entity:get_player_info().userid == me:get_player_info().userid)
    else
        hit_me = false
    end

    if dist < 45 and not hit_me then
        G8.vars.be_attacked = true
        if UI.get("log_attacked_sound") then
            G8.funs.playsound("[G8]attacked.wav", 100)
        end
        if UI.get("log_attacked_say") and G8.vars.attacked_say_time < globals.realtime then
            local text = G8.vars.attacked_str[utils_random_int(1, #G8.vars.attacked_str)]
            text = string.gsub(text, "{attacker}", entity_get(info.userid, true):get_name())
            text = string.gsub(text, "{dist}", string.format("%.2f", dist))
            utils_console_exec("say " .. text)
            G8.vars.attacked_say_time = globals.realtime + UI.get("log_attacked_say_cooltime")
        end
    end
end

G8.feat.fake_lag = function (cmd)
    if not UI.get("fakelag_switch") then return end

    local me = entity_get_local_player()
    if not me or not me:is_alive() then return end

    if UI.get("fakelag_fix_switch") then
        if UI.get("fakelag_fix_style") == "Weapon Timer" then
            local weapon = me:get_player_weapon(false)
            if not weapon then goto skiper end

            if weapon:get_weapon_index() ~= G8.vars.last_weapon then
                G8.vars.last_weapon = weapon:get_weapon_index()
                G8.vars.last_value = weapon["m_fLastShotTime"]
                goto skiper
            end

            if weapon["m_fLastShotTime"] ~= G8.vars.last_value then
                G8.vars.last_value = weapon["m_fLastShotTime"]
                if G8.refs.antiaim.misc.fake_duck:get() then
                    if UI.get("fakelag_fix_fakeduck") then
                        G8.vars.send_tick = 4
                    end
                else
                    G8.vars.send_tick = 4
                end
            end

        elseif UI.get("fakelag_fix_style") == "Weapon Swtich" then
            local weapon = me:get_player_weapon(false)
            if not weapon then goto skiper end

            if weapon:get_weapon_index() ~= G8.vars.last_weapon then
                G8.vars.last_weapon = weapon:get_weapon_index()
                G8.vars.last_value = weapon["m_iClip1"]
                goto skiper
            end

            if weapon["m_iClip1"] ~= G8.vars.last_value then
                G8.vars.last_value = weapon["m_iClip1"]
                if G8.refs.antiaim.misc.fake_duck:get() then
                    if UI.get("fakelag_fix_fakeduck") then
                        G8.vars.send_tick = 4
                    end
                else
                    G8.vars.send_tick = 4
                end
            end
        end

        ::skiper::
    end

    local state = G8.vars.player_state
    if state == "On-Peek" and not UI.get("fakelag_override_On-Peek") then state = "Running" end
    state = UI.get("fakelag_override_" .. state) and state or "Global"

    local function setvalues(tab)
        G8.refs.antiaim.fakelag.switch:set(tab.switch)
        G8.refs.antiaim.fakelag.limit:set(tab.limit)
        G8.refs.antiaim.fakelag.variability:set(tab.variability)
    end

    local _data = {
        switch = G8.refs.antiaim.fakelag.switch:get(),
        limit = G8.vars.fl_limit,
        variability = G8.refs.antiaim.fakelag.variability:get(),
    }

    local flmode = UI.get("fakelag_mode_" .. state)

    if flmode == "Static" then
        _data.switch = true
        _data.limit = UI.get("fakelag_limit_" .. state)
        _data.variability = UI.get("fakelag_variability_" .. state)
    elseif flmode == "Jitter" then
        _data.switch = true
        _data.variability = 0
        if cmd.tickcount % UI.get("fakelag_step_" .. state) == 0 then
            if _data.limit == UI.get("fakelag_limitmin_" .. state) then
                _data.limit = UI.get("fakelag_limitmax_" .. state)
            else
                _data.limit = UI.get("fakelag_limitmin_" .. state)
            end
        end
    elseif flmode == "Random" then
        _data.switch = true
        _data.variability = 0
        if cmd.tickcount % UI.get("fakelag_step_" .. state) == 0 then
            _data.limit = utils_random_int(UI.get("fakelag_limitmin_" .. state), UI.get("fakelag_limitmax_" .. state))
        end
    elseif flmode == "Fluctuate" then
        if cmd.tickcount % UI.get("fakelag_step_" .. state) == 0 then
            _data.limit = _data.limit + 1
            if _data.limit > UI.get("fakelag_limitmax_" .. state) then
                _data.limit = UI.get("fakelag_limitmin_" .. state)
            end
        end
    elseif flmode == "Fluctuate-Update" then
        _data.switch = true
        _data.variability = 0
        if cmd.tickcount % UI.get("fakelag_step_" .. state) == 0 then
            if _data.limit == UI.get("fakelag_limitmin_" .. state) then
                G8.vars.temp_fl = G8.vars.temp_fl + 1
                _data.limit = G8.vars.temp_fl
            else
                _data.limit = UI.get("fakelag_limitmin_" .. state)
            end

            if G8.vars.temp_fl == UI.get("fakelag_limitmax_" .. state) then
                G8.vars.temp_fl = UI.get("fakelag_limitmin_" .. state)
            end
        end
    elseif flmode == "Always-Choke" then
        _data.switch = false
        _data.limit = 1
        _data.variability = 0
    elseif flmode == "Custom-Builder" then
        _data.switch = true
        _data.variability = 0
        if G8.vars.fl_tick < 1 then
            G8.vars.fl_way = G8.vars.fl_way + 1
            if G8.vars.fl_way > UI.get("fakelag_custom_value_" .. state) then G8.vars.fl_way = 1 end
            _data.limit = UI.get("fakelag_customlimit_" .. state .. "_" .. G8.vars.fl_way) or 1
            G8.vars.fl_tick = UI.get("fakelag_customtick_" .. state .. "_" .. G8.vars.fl_way) or 1
        else
            G8.vars.fl_tick = G8.vars.fl_tick - 1
        end
    end

    if G8.refs.ragebot.double_tap.switch:get() then
        if not UI.get("ragebot_doubletap") or not UI.get("ragebot_tickbase") then
            cvar.sv_maxusrcmdprocessticks:int(16)
        end
    else
        if flmode == "Always-Choke" then
            cvar.sv_maxusrcmdprocessticks:int(UI.get("fakelag_maxlimit_" .. state) + 1)
        else
            if _data.limit > 15 then
                cvar.sv_maxusrcmdprocessticks:int(_data.limit + 1)
            else
                cvar.sv_maxusrcmdprocessticks:int(16)
            end
        end
    end

    if not G8.refs.ragebot.double_tap.switch:get() then
        if flmode == "Always-Choke" and not entity_get_game_rules()["m_bFreezePeriod"] and (G8.vars.send_tick == 0) then
            cmd.send_packet = false
        else
            if cmd.choked_commands < _data.limit and not entity_get_game_rules()["m_bFreezePeriod"] and (G8.vars.send_tick == 0) then
                cmd.send_packet = false
            end
        end
    end

    if G8.vars.send_tick > 2 then
        if not G8.refs.ragebot.double_tap.switch:get() and not G8.refs.ragebot.hide_shot.switch:get() then
            cmd.no_choke = true
            G8.refs.antiaim.body_yaw.switch:override(false)
        end
        G8.vars.send_tick = G8.vars.send_tick - 1
    elseif G8.vars.send_tick > 0 and G8.vars.send_tick <= 2 then
        cmd.send_packet = false
        G8.refs.antiaim.body_yaw.switch:override(false)
        G8.vars.send_tick = G8.vars.send_tick - 1
    else
        G8.refs.antiaim.body_yaw.switch:override()
    end

    if G8.refs.ragebot.double_tap.switch:get() and UI.get("antiaim_switch") and UI.get("antiaim_override_Exploit-Defensive") then
        _data.switch = false
    end

    G8.vars.fl_limit = _data.limit

    setvalues(_data)
end

G8.feat.fl_fix_fire = function ()
    if G8.refs.antiaim.misc.fake_duck:get() then return end

    if UI.get("fakelag_fix_switch") and UI.get("fakelag_fix_style") == "Aimbot" then
        G8.vars.send_tick = 4
    end
end

G8.feat.fl_fix_ack = function ()
    if not G8.refs.antiaim.misc.fake_duck:get() then return end

    if UI.get("fakelag_fix_switch")and UI.get("fakelag_fix_style") == "Aimbot" and UI.get("fakelag_fix_fakeduck") then
        G8.vars.send_tick = 4
    end
end

G8.feat.fl_fix_weaponfire = function (info)
    if info.userid ~= entity_get_local_player():get_player_info().userid then return end
    if UI.get("fakelag_fix_switch") and UI.get("fakelag_fix_style") == "Weapon Fire" then
        if G8.refs.antiaim.misc.fake_duck:get() then
            if UI.get("fakelag_fix_fakeduck") then
                G8.vars.send_tick = 4
            end
        else
            G8.vars.send_tick = 4
        end
    end
end

G8.feat.view_model = function ()
    if not UI.get("visual_viewmodel_changer") then return end
    local fov, x, y, z = UI.get("viewmodel_fov"), UI.get("viewmodel_x"), UI.get("viewmodel_y"), UI.get("viewmodel_z")
    cvar.viewmodel_fov:float(fov, true)
    cvar.viewmodel_offset_x:float(x, true)
    cvar.viewmodel_offset_y:float(y, true)
    cvar.viewmodel_offset_z:float(z, true)
end


G8.feat.skeet_indicator = function ()
    if not UI.get("visual_skeet") then return end
    if not entity_get_local_player() or not entity_get_local_player():is_alive() then return end

    local index = 0
    local offset = UI.get("visual_skeet_offset")

    if UI.contains("visual_skeet_list", "G8") then
        local alpha1 = math.abs(math.sin((globals.realtime - (10 * 0.08)) * 2))
        local alpha2 = math.abs(4 - globals.realtime % 8) / 4
        G8.funs.indicator(G8.funs.clr_lerp(alpha1, color(0, 0, 0, 0), G8.funs.clr_lerp(alpha2, color(106,17,203,255), color(221,99,231,255))), "CROW.PUB", index, offset)
        index = index + 1
    end

    if UI.contains("visual_skeet_list", "Weapon State") then
        G8.funs.indicator(color(255, 255, 255, 255), G8.vars.weapon_state, index, offset)
        index = index + 1
    end

    if UI.contains("visual_skeet_list", "DMG") then
        local dmg = G8.refs.ragebot.weapon.minimum_damage:get()
        dmg = G8.refs.ragebot.weapon.minimum_damage:get_override() or dmg
        G8.funs.indicator(color(255, 255, 255, 255), "DMG: " .. (dmg == 0 and "Auto" or dmg), index, offset)
        index = index + 1
    end

    if UI.contains("visual_skeet_list", "HC") then
        local hc = G8.refs.ragebot.weapon.hit_chance:get()
        G8.funs.indicator(color(255, 255, 255, 255), "HC: " .. (G8.refs.ragebot.weapon.hit_chance:get_override() or hc), index, offset)
        index = index + 1
    end

    if UI.contains("visual_skeet_list", "FL") then
        G8.funs.indicator(color(255, 255, 255, 255), "FL: " .. G8.refs.antiaim.fakelag.limit:get(), index, offset)
        index = index + 1
    end

    if UI.contains("visual_skeet_list", "DT") then
        if G8.refs.ragebot.double_tap.switch:get() then
            G8.funs.indicator(G8.funs.clr_lerp(rage_exploit:get(), color(0, 0, 255, 255), color(255, 0, 0, 255)), "DT", index, offset)
            index = index + 1
        end
    end

    if UI.contains("visual_skeet_list", "HS") then
        if G8.refs.ragebot.hide_shot.switch:get() then
            G8.funs.indicator(color(140, 210, 124, 255), "HS", index, offset)
            index = index + 1
        end
    end

    if UI.contains("visual_skeet_list", "FD") then
        if G8.refs.antiaim.misc.fake_duck:get() then
            G8.funs.indicator(color(53, 59, 52, 255), "FD", index, offset)
            index = index + 1
        end
    end

    if UI.contains("visual_skeet_list", "DA") then
        if G8.refs.ragebot.misc.dormant_aimbot:get() then
            G8.funs.indicator(color(92, 237, 50, 255), "DA", index, offset)
            index = index + 1
        end
    end

    if UI.contains("visual_skeet_list", "LC") then
        if get_lc() ~= -1 then
            G8.funs.indicator(get_lc() == 0 and color(0, 255, 0, 255) or color(255, 0, 0, 255), "LC", index, offset)
            index = index + 1
        end
    end
end

--{"Watermark", "Spectators", "Keybinds"}
G8.feat.solusui = function ()
    if UI.contains("visual_solusui", "Watermark") then
        local base_x = G8.defs.screen_size.x - 6
        local base_y = 6
        local latency = utils_net_channel() == nil and "Local" or math.floor(utils_net_channel().avg_latency[1] * 1000)
        local time = common_get_system_time()
        local system_time = string.format('%02d:%02d', time.hours, time.minutes)
        local watermark_text = "     |  G8  |  " .. G8.defs.username .. "  |  Ping: " .. latency .. "  |  " .. system_time .. "  "
        local text_size_x, text_size_y = render_measure_text(G8.defs.fonts.pixel14odu, nil, watermark_text):unpack()

        render.rect_outline(vector(base_x - text_size_x - 1, base_y), vector(base_x, base_y + 24), color(0, 0, 0, 255), 2, 2)
        render.rect(vector(base_x - text_size_x - 1, base_y), vector(base_x, base_y + 24), color(0,0,0,80), 2)

        render_text(G8.defs.fonts.pixel14odu, vector(base_x - text_size_x - 5, base_y + 3), color(255,255,255,255), nil, watermark_text)
        render_texture(G8.defs.useravatar, vector(base_x - text_size_x + 6, base_y + 3), vector(18, 18))
    end
end

G8.feat.choked_list = function (cmd)
    if (cmd.choked_commands < G8.vars.choked_history[5]) then
        G8.vars.choked_history[1] = G8.vars.choked_history[2]
        G8.vars.choked_history[2] = G8.vars.choked_history[3]
        G8.vars.choked_history[3] = G8.vars.choked_history[4]
        G8.vars.choked_history[4] = G8.vars.choked_history[5]
    end

    G8.vars.choked_history[5] = cmd.choked_commands
end

G8.feat.crosshair = function ()
    local me = entity_get_local_player()
    if not me or not me:is_alive() then return end

    if UI.get("visual_crosshair") then
        local base_x = G8.defs.screen_size.x / 2
        local base_y = G8.defs.screen_size.y / 2 + 10
        local vlist = { base_x, base_x, base_x}


        local scoped = false
        local me = entity_get_local_player()
        if me and me:is_alive() then
            if me.m_bIsScoped then
                scoped = true
            end
        end

        local fl_text = table.concat(G8.vars.choked_history, "-")

        if not scoped then
            vlist[1] = math.floor((base_x - (render_measure_text(1, nil, "CROW.PUB").x / 2)))
            vlist[2] = math.floor((base_x - (render_measure_text(1, nil, G8.vars.player_state).x / 2)))
            vlist[3] = math.floor((base_x - (render_measure_text(1, nil, fl_text).x / 2)))
        end

        for i = 1, 3 do
            if vlist[i] ~= G8.vars.crosshair_list[i] then
                G8.vars.crosshair_list[i] = G8.vars.crosshair_list[i] + (G8.vars.crosshair_list[i] > vlist[i] and -1 or 1)
            end
        end

        render_text(1, vector(G8.vars.crosshair_list[1], base_y), color(255,255,255,255), nil, "CROW.PUB")
        render_text(1, vector(G8.vars.crosshair_list[2], base_y + 10), color(255,255,255,255), nil, G8.vars.player_state)
        render_text(1, vector(G8.vars.crosshair_list[3], base_y + 20), color(255,255,255,255), nil, fl_text)
    end

    if UI.get("visual_crosshair_dmg") then
        render_text(1, vector(G8.defs.screen_size.x / 2 + 15, G8.defs.screen_size.y / 2 - 15), color(255, 255, 255, 255), nil, G8.refs.ragebot.weapon.minimum_damage:get_override() or G8.refs.ragebot.weapon.minimum_damage:get())
    end

end


G8.feat.log_ack = function (info)
    local language = UI.get("log_language")
    if info.state then
        local name = info.target:get_name()
        local wanted_hitgroup = G8.defs.hitgroups[language][info.wanted_hitgroup]
        local state = language == "en_US" and info.state or G8.defs.missreason[info.state]
        local hitchance = info.hitchance
        local backtrack = info.backtrack
        if UI.contains(" log_style", "Chat") then
            printchat(string.format(G8.defs.hitlogstr[language]["Chat"]["miss"], name, wanted_hitgroup, state, hitchance, backtrack))
        end
        if UI.contains(" log_style", "Console") then
            printraw(string.format(G8.defs.hitlogstr[language]["Console"]["miss"], name, wanted_hitgroup, state, hitchance, backtrack))
        end
        if UI.contains(" log_style", "Screen") then
            table.insert(G8.vars.log_list, {
                text = string.format(G8.defs.hitlogstr[language]["Screen"]["miss"], name, wanted_hitgroup, state, hitchance, backtrack),
            })
        end
    else
        local name = info.target:get_name()
        local hitgroups = G8.defs.hitgroups[language][info.hitgroup]
        local damage = info.damage
        local wanted_damage = info.wanted_damage
        local remaining = info.target.m_iHealth
        local hitchance = info.hitchance
        local backtrack = info.backtrack
        if UI.contains(" log_style", "Chat") then
            printchat(string.format(G8.defs.hitlogstr[language]["Chat"]["hit"], name, hitgroups, damage, wanted_damage, remaining, hitchance))
        end
        if UI.contains(" log_style", "Console") then
            printraw(string.format(G8.defs.hitlogstr[language]["Console"]["hit"], name, hitgroups, damage, wanted_damage, remaining, hitchance, backtrack))
        end
        if UI.contains(" log_style", "Screen") then
            table.insert(G8.vars.log_list, {
                text = string.format(G8.defs.hitlogstr[language]["Screen"]["hit"], name, hitgroups, damage, wanted_damage, remaining, hitchance),
            })
        end
    end
end



G8.feat.log_render = function ()
    if #G8.vars.log_list == 0 then return end
    local base_x = G8.defs.screen_size.x / 2
    local base_y = G8.defs.screen_size.y - 200
    if #G8.vars.log_list > 10 then
        for i = 1, #G8.vars.log_list - 10 do
            if G8.vars.log_list[i].time then
                if G8.vars.log_list[i].time > globals.tickcount + 5 then
                    G8.vars.log_list[i].time = globals.tickcount + 5
                end
            else
                G8.vars.log_list[i].time = globals.tickcount + 5
            end
        end
    end
    for i, obj in pairs(G8.vars.log_list) do
        if not obj then return end
        if not obj.init then
            obj.time = globals.tickcount + 256
            obj.init = true
        end
        local alpha
        if obj.time - globals.tickcount > 240 then
            alpha = math.floor(255 / (obj.time - globals.tickcount - 240))
        elseif obj.time - globals.tickcount < 16 and obj.time - globals.tickcount > 0 then
            alpha = math.floor(255 / (16 - obj.time + globals.tickcount))
        elseif obj.time - globals.tickcount <= 0 then
            table.remove(G8.vars.log_list, i)
            return
        else
            alpha = 255
        end
        render_text(1, vector(base_x, base_y + i * 12), color(255, 255, 255, alpha), "c", obj.text)
    end
end

G8.feat.animbreaker = function ()
    if UI.get_element("animbreaker_list") and (#UI.get_element("animbreaker_list"):get() > 0) then
        local local_player = entity_get_local_player()
        if not local_player or not local_player:is_alive() then
            return
        end

        local local_player_index = local_player:get_index()
        local local_player_address = G8.funs.get_entity_address(local_player_index)

        if not local_player_address or G8.vars.hooked_function then
            return
        end

        local new_point = vmthook.new(local_player_address)
        G8.vars.hooked_function = new_point.hook("void(__fastcall*)(void*, void*)", G8.funs.inside_updateCSA, 224)
    end
end

-- FEAT END


-- REGS START

G8.regs.createmove = function (cmd)
    G8.feat.updatevar(cmd)
    G8.feat.weapon_builder()
    G8.feat.tp_onkey()
    G8.feat.clock_correction()
    G8.feat.dt_defensive(cmd)
    G8.feat.dt_tickbase()
    G8.feat.auto_tp()
    G8.feat.jump_scout()
    G8.feat.adaptive_backtrack()
    -- G8.feat.fix_aa(cmd)
    G8.feat.anti_aim(cmd)
    G8.feat.fake_lag(cmd)
    G8.feat.animbreaker()
    G8.feat.choked_list(cmd)
end

G8.regs.aim_fire = function ()
    G8.feat.fl_fix_fire()
end

G8.regs.aim_ack = function (info)
    G8.feat.fl_fix_ack()
    G8.feat.log_ack(info)
end

G8.regs.weapon_fire = function (info)
    G8.feat.aa_defensive_weaponfire(info)
    G8.feat.fl_fix_weaponfire(info)
end

G8.regs.bullet_impact = function (info)
    G8.feat.attacked(info)
end

G8.regs.render = function ()
    G8.feat.view_model()
    G8.feat.solusui()
    G8.feat.crosshair()
    G8.feat.skeet_indicator()
    G8.feat.log_render()
end

G8.regs.shutdown = function ()
    for _, reset_function in ipairs(vmthook.list) do
        reset_function()
    end

    local _reset

    _reset = function (tab)
        if type(tab) == "table" then
            for _, obj in pairs(tab) do
                _reset(obj)
            end
        else
            tab:override()
        end
    end

    _reset(G8.refs)


    cvar.sv_maxusrcmdprocessticks:int(16)
    rage_exploit:allow_defensive(true)
end

G8.setup = function ()
    utils_console_exec("clear")
    G8.funs.prepare_func()
    if not files_get_crc32("csgo\\sound\\[G8]LOAD.wav") or not files_get_crc32("nl\\Crow\\imgs\\G8.gif") or not files_get_crc32("csgo\\sound\\[G8]attacked.wav") then
        utils_execute_after(0.2, function ()
            printraw([[
            ⠀⠀⠀⠀⠀⠀⠀⣨⣿⣷
            ⠀⠀⠀⠀⠀⠀⣾⣿⠉⣿⣷
            ⠀⠀⠀⠀⠀⣾⣿⡇⠀⢸⣿⣿⡀
            ⠀⠀⠀⢀⣿⣿⣿⣿⠀⣿⣿⣿⣿⡀
            ⠀⠀⢀⣿⣿⣿⣿⣿⠀⣿⣿⣿⣿⣿⡀
            ⠀⢠⣿⣿⣿⣿⣿⣿⠶⣿⣿⣿⣿⣿⣿⡄
            ⢠⣿⣿⣿⣿⣿⣿⣷⣤⣾⣿⣿⣿⣿⣿⣿⡄
            ⠀⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉
            ]])
            for i = 1, 10 do
                printraw("\aDD63E7[G8] \a868686» \aD5D5D5Invaild to download files")
                printdev("[G8] » Invaild to download files")
            end
            utils_console_exec("showconsole")
        end)
        return
    end


    G8.funs.create_menu()
    utils_execute_after(1, UI.visibility_handle)
    cvar.r_aspectratio:float(UI.get("visual_aspect_ratio") and UI.get("visual_aspect_value") / 10 or 0)


    for event, element in pairs(G8.regs) do
        events[tostring(event)]:set(element)
    end


    utils_execute_after(0.2, function ()
        G8.funs.log("Welcome, " .. G8.defs.username)
        printraw([[
            ⠀⠀⠀⠀⠀⠀⠀⣠⣤⣤⣤⣤⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⢰⡿⠋⠁⠀⠀⠈⠉⠙⠻⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⢀⣿⠇⠀⢀⣴⣶⡾⠿⠿⠿⢿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⣀⣀⣸⡿⠀⠀⢸⣿⣇⠀⠀⠀⠀⠀⠀⠙⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⣾⡟⠛⣿⡇⠀⠀⢸⣿⣿⣷⣤⣤⣤⣤⣶⣶⣿⠇⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀
            ⢀⣿⠀⢀⣿⡇⠀⠀⠀⠻⢿⣿⣿⣿⣿⣿⠿⣿⡏⠀⠀⠀⠀⢴⣶⣶⣿⣿⣿⣆
            ⢸⣿⠀⢸⣿⡇⠀⠀⠀⠀⠀⠈⠉⠁⠀⠀⠀⣿⡇⣀⣠⣴⣾⣮⣝⠿⠿⠿⣻⡟
            ⢸⣿⠀⠘⣿⡇⠀⠀⠀⠀⠀⠀⠀⣠⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁⠉⠀
            ⠸⣿⠀⠀⣿⡇⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠉⠀⠀⠀⠀
            ⠀⠻⣷⣶⣿⣇⠀⠀⠀⢠⣼⣿⣿⣿⣿⣿⣿⣿⣛⣛⣻⠉⠁⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⢸⣿⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⢸⣿⣀⣀⣀⣼⡿⢿⣿⣿⣿⣿⣿⡿⣿⣿⣿
            
        ]])
    end)

    utils_execute_after(0.5, function ()
        if UI.get("main_loaded_sound") then
            G8.funs.playsound("[G8]LOAD.wav", 100)
        end
    end)

end
-- REGS END

G8.setup()
ui.sidebar(G8.funs.gradient_text(50, 245, 215, 255, 75, 85, 240, 255, 'G8 2.0'), 'wheelchair')










--------------------------------------------------------Recycling station--------------------------------------------------------


-- ⠀⠀⠀⠀⠀⠀⠀⣠⣤⣤⣤⣤⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
-- ⠀⠀⠀⠀⠀⢰⡿⠋⠁⠀⠀⠈⠉⠙⠻⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
-- ⠀⠀⠀⠀⢀⣿⠇⠀⢀⣴⣶⡾⠿⠿⠿⢿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
-- ⠀⠀⣀⣀⣸⡿⠀⠀⢸⣿⣇⠀⠀⠀⠀⠀⠀⠙⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
-- ⠀⣾⡟⠛⣿⡇⠀⠀⢸⣿⣿⣷⣤⣤⣤⣤⣶⣶⣿⠇⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀
-- ⢀⣿⠀⢀⣿⡇⠀⠀⠀⠻⢿⣿⣿⣿⣿⣿⠿⣿⡏⠀⠀⠀⠀⢴⣶⣶⣿⣿⣿⣆
-- ⢸⣿⠀⢸⣿⡇⠀⠀⠀⠀⠀⠈⠉⠁⠀⠀⠀⣿⡇⣀⣠⣴⣾⣮⣝⠿⠿⠿⣻⡟
-- ⢸⣿⠀⠘⣿⡇⠀⠀⠀⠀⠀⠀⠀⣠⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁⠉⠀
-- ⠸⣿⠀⠀⣿⡇⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠉⠀⠀⠀⠀
-- ⠀⠻⣷⣶⣿⣇⠀⠀⠀⢠⣼⣿⣿⣿⣿⣿⣿⣿⣛⣛⣻⠉⠁⠀⠀⠀⠀⠀⠀⠀
-- ⠀⠀⠀⠀⢸⣿⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀
-- ⠀⠀⠀⠀⢸⣿⣀⣀⣀⣼⡿⢿⣿⣿⣿⣿⣿⡿⣿⣿⣿





-- UI.new = function(obj)
--     assert(obj.element, "Element is nil")
--     assert(obj.index, "Index is nil")
--     assert(type(obj.index) == "string", "Invalid type of index")
--     UI.list[obj.index] = {}
--     UI.list[obj.index].element = obj.element;
--     UI.list[obj.index].flags = obj.flags or ""
--     UI.list[obj.index].visible_state = function()
--         if not obj.conditions then
--             return true
--         end
--         for c, d in pairs(obj.conditions) do
--             if not d() then
--                 return false
--             end
--         end
--         return true
--     end;

--     UI.list[obj.index].element:set_callback(UI.visibility_handle)
--     UI.visibility_handle()
-- end;

