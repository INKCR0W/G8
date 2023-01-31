-- EXTERN START

local ui_create, ui_find, utils_create_interface, files_write, files_read, printdev, printraw, printchat, entity_get_local_player, utils_console_exec, render_load_image_from_file, common_add_notify, common_get_username, render_texture, render_world_to_ , is_button_down, render_screen_size, render_load_font, render_text, render_poly_blur, utils_execute_after, render_circle_outline, entity_get_game_rules, render_gradient, render_measure_text, rage_exploit, ui_get_icon, files_get_crc32, ui_get_alpha, common_reload_script, files_create_folder, math_sqrt, string_sub, utils_random_int, entity_get_players, utils_net_channel, utils_get_vfunc, bit_band, bit_lshift, entity_get, entity_get_entities, render_camera_angles, common_get_unixtime = ui.create, ui.find, utils.create_interface, files.write, files.read, print_dev, print_raw, print_chat, entity.get_local_player, utils.console_exec, render.load_image_from_file, common.add_notify, common.get_username, render.texture, render.world_to_screen, common.is_button_down, render.screen_size, render.load_font, render.text, render.poly_blur, utils.execute_after, render.circle_outline, entity.get_game_rules, render.gradient, render.measure_text, rage.exploit, ui.get_icon, files.get_crc32, ui.get_alpha, common.reload_script, files.create_folder, math.sqrt, string.sub, utils.random_int, entity.get_players, utils.net_channel, utils.get_vfunc, bit.band, bit.lshift, entity.get, entity.get_entities, render.camera_angles, common.get_unixtime

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
        return target:dist(target:closest_ray_point(start, to))
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
        render_gradient(vector(20 + (render_measure_text(G8.defs.fonts.skeet_indicator, "", string).x / 2), G8.defs.screen_size.y - 548 + xtazst * 37 + yoffset), vector(15 , (G8.defs.screen_size.y - 548 + xtazst * 37) + 28 + yoffset), color(0, 0, 0, 60), color(0, 0, 0, 0), color(0, 0, 0, 60), color(0, 0, 0, 0), 0)
        render_gradient(vector(20 + (render_measure_text(G8.defs.fonts.skeet_indicator, "", string).x / 2), G8.defs.screen_size.y - 548 + xtazst * 37 + yoffset), vector(25 + (render_measure_text(G8.defs.fonts.skeet_indicator, "", string).x), (G8.defs.screen_size.y - 548 + xtazst * 37) + 28 + yoffset), color(0, 0, 0, 60), color(0, 0, 0, 0), color(0, 0, 0, 60), color(0, 0, 0, 0), 0)

        render_text(G8.defs.fonts.skeet_indicator, vector(21, (G8.defs.screen_size.y - 543) + xtazst * 37 + yoffset), color(0, 0, 0, (scolor.a - 105) >=0 and (scolor.a - 105) or 0), "", string)
        render_text(G8.defs.fonts.skeet_indicator, vector(20, (G8.defs.screen_size.y - 544) + xtazst * 37 + yoffset), scolor, "", string)
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
            return "Pistol"
        elseif (weapon_name == "weapon_deagle") then
            return "Heavy"
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

        G8.defs.gif = render_load_image_from_file("nl\\Crow\\imgs\\G8.gif")
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

    import_global = function (cfg)
        ::starter::
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
            if not (G8.vars.load_timer > 1) then
                G8.vars.load_timer = G8.vars.load_timer + 1
                goto starter
            else
                G8.vars.load_timer = 0
                common_add_notify("CFG SYSTEM", "failed to import\ncheck ur clipboard")
                G8.funs.log(message)
            end
        else
            common_add_notify("CFG SYSTEM", "CFG Import Success")
        end
    end;

    entity_list_pointer = ffi.cast("void***", utils_create_interface("client.dll", "VClientEntityList003"));
    inside_updateCSA = function(thisptr, edx)
        G8.vars.hooked_function(thisptr, edx)
        if entity_get_local_player() == nil or ffi.cast('uintptr_t**', thisptr) == nil then return end
        if not entity_get_local_player():is_alive() then return end

        if UI.contains("animbreaker_list", "Pitch Onground") then
            if ffi.cast("CCSGOPlayerAnimationState_534535_t**", ffi.cast("uintptr_t", thisptr) + 0x9960)[0].bHitGroundAnimation then
                if G8.vars.on_ground then
                    entity_get_local_player().m_flPoseParameter[12] = 0.5
                end
            end
        end

        entity_get_local_player().m_flPoseParameter[6] = UI.contains("animbreaker_list", "In Air") and 1 or 0

        if UI.contains("animbreaker_list", "Leg Fucker") then
            G8.refs.antiaim.misc.leg_movement:override("Sliding")
            entity_get_local_player().m_flPoseParameter[0] = 0
        end

        if UI.contains("animbreaker_list", "Slow Walk") then
            entity_get_local_player().m_flPoseParameter[9] = 0
        end

        if UI.contains("animbreaker_list", "Duck") then
            entity_get_local_player().m_flPoseParameter[8] = 0
        end
    end;

    create_menu = function ()
        UI.new(G8.defs.groups.main.main:label("Welcome, " .. G8.funs.gradient_text(255, 8, 68, 255, 255, 177, 153, 255, G8.defs.username)), "main_label", "-", nil, nil, nil)
        UI.new(G8.defs.groups.main.main:switch("Enable G8 GIF", false), "main_gif_switch", "m", nil, nil, "FFYOU SURE???")
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
        UI.new(UI.get_element("ragebot_tickbase"):create():slider("Tick Base", 16, 21, 16), "ragebot_tickbase_value", "i", {
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
        local aa_manual = UI.get_element("antiaim_manual"):create()
        UI.new(aa_manual:selectable("Disable Yaw", G8.defs.aa_manuals), "antiaim_disable_yaw", "t", {function () return UI.get("antiaim_switch") end;}, nil, nil)
        UI.new(aa_manual:selectable("Disable Desync", G8.defs.aa_manuals), "antiaim_disable_desync", "t", {function () return UI.get("antiaim_switch") end;}, nil, nil)
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
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string_sub(state, 1, 1) .. "] Pitch", {"Up", "Disabled", "Down"}), "antiaim_pitch_" .. state, "s", {
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
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string_sub(state, 1, 1) .. "] Pitch 1", {"Up", "Disabled", "Down"}), "antiaim_pitch1_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_pitchmode_" .. state) == "Jitter" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string_sub(state, 1, 1) .. "] Pitch 2", {"Up", "Disabled", "Down"}), "antiaim_pitch2_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_pitchmode_" .. state) == "Jitter" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:selectable("[" .. string_sub(state, 1, 1) .. "] Random Pitchs", {"Up", "Disabled", "Down"}), "antiaim_randompitchs_" .. state, "t", {
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
        UI.new(G8.defs.groups.fakelag.main:combo("Fix Style", {"Aimbot", "Weapon Timer", "Weapon Fire", "Weapon Ammo"}), "fakelag_fix_style", "s", {
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

        -- UI.new(G8.defs.groups.visual.solus_ui:selectable("Solus UI", {"Watermark", "Spectators", "Keybinds"}), "visual_solusui", "t", nil, nil, nil)

        -- UI.new(G8.defs.groups.visual.crosshair_indicator:switch("Crosshair Indicators", false), "visual_crosshair", "b", nil, nil, nil)

        UI.new(G8.defs.groups.visual.skeet_indicator:switch("Skeet Indicator", false), "visual_skeet", "b", nil, nil, nil)
        UI.new(UI.get_element("visual_skeet"):create():selectable("Indicators", {"G8", "Weapon State", "DMG", "HC", "FL", "DT", "HS", "FD", "DA", "LC"}), "visual_skeet_list", "t", { function () return UI.get("visual_skeet") end; }, nil, nil)
        UI.new(UI.get_element("visual_skeet"):create():slider("Y Offset", -500, 500, 0), "visual_skeet_offset", "i", { function () return UI.get("visual_skeet") end; }, nil, nil)

        UI.new(G8.defs.groups.misc.logs:switch("Hit/Mis log", false), "log_hitmiss", "b", nil, nil, nil)
        local tlog = UI.get_element("log_hitmiss"):create()
        UI.new(tlog:combo("Language", {"zh_CN", "en_US"}), "log_language", "s", { function () return UI.get("log_hitmiss") end; }, nil, nil)
        UI.new(tlog:selectable("Log Style", {"Chat", "Console", "Screen"}), " log_style", "t", { function () return UI.get("log_hitmiss") end; }, nil, nil)

        UI.new(G8.defs.groups.misc.unsafe_feature:selectable("Animbreaker", {"Pitch Onground", "In Air", "Leg Fucker", "Slow Walk", "Duck"}), "animbreaker_list", "t", nil, nil, nil)

        UI.new(G8.defs.groups.misc.logs:switch("Be Attacked Sound", false), "log_attacked_sound", "b", nil, nil, nil)

        UI.new(G8.defs.groups.config.global:button("Export Global Config To Clipboard", function ()
            G8.funs.export_global()
        end), "config_export_global", "-", nil, nil, nil)
        UI.new(G8.defs.groups.config.global:button("Import Global Config From Clipboard", function ()
            G8.funs.import_global(clipboard.get())
        end), "config_import_global", "-", nil, nil, nil)
        UI.new(G8.defs.groups.config.global:button("Load Default Global Config", function ()
            G8.funs.import_global(G8.defs.default_cfg)
        end), "config_import_global", "-", nil, nil, nil)
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


--DEFS START

G8.defs = {
    default_cfg = "eyJmYWtlbGFnX2N1c3RvbWxpbWl0X0dsb2JhbF8yMCI6MSwgInJhZ2Vib3RfRGVmdWFsdF9kbWdfQXV0byI6MCwgImZha2VsYWdfb3ZlcnJpZGVfU3RhbmRpbmciOmZhbHNlLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzE2IjowLCAiYW50aWFpbV94d2F5X0Fpcl8xNyI6MCwgInJhZ2Vib3RfRGVmdWFsdF9oY19BdXRvIjowLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzE3IjowLCAiYW50aWFpbV94d2F5X0Fpcl8xOCI6MCwgInJhZ2Vib3RfT3ZlcnJpZGVfZG1nX0F1dG8iOjAsICJhbnRpYWltX3h3YXlfQWlyXzE5IjowLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzE5IjowLCAicmFnZWJvdF9PdmVycmlkZV9oY19BdXRvIjowLCAiYW50aWFpbV94d2F5X0Fpcl8yMCI6MCwgImFudGlhaW1feHdheV9BaXItRHVja18yMCI6MCwgInJhZ2Vib3RfQWlyX2RtZ19BdXRvIjowLCAiZmFrZWxhZ19saW1pdG1pbl9TdGFuZGluZyI6MSwgImFudGlhaW1fYmZfdmFsdWVfQWlyLUR1Y2siOjIsICJyYWdlYm90X0Fpcl9oY19BdXRvIjowLCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfMSI6MCwgInJhZ2Vib3RfRGVmdWFsdF9kbWdfUGlzdG9scyI6MCwgImFudGlhaW1fYmZfd2F5X0Fpcl8yIjowLCAiYW50aWFpbV9iYWNrd2FyZF9vZmZzZXRfR2xvYmFsIjowLCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfMiI6MCwgImZha2VsYWdfY3VzdG9tdGlja19GYWtlLUR1Y2tfOCI6MSwgImZha2VsYWdfY3VzdG9tX3ZhbHVlX1N0YW5kaW5nIjoyLCAicmFnZWJvdF9EZWZ1YWx0X2hjX1Bpc3RvbHMiOjAsICJhbnRpYWltX3BpdGNobW9kZV9HbG9iYWwiOiJEZWZ1YWx0IiwgImFudGlhaW1fYmZfd2F5X0Fpcl80IjowLCAicmFnZWJvdF9PdmVycmlkZV9kbWdfUGlzdG9scyI6MCwgImFudGlhaW1fcGl0Y2hfR2xvYmFsIjoiRG93biIsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1N0YW5kaW5nXzEiOjEsICJhbnRpYWltX2JmX3dheV9BaXJfNSI6MCwgInJhZ2Vib3RfT3ZlcnJpZGVfaGNfUGlzdG9scyI6MCwgImZha2VsYWdfY3VzdG9tdGlja19TdGFuZGluZ18yIjoxLCAiYW50aWFpbV9waXRjaHN0ZXBfR2xvYmFsIjoxLCAiYW50aWFpbV9iZl93YXlfQWlyXzYiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1N0YW5kaW5nXzIiOjEsICJyYWdlYm90X0Fpcl9kbWdfUGlzdG9scyI6MCwgImFudGlhaW1fYmZfd2F5X0Fpcl83IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX1N0YW5kaW5nXzMiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfRmFrZS1EdWNrXzExIjoxLCAicmFnZWJvdF9BaXJfaGNfUGlzdG9scyI6MCwgImFudGlhaW1fYmZfd2F5X0Fpcl84IjowLCAiYW50aWFpbV9waXRjaDJfR2xvYmFsIjoiVXAiLCAiZmFrZWxhZ19jdXN0b210aWNrX1N0YW5kaW5nXzQiOjEsICJhbnRpYWltX2JmX3dheV9BaXJfOSI6MCwgImFudGlhaW1fcmFuZG9tcGl0Y2hzX0dsb2JhbCI6e30sICJmYWtlbGFnX2N1c3RvbWxpbWl0X1N0YW5kaW5nXzQiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Zha2UtRHVja18xMiI6MSwgImFudGlhaW1fYmZfd2F5X0Fpcl8xMCI6MCwgInJhZ2Vib3RfTm8tU2NvcGVfaGNfUGlzdG9scyI6MCwgImFudGlhaW1feWF3YmFzZV9HbG9iYWwiOiJBdCBUYXJnZXQiLCAiYW50aWFpbV9iZl93YXlfQWlyXzExIjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9GYWtlLUR1Y2tfMTMiOjEsICJyYWdlYm90X292ZXJyaWRlX3N3aXRjaF9aZXVzIjpmYWxzZSwgImFudGlhaW1feWF3bW9kZV9HbG9iYWwiOiJEaXNhYmxlZCIsICJhbnRpYWltX2JmX3dheV9BaXJfMTIiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfRmFrZS1EdWNrXzE0IjoxLCAicmFnZWJvdF9vdmVycmlkZV9saXN0X1pldXMiOlsiT3ZlcnJpZGUiXSwgImFudGlhaW1feHdheV9Pbi1QZWVrXzkiOjAsICJhbnRpYWltX2JmX3dheV9BaXJfMTMiOjAsICJyYWdlYm90X0RlZnVhbHRfZG1nX1pldXMiOjAsICJhbnRpYWltX2JmX3dheV9BaXJfMTQiOjAsICJhbnRpYWltX3lhd2xlZnRfR2xvYmFsIjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9GYWtlLUR1Y2tfMTUiOjEsICJhbnRpYWltX3h3YXlfT24tUGVla18xMSI6MCwgImFudGlhaW1fYmZfd2F5X0Fpcl8xNSI6MCwgImFudGlhaW1feWF3cmlnaHRfR2xvYmFsIjowLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMTIiOjAsICJyYWdlYm90X092ZXJyaWRlX2RtZ19aZXVzIjowLCAiYW50aWFpbV9zcGlub2Zmc2V0X0dsb2JhbCI6MCwgImFudGlhaW1feHdheV9Pbi1QZWVrXzEzIjowLCAicmFnZWJvdF9PdmVycmlkZV9oY19aZXVzIjowLCAiYW50aWFpbV95YXdtb2RpZmllcl9HbG9iYWwiOiJEaXNhYmxlZCIsICJyYWdlYm90X0Fpcl9kbWdfWmV1cyI6MCwgImFudGlhaW1feHdheV9Pbi1QZWVrXzE1IjowLCAicmFnZWJvdF9BaXJfaGNfWmV1cyI6MCwgImFudGlhaW1feHdheV9Pbi1QZWVrXzE3IjowLCAicmFnZWJvdF9Oby1TY29wZV9kbWdfWmV1cyI6MCwgImFudGlhaW1feHdheV9Pbi1QZWVrXzE4IjowLCAicmFnZWJvdF9Oby1TY29wZV9oY19aZXVzIjowLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMTkiOjAsICJhbnRpYWltX3h3YXlfT24tUGVla18yMCI6MCwgImFudGlhaW1fYmZfdmFsdWVfT24tUGVlayI6MiwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMTQiOjAsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzE1IjowLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa18xNiI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMTciOjAsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzE4IjowLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa18xOSI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMjAiOjAsICJhbnRpYWltX2JmX3ZhbHVlX1Nsb3ctV2FsayI6MiwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa18xIjowLCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzIiOjAsICJhbnRpYWltX292ZXJyaWRlX1N0YW5kaW5nIjp0cnVlLCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzMiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfNCI6MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMSI6MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMiI6MCwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa183IjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ180IjowLCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzkiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMTAiOjAsICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzciOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMTIiOjAsICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzkiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMTQiOjAsICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzExIjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18xMiI6MCwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa18xNyI6MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMTQiOjAsICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzE1IjowLCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzIwIjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18xNyI6MCwgImFudGlhaW1fb3ZlcnJpZGVfQWlyIjp0cnVlLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18xOCI6MCwgImFudGlhaW1fYmFja3dhcmRfb2Zmc2V0X0FpciI6MSwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRfU2xvdy1XYWxrIjoxLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18xOSI6MCwgImFudGlhaW1fcGl0Y2htb2RlX0FpciI6IkRlZnVhbHQiLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRfU2xvdy1XYWxrIjoxLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18yMCI6MCwgImFudGlhaW1fcGl0Y2hfQWlyIjoiRG93biIsICJhbnRpYWltX2JvZHl5YXdfc3RlcF9TbG93LVdhbGsiOjEsICJhbnRpYWltX3BpdGNoc3RlcF9BaXIiOjEsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWluX1Nsb3ctV2FsayI6MSwgImFudGlhaW1fYmZfd2F5X0Nyb3VjaGluZ18xIjowLCAiYW50aWFpbV9waXRjaDFfQWlyIjoiVXAiLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1heF9TbG93LVdhbGsiOjEsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMiI6MCwgImFudGlhaW1fcGl0Y2gyX0FpciI6IlVwIiwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWluX1Nsb3ctV2FsayI6MSwgImFudGlhaW1fYmZfd2F5X0Nyb3VjaGluZ18zIjowLCAiYW50aWFpbV9yYW5kb21waXRjaHNfQWlyIjp7fSwgImZha2VsYWdfY3VzdG9tdGlja19BaXJfMTMiOjEsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1heF9TbG93LVdhbGsiOjEsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfNCI6MCwgInJhZ2Vib3RfTm8tU2NvcGVfaGNfQXV0byI6MCwgImFudGlhaW1fYm9keXlhd19vcHRpb25fU2xvdy1XYWxrIjp7fSwgImZha2VsYWdfY3VzdG9tdGlja19BaXJfMTQiOjEsICJhbnRpYWltX3lhd21vZGVfQWlyIjoiRGlzYWJsZWQiLCAicmFnZWJvdF9vdmVycmlkZV9zd2l0Y2hfQVdQIjpmYWxzZSwgImFudGlhaW1fbGJ5X29wdGlvbl9TbG93LVdhbGsiOiJEaXNhYmxlZCIsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfNiI6MCwgImFudGlhaW1feWF3c3RlcF9BaXIiOjEsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzgiOjAsICJyYWdlYm90X292ZXJyaWRlX2xpc3RfQVdQIjpbIk92ZXJyaWRlIl0sICJhbnRpYWltX3h3YXlfdmFsdWVfU2xvdy1XYWxrIjoyLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzciOjAsICJhbnRpYWltX3lhd2xlZnRfQWlyIjo4LCAiYW50aWFpbV9iZl93YXlfUnVubmluZ185IjowLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa18xIjowLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzgiOjAsICJhbnRpYWltX3lhd3JpZ2h0X0FpciI6OCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMTAiOjAsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzIiOjAsICJyYWdlYm90X0RlZnVhbHRfaGNfQVdQIjowLCAiYW50aWFpbV9zcGlub2Zmc2V0X0FpciI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMTEiOjAsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzMiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX0FpciI6IkNlbnRlciIsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzEyIjowLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa180IjowLCAiYW50aWFpbV9iZl93YXlfUnVubmluZ18xMyI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfNSI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMTQiOjAsICJyYWdlYm90X0Fpcl9kbWdfQVdQIjowLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa182IjowLCAiYW50aWFpbV9iZl93YXlfUnVubmluZ18xNSI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfNyI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMTYiOjAsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzgiOjAsICJyYWdlYm90X05vLVNjb3BlX2RtZ19BV1AiOjAsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzE3IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpci1EdWNrXzYiOjEsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzkiOjAsICJyYWdlYm90X05vLVNjb3BlX2hjX0FXUCI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMTgiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Fpci1EdWNrXzYiOjEsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzEwIjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpci1EdWNrXzciOjEsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzE5IjowLCAicmFnZWJvdF9vdmVycmlkZV9zd2l0Y2hfSGVhdnkgUGlzdG9sIjpmYWxzZSwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMTEiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Fpci1EdWNrXzciOjEsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzIwIjowLCAicmFnZWJvdF9vdmVycmlkZV9saXN0X0hlYXZ5IFBpc3RvbCI6WyJPdmVycmlkZSJdLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa18xMiI6MCwgImFudGlhaW1fb3ZlcnJpZGVfQ3JvdWNoaW5nIjpmYWxzZSwgImFudGlhaW1fcGl0Y2hfQ3JvdWNoaW5nIjoiVXAiLCAiZmFrZWxhZ19jdXN0b21saW1pdF9BaXItRHVja184IjoxLCAiYW50aWFpbV9iYWNrd2FyZF9vZmZzZXRfQ3JvdWNoaW5nIjowLCAiYW50aWFpbV9waXRjaHN0ZXBfQ3JvdWNoaW5nIjoxLCAicmFnZWJvdF9EZWZ1YWx0X2hjX0hlYXZ5IFBpc3RvbCI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyLUR1Y2tfOSI6MSwgImFudGlhaW1fcGl0Y2gxX0Nyb3VjaGluZyI6IlVwIiwgImZha2VsYWdfY3VzdG9tdGlja19BaXItRHVja18xMCI6MSwgInJhZ2Vib3RfT3ZlcnJpZGVfZG1nX0hlYXZ5IFBpc3RvbCI6MCwgImFudGlhaW1fcGl0Y2gyX0Nyb3VjaGluZyI6IlVwIiwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyLUR1Y2tfMTAiOjEsICJyYWdlYm90X092ZXJyaWRlX2hjX0hlYXZ5IFBpc3RvbCI6MCwgImZha2VsYWdfY3VzdG9tdGlja19BaXItRHVja18xMSI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyLUR1Y2tfMTEiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfQWlyLUR1Y2tfMTIiOjEsICJhbnRpYWltX3lhd21vZGVfQ3JvdWNoaW5nIjoiRGlzYWJsZWQiLCAicmFnZWJvdF9BaXJfaGNfSGVhdnkgUGlzdG9sIjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9BaXItRHVja18xMiI6MSwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMiI6MCwgImZha2VsYWdfY3VzdG9tdGlja19BaXItRHVja18xMyI6MSwgInJhZ2Vib3RfTm8tU2NvcGVfZG1nX0hlYXZ5IFBpc3RvbCI6MCwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMyI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyLUR1Y2tfMTMiOjEsICJyYWdlYm90X05vLVNjb3BlX2hjX0hlYXZ5IFBpc3RvbCI6MCwgImZha2VsYWdfY3VzdG9tdGlja19BaXItRHVja18xNCI6MSwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfNCI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyLUR1Y2tfMTQiOjEsICJyYWdlYm90X292ZXJyaWRlX3N3aXRjaF9QaXN0b2xzIjpmYWxzZSwgImZha2VsYWdfY3VzdG9tdGlja19BaXItRHVja18xNSI6MSwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfNiI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyLUR1Y2tfMTUiOjEsICJhbnRpYWltX3lhd21vZGlmaWVyX29mZnNldF9Dcm91Y2hpbmciOjAsICJ2aXN1YWxfYXNwZWN0X3JhdGlvIjp0cnVlLCAidmlzdWFsX2FzcGVjdF92YWx1ZSI6MTUsICJhbnRpYWltX2JvZHl5YXdfQ3JvdWNoaW5nIjpmYWxzZSwgInZpc3VhbF92aWV3bW9kZWxfY2hhbmdlciI6dHJ1ZSwgImZha2VsYWdfY3VzdG9tdGlja19BaXItRHVja18xNyI6MSwgInZpZXdtb2RlbF9mb3YiOjYwLCAiYW50aWFpbV9ib2R5eWF3X21vZGVfQ3JvdWNoaW5nIjoiU3RhdGljIiwgInZpZXdtb2RlbF94Ijo1LCAidmlld21vZGVsX3kiOjUsICJ2aWV3bW9kZWxfeiI6LTAsICJmYWtlbGFnX2N1c3RvbXRpY2tfQWlyLUR1Y2tfMTgiOjEsICJ2aXN1YWxfc2tlZXQiOnRydWUsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdF9Dcm91Y2hpbmciOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Fpci1EdWNrXzE4IjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpci1EdWNrXzE5IjoxLCAiYW50aWFpbV94d2F5X0Zha2UtRHVja18xMiI6MCwgInZpc3VhbF9za2VldF9saXN0IjpbIkc4IiwgIldlYXBvbiBTdGF0ZSIsICJETUciLCAiSEMiLCAiRFQiLCAiSFMiLCAiRkQiLCAiREEiLCAiTEMiXSwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyLUR1Y2tfMTkiOjEsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzEzIjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpci1EdWNrXzIwIjoxLCAibG9nX2F0dGFja2VkX3NvdW5kIjp0cnVlLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1heF9Dcm91Y2hpbmciOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Fpci1EdWNrXzIwIjoxLCAiYW50aWFpbV94d2F5X0Zha2UtRHVja18xNSI6MCwgImZha2VsYWdfbW9kZV9GYWtlLUR1Y2siOiJTdGF0aWMiLCAiYW50aWFpbV94d2F5X0Zha2UtRHVja18xNiI6MCwgImZha2VsYWdfbGltaXRfRmFrZS1EdWNrIjoxLCAiYW50aWFpbV94d2F5X0Zha2UtRHVja18xNyI6MCwgImZha2VsYWdfdmFyaWFiaWxpdHlfRmFrZS1EdWNrIjowLCAiYW50aWFpbV94d2F5X0Zha2UtRHVja18xOCI6MCwgImZha2VsYWdfc3RlcF9GYWtlLUR1Y2siOjEsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzE5IjowLCAiZmFrZWxhZ19saW1pdG1pbl9GYWtlLUR1Y2siOjEsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzIwIjowLCAiYW50aWFpbV9iZl92YWx1ZV9GYWtlLUR1Y2siOjIsICJmYWtlbGFnX21heGxpbWl0X0Zha2UtRHVjayI6MTUsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfMSI6MCwgImZha2VsYWdfY3VzdG9tX3ZhbHVlX0Zha2UtRHVjayI6MiwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18yIjowLCAiZmFrZWxhZ19jdXN0b210aWNrX1N0YW5kaW5nXzUiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfRmFrZS1EdWNrXzEiOjEsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfMyI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfU3RhbmRpbmdfNSI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfRmFrZS1EdWNrXzEiOjEsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfNCI6MCwgImZha2VsYWdfY3VzdG9tdGlja19TdGFuZGluZ182IjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0Zha2UtRHVja18yIjoxLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzUiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Zha2UtRHVja18yIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX1N0YW5kaW5nXzciOjEsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfNiI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfU3RhbmRpbmdfNyI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfRmFrZS1EdWNrXzMiOjEsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfNyI6MCwgImZha2VsYWdfY3VzdG9tdGlja19TdGFuZGluZ184IjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0Zha2UtRHVja180IjoxLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzgiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1N0YW5kaW5nXzgiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Zha2UtRHVja180IjoxLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzkiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfRmFrZS1EdWNrXzUiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1N0YW5kaW5nXzkiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Zha2UtRHVja181IjoxLCAiYW50aWFpbV9iZl93YXlfQWlyXzE2IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX1N0YW5kaW5nXzEwIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0Zha2UtRHVja182IjoxLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzExIjowLCAiYW50aWFpbV9iZl93YXlfQWlyXzE3IjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9TdGFuZGluZ18xMCI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfRmFrZS1EdWNrXzYiOjEsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfMTIiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfU3RhbmRpbmdfMTEiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1N0YW5kaW5nXzExIjoxLCAiYW50aWFpbV9iZl93YXlfQWlyXzE5IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX1N0YW5kaW5nXzEyIjoxLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzE0IjowLCAiYW50aWFpbV9iZl93YXlfQWlyXzIwIjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9TdGFuZGluZ18xMiI6MSwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18xNSI6MCwgImFudGlhaW1fb3ZlcnJpZGVfQWlyLUR1Y2siOmZhbHNlLCAiZmFrZWxhZ19jdXN0b210aWNrX1N0YW5kaW5nXzEzIjoxLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzE2IjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9TdGFuZGluZ18xMyI6MSwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18xNyI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfU3RhbmRpbmdfMTQiOjEsICJhbnRpYWltX3BpdGNoX0Fpci1EdWNrIjoiVXAiLCAiZmFrZWxhZ19jdXN0b210aWNrX1N0YW5kaW5nXzE1IjoxLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzE5IjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9TdGFuZGluZ18xNSI6MSwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18yMCI6MCwgImZha2VsYWdfY3VzdG9tdGlja19TdGFuZGluZ18xNiI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfU3RhbmRpbmdfMTYiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfU3RhbmRpbmdfMTciOjEsICJhbnRpYWltX3JhbmRvbXBpdGNoc19BaXItRHVjayI6e30sICJmYWtlbGFnX2N1c3RvbWxpbWl0X1N0YW5kaW5nXzE3IjoxLCAiYW50aWFpbV95YXdiYXNlX0Fpci1EdWNrIjoiTG9jYWwgVmlldyIsICJmYWtlbGFnX2N1c3RvbXRpY2tfU3RhbmRpbmdfMTgiOjEsICJhbnRpYWltX3lhd21vZGVfQWlyLUR1Y2siOiJEaXNhYmxlZCIsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1N0YW5kaW5nXzE4IjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX1N0YW5kaW5nXzE5IjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9TdGFuZGluZ18xOSI6MSwgImFudGlhaW1feWF3bGVmdF9BaXItRHVjayI6MCwgImZha2VsYWdfY3VzdG9tdGlja19TdGFuZGluZ18yMCI6MSwgImFudGlhaW1feWF3cmlnaHRfQWlyLUR1Y2siOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1N0YW5kaW5nXzIwIjoxLCAiYW50aWFpbV9zcGlub2Zmc2V0X0Fpci1EdWNrIjowLCAiZmFrZWxhZ19tb2RlX1J1bm5pbmciOiJTdGF0aWMiLCAiYW50aWFpbV95YXdtb2RpZmllcl9BaXItRHVjayI6IkRpc2FibGVkIiwgImZha2VsYWdfbGltaXRfUnVubmluZyI6MSwgImFudGlhaW1feWF3bW9kaWZpZXJfb2Zmc2V0X0Fpci1EdWNrIjowLCAiYW50aWFpbV9ib2R5eWF3X0Fpci1EdWNrIjpmYWxzZSwgImZha2VsYWdfdmFyaWFiaWxpdHlfUnVubmluZyI6MCwgImFudGlhaW1fYm9keXlhd19tb2RlX0Fpci1EdWNrIjoiU3RhdGljIiwgImZha2VsYWdfc3RlcF9SdW5uaW5nIjoxLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdF9BaXItRHVjayI6MSwgImZha2VsYWdfbGltaXRtaW5fUnVubmluZyI6MSwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0X0Fpci1EdWNrIjoxLCAiZmFrZWxhZ19saW1pdG1heF9SdW5uaW5nIjoxLCAiZmFrZWxhZ19tYXhsaW1pdF9SdW5uaW5nIjoxNSwgImFudGlhaW1fc3dpdGNoIjp0cnVlLCAiYW50aWFpbV95YXdyaWdodF9Pbi1QZWVrIjowLCAiZmFrZWxhZ19jdXN0b21fdmFsdWVfUnVubmluZyI6MiwgImFudGlhaW1fc3Bpbm9mZnNldF9Pbi1QZWVrIjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1heF9BaXItRHVjayI6MSwgImZha2VsYWdfY3VzdG9tdGlja19SdW5uaW5nXzEiOjEsICJhbnRpYWltX3lhd21vZGlmaWVyX09uLVBlZWsiOiJEaXNhYmxlZCIsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1J1bm5pbmdfMSI6MSwgImZha2VsYWdfY3VzdG9tdGlja19SdW5uaW5nXzIiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1J1bm5pbmdfMiI6MSwgImFudGlhaW1fYm9keXlhd19Pbi1QZWVrIjpmYWxzZSwgImZha2VsYWdfY3VzdG9tdGlja19SdW5uaW5nXzMiOjEsICJhbnRpYWltX2JvZHl5YXdfbW9kZV9Pbi1QZWVrIjoiU3RhdGljIiwgImZha2VsYWdfY3VzdG9tbGltaXRfUnVubmluZ18zIjoxLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdF9Pbi1QZWVrIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX1J1bm5pbmdfNCI6MSwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0X09uLVBlZWsiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfUnVubmluZ181IjoxLCAiYW50aWFpbV9ib2R5eWF3X3N0ZXBfT24tUGVlayI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfUnVubmluZ181IjoxLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1pbl9Pbi1QZWVrIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX1J1bm5pbmdfNiI6MSwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtYXhfT24tUGVlayI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfUnVubmluZ182IjoxLCAibWFpbl9naWZfc3dpdGNoIjp0cnVlLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtaW5fT24tUGVlayI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfUnVubmluZ183IjoxLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfT24tUGVlayI6MSwgInJhZ2Vib3Rfb3ZlcnJpZGVfa2V5IjpmYWxzZSwgImZha2VsYWdfY3VzdG9tdGlja19SdW5uaW5nXzgiOjEsICJhbnRpYWltX2JvZHl5YXdfb3B0aW9uX09uLVBlZWsiOnt9LCAiZmFrZWxhZ19jdXN0b21saW1pdF9SdW5uaW5nXzgiOjEsICJhbnRpYWltX2xieV9vcHRpb25fT24tUGVlayI6IkRpc2FibGVkIiwgImZha2VsYWdfY3VzdG9tdGlja19SdW5uaW5nXzkiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1J1bm5pbmdfOSI6MSwgImZha2VsYWdfY3VzdG9tdGlja19SdW5uaW5nXzEwIjoxLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMSI6MCwgInJhZ2Vib3RfZG91YmxldGFwIjp0cnVlLCAicmFnZWJvdF9kb3VibGV0YXBfdHAiOmZhbHNlLCAicmFnZWJvdF9jbG9ja19jb3JyZWN0aW9uIjp0cnVlLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMyI6MCwgInJhZ2Vib3RfZGVmZW5zaXZlX3ZlbG9jaXR5Ijo1LCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfNCI6MCwgInJhZ2Vib3RfdGlja2Jhc2VfdmFsdWUiOjE4LCAicmFnZWJvdF9hdXRvdHAiOmZhbHNlLCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfNSI6MCwgInJhZ2Vib3RfanVtcHNjb3V0Ijp0cnVlLCAicmFnZWJvdF9hZGFwdGl2ZSI6dHJ1ZSwgImFudGlhaW1feHdheV9Pbi1QZWVrXzYiOjAsICJhbnRpYWltX21hbnVhbCI6IkJhY2t3YXJkIiwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzciOjAsICJhbnRpYWltX2Rpc2FibGVfeWF3IjpbIkxlZnQiLCAiUmlnaHQiXSwgImFudGlhaW1fZGlzYWJsZV9kZXN5bmMiOnt9LCAiYW50aWFpbV94d2F5X0dsb2JhbF8xNCI6MCwgImFudGlhaW1fYm9keXlhd19pbnZlcnQiOmZhbHNlLCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfOSI6MCwgImFudGlhaW1feHdheV9HbG9iYWxfMTUiOjAsICJhbnRpYWltX2JmX3dheV9BaXItRHVja18xMCI6MCwgImFudGlhaW1feHdheV9HbG9iYWxfMTYiOjAsICJhbnRpYWltX292ZXJyaWRlX0dsb2JhbCI6dHJ1ZSwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzExIjowLCAiYW50aWFpbV94d2F5X0dsb2JhbF8xNyI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzEyIjowLCAiYW50aWFpbV94d2F5X0dsb2JhbF8xOCI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzEzIjowLCAiYW50aWFpbV94d2F5X0dsb2JhbF8xOSI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzE1IjowLCAiYW50aWFpbV94d2F5X0dsb2JhbF8yMCI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzE2IjowLCAiYW50aWFpbV9iZl92YWx1ZV9HbG9iYWwiOjIsICJhbnRpYWltX2JmX3dheV9BaXItRHVja18xNyI6MCwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF8xIjowLCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfMTgiOjAsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMiI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzE5IjowLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzMiOjAsICJhbnRpYWltX2JmX3dheV9BaXItRHVja18yMCI6MCwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF80IjowLCAiYW50aWFpbV9vdmVycmlkZV9GYWtlLUR1Y2siOmZhbHNlLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzUiOjAsICJhbnRpYWltX3BpdGNobW9kZV9GYWtlLUR1Y2siOiJEZWZ1YWx0IiwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF82IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX09uLVBlZWtfMTkiOjEsICJhbnRpYWltX3BpdGNoX0Zha2UtRHVjayI6IlVwIiwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF83IjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9Pbi1QZWVrXzE5IjoxLCAiYW50aWFpbV9waXRjaHN0ZXBfRmFrZS1EdWNrIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX09uLVBlZWtfMjAiOjEsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfOCI6MCwgImZha2VsYWdfZml4X3N3aXRjaCI6ZmFsc2UsICJhbnRpYWltX3BpdGNoMV9GYWtlLUR1Y2siOiJVcCIsICJmYWtlbGFnX2N1c3RvbWxpbWl0X09uLVBlZWtfMjAiOjEsICJmYWtlbGFnX2ZpeF9mYWtlZHVjayI6ZmFsc2UsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfOSI6MCwgImFudGlhaW1fcGl0Y2gyX0Zha2UtRHVjayI6IlVwIiwgImZha2VsYWdfZml4X3N0eWxlIjoiQWltYm90IiwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF8xMCI6MCwgImZha2VsYWdfb3ZlcnJpZGVfR2xvYmFsIjp0cnVlLCAiYW50aWFpbV95YXdiYXNlX0Zha2UtRHVjayI6IkxvY2FsIFZpZXciLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzExIjowLCAiYW50aWFpbV95YXdtb2RlX0Zha2UtRHVjayI6IkRpc2FibGVkIiwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF8xMiI6MCwgImFudGlhaW1feWF3c3RlcF9GYWtlLUR1Y2siOjEsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMTMiOjAsICJhbnRpYWltX3lhd2xlZnRfRmFrZS1EdWNrIjowLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzE0IjowLCAiYW50aWFpbV95YXdyaWdodF9GYWtlLUR1Y2siOjAsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMTUiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX0Zha2UtRHVjayI6IkRpc2FibGVkIiwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF8xNiI6MCwgImFudGlhaW1feWF3bW9kaWZpZXJfb2Zmc2V0X0Zha2UtRHVjayI6MCwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF8xNyI6MCwgImFudGlhaW1fYm9keXlhd19GYWtlLUR1Y2siOmZhbHNlLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzE4IjowLCAiYW50aWFpbV9ib2R5eWF3X21vZGVfRmFrZS1EdWNrIjoiU3RhdGljIiwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF8xOSI6MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRfRmFrZS1EdWNrIjoxLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzIwIjowLCAiYW50aWFpbV9ib2R5eWF3X3N0ZXBfRmFrZS1EdWNrIjoxLCAiYW50aWFpbV9ib2R5eWF3X1N0YW5kaW5nIjp0cnVlLCAiYW50aWFpbV9iYWNrd2FyZF9vZmZzZXRfU3RhbmRpbmciOjAsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWF4X0Zha2UtRHVjayI6MSwgImFudGlhaW1fcGl0Y2htb2RlX1N0YW5kaW5nIjoiRGVmdWFsdCIsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1pbl9GYWtlLUR1Y2siOjEsICJhbnRpYWltX3BpdGNoX1N0YW5kaW5nIjoiRG93biIsICJhbnRpYWltX3BpdGNoc3RlcF9TdGFuZGluZyI6MSwgImFudGlhaW1fcGl0Y2gxX1N0YW5kaW5nIjoiVXAiLCAiYW50aWFpbV9waXRjaDJfU3RhbmRpbmciOiJVcCIsICJhbnRpYWltX3JhbmRvbXBpdGNoc19TdGFuZGluZyI6e30sICJhbnRpYWltX3lhd2Jhc2VfU3RhbmRpbmciOiJBdCBUYXJnZXQiLCAiYW50aWFpbV95YXdtb2RlX1N0YW5kaW5nIjoiRGlzYWJsZWQiLCAiYW50aWFpbV95YXdzdGVwX1N0YW5kaW5nIjoxLCAiYW50aWFpbV95YXdsZWZ0X1N0YW5kaW5nIjowLCAiYW50aWFpbV95YXdtb2RpZmllcl9vZmZzZXRfR2xvYmFsIjowLCAiYW50aWFpbV9ib2R5eWF3X0dsb2JhbCI6ZmFsc2UsICJhbnRpYWltX2JvZHl5YXdfbW9kZV9HbG9iYWwiOiJTdGF0aWMiLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdF9HbG9iYWwiOjEsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdF9HbG9iYWwiOjEsICJhbnRpYWltX2JvZHl5YXdfc3RlcF9HbG9iYWwiOjEsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWluX0dsb2JhbCI6MSwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtYXhfR2xvYmFsIjoxLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtaW5fR2xvYmFsIjoxLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfR2xvYmFsIjoxLCAiYW50aWFpbV9ib2R5eWF3X29wdGlvbl9HbG9iYWwiOnt9LCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzkiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTAiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTEiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTIiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTMiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTQiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTUiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTYiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTciOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTgiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTkiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMjAiOjAsICJhbnRpYWltX3h3YXlfQWlyXzE2IjowLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfNSI6NDQsICJyYWdlYm90X0RlZnVhbHRfaGNfWmV1cyI6MCwgImZha2VsYWdfY3VzdG9tdGlja19Dcm91Y2hpbmdfMTQiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfR2xvYmFsXzIwIjoxLCAiYW50aWFpbV9iYWNrd2FyZF9vZmZzZXRfU2xvdy1XYWxrIjowLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfNiI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfUnVubmluZ18xMSI6MSwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMSI6MCwgImZha2VsYWdfY3VzdG9tdGlja19BaXJfMiI6MSwgImFudGlhaW1fcGl0Y2htb2RlX1Nsb3ctV2FsayI6IkRlZnVhbHQiLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfNyI6MCwgImZha2VsYWdfY3VzdG9tdGlja19SdW5uaW5nXzciOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0dsb2JhbF8xOSI6MSwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa181IjowLCAiYW50aWFpbV9waXRjaF9TbG93LVdhbGsiOiJEb3duIiwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzgiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMTEiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfNiI6MCwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV8yMCI6MCwgImFudGlhaW1fcGl0Y2hzdGVwX1Nsb3ctV2FsayI6MSwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzkiOjAsICJhbnRpYWltX3lhd3JpZ2h0X1J1bm5pbmciOjM2LCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzgiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMTYiOjAsICJhbnRpYWltX3BpdGNoMV9TbG93LVdhbGsiOiJVcCIsICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ18xMCI6MCwgImFudGlhaW1fc3Bpbm9mZnNldF9SdW5uaW5nIjo0MywgImFudGlhaW1fbGJ5X29wdGlvbl9GYWtlLUR1Y2siOiJEaXNhYmxlZCIsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0dsb2JhbF8xOCI6MSwgImFudGlhaW1fcGl0Y2gyX1Nsb3ctV2FsayI6IlVwIiwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzExIjowLCAiYW50aWFpbV95YXdtb2RpZmllcl9SdW5uaW5nIjoiU3BpbiIsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTIiOjAsICJhbnRpYWltX3lhd2Jhc2VfQ3JvdWNoaW5nIjoiTG9jYWwgVmlldyIsICJhbnRpYWltX3JhbmRvbXBpdGNoc19TbG93LVdhbGsiOnt9LCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMTIiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX29mZnNldF9SdW5uaW5nIjoxOCwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMiI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzgiOjAsICJhbnRpYWltX3lhd2Jhc2VfU2xvdy1XYWxrIjoiQXQgVGFyZ2V0IiwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzEzIjowLCAiYW50aWFpbV9ib2R5eWF3X1J1bm5pbmciOmZhbHNlLCAiYW50aWFpbV9iZl93YXlfT24tUGVla18zIjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ181IjowLCAiYW50aWFpbV95YXdtb2RlX1Nsb3ctV2FsayI6IkppdHRlciIsICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ18xNCI6MCwgImFudGlhaW1fYm9keXlhd19tb2RlX1J1bm5pbmciOiJGbHVjdHVhdGUiLCAiYW50aWFpbV9iZl93YXlfT24tUGVla180IjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18zIjowLCAiYW50aWFpbV95YXdzdGVwX1Nsb3ctV2FsayI6MSwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzE1IjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdF9SdW5uaW5nIjoxLCAiYW50aWFpbV9iZl93YXlfT24tUGVla181IjowLCAiYW50aWFpbV9ib2R5eWF3X3N0ZXBfRXhwbG9pdC1EZWZlbnNpdmUiOjEsICJhbnRpYWltX3lhd2xlZnRfU2xvdy1XYWxrIjozNSwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzE2IjowLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRfUnVubmluZyI6MSwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfNiI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfQ3JvdWNoaW5nXzgiOjEsICJhbnRpYWltX3lhd3JpZ2h0X1Nsb3ctV2FsayI6MzUsICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ18xNyI6MCwgImFudGlhaW1fYm9keXlhd19zdGVwX1J1bm5pbmciOjUsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzciOjAsICJyYWdlYm90X05vLVNjb3BlX2RtZ19BdXRvIjowLCAiYW50aWFpbV9zcGlub2Zmc2V0X1Nsb3ctV2FsayI6MCwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzE4IjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1pbl9SdW5uaW5nIjoxLCAiYW50aWFpbV9iZl93YXlfT24tUGVla184IjowLCAiZmFrZWxhZ192YXJpYWJpbGl0eV9TdGFuZGluZyI6MCwgImFudGlhaW1feWF3bW9kaWZpZXJfU2xvdy1XYWxrIjoiU3BpbiIsICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ18xOSI6MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtYXhfUnVubmluZyI6NjAsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzkiOjAsICJyYWdlYm90X092ZXJyaWRlX2RtZ19BV1AiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX29mZnNldF9TbG93LVdhbGsiOjIwLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMjAiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1pbl9SdW5uaW5nIjoxLCAiYW50aWFpbV9ib2R5eWF3X1Nsb3ctV2FsayI6ZmFsc2UsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzEwIjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0dsb2JhbF8xNyI6MSwgImFudGlhaW1fb3ZlcnJpZGVfUnVubmluZyI6dHJ1ZSwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWF4X1J1bm5pbmciOjYwLCAiYW50aWFpbV9ib2R5eWF3X21vZGVfU2xvdy1XYWxrIjoiU3RhdGljIiwgImZha2VsYWdfY3VzdG9tbGltaXRfUnVubmluZ18xMiI6MSwgImFudGlhaW1feHdheV9BaXItRHVja18xOCI6MCwgImFudGlhaW1fYmFja3dhcmRfb2Zmc2V0X1J1bm5pbmciOjAsICJhbnRpYWltX2JvZHl5YXdfb3B0aW9uX1J1bm5pbmciOlsiQXZvaWQgT3ZlcmxhcCJdLCAiZmFrZWxhZ19jdXN0b21saW1pdF9Dcm91Y2hpbmdfNyI6MSwgImFudGlhaW1feHdheV92YWx1ZV9GYWtlLUR1Y2siOjIsICJmYWtlbGFnX2N1c3RvbXRpY2tfQWlyLUR1Y2tfNSI6MSwgImFudGlhaW1fcGl0Y2htb2RlX1J1bm5pbmciOiJEZWZ1YWx0IiwgImFudGlhaW1fbGJ5X29wdGlvbl9SdW5uaW5nIjoiU3dheSIsICJhbnRpYWltX2JmX3dheV9BaXJfMyI6MCwgImFudGlhaW1feWF3c3RlcF9Dcm91Y2hpbmciOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfR2xvYmFsXzE2IjoxLCAiYW50aWFpbV9waXRjaF9SdW5uaW5nIjoiRG93biIsICJhbnRpYWltX3h3YXlfdmFsdWVfUnVubmluZyI6MjAsICJhbnRpYWltX3lhd2Jhc2VfQWlyIjoiQXQgVGFyZ2V0IiwgInJhZ2Vib3Rfb3ZlcnJpZGVfbGlzdF9QaXN0b2xzIjpbIk92ZXJyaWRlIl0sICJmYWtlbGFnX21vZGVfU3RhbmRpbmciOiJTdGF0aWMiLCAiYW50aWFpbV9waXRjaHN0ZXBfUnVubmluZyI6MiwgImFudGlhaW1feHdheV9SdW5uaW5nXzEiOi0zOSwgImZha2VsYWdfY3VzdG9tbGltaXRfR2xvYmFsXzE1IjoxLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ182IjowLCAiYW50aWFpbV95YXdsZWZ0X0Nyb3VjaGluZyI6MCwgImFudGlhaW1fcGl0Y2gxX1J1bm5pbmciOiJVcCIsICJhbnRpYWltX3h3YXlfUnVubmluZ18yIjo0MywgImZha2VsYWdfY3VzdG9tdGlja19Dcm91Y2hpbmdfNiI6MSwgInZpc3VhbF9za2VldF9vZmZzZXQiOjAsICJhbnRpYWltX3lhd3JpZ2h0X0Nyb3VjaGluZyI6MCwgImFudGlhaW1fcGl0Y2gyX1J1bm5pbmciOiJEb3duIiwgImFudGlhaW1feHdheV9SdW5uaW5nXzMiOi01MCwgImFudGlhaW1fYmFja3dhcmRfb2Zmc2V0X09uLVBlZWsiOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfNiI6MCwgImFudGlhaW1fcGl0Y2gxX0dsb2JhbCI6IlVwIiwgImFudGlhaW1fcmFuZG9tcGl0Y2hzX1J1bm5pbmciOlsiVXAiLCAiRG93biJdLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfNCI6ODQsICJhbnRpYWltX3BpdGNobW9kZV9Pbi1QZWVrIjoiRGVmdWFsdCIsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0dsb2JhbF8xNCI6MSwgInJhZ2Vib3RfRGVmdWFsdF9kbWdfSGVhdnkgUGlzdG9sIjowLCAiYW50aWFpbV95YXdiYXNlX1J1bm5pbmciOiJBdCBUYXJnZXQiLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfNSI6LTM2LCAiYW50aWFpbV9waXRjaF9Pbi1QZWVrIjoiVXAiLCAiYW50aWFpbV95YXdtb2RpZmllcl9Dcm91Y2hpbmciOiJEaXNhYmxlZCIsICJmYWtlbGFnX2N1c3RvbXRpY2tfQ3JvdWNoaW5nXzUiOjEsICJhbnRpYWltX3lhd21vZGVfUnVubmluZyI6IkppdHRlciIsICJhbnRpYWltX3h3YXlfUnVubmluZ182Ijo2NSwgImFudGlhaW1fcGl0Y2hzdGVwX09uLVBlZWsiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfR2xvYmFsXzE0IjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX1N0YW5kaW5nXzEiOjEsICJhbnRpYWltX3lhd3N0ZXBfUnVubmluZyI6MiwgImFudGlhaW1feHdheV9SdW5uaW5nXzciOi01MCwgImFudGlhaW1fcGl0Y2gxX09uLVBlZWsiOiJVcCIsICJhbnRpYWltX3h3YXlfUnVubmluZ18yMCI6MjQsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Zha2UtRHVja18xOCI6MSwgImFudGlhaW1feWF3bGVmdF9SdW5uaW5nIjozNiwgImFudGlhaW1feHdheV9SdW5uaW5nXzgiOjM5LCAiYW50aWFpbV9waXRjaDJfT24tUGVlayI6IlVwIiwgImZha2VsYWdfY3VzdG9tbGltaXRfR2xvYmFsXzEzIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9HbG9iYWxfNCI6MSwgImFudGlhaW1fb3ZlcnJpZGVfT24tUGVlayI6ZmFsc2UsICJhbnRpYWltX292ZXJyaWRlX0V4cGxvaXQtRGVmZW5zaXZlIjp0cnVlLCAiYW50aWFpbV9yYW5kb21waXRjaHNfT24tUGVlayI6e30sICJyYWdlYm90X0RlZnVhbHRfZG1nX1Njb3V0IjoxMDAsICJmYWtlbGFnX2N1c3RvbXRpY2tfU3RhbmRpbmdfOSI6MSwgInJhZ2Vib3RfQWlyX2RtZ19IZWF2eSBQaXN0b2wiOjAsICJhbnRpYWltX3h3YXlfUnVubmluZ18xMCI6NjksICJhbnRpYWltX3lhd2Jhc2VfT24tUGVlayI6IkxvY2FsIFZpZXciLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzEwIjowLCAicmFnZWJvdF9vdmVycmlkZV9saXN0X0dsb2JhbCI6WyJPdmVycmlkZSJdLCAiZmFrZWxhZ19jdXN0b21saW1pdF9Dcm91Y2hpbmdfMyI6MSwgImFudGlhaW1feHdheV9SdW5uaW5nXzExIjotNTgsICJhbnRpYWltX3lhd21vZGVfT24tUGVlayI6IkRpc2FibGVkIiwgImZha2VsYWdfY3VzdG9tbGltaXRfR2xvYmFsXzEyIjoxLCAiZmFrZWxhZ19vdmVycmlkZV9Pbi1QZWVrIjpmYWxzZSwgImZha2VsYWdfbWF4bGltaXRfR2xvYmFsIjoxNSwgImFudGlhaW1feHdheV9SdW5uaW5nXzEyIjo2NCwgImFudGlhaW1feWF3c3RlcF9Pbi1QZWVrIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX1N0YW5kaW5nXzE0IjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpcl8xNSI6MSwgImZha2VsYWdfY3VzdG9tdGlja19HbG9iYWxfMTIiOjEsICJhbnRpYWltX3h3YXlfUnVubmluZ18xMyI6LTU3LCAiYW50aWFpbV95YXdsZWZ0X09uLVBlZWsiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdF9FeHBsb2l0LURlZmVuc2l2ZSI6NjAsICJhbnRpYWltX3h3YXlfR2xvYmFsXzEyIjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9Dcm91Y2hpbmdfMiI6MSwgImFudGlhaW1feHdheV9SdW5uaW5nXzE0Ijo2NSwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyXzE0IjoxLCAiYW50aWFpbV9yYW5kb21waXRjaHNfRmFrZS1EdWNrIjp7fSwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMTYiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfQ3JvdWNoaW5nXzIiOjEsICJhbnRpYWltX3h3YXlfUnVubmluZ18xNSI6LTU0LCAiYW50aWFpbV9sYnlfb3B0aW9uX0dsb2JhbCI6IkRpc2FibGVkIiwgImZha2VsYWdfY3VzdG9tdGlja19HbG9iYWxfMTEiOjEsICJhbnRpYWltX3h3YXlfdmFsdWVfQ3JvdWNoaW5nIjoyLCAiZmFrZWxhZ19jdXN0b21saW1pdF9TbG93LVdhbGtfMTUiOjEsICJhbnRpYWltX3h3YXlfUnVubmluZ18xNiI6NDMsICJmYWtlbGFnX292ZXJyaWRlX1J1bm5pbmciOmZhbHNlLCAiYW50aWFpbV94d2F5X3ZhbHVlX0dsb2JhbCI6MiwgImZha2VsYWdfY3VzdG9tdGlja19TbG93LVdhbGtfMTciOjEsICJhbnRpYWltX2xieV9vcHRpb25fQWlyLUR1Y2siOiJEaXNhYmxlZCIsICJhbnRpYWltX3h3YXlfUnVubmluZ18xNyI6LTM5LCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE5IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0Nyb3VjaGluZ18xIjoxLCAiYW50aWFpbV94d2F5X0dsb2JhbF8xIjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9Pbi1QZWVrXzEwIjoxLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfMTgiOjUwLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzExIjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9BaXJfMTUiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfU2xvdy1XYWxrXzIwIjoxLCAiYW50aWFpbV94d2F5X0dsb2JhbF8yIjowLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfMTkiOi01OCwgImZha2VsYWdfY3VzdG9tbGltaXRfR2xvYmFsXzkiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1Nsb3ctV2Fsa18yMCI6MSwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMTAiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X09uLVBlZWtfMTMiOjEsICJhbnRpYWltX3h3YXlfR2xvYmFsXzMiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Fpcl80IjoxLCAicmFnZWJvdF9BaXJfZG1nX0dsb2JhbCI6MCwgImZha2VsYWdfY3VzdG9tdGlja19Pbi1QZWVrXzE0IjoxLCAiYW50aWFpbV9iZl92YWx1ZV9SdW5uaW5nIjoyLCAiYW50aWFpbV9iZl93YXlfQWlyXzE4IjowLCAiYW50aWFpbV94d2F5X0dsb2JhbF80IjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9HbG9iYWxfOCI6MSwgImFudGlhaW1feHdheV92YWx1ZV9Pbi1QZWVrIjoyLCAiZmFrZWxhZ19saW1pdG1heF9Dcm91Y2hpbmciOjEsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzEiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1J1bm5pbmdfNCI6MSwgImFudGlhaW1feHdheV9HbG9iYWxfNSI6MCwgImZha2VsYWdfY3VzdG9tdGlja19Pbi1QZWVrXzE3IjoxLCAiYW50aWFpbV9iZl93YXlfT24tUGVla18xMSI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMiI6MCwgImFudGlhaW1fYmFja3dhcmRfb2Zmc2V0X0Fpci1EdWNrIjowLCAiZmFrZWxhZ19saW1pdG1pbl9Dcm91Y2hpbmciOjEsICJhbnRpYWltX3h3YXlfR2xvYmFsXzYiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfQWlyXzEiOjEsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzMiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Fpcl8xIjoxLCAiYW50aWFpbV9waXRjaG1vZGVfQWlyLUR1Y2siOiJEZWZ1YWx0IiwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRfRXhwbG9pdC1EZWZlbnNpdmUiOjYwLCAiYW50aWFpbV94d2F5X0dsb2JhbF83IjowLCAiYW50aWFpbV9iZl93YXlfUnVubmluZ180IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX1Nsb3ctV2Fsa182IjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpcl8xNiI6MSwgImFudGlhaW1feHdheV9Pbi1QZWVrXzE2IjowLCAiYW50aWFpbV9iZl93YXlfT24tUGVla18xMyI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfNSI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyXzE2IjoxLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMTAiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1Nsb3ctV2Fsa181IjoxLCAiYW50aWFpbV9iZl93YXlfT24tUGVla18xNCI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfNiI6MCwgImFudGlhaW1feHdheV9HbG9iYWxfOSI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyXzMiOjEsICJmYWtlbGFnX3ZhcmlhYmlsaXR5X0Nyb3VjaGluZyI6MCwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMTUiOjAsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzciOjAsICJhbnRpYWltX3BpdGNoc3RlcF9BaXItRHVjayI6MSwgImFudGlhaW1feHdheV9HbG9iYWxfMTAiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfQWlyXzE4IjoxLCAiYW50aWFpbV9iZl93YXlfT24tUGVla18xNiI6MCwgImFudGlhaW1feHdheV9Pbi1QZWVrXzUiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfU2xvdy1XYWxrXzUiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Fpcl8xOCI6MSwgImFudGlhaW1feHdheV9HbG9iYWxfMTEiOjAsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzE3IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpci1EdWNrXzE2IjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpcl8xOSI6MSwgImZha2VsYWdfbGltaXRfQ3JvdWNoaW5nIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpcl81IjoxLCAiYW50aWFpbV9iZl93YXlfT24tUGVla18xOCI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyXzE5IjoxLCAiZmFrZWxhZ19saW1pdG1heF9GYWtlLUR1Y2siOjEsICJhbnRpYWltX2JmX3ZhbHVlX0Nyb3VjaGluZyI6MiwgImFudGlhaW1feWF3c3RlcF9BaXItRHVjayI6MSwgImZha2VsYWdfY3VzdG9tdGlja19BaXJfMjAiOjEsICJhbnRpYWltX3h3YXlfR2xvYmFsXzEzIjowLCAiZmFrZWxhZ19tb2RlX0Nyb3VjaGluZyI6IlN0YXRpYyIsICJmYWtlbGFnX2N1c3RvbXRpY2tfU2xvdy1XYWxrXzQiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Fpcl8yMCI6MSwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMjAiOjAsICJhbnRpYWltX2xieV9vcHRpb25fRXhwbG9pdC1EZWZlbnNpdmUiOiJPcHBvc2l0ZSIsICJmYWtlbGFnX292ZXJyaWRlX0Fpci1EdWNrIjpmYWxzZSwgImZha2VsYWdfY3VzdG9tbGltaXRfRmFrZS1EdWNrXzkiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1Nsb3ctV2Fsa18zIjoxLCAiZmFrZWxhZ19tb2RlX0Fpci1EdWNrIjoiU3RhdGljIiwgInJhZ2Vib3Rfb3ZlcnJpZGVfc3dpdGNoX0dsb2JhbCI6ZmFsc2UsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfMTgiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Zha2UtRHVja18xMSI6MSwgImFudGlhaW1fYmFja3dhcmRfb2Zmc2V0X0V4cGxvaXQtRGVmZW5zaXZlIjowLCAiZmFrZWxhZ19saW1pdF9BaXItRHVjayI6MSwgImZha2VsYWdfY3VzdG9tdGlja19GYWtlLUR1Y2tfMTIiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfU2xvdy1XYWxrXzMiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfRmFrZS1EdWNrXzE1IjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9GYWtlLUR1Y2tfMTYiOjEsICJmYWtlbGFnX3ZhcmlhYmlsaXR5X0Fpci1EdWNrIjowLCAiYW50aWFpbV94d2F5X09uLVBlZWtfOCI6MCwgImZha2VsYWdfY3VzdG9tdGlja19GYWtlLUR1Y2tfMTYiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfRmFrZS1EdWNrXzE3IjoxLCAiYW50aWFpbV9waXRjaF9FeHBsb2l0LURlZmVuc2l2ZSI6IlVwIiwgImZha2VsYWdfc3RlcF9BaXItRHVjayI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfR2xvYmFsXzMiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Zha2UtRHVja18xNyI6MSwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMTQiOjAsICJhbnRpYWltX3BpdGNoc3RlcF9FeHBsb2l0LURlZmVuc2l2ZSI6MiwgImZha2VsYWdfbGltaXRtaW5fQWlyLUR1Y2siOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfRmFrZS1EdWNrXzE4IjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9SdW5uaW5nXzE5IjoxLCAiYW50aWFpbV94d2F5X0Zha2UtRHVja18xMSI6MCwgImFudGlhaW1fcGl0Y2gxX0V4cGxvaXQtRGVmZW5zaXZlIjoiVXAiLCAiZmFrZWxhZ19saW1pdG1heF9BaXItRHVjayI6MSwgImZha2VsYWdfY3VzdG9tdGlja19TbG93LVdhbGtfMiI6MSwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfOSI6MCwgImZha2VsYWdfY3VzdG9tdGlja19SdW5uaW5nXzE5IjoxLCAiYW50aWFpbV9waXRjaDJfRXhwbG9pdC1EZWZlbnNpdmUiOiJEb3duIiwgImZha2VsYWdfbWF4bGltaXRfQWlyLUR1Y2siOjE1LCAiZmFrZWxhZ19jdXN0b21saW1pdF9TdGFuZGluZ18zIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0Zha2UtRHVja18xMCI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfRmFrZS1EdWNrXzE5IjoxLCAiYW50aWFpbV9yYW5kb21waXRjaHNfRXhwbG9pdC1EZWZlbnNpdmUiOlsiVXAiLCAiRG93biJdLCAiZmFrZWxhZ19jdXN0b21fdmFsdWVfQWlyLUR1Y2siOjIsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzUiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfRmFrZS1EdWNrXzIwIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9SdW5uaW5nXzE4IjoxLCAiYW50aWFpbV95YXdiYXNlX0V4cGxvaXQtRGVmZW5zaXZlIjoiQXQgVGFyZ2V0IiwgImZha2VsYWdfY3VzdG9tdGlja19BaXItRHVja18xIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9GYWtlLUR1Y2tfMjAiOjEsICJhbnRpYWltX2JvZHl5YXdfb3B0aW9uX0Zha2UtRHVjayI6e30sICJmYWtlbGFnX2N1c3RvbXRpY2tfU2xvdy1XYWxrXzEiOjEsICJhbnRpYWltX3lhd21vZGVfRXhwbG9pdC1EZWZlbnNpdmUiOiJKaXR0ZXIiLCAiZmFrZWxhZ19jdXN0b21saW1pdF9BaXItRHVja18xIjoxLCAiYW50aWFpbV9ib2R5eWF3X3N0ZXBfQWlyLUR1Y2siOjEsICJmYWtlbGFnX21vZGVfT24tUGVlayI6IlN0YXRpYyIsICJmYWtlbGFnX2N1c3RvbXRpY2tfQWlyLUR1Y2tfMiI6MSwgImFudGlhaW1feWF3c3RlcF9FeHBsb2l0LURlZmVuc2l2ZSI6MiwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfOCI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfRmFrZS1EdWNrXzE0IjoxLCAiZmFrZWxhZ19saW1pdF9Pbi1QZWVrIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9BaXItRHVja18yIjoxLCAiYW50aWFpbV95YXdsZWZ0X0V4cGxvaXQtRGVmZW5zaXZlIjo5MCwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzQiOjYwLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpci1EdWNrXzMiOjEsICJmYWtlbGFnX3ZhcmlhYmlsaXR5X09uLVBlZWsiOjAsICJhbnRpYWltX3h3YXlfT24tUGVla180IjowLCAiYW50aWFpbV95YXdyaWdodF9FeHBsb2l0LURlZmVuc2l2ZSI6OTAsICJmYWtlbGFnX2N1c3RvbXRpY2tfT24tUGVla18xIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9BaXItRHVja18zIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9TbG93LVdhbGtfNiI6MSwgImFudGlhaW1feWF3bW9kaWZpZXJfb2Zmc2V0X09uLVBlZWsiOjAsICJhbnRpYWltX3NwaW5vZmZzZXRfRXhwbG9pdC1EZWZlbnNpdmUiOjMyLCAiZmFrZWxhZ19jdXN0b210aWNrX1Nsb3ctV2Fsa183IjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0dsb2JhbF8xIjoxLCAiZmFrZWxhZ19saW1pdG1pbl9Pbi1QZWVrIjoxLCAicmFnZWJvdF9PdmVycmlkZV9oY19BV1AiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX0V4cGxvaXQtRGVmZW5zaXZlIjoiRGlzYWJsZWQiLCAiZmFrZWxhZ19jdXN0b21saW1pdF9TbG93LVdhbGtfNyI6MSwgImZha2VsYWdfbWF4bGltaXRfU2xvdy1XYWxrIjoxNSwgImZha2VsYWdfbGltaXRtYXhfT24tUGVlayI6MSwgImZha2VsYWdfY3VzdG9tdGlja19TbG93LVdhbGtfOCI6MSwgImFudGlhaW1feWF3bW9kaWZpZXJfb2Zmc2V0X0V4cGxvaXQtRGVmZW5zaXZlIjo3MiwgInJhZ2Vib3RfQWlyX2hjX0FXUCI6MCwgImZha2VsYWdfbWF4bGltaXRfT24tUGVlayI6MTUsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Fpci1EdWNrXzUiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1Nsb3ctV2Fsa184IjoxLCAiYW50aWFpbV9ib2R5eWF3X0V4cGxvaXQtRGVmZW5zaXZlIjpmYWxzZSwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzEwIjowLCAiZmFrZWxhZ19jdXN0b210aWNrX1Nsb3ctV2Fsa185IjoxLCAiZmFrZWxhZ19jdXN0b21fdmFsdWVfR2xvYmFsIjoyLCAiZmFrZWxhZ19jdXN0b21saW1pdF9SdW5uaW5nXzE2IjoxLCAiYW50aWFpbV9ib2R5eWF3X21vZGVfRXhwbG9pdC1EZWZlbnNpdmUiOiJTdGF0aWMiLCAiZmFrZWxhZ19jdXN0b210aWNrX09uLVBlZWtfMTYiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1Nsb3ctV2Fsa185IjoxLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzkiOjAsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV8xNCI6MCwgImZha2VsYWdfY3VzdG9tdGlja19TbG93LVdhbGtfMTAiOjEsICJhbnRpYWltX2JmX3dheV9BaXItRHVja182IjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9Pbi1QZWVrXzEiOjEsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTAiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfUnVubmluZ18xNiI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfU2xvdy1XYWxrXzEwIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX09uLVBlZWtfMiI6MSwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzMiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfU2xvdy1XYWxrXzExIjoxLCAiYW50aWFpbV9iYWNrd2FyZF9vZmZzZXRfRmFrZS1EdWNrIjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9Pbi1QZWVrXzIiOjEsICJhbnRpYWltX2JmX3dheV9BaXJfMSI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfUnVubmluZ18xNSI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfU2xvdy1XYWxrXzExIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX09uLVBlZWtfMyI6MSwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtaW5fRXhwbG9pdC1EZWZlbnNpdmUiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfU2xvdy1XYWxrXzEyIjoxLCAiZmFrZWxhZ19zdGVwX1N0YW5kaW5nIjoxLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzEzIjowLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzgiOjAsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWF4X0V4cGxvaXQtRGVmZW5zaXZlIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9TbG93LVdhbGtfMTIiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfT24tUGVla180IjoxLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE0IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX1Nsb3ctV2Fsa18xMyI6MSwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWluX0V4cGxvaXQtRGVmZW5zaXZlIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9Pbi1QZWVrXzQiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfUnVubmluZ18xNSI6MSwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV8xNSI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfU2xvdy1XYWxrXzEzIjoxLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfRXhwbG9pdC1EZWZlbnNpdmUiOjEsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzEiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfU2xvdy1XYWxrXzE0IjoxLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE2IjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9Pbi1QZWVrXzUiOjEsICJhbnRpYWltX2JvZHl5YXdfb3B0aW9uX0V4cGxvaXQtRGVmZW5zaXZlIjp7fSwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfNyI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfU2xvdy1XYWxrXzE0IjoxLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE3IjowLCAicmFnZWJvdF9zd2l0Y2giOnRydWUsICJmYWtlbGFnX2N1c3RvbXRpY2tfU2xvdy1XYWxrXzE1IjoxLCAiZmFrZWxhZ192YXJpYWJpbGl0eV9TbG93LVdhbGsiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X09uLVBlZWtfNiI6MSwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV8xOCI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfU3RhbmRpbmdfNiI6MSwgImFudGlhaW1feHdheV92YWx1ZV9FeHBsb2l0LURlZmVuc2l2ZSI6MiwgImZha2VsYWdfY3VzdG9tdGlja19Pbi1QZWVrXzciOjEsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfNCI6MCwgImZha2VsYWdfY3VzdG9tdGlja19TbG93LVdhbGtfMTYiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X09uLVBlZWtfNyI6MSwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV8xIjowLCAiZmFrZWxhZ19jdXN0b210aWNrX1J1bm5pbmdfMTQiOjEsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzE5IjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9TbG93LVdhbGtfMTYiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfT24tUGVla184IjoxLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzIiOjAsICJhbnRpYWltX3lhd3JpZ2h0X1N0YW5kaW5nIjowLCAiYW50aWFpbV9iZl92YWx1ZV9FeHBsb2l0LURlZmVuc2l2ZSI6MiwgImZha2VsYWdfY3VzdG9tbGltaXRfT24tUGVla184IjoxLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfRmFrZS1EdWNrIjoxLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzMiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1Nsb3ctV2Fsa18xNyI6MSwgImFudGlhaW1fc3Bpbm9mZnNldF9TdGFuZGluZyI6MCwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzEiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfU2xvdy1XYWxrXzE4IjoxLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzQiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X09uLVBlZWtfOSI6MSwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtaW5fQWlyLUR1Y2siOjEsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV8yIjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9TbG93LVdhbGtfMTgiOjEsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfNSI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfUnVubmluZ18xMyI6MSwgImZha2VsYWdfY3VzdG9tdGlja19TbG93LVdhbGtfMTkiOjEsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV8zIjowLCAiYW50aWFpbV95YXdtb2RpZmllcl9vZmZzZXRfU3RhbmRpbmciOjQsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfNiI6MCwgImFudGlhaW1fYmZfdmFsdWVfQWlyIjoyLCAiZmFrZWxhZ19jdXN0b21saW1pdF9TbG93LVdhbGtfMTkiOjEsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV80IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX09uLVBlZWtfOSI6MSwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV83IjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9SdW5uaW5nXzEwIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9Pbi1QZWVrXzExIjoxLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfNSI6MCwgImFudGlhaW1fYm9keXlhd19tb2RlX1N0YW5kaW5nIjoiU3RhdGljIiwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV84IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX09uLVBlZWtfMTIiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfUnVubmluZ18xMyI6MSwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzYiOjAsICJmYWtlbGFnX292ZXJyaWRlX1Nsb3ctV2FsayI6ZmFsc2UsICJmYWtlbGFnX2N1c3RvbWxpbWl0X09uLVBlZWtfMTIiOjEsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0X1N0YW5kaW5nIjo2MCwgImZha2VsYWdfbW9kZV9BaXIiOiJTdGF0aWMiLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfNyI6MCwgImZha2VsYWdfY3VzdG9tdGlja19Pbi1QZWVrXzEzIjoxLCAiZmFrZWxhZ19saW1pdG1heF9TdGFuZGluZyI6MSwgInJhZ2Vib3RfTm8tU2NvcGVfZG1nX1Bpc3RvbHMiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdF9TdGFuZGluZyI6NjAsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV84IjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9Dcm91Y2hpbmdfMjAiOjEsICJhbnRpYWltX3lhd3N0ZXBfR2xvYmFsIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9BaXJfMTciOjEsICJmYWtlbGFnX3ZhcmlhYmlsaXR5X0FpciI6MCwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzkiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfQWlyXzE3IjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0Nyb3VjaGluZ18yMCI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfT24tUGVla18xNCI6MSwgImZha2VsYWdfc3RlcF9BaXIiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfQ3JvdWNoaW5nXzEwIjoxLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1pbl9TdGFuZGluZyI6MSwgImZha2VsYWdfY3VzdG9tdGlja19Pbi1QZWVrXzE1IjoxLCAicmFnZWJvdF90aWNrYmFzZSI6dHJ1ZSwgImZha2VsYWdfY3VzdG9tbGltaXRfQ3JvdWNoaW5nXzEwIjoxLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTEiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X09uLVBlZWtfMTUiOjEsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWF4X1N0YW5kaW5nIjo2MCwgImZha2VsYWdfY3VzdG9tdGlja19Dcm91Y2hpbmdfMTEiOjEsICJmYWtlbGFnX2xpbWl0bWF4X0FpciI6MSwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzEyIjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18xMCI6MCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWluX1N0YW5kaW5nIjoxLCAiZmFrZWxhZ19tYXhsaW1pdF9BaXIiOjE1LCAiZmFrZWxhZ19jdXN0b21saW1pdF9Pbi1QZWVrXzE2IjoxLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTMiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfQ3JvdWNoaW5nXzEyIjoxLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfU3RhbmRpbmciOjYwLCAiZmFrZWxhZ19jdXN0b21fdmFsdWVfQWlyIjoyLCAiYW50aWFpbV94d2F5X0dsb2JhbF84IjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9Dcm91Y2hpbmdfMTIiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Nyb3VjaGluZ18xOSI6MSwgImFudGlhaW1fYm9keXlhd19vcHRpb25fU3RhbmRpbmciOlsiQXZvaWQgT3ZlcmxhcCJdLCAiZmFrZWxhZ19jdXN0b210aWNrX1J1bm5pbmdfMTIiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfQ3JvdWNoaW5nXzEzIjoxLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTUiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfT24tUGVla18xOCI6MSwgImFudGlhaW1fbGJ5X29wdGlvbl9TdGFuZGluZyI6IlN3YXkiLCAiZmFrZWxhZ19jdXN0b21saW1pdF9Dcm91Y2hpbmdfMTMiOjEsICJmYWtlbGFnX2xpbWl0X0dsb2JhbCI6MTQsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV8xNiI6MCwgImFudGlhaW1feHdheV9SdW5uaW5nXzkiOi01MCwgImFudGlhaW1feHdheV92YWx1ZV9TdGFuZGluZyI6MiwgImZha2VsYWdfY3VzdG9tdGlja19Dcm91Y2hpbmdfMTkiOjEsICJhbnRpYWltX3h3YXlfQWlyXzEwIjowLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTciOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Nyb3VjaGluZ18xNCI6MSwgImFudGlhaW1feHdheV9TdGFuZGluZ18xIjowLCAicmFnZWJvdF9kZWZlbnNpdmUiOmZhbHNlLCAiYW50aWFpbV9ib2R5eWF3X29wdGlvbl9Dcm91Y2hpbmciOnt9LCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTgiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Nyb3VjaGluZ18xOCI6MSwgImFudGlhaW1feHdheV9TdGFuZGluZ18yIjowLCAiYW50aWFpbV9wbGF5ZXJjb25kaXRpb24iOiJFeHBsb2l0LURlZmVuc2l2ZSIsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Nyb3VjaGluZ18xNSI6MSwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE5IjowLCAiYW50aWFpbV9sYnlfb3B0aW9uX0Nyb3VjaGluZyI6IkRpc2FibGVkIiwgImFudGlhaW1feHdheV9TdGFuZGluZ18zIjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0Nyb3VjaGluZ18xNiI6MSwgImFudGlhaW1feHdheV9TdGFuZGluZ18xMiI6MCwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzIwIjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0Nyb3VjaGluZ18xOCI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfQ3JvdWNoaW5nXzE2IjoxLCAiZmFrZWxhZ19tYXhsaW1pdF9TdGFuZGluZyI6MTUsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWluX0Zha2UtRHVjayI6MSwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa18xOCI6MCwgImZha2VsYWdfY3VzdG9tdGlja19Dcm91Y2hpbmdfMTciOjEsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfNSI6MCwgInJhZ2Vib3RfTm8tU2NvcGVfaGNfU2NvdXQiOjAsICJhbnRpYWltX3h3YXlfT24tUGVla18yIjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9Dcm91Y2hpbmdfMTciOjEsICJmYWtlbGFnX3N3aXRjaCI6ZmFsc2UsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfNiI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyLUR1Y2tfMTciOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfQWlyXzYiOjEsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdF9GYWtlLUR1Y2siOjEsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0X0Nyb3VjaGluZyI6MSwgImFudGlhaW1feHdheV9TdGFuZGluZ183IjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9BaXJfNiI6MSwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMTMiOjAsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWluX0Nyb3VjaGluZyI6MSwgImZha2VsYWdfbW9kZV9HbG9iYWwiOiJDdXN0b20tQnVpbGRlciIsICJmYWtlbGFnX2N1c3RvbXRpY2tfUnVubmluZ18xMSI6MSwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfOCI6MCwgImFudGlhaW1fcmFuZG9tcGl0Y2hzX0Nyb3VjaGluZyI6e30sICJyYWdlYm90X0RlZnVhbHRfZG1nX0FXUCI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyXzciOjEsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfOSI6MCwgImFudGlhaW1fcGl0Y2gyX0Fpci1EdWNrIjoiVXAiLCAiYW50aWFpbV9ib2R5eWF3X3N0ZXBfQ3JvdWNoaW5nIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpcl84IjoxLCAiZmFrZWxhZ192YXJpYWJpbGl0eV9HbG9iYWwiOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfMTAiOjAsICJhbnRpYWltX3NwaW5vZmZzZXRfRmFrZS1EdWNrIjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9BaXJfOCI6MSwgImZha2VsYWdfbGltaXRfU3RhbmRpbmciOjEsICJmYWtlbGFnX3N0ZXBfR2xvYmFsIjoxLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzExIjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpcl85IjoxLCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzEzIjowLCAiZmFrZWxhZ19tb2RlX1Nsb3ctV2FsayI6IlN0YXRpYyIsICJmYWtlbGFnX3N0ZXBfQ3JvdWNoaW5nIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9BaXJfOSI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyLUR1Y2tfNCI6MSwgImFudGlhaW1fcGl0Y2htb2RlX0V4cGxvaXQtRGVmZW5zaXZlIjoiUmFuZG9tIiwgImZha2VsYWdfbGltaXRfU2xvdy1XYWxrIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpcl8xMCI6MSwgImFudGlhaW1feHdheV9TdGFuZGluZ18xMyI6MCwgImZha2VsYWdfcGxheWVyY29uZGl0aW9uIjoiR2xvYmFsIiwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyXzEzIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9SdW5uaW5nXzE0IjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX09uLVBlZWtfMTAiOjEsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfMTQiOjAsICJmYWtlbGFnX2xpbWl0bWluX0dsb2JhbCI6MSwgImZha2VsYWdfY3VzdG9tdGlja19BaXJfMTEiOjEsICJmYWtlbGFnX3N0ZXBfU2xvdy1XYWxrIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX09uLVBlZWtfNiI6MSwgImFudGlhaW1feHdheV9TdGFuZGluZ18xNSI6MCwgImZha2VsYWdfbGltaXRtYXhfR2xvYmFsIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0dsb2JhbF83IjoxLCAiZmFrZWxhZ19saW1pdG1pbl9TbG93LVdhbGsiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfQWlyXzMiOjEsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfMTYiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfQWlyLUR1Y2tfOSI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfT24tUGVla18zIjoxLCAiZmFrZWxhZ19saW1pdG1heF9TbG93LVdhbGsiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Fpcl8xMiI6MSwgImFudGlhaW1feHdheV9TdGFuZGluZ18xNyI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfQWlyLUR1Y2tfMTYiOjEsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfMTMiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfUnVubmluZ18xNyI6MSwgImZha2VsYWdfY3VzdG9tdGlja19GYWtlLUR1Y2tfNyI6MSwgImFudGlhaW1feHdheV9TdGFuZGluZ18xOCI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfRmFrZS1EdWNrXzciOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X1J1bm5pbmdfMTciOjEsICJmYWtlbGFnX2N1c3RvbV92YWx1ZV9TbG93LVdhbGsiOjIsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0dsb2JhbF8xIjoxLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzE5IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX1J1bm5pbmdfMTgiOjEsICJmYWtlbGFnX3N0ZXBfT24tUGVlayI6MSwgImZha2VsYWdfY3VzdG9tdGlja19HbG9iYWxfMiI6MSwgImFudGlhaW1fcGl0Y2gxX0Fpci1EdWNrIjoiVXAiLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzIwIjowLCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfMTQiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0dsb2JhbF8yIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9TbG93LVdhbGtfMSI6MSwgImFudGlhaW1fYmZfdmFsdWVfU3RhbmRpbmciOjUsICJhbnRpYWltX3h3YXlfT24tUGVla183IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0dsb2JhbF8zIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9BaXJfMTEiOjEsICJhbnRpYWltX3lhd21vZGlmaWVyX29mZnNldF9BaXIiOjYsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Fpcl8xMCI6MSwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzEiOjQ4LCAiZmFrZWxhZ19jdXN0b21saW1pdF9TbG93LVdhbGtfMiI6MSwgImZha2VsYWdfY3VzdG9tdGlja19SdW5uaW5nXzIwIjoxLCAiYW50aWFpbV9ib2R5eWF3X0FpciI6ZmFsc2UsICJmYWtlbGFnX2N1c3RvbXRpY2tfR2xvYmFsXzQiOjEsICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ18yIjozMiwgImZha2VsYWdfY3VzdG9tbGltaXRfUnVubmluZ18yMCI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfRmFrZS1EdWNrXzEwIjoxLCAiYW50aWFpbV9ib2R5eWF3X21vZGVfQWlyIjoiU3RhdGljIiwgImZha2VsYWdfb3ZlcnJpZGVfQ3JvdWNoaW5nIjpmYWxzZSwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzMiOjQ0LCAiZmFrZWxhZ19jdXN0b210aWNrX0Zha2UtRHVja185IjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0dsb2JhbF81IjoxLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdF9BaXIiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Fpcl81IjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0Zha2UtRHVja18zIjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9HbG9iYWxfNSI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfU2xvdy1XYWxrXzQiOjEsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdF9BaXIiOjEsICJyYWdlYm90X0RlZnVhbHRfZG1nX0dsb2JhbCI6MCwgImZha2VsYWdfY3VzdG9tdGlja19HbG9iYWxfNiI6MSwgImZha2VsYWdfY3VzdG9tdGlja19BaXJfNCI6MSwgInJhZ2Vib3Rfd2VhcG9uX2xpc3QiOiJTY291dCIsICJhbnRpYWltX2JvZHl5YXdfc3RlcF9BaXIiOjQsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0dsb2JhbF82IjoxLCAicmFnZWJvdF9EZWZ1YWx0X2hjX0dsb2JhbCI6MCwgImZha2VsYWdfY3VzdG9tdGlja19BaXItRHVja184IjoxLCAiZmFrZWxhZ19jdXN0b21saW1pdF9BaXJfMiI6MSwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtaW5fQWlyIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX09uLVBlZWtfNSI6MSwgImZha2VsYWdfY3VzdG9tbGltaXRfT24tUGVla18xOCI6MSwgInJhZ2Vib3RfT3ZlcnJpZGVfZG1nX0dsb2JhbCI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfR2xvYmFsXzciOjEsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWF4X0FpciI6MjMsICJmYWtlbGFnX2N1c3RvbWxpbWl0X09uLVBlZWtfMTciOjEsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMTkiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfR2xvYmFsXzgiOjEsICJyYWdlYm90X092ZXJyaWRlX2hjX0dsb2JhbCI6MCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWluX0FpciI6MSwgImZha2VsYWdfbGltaXRtaW5fQWlyIjoxLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtaW5fQWlyLUR1Y2siOjEsICJhbnRpYWltX2JvZHl5YXdfc3RlcF9TdGFuZGluZyI6NjQsICJmYWtlbGFnX21heGxpbWl0X0Nyb3VjaGluZyI6MTUsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1heF9BaXIiOjIzLCAiZmFrZWxhZ19jdXN0b210aWNrX0dsb2JhbF85IjoxLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfQWlyLUR1Y2siOjEsICJmYWtlbGFnX292ZXJyaWRlX0FpciI6ZmFsc2UsICJmYWtlbGFnX2N1c3RvbV92YWx1ZV9Dcm91Y2hpbmciOjIsICJhbnRpYWltX2JvZHl5YXdfb3B0aW9uX0FpciI6WyJBdm9pZCBPdmVybGFwIl0sICJyYWdlYm90X0Fpcl9oY19HbG9iYWwiOjAsICJhbnRpYWltX2JvZHl5YXdfb3B0aW9uX0Fpci1EdWNrIjp7fSwgImZha2VsYWdfY3VzdG9tdGlja19Pbi1QZWVrXzExIjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0dsb2JhbF8xMCI6MSwgImFudGlhaW1fbGJ5X29wdGlvbl9BaXIiOiJTd2F5IiwgImFudGlhaW1feWF3bW9kaWZpZXJfU3RhbmRpbmciOiJSYW5kb20iLCAicmFnZWJvdF9Oby1TY29wZV9kbWdfR2xvYmFsIjowLCAiZmFrZWxhZ19jdXN0b21saW1pdF9HbG9iYWxfMTAiOjEsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Nyb3VjaGluZ18xIjoxLCAiYW50aWFpbV94d2F5X3ZhbHVlX0FpciI6MiwgImZha2VsYWdfY3VzdG9tbGltaXRfRmFrZS1EdWNrXzgiOjEsICJhbnRpYWltX3h3YXlfdmFsdWVfQWlyLUR1Y2siOjIsICJyYWdlYm90X05vLVNjb3BlX2hjX0dsb2JhbCI6MCwgImZha2VsYWdfb3ZlcnJpZGVfRmFrZS1EdWNrIjpmYWxzZSwgImFudGlhaW1feHdheV9BaXJfMSI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfR2xvYmFsXzExIjoxLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzEiOjAsICJmYWtlbGFnX2xpbWl0X0FpciI6MSwgInJhZ2Vib3Rfb3ZlcnJpZGVfc3dpdGNoX1Njb3V0Ijp0cnVlLCAiYW50aWFpbV94d2F5X0Fpcl8yIjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0Nyb3VjaGluZ18zIjoxLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzIiOjAsICJmYWtlbGFnX2N1c3RvbV92YWx1ZV9Pbi1QZWVrIjoyLCAicmFnZWJvdF9vdmVycmlkZV9saXN0X1Njb3V0IjpbIk92ZXJyaWRlIiwgIkFpciJdLCAiYW50aWFpbV94d2F5X0Fpcl8zIjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpci1EdWNrXzQiOjEsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMyI6MCwgImZha2VsYWdfY3VzdG9tdGlja19HbG9iYWxfMTMiOjEsICJmYWtlbGFnX2N1c3RvbXRpY2tfQ3JvdWNoaW5nXzQiOjEsICJhbnRpYWltX3h3YXlfQWlyXzQiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfRmFrZS1EdWNrXzE5IjoxLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzQiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Nyb3VjaGluZ180IjoxLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMTQiOjAsICJhbnRpYWltX3h3YXlfQWlyXzUiOjAsICJyYWdlYm90X0RlZnVhbHRfaGNfU2NvdXQiOjU4LCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzUiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1heF9Dcm91Y2hpbmciOjEsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1pbl9Dcm91Y2hpbmciOjEsICJhbnRpYWltX3h3YXlfQWlyXzYiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Nyb3VjaGluZ181IjoxLCAicmFnZWJvdF9PdmVycmlkZV9kbWdfU2NvdXQiOjE1LCAiYW50aWFpbV9vdmVycmlkZV9TbG93LVdhbGsiOnRydWUsICJmYWtlbGFnX2N1c3RvbXRpY2tfR2xvYmFsXzE1IjoxLCAiYW50aWFpbV94d2F5X0Fpcl83IjowLCAiYW50aWFpbV9iZl93YXlfT24tUGVla18xMiI6MCwgImFudGlhaW1feHdheV9BaXItRHVja183IjowLCAicmFnZWJvdF9PdmVycmlkZV9oY19TY291dCI6NTIsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Nyb3VjaGluZ182IjoxLCAiYW50aWFpbV94d2F5X0Fpcl84IjowLCAiYW50aWFpbV9zcGlub2Zmc2V0X0Nyb3VjaGluZyI6MCwgImFudGlhaW1feHdheV9BaXItRHVja184IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0Nyb3VjaGluZ183IjoxLCAicmFnZWJvdF9BaXJfZG1nX1Njb3V0Ijo4NCwgImFudGlhaW1feHdheV9BaXJfOSI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfR2xvYmFsXzE2IjoxLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzkiOjAsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzEzIjowLCAiYW50aWFpbV9waXRjaG1vZGVfQ3JvdWNoaW5nIjoiRGVmdWFsdCIsICJyYWdlYm90X0Fpcl9oY19TY291dCI6MzUsICJmYWtlbGFnX2N1c3RvbXRpY2tfQ3JvdWNoaW5nXzgiOjEsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMTAiOjAsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfNSI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfR2xvYmFsXzE3IjoxLCAiYW50aWFpbV94d2F5X0Fpcl8xMSI6MCwgInJhZ2Vib3RfTm8tU2NvcGVfZG1nX1Njb3V0IjowLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzExIjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0dsb2JhbF8xOCI6MSwgImZha2VsYWdfY3VzdG9tdGlja19Dcm91Y2hpbmdfOSI6MSwgImFudGlhaW1feHdheV9BaXJfMTIiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMTUiOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMTIiOjAsICJmYWtlbGFnX2N1c3RvbWxpbWl0X0Nyb3VjaGluZ185IjoxLCAiZmFrZWxhZ19jdXN0b210aWNrX0Fpcl83IjoxLCAiYW50aWFpbV94d2F5X0Fpcl8xMyI6MCwgImZha2VsYWdfY3VzdG9tdGlja19HbG9iYWxfMTkiOjEsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMTMiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfQWlyXzEyIjoxLCAicmFnZWJvdF9vdmVycmlkZV9zd2l0Y2hfQXV0byI6ZmFsc2UsICJhbnRpYWltX3h3YXlfQWlyXzE0IjowLCAiZmFrZWxhZ19jdXN0b210aWNrX0Zha2UtRHVja18xMyI6MSwgImFudGlhaW1feHdheV9BaXItRHVja18xNCI6MCwgImZha2VsYWdfY3VzdG9tbGltaXRfQ3JvdWNoaW5nXzExIjoxLCAicmFnZWJvdF9vdmVycmlkZV9saXN0X0F1dG8iOlsiT3ZlcnJpZGUiXSwgImFudGlhaW1feHdheV9BaXJfMTUiOjAsICJmYWtlbGFnX2N1c3RvbXRpY2tfQ3JvdWNoaW5nXzE1IjoxLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzE1IjowfQ==",
    username = common_get_username(),
    screen_size = render_screen_size(),

    fonts = {
        skeet_indicator = render_load_font("Calibri", vector(24, 24, 0), "ba")
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
--1白 7红 6绿         printraw("\aDD63E7[G8] \a868686» \aD5D5D5" .. string)
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
	    "Heavy Pistol",
	    "Pistols",
	    "Zeus"
	},

	weapon_types = {
	    ["SCAR-20"] = "Auto",
	    ["G3SG1"] = "Auto",
	    ["SSG 08"] = "Scout",
	    ["AWP"] = "AWP",
	    ["USP-S"] = "Pistols",
	    ["Five-SeveN"] = "Pistols",
	    ["Glock-18"] = "Pistols",
	    ["Tec-9"] = "Pistols",
	    ["R8 Revolver"] = "Revolver",
	    ["P250"] = "Pistols",
	    ["Dual Berettas"] = "Pistols",
	    ["Desert Eagle"] = "Deagle"
	},

	weapon_indexs = {
	    ["Global"] = 1,
	    ["Scout"] = 2,
	    ["Auto"] = 3,
	    ["AWP"] = 4,
	    ["Heavy"] = 5,
	    ["Pistol"] = 6,
	    ["Zeus"] = 7
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
    ok_teleported = false,
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

    if G8.refs.ragebot.misc.peek_assist:get() and G8.vars.velocity > 5 then
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
    elseif G8.vars.velocity > 5 and G8.vars.on_ground_ticks > 8 and not G8.refs.antiaim.misc.slow_walk:get() then
        G8.vars.player_state = "Running"
    elseif G8.vars.velocity <= 5 and G8.vars.on_ground_ticks > 8 then
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

    G8.vars.ok_teleported = true
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
    -- else
    --     rage_exploit:allow_defensive(false)
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

    if G8.refs.ragebot.double_tap.switch:get() and rage_exploit:get() ~= 1 and UI.get("antiaim_override_Exploit-Defensive") and not G8.vars.ok_teleported and not G8.refs.antiaim.misc.fake_duck:get() then
        state = "Exploit-Defensive"
    end

    if rage_exploit:get() == 1 and G8.vars.ok_teleported then
        G8.vars.ok_teleported = false
    end

    local me = entity_get_local_player()

    local offset = 0

    local manual = UI.get("antiaim_manual")
    if manual == "Forward" then
        offset = 180
    elseif manual == "Backward" then
        offset = UI.get("antiaim_backward_offset_" .. state)
    elseif manual == "Left" then
        offset = -93
    elseif manual == "Right" then
        offset = 92
    end

    if UI.get("antiaim_pitchmode_" .. state) == "Default" then
        _data.pitch = UI.get("antiaim_pitch_" .. state)
    elseif UI.get("antiaim_pitchmode_" .. state) == "Jitter" then
        if cmd.tickcount % UI.get("antiaim_pitchstep_" .. state) == 0 then
            _data.pitch = G8.refs.antiaim.pitch:get()
            if _data.pitch == "Fake Up" then _data.pitch = "Up" end
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
            if _data.yawoffset > 180 then
                _data.yawoffset = _data.yawoffset - 360
            elseif _data.yawoffset < -180 then
                _data.yawoffset = _data.yawoffset + 360
            end
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

    _data.bodyyaw_options = UI.get("antiaim_bodyyaw_option_" .. state)
    _data.bodyyaw_lby = UI.get("antiaim_lby_option_" .. state)


    if _data.pitch == "Up" then _data.pitch = "Fake Up" end

    if UI.contains("antiaim_disable_yaw", manual) then
        _data.yawoffset = offset
        _data.yawmodifier = "Disabled"
    end
    if UI.contains("antiaim_disable_desync", manual) then
        _data.bodyyaw = false
    end

    setvalues(_data)
end

G8.feat.attacked = function (info)
    local me = entity_get_local_player()
    if not me or not me:is_alive() then return end
    if info.userid == me:get_player_info().userid then return end
    if not entity_get(info.userid, true) then return end
    if me.m_iTeamNum == entity_get(info.userid, true).m_iTeamNum then return end
    local shoter_position = entity_get(info.userid, true):get_eye_position()

    if G8.funs.get_dist(shoter_position, vector(info.x, info.y, info.z), me:get_hitbox_position(2)) < 45 then
        G8.vars.be_attacked = true
        if UI.get("log_attacked_sound") then
            G8.funs.playsound("[G8]attacked.wav", 100)
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
                        G8.vars.send_tick = 2
                    end
                else
                    G8.vars.send_tick = 2
                end
            end

        elseif UI.get("fakelag_fix_style") == "Weapon Ammo" then
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
                        G8.vars.send_tick = 2
                    end
                else
                    G8.vars.send_tick = 2
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
        if flmode == "Always-Choke" then
            cmd.send_packet = false
        else
            if cmd.choked_commands < _data.limit then
                cmd.send_packet = false
            end
        end
    end

    if G8.vars.send_tick > 0 then
        cmd.send_packet = true
        cmd.no_choke = true
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
        G8.vars.send_tick = 2
    end
end

G8.feat.fl_fix_ack = function ()
    if not G8.refs.antiaim.misc.fake_duck:get() then return end

    if UI.get("fakelag_fix_switch")and UI.get("fakelag_fix_style") == "Aimbot" and UI.get("fakelag_fix_fakeduck") then
        G8.vars.send_tick = 2
    end
end

G8.feat.fl_fix_weaponfire = function (info)
    if info.userid ~= entity_get_local_player():get_player_info().userid then return end
    if UI.get("fakelag_fix_switch") and UI.get("fakelag_fix_style") == "Weapon Fire" then
        if G8.refs.antiaim.misc.fake_duck:get() then
            if UI.get("fakelag_fix_fakeduck") then
                G8.vars.send_tick = 2
            end
        else
            G8.vars.send_tick = 3
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
        G8.funs.indicator(color(255, 255, 255, 255), "DMG: " .. (G8.refs.ragebot.weapon.minimum_damage:get_override() or dmg), index, offset)
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
--{"Chat", "Console", "Screen"}
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
end

G8.regs.aim_fire = function ()
    G8.feat.fl_fix_fire()
end

G8.regs.aim_ack = function (info)
    G8.feat.fl_fix_ack()
    G8.feat.log_ack(info)
end

G8.regs.weapon_fire = function (info)
    G8.feat.fl_fix_weaponfire(info)
end

G8.regs.bullet_impact = function (info)
    G8.feat.attacked(info)
end

G8.regs.render = function ()
    G8.feat.view_model()
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
        G8.funs.playsound("[G8]LOAD.wav", 100)
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

