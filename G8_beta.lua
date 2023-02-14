-- EXTERN START

local ui_create, ui_find, utils_create_interface, files_write, files_read, printdev, printraw, printchat, entity_get_local_player, utils_console_exec, render_load_image_from_file, common_add_notify, common_get_username, render_texture, render_world_to_screen , is_button_down, render_screen_size, render_load_font, render_text, render_poly_blur, utils_execute_after, render_circle_outline, entity_get_game_rules, render_gradient, render_measure_text, rage_exploit, ui_get_icon, files_get_crc32, ui_get_alpha, common_reload_script, files_create_folder, math_sqrt, utils_random_int, entity_get_players, utils_net_channel, utils_get_vfunc, bit_band, bit_lshift, entity_get, entity_get_entities, render_camera_angles, common_get_unixtime, network_get, common_get_system_time = ui.create, ui.find, utils.create_interface, files.write, files.read, print_dev, print_raw, print_chat, entity.get_local_player, utils.console_exec, render.load_image_from_file, common.add_notify, common.get_username, render.texture, render.world_to_screen, common.is_button_down, render.screen_size, render.load_font, render.text, render.poly_blur, utils.execute_after, render.circle_outline, entity.get_game_rules, render.gradient, render.measure_text, rage.exploit, ui.get_icon, files.get_crc32, ui.get_alpha, common.reload_script, files.create_folder, math.sqrt, utils.random_int, entity.get_players, utils.net_channel, utils.get_vfunc, bit.band, bit.lshift, entity.get, entity.get_entities, render.camera_angles, common.get_unixtime, network.get, common.get_system_time

local ffi = require ("ffi")
local bit = require ("bit")
local urlmon = ffi.load "UrlMon"
local wininet = ffi.load "WinInet"
local clipboard = require("neverlose/clipboard")
local base64 = require("neverlose/base64")
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
        for idx, _ in pairs(UI.list) do
            if idx == index then
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

    typedef struct
    {
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

    typedef struct
    {
        char  pad_0000[20];
        int m_nOrder; //0x0014
        int m_nSequence; //0x0018
        float m_flPrevCycle; //0x001C
        float m_flWeight; //0x0020
        float m_flWeightDeltaRate; //0x0024
        float m_flPlaybackRate; //0x0028
        float m_flCycle; //0x002C
        void *m_pOwner; //0x0030
        char  pad_0038[4]; //0x0034
    } CAnimationLayer;
]]

local ffi_helpers = {}
ffi_helpers.entity_list_pointer = ffi.cast('void***', utils.create_interface('client.dll', 'VClientEntityList003'))
ffi_helpers.get_client_entity_fn = ffi.cast('GetClientEntity_4242425_t', ffi_helpers.entity_list_pointer[0][3])
ffi_helpers.get_entity_address = function(ent_index)
	local addr = ffi_helpers.get_client_entity_fn(ffi_helpers.entity_list_pointer, ent_index)
	return addr
end
ffi_helpers.buff = { free = {} }
ffi_helpers.hook_helper = {
	copy = function(dst, src, len)
		return ffi.copy(ffi.cast('void*', dst), ffi.cast('const void*', src), len)
	end,
	virtual_protect = function(lpAddress, dwSize, flNewProtect, lpflOldProtect)
		return ffi.C.VirtualProtect(ffi.cast('void*', lpAddress), dwSize, flNewProtect, lpflOldProtect)
	end,
	virtual_alloc = function(lpAddress, dwSize, flAllocationType, flProtect, blFree)
		local alloc = ffi.C.VirtualAlloc(lpAddress, dwSize, flAllocationType, flProtect)
		if blFree then
			table.insert(ffi_helpers.buff.free, function()
				ffi.C.VirtualFree(alloc, 0, 0x8000)
			end)
		end
		return ffi.cast('intptr_t', alloc)
	end
}
ffi_helpers.vmt_hook = {
	hooks = {},
	new = function(vt)
		local new_hook = {}
		local org_func = {}
		local old_prot = ffi.new('unsigned long[1]')
		local virtual_table = ffi.cast('intptr_t**', vt)[0]
		new_hook.this = virtual_table
		new_hook.hookMethod = function(cast, func, method)
			org_func[method] = virtual_table[method]
			ffi_helpers.hook_helper.virtual_protect(virtual_table + method, 4, 0x4, old_prot)

			virtual_table[method] = ffi.cast('intptr_t', ffi.cast(cast, func))
			ffi_helpers.hook_helper.virtual_protect(virtual_table + method, 4, old_prot[0], old_prot)

			return ffi.cast(cast, org_func[method])
		end
		new_hook.unHookMethod = function(method)
			ffi_helpers.hook_helper.virtual_protect(virtual_table + method, 4, 0x4, old_prot)
			local alloc_addr = ffi_helpers.hook_helper.virtual_alloc(nil, 5, 0x1000, 0x40, false)
			local trampoline_bytes = ffi.new('uint8_t[?]', 5, 0x90)

			trampoline_bytes[0] = 0xE9
			ffi.cast('int32_t*', trampoline_bytes + 1)[0] = org_func[method] - tonumber(alloc_addr) - 5

			ffi_helpers.hook_helper.copy(alloc_addr, trampoline_bytes, 5)
			virtual_table[method] = ffi.cast('intptr_t', alloc_addr)

			ffi_helpers.hook_helper.virtual_protect(virtual_table + method, 4, old_prot[0], old_prot)
			org_func[method] = nil
		end
		new_hook.unHookAll = function()
			for method, func in pairs(org_func) do
				new_hook.unHookMethod(method)
			end
		end

		table.insert(ffi_helpers.vmt_hook.hooks, new_hook.unHookAll)
		return new_hook
	end,
}

-- EXTERN END

G8 = {
    defs = {},
    vars = {},
    funs = {},
    refs = {},
    feat = {},
    regs = {},
    ui_handler = {},
}


-- UI HANDLER START
G8.ui_handler.list = {}

G8.ui_handler.TAB = ui_create("HIDE TAB", "UI POSITIONS")

G8.ui_handler.moving = nil
G8.ui_handler.mouse = nil

G8.ui_handler.new = function (index, position)
    assert(type(index) == "string", "Invalid type of index, index -> " .. (index or "nil"))
    assert(index ~= "nil", "Invalid index -> don't use 'nil'")
    assert(type(position) == "userdata" or type(position) == "nil", "Invalid type of position, index -> " .. (index or "nil"))
    assert(function ()
        for idx, _ in pairs(G8.ui_handler.list) do
            if idx == index then
                return false
            end
        end
        return true
    end, "Defined index, index -> " .. (index or "nil"))

    UI.new(G8.ui_handler.TAB:slider("visual_" .. index .. "_x", 1, G8.defs.screen_size.x), "visual_solusui_" .. index .. "_x", "i", {function ()
        return false
    end;}, nil, nil)
    UI.new(G8.ui_handler.TAB:slider("visual_" .. index .. "_y", 1, G8.defs.screen_size.y), "visual_solusui_" .. index .. "_y", "i", {function ()
        return false
    end;}, nil, nil)

    G8.ui_handler.list[index] = vector(1, 1)
end

G8.ui_handler.update = function (index, x, y)
    -- assert(type(index) == "string", "Invalid type of index, index -> " .. (index or "nil"))
    -- assert(function ()
    --     for idx, _ in pairs(G8.ui_handler.list) do
    --         if idx == index then
    --             return true
    --         end
    --     end
    --     return false
    -- end, "Unknow index, index -> " .. (index or "nil"))

    if not x or not y then return nil end

    G8.ui_handler.list[index] = vector(x, y)
end

G8.ui_handler.get = function (index)
    -- assert(type(index) == "string", "Invalid type of index, index -> " .. (index or "nil"))
    -- assert(function ()
    --     for idx, _ in pairs(G8.ui_handler.list) do
    --         if idx == index then
    --             return true
    --         end
    --     end
    --     return false
    -- end, "Unknow index, index -> " .. (index or "nil"))

    return vector(UI.get("visual_solusui_" .. index .. "_x"), UI.get("visual_solusui_" .. index .. "_y"))
end

G8.ui_handler.render_callback = function ()
    local left_down = common.is_button_down(0x01)
    if left_down and ui_get_alpha() > 0.3 then
        local mouse = ui.get_mouse_position()
        if G8.ui_handler.moving == nil then
            for index, volume in pairs(G8.ui_handler.list) do
                local left = UI.get("visual_solusui_" .. index .. "_x")
                local right = UI.get("visual_solusui_" .. index .. "_x") + volume.x
                local top = UI.get("visual_solusui_" .. index .. "_y")
                local bottom = UI.get("visual_solusui_" .. index .. "_y") + volume.y
                if mouse.x > left and mouse.x < right and mouse.y > top and mouse.y < bottom then
                    G8.ui_handler.mouse = mouse
                    G8.ui_handler.moving = index
                    return
                else
                    G8.ui_handler.moving = "nil"
                end
            end
        elseif G8.ui_handler.moving ~= nil and G8.ui_handler.moving ~= "nil" then
            local move_x = mouse.x - G8.ui_handler.mouse.x
            local move_y = mouse.y - G8.ui_handler.mouse.y
            UI.set("visual_solusui_" .. G8.ui_handler.moving .. "_x", UI.get("visual_solusui_" .. G8.ui_handler.moving .. "_x") + move_x)
            UI.set("visual_solusui_" .. G8.ui_handler.moving .. "_y", UI.get("visual_solusui_" .. G8.ui_handler.moving .. "_y") + move_y)
            G8.ui_handler.mouse = mouse
        end
    else
        G8.ui_handler.moving = nil
        G8.ui_handler.mouse = nil
    end
end

-- G8.ui_handler.mouse_callback = function ()
--     if G8.ui_handler.moving ~= nil then
--         return false
--     end
-- end
-- UI HANDLER END


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
        render_gradient(vector(20 + (render_measure_text(G8.defs.fonts.calibri24ba, nil, string).x / 2), G8.defs.screen_size.y - 548 + xtazst * 37 + yoffset), vector(15 , (G8.defs.screen_size.y - 548 + xtazst * 37) + 28 + yoffset), color(0, 0, 0, 60), color(0, 0, 0, 0), color(0, 0, 0, 60), color(0, 0, 0, 0), 0)
        render_gradient(vector(20 + (render_measure_text(G8.defs.fonts.calibri24ba, nil, string).x / 2), G8.defs.screen_size.y - 548 + xtazst * 37 + yoffset), vector(25 + (render_measure_text(G8.defs.fonts.calibri24ba, nil, string).x), (G8.defs.screen_size.y - 548 + xtazst * 37) + 28 + yoffset), color(0, 0, 0, 60), color(0, 0, 0, 0), color(0, 0, 0, 60), color(0, 0, 0, 0), 0)

        render_text(G8.defs.fonts.calibri24ba, vector(21, (G8.defs.screen_size.y - 543) + xtazst * 37 + yoffset), color(0, 0, 0, (scolor.a - 105) >=0 and (scolor.a - 105) or 0), "", string)
        render_text(G8.defs.fonts.calibri24ba, vector(20, (G8.defs.screen_size.y - 544) + xtazst * 37 + yoffset), scolor, "", string)
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

        UI.new(G8.defs.groups.antiaim.xwaybuilder:slider("[" .. string.sub(state, 1, 1) .. "] Way " .. ways, -180, 180, 0), "antiaim_xway_" .. state .. "_" .. ways, "i", {
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

    lerp = function(time,a,b)
        return a * (1 - time) + b * time
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
        if ffi.cast('uintptr_t', thisptr) == nil then
            return
        end

        G8.vars.hooked_function(thisptr, edx)

        local entity_localplayer_address = ffi_helpers.get_entity_address(entity.get_local_player():get_index())

        if ffi.cast('uintptr_t', thisptr) == entity_localplayer_address then
            local lp = entity_get_local_player()

            G8.refs.antiaim.misc.leg_movement:override()

            if UI.contains("animbreaker_list", "Pitch Onground") then
                if ffi.cast("CCSGOPlayerAnimationState_534535_t**", ffi.cast("uintptr_t", thisptr) + 0x9960)[0].bHitGroundAnimation then
                    if not G8.vars.is_jumping then
                        lp.m_flPoseParameter[12] = 0.5
                    end
                end
            end

            if UI.contains("animbreaker_list", "In Air") and UI.get("animbreaker_inair_style") == "Static" then
                lp.m_flPoseParameter[6] = 1
            end

            if UI.contains("animbreaker_list", "Leg Fucker") and G8.vars.velocity >= 130 and not G8.vars.is_jumping then
                if UI.get("animbreaker_legfucker_style") == "Reserved side" then
                    G8.refs.antiaim.misc.leg_movement:override("Sliding")
                    lp.m_flPoseParameter[0] = 0
                elseif UI.get("animbreaker_legfucker_style") == "Moon Walk" then
                    G8.refs.antiaim.misc.leg_movement:override("Walking")
                    lp.m_flPoseParameter[7] = 0
                elseif UI.get("animbreaker_legfucker_style") == "Static" then
                    G8.refs.antiaim.misc.leg_movement:override("Walking")
                    lp.m_flPoseParameter[10] = 0
                end
            end

            if UI.contains("animbreaker_list", "Slow Walk") and G8.vars.velocity < 130 then
                G8.refs.antiaim.misc.leg_movement:override("Walking")
                lp.m_flPoseParameter[9] = 0
            end

            if UI.contains("animbreaker_list", "Duck") then
                lp.m_flPoseParameter[8] = 0
            end

            if UI.contains("animbreaker_list", "In Air") and UI.get("animbreaker_inair_style") == "Moon Walk" and G8.vars.on_ground_ticks == 0 then
                ffi.cast('CAnimationLayer**', ffi.cast('uintptr_t', entity_localplayer_address) + 10640)[0][6].m_flWeight = 1
            end

            if UI.contains("animbreaker_list", "Move Lean") and G8.vars.player_state ~= "Crouching" then
                ffi.cast('CAnimationLayer**', ffi.cast('uintptr_t', entity_localplayer_address) + 10640)[0][12].m_flWeight = UI.get("animbreaker_movelean_force") / 100
            end
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

        UI.new(G8.defs.groups.antiaim.main:switch("Anti-Aim Builder", false), "antiaim_switch", "b", nil, nil, nil)
        UI.new(G8.defs.groups.antiaim.main:combo("Manual Anti-Aim", G8.defs.aa_manuals), "antiaim_manual", "s", {function () return UI.get("antiaim_switch") end;}, nil, nil)


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
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string.sub(state, 1, 1) .. "] Backward Offset", -20, 20, 0, 1, "°"), "antiaim_backward_offset_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string.sub(state, 1, 1) .. "] Pitch Mode", {"Default", "Jitter", "Random"}), "antiaim_pitchmode_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string.sub(state, 1, 1) .. "] Pitch", {"Disabled", "Down", "Fake Down", "Fake Up"}), "antiaim_pitch_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_pitchmode_" .. state) == "Default" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string.sub(state, 1, 1) .. "] Pitch Step", 1, 32, 1, 1, "T"), "antiaim_pitchstep_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_pitchmode_" .. state) ~= "Default" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string.sub(state, 1, 1) .. "] Pitch 1", {"Disabled", "Down", "Fake Down", "Fake Up"}), "antiaim_pitch1_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_pitchmode_" .. state) == "Jitter" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string.sub(state, 1, 1) .. "] Pitch 2", {"Disabled", "Down", "Fake Down", "Fake Up"}), "antiaim_pitch2_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_pitchmode_" .. state) == "Jitter" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:selectable("[" .. string.sub(state, 1, 1) .. "] Random Pitchs", {"Disabled", "Down", "Fake Down", "Fake Up"}), "antiaim_randompitchs_" .. state, "t", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_pitchmode_" .. state) == "Random" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string.sub(state, 1, 1) .. "] Yaw Base", {"Local View", "At Target"}), "antiaim_yawbase_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string.sub(state, 1, 1) .. "] Yaw Mode", G8.defs.yaw_modes), "antiaim_yawmode_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string.sub(state, 1, 1) .. "] Yaw Step", 1, 64, 1, 1, "T"), "antiaim_yawstep_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_yawmode_" .. state) == "Jitter" or UI.get("antiaim_yawmode_" .. state) == "Random" or UI.get("antiaim_yawmode_" .. state) == "X-Way" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string.sub(state, 1, 1) .. "] Yaw Left", 0, 180, 0, 1, "°"), "antiaim_yawleft_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_yawmode_" .. state) == "Jitter" or UI.get("antiaim_yawmode_" .. state) == "Random" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string.sub(state, 1, 1) .. "] Yaw Right", 0, 180, 0, 1, "°"), "antiaim_yawright_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_yawmode_" .. state) == "Jitter" or UI.get("antiaim_yawmode_" .. state) == "Random" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string.sub(state, 1, 1) .. "] Spin Offset", -180, 180, 0, 1, "°"), "antiaim_spinoffset_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_yawmode_" .. state) == "Spin" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string.sub(state, 1, 1) .. "] Yaw Modifier", {"Disabled", "Center", "Offset", "Random", "Spin"}), "antiaim_yawmodifier_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
            }, nil, nil)
            UI.new(UI.get_element("antiaim_yawmodifier_" .. state):create():slider("[" .. string.sub(state, 1, 1) .. "] Offset", -180, 180, 0, 1, "°"), "antiaim_yawmodifier_offset_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_yawmodifier_" .. state) ~= "Disabled" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:switch("[" .. string.sub(state, 1, 1) .. "] Body Yaw", false), "antiaim_bodyyaw_" .. state, "b", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string.sub(state, 1, 1) .. "] Body Yaw Mode", {"Static", "Jitter", "Random", "Fluctuate", "Anti-Bruteforce"}), "antiaim_bodyyaw_mode_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string.sub(state, 1, 1) .. "] Body Yaw Left", 1, 60, 1, 1, "°"), "antiaim_bodyyaw_leftlimit_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) == "Static" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string.sub(state, 1, 1) .. "] Body Yaw Right", 1, 60, 1, 1, "°"), "antiaim_bodyyaw_rightlimit_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) == "Static" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string.sub(state, 1, 1) .. "] Body Yaw Step", 1, 64, 1, 1, "T"), "antiaim_bodyyaw_step_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Static" and UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Anti-Bruteforce" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string.sub(state, 1, 1) .. "] Body Yaw Left Min", 1, 60, 1, 1, "°"), "antiaim_bodyyaw_leftlimitmin_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Static" and UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Anti-Bruteforce" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string.sub(state, 1, 1) .. "] Body Yaw Left Max", 1, 60, 1, 1, "°"), "antiaim_bodyyaw_leftlimitmax_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Static" and UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Anti-Bruteforce" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string.sub(state, 1, 1) .. "] Body Yaw Right Min", 1, 60, 1, 1, "°"), "antiaim_bodyyaw_rightlimitmin_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Static" and UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Anti-Bruteforce" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:slider("[" .. string.sub(state, 1, 1) .. "] Body Yaw Right Max", 1, 60, 1, 1, "°"), "antiaim_bodyyaw_rightlimitmax_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Static" and UI.get("antiaim_bodyyaw_mode_" .. state) ~= "Anti-Bruteforce" end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:selectable("[" .. string.sub(state, 1, 1) .. "] Body Yaw Options", {"Avoid Overlap", "Jitter", "Randomize Jitter", "Anti Bruteforce"}), "antiaim_bodyyaw_option_" .. state, "t", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.builder:combo("[" .. string.sub(state, 1, 1) .. "] LBY Option", {"Disabled", "Opposite", "Sway"}), "antiaim_lby_option_" .. state, "s", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_bodyyaw_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.antiaim.xwaybuilder:slider("[" .. string.sub(state, 1, 1) .. "] X-ways", 2, 20, 2), "antiaim_xway_value_" .. state, "i", {
                function () return UI.get("antiaim_switch") end;
                function () return UI.get("antiaim_playercondition") == state end;
                function () return UI.get("antiaim_override_" .. state) end;
                function () return UI.get("antiaim_yawmode_" .. state) == "X-Way" end;
            }, nil, nil)

            for i = 1, 20 do
                UI.new(G8.defs.groups.antiaim.xwaybuilder:slider("[" .. string.sub(state, 1, 1) .. "] Way " .. i, -180, 180, 0), "antiaim_xway_" .. state .. "_" .. i, "i", {
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
                UI.new(G8.defs.groups.antiaim.bfbuilder:slider("[" .. string.sub(state, 1, 1) .. "] Limit " .. i, 0, 60, 0), "antiaim_bf_way_" .. state .. "_" .. i, "i", {
                    function () return UI.get("antiaim_switch") end;
                    function () return UI.get("antiaim_playercondition") == state end;
                    function () return UI.get("antiaim_override_" .. UI.get("antiaim_playercondition")) end;
                    function () return UI.get("antiaim_bodyyaw_" .. UI.get("antiaim_playercondition")) end;
                    function () return UI.get("antiaim_bodyyaw_mode_" .. UI.get("antiaim_playercondition")) == "Anti-Bruteforce" end;
                    function () return UI.get("antiaim_bf_value_" .. state) >= i end;
                }, nil, nil)
            end

        end


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
            UI.new(G8.defs.groups.fakelag.builder:combo("[" .. string.sub(state, 1, 1) .. "] Fake-Lag Mode", G8.defs.fl_modes), "fakelag_mode_" .. state, "s", {
                function () return UI.get("fakelag_switch") end;
                function () return UI.get("fakelag_playercondition") == state end;
                function () return UI.get("fakelag_override_" .. state) end;
            }, nil, nil)
            UI.new(G8.defs.groups.fakelag.builder:slider("[" .. string.sub(state, 1, 1) .. "] Fake-Lag Limit", 1, 24, 1), "fakelag_limit_" .. state, "i", {
                function () return UI.get("fakelag_switch") end;
                function () return UI.get("fakelag_playercondition") == state end;
                function () return UI.get("fakelag_override_" .. state) end;
                function () return UI.get("fakelag_mode_" .. state) == "Static" end;
            }, nil, nil)
            UI.new(G8.defs.groups.fakelag.builder:slider("[" .. string.sub(state, 1, 1) .. "] Fake-Lag Variability", 0, 24, 0), "fakelag_variability_" .. state, "i", {
                function () return UI.get("fakelag_switch") end;
                function () return UI.get("fakelag_playercondition") == state end;
                function () return UI.get("fakelag_override_" .. state) end;
                function () return UI.get("fakelag_mode_" .. state) == "Static" end;
            }, nil, nil)
            UI.new(G8.defs.groups.fakelag.builder:slider("[" .. string.sub(state, 1, 1) .. "] Fake-Lag Step", 1, 64, 0, 1, "T"), "fakelag_step_" .. state, "i", {
                function () return UI.get("fakelag_switch") end;
                function () return UI.get("fakelag_playercondition") == state end;
                function () return UI.get("fakelag_override_" .. state) end;
                function () return UI.get("fakelag_mode_" .. state) ~= "Static" and  UI.get("fakelag_mode_" .. state) ~= "Custom-Builder" and UI.get("fakelag_mode_" .. state) ~= "Always-Choke" end;
            }, nil, nil)
            UI.new(G8.defs.groups.fakelag.builder:slider("[" .. string.sub(state, 1, 1) .. "] Fake-Lag Limit Min", 1, 24, 0), "fakelag_limitmin_" .. state, "i", {
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
            UI.new(G8.defs.groups.fakelag.builder:slider("[" .. string.sub(state, 1, 1) .. "] Fake-Lag Limit Max", 1, 24, 0), "fakelag_limitmax_" .. state, "i", {
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
            UI.new(G8.defs.groups.fakelag.builder:slider("[" .. string.sub(state, 1, 1) .. "] Fake-Lag Limit", 15, 24, 15), "fakelag_maxlimit_" .. state, "i", {
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
                UI.new(G8.defs.groups.fakelag.custom_builder:slider("[" .. string.sub(state, 1, 1) .. "] Tick " .. i , 1, 64, 0, 1, "T"), "fakelag_customtick_" .. state .. "_" .. i, "i", {
                    function () return UI.get("fakelag_switch") end;
                    function () return UI.get("fakelag_playercondition") == state end;
                    function () return UI.get("fakelag_override_" .. state) end;
                    function () return UI.get("fakelag_mode_" .. state) == "Custom-Builder" end;
                    function () return UI.get("fakelag_custom_value_" .. state) >= i end;
                }, nil, nil)
                UI.new(G8.defs.groups.fakelag.custom_builder:slider("[" .. string.sub(state, 1, 1) .. "] Limit " .. i, 1, 24, 1), "fakelag_customlimit_" .. state .. "_" .. i, "i", {
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

        UI.new(G8.defs.groups.visual.solus_ui:selectable("Solus UI", {"Watermark", "Keybinds", "Spectators"}), "visual_solusui", "t", nil, nil, nil)
        UI.new(G8.defs.groups.visual.solus_ui:combo("Language", {"zh_CN", "en_US"}), "visual_solusui_language", "s", { function () return UI.contains("visual_solusui", "Keybinds") end; }, nil, nil)
        UI.new(G8.defs.groups.visual.solus_ui:switch("Lock Mouse", false), "visual_lockmouse", "b", nil, nil, nil)
        G8.ui_handler.new("Keybinds", vector(100, 100))
        G8.ui_handler.new("Spectators", vector(100, 100))

        UI.new(G8.defs.groups.visual.crosshair_indicator:switch("Crosshair Indicators", false), "visual_crosshair", "b", nil, nil, nil)
        UI.new(G8.defs.groups.visual.crosshair_indicator:switch("Crosshair Damage", false), "visual_crosshair_dmg", "b", nil, nil, nil)

        UI.new(G8.defs.groups.visual.skeet_indicator:switch("Skeet Indicator", false), "visual_skeet", "b", nil, nil, nil)
        UI.new(UI.get_element("visual_skeet"):create():selectable("Indicators", {"G8", "Weapon State", "DMG", "HC", "FL", "DT", "HS", "FD", "DA", "LC"}), "visual_skeet_list", "t", { function () return UI.get("visual_skeet") end; }, nil, nil)
        UI.new(UI.get_element("visual_skeet"):create():slider("Y Offset", -500, 500, 0), "visual_skeet_offset", "i", { function () return UI.get("visual_skeet") end; }, nil, nil)

        -- UI.new(G8.defs.groups.visual.scope_overlay:switch("Scope Overlay", false), "visual_scope_overlay", "b", nil, nil, nil)
        -- local sover = UI.get_element("visual_scope_overlay"):create()

        UI.new(G8.defs.groups.visual.misc:switch("Line", false), "visual_line", "b", nil, nil, nil)

        UI.new(G8.defs.groups.misc.logs:switch("Hit/Mis log", false), "log_hitmiss", "b", nil, nil, nil)
        local tlog = UI.get_element("log_hitmiss"):create()
        UI.new(tlog:combo("Language", {"zh_CN", "en_US"}), "log_language", "s", { function () return UI.get("log_hitmiss") end; }, nil, nil)
        UI.new(tlog:selectable("Log Style", {"Chat", "Console", "Screen"}), " log_style", "t", { function () return UI.get("log_hitmiss") end; }, nil, nil)

        UI.new(G8.defs.groups.misc.unsafe_feature:selectable("Animbreaker", {"Pitch Onground", "In Air", "Leg Fucker", "Slow Walk", "Duck", "Move Lean"}), "animbreaker_list", "t", nil, nil, "Unsafe: Red Trust Factor")
        UI.new(G8.defs.groups.misc.unsafe_feature:combo("In Air Style", {"Static", "Moon Walk"}), "animbreaker_inair_style", "s", {function () return UI.contains("animbreaker_list", "In Air") end;}, nil, nil)
        UI.new(G8.defs.groups.misc.unsafe_feature:combo("Leg Fucker Style", {"Reserved side", "Moon Walk", "Static"}), "animbreaker_legfucker_style", "s", {function () return UI.contains("animbreaker_list", "Leg Fucker") end;}, nil, nil)
        UI.new(G8.defs.groups.misc.unsafe_feature:slider("Move Lean Force", 1, 100, 50, 1, "%"), "animbreaker_movelean_force", "i", {function () return UI.contains("animbreaker_list", "Move Lean") end;}, nil, nil)

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



-- FUNS END


-- DEFS START

G8.defs = {
    default_cfg = "eyJhbnRpYWltX3BpdGNobW9kZV9BaXIiOiJEZWZhdWx0IiwgImFudGlhaW1fcGl0Y2hzdGVwX1J1bm5pbmciOjIsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzkiOjAsICJhbnRpYWltX3BpdGNoX0FpciI6IkRvd24iLCAiYW50aWFpbV9waXRjaDFfUnVubmluZyI6IkRpc2FibGVkIiwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMTAiOjAsICJhbnRpYWltX3BpdGNoc3RlcF9BaXIiOjEsICJhbnRpYWltX3BpdGNoMl9SdW5uaW5nIjoiRmFrZSBEb3duIiwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMTEiOjAsICJhbnRpYWltX3BpdGNoMV9BaXIiOiJEaXNhYmxlZCIsICJhbnRpYWltX3JhbmRvbXBpdGNoc19SdW5uaW5nIjpbIkRpc2FibGVkIiwgIkZha2UgRG93biJdLCAiYW50aWFpbV94d2F5X0Zha2UtRHVja18xMiI6MCwgImFudGlhaW1fcGl0Y2gyX0FpciI6IkRpc2FibGVkIiwgImFudGlhaW1feWF3YmFzZV9SdW5uaW5nIjoiQXQgVGFyZ2V0IiwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMTMiOjAsICJhbnRpYWltX3JhbmRvbXBpdGNoc19BaXIiOnt9LCAiYW50aWFpbV95YXdtb2RlX1J1bm5pbmciOiJEaXNhYmxlZCIsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzE0IjowLCAiYW50aWFpbV95YXdiYXNlX0FpciI6IkF0IFRhcmdldCIsICJhbnRpYWltX3lhd3N0ZXBfUnVubmluZyI6MiwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMTUiOjAsICJhbnRpYWltX3lhd21vZGVfQWlyIjoiSml0dGVyIiwgImFudGlhaW1feWF3bGVmdF9SdW5uaW5nIjozMCwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMTYiOjAsICJhbnRpYWltX3lhd3N0ZXBfQWlyIjoxLCAiYW50aWFpbV95YXdyaWdodF9SdW5uaW5nIjozMCwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMTciOjAsICJhbnRpYWltX3lhd2xlZnRfQWlyIjozMiwgImFudGlhaW1fc3Bpbm9mZnNldF9SdW5uaW5nIjo1OCwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMTgiOjAsICJhbnRpYWltX3lhd3JpZ2h0X0FpciI6MzQsICJhbnRpYWltX3lhd21vZGlmaWVyX1J1bm5pbmciOiJDZW50ZXIiLCAiYW50aWFpbV94d2F5X0Zha2UtRHVja18xOSI6MCwgImFudGlhaW1fc3Bpbm9mZnNldF9BaXIiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX29mZnNldF9SdW5uaW5nIjo2MiwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfMjAiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX0FpciI6IkRpc2FibGVkIiwgImFudGlhaW1feHdheV9HbG9iYWxfMTciOjAsICJhbnRpYWltX2JmX3ZhbHVlX0Zha2UtRHVjayI6MiwgImFudGlhaW1feWF3bW9kaWZpZXJfb2Zmc2V0X0FpciI6MCwgImFudGlhaW1fYm9keXlhd19tb2RlX1J1bm5pbmciOiJTdGF0aWMiLCAiYW50aWFpbV94d2F5X0dsb2JhbF8xOCI6MCwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18xIjowLCAiYW50aWFpbV9ib2R5eWF3X0FpciI6ZmFsc2UsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0X1J1bm5pbmciOjYwLCAiYW50aWFpbV94d2F5X0dsb2JhbF8xOSI6MCwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18yIjowLCAiYW50aWFpbV9ib2R5eWF3X21vZGVfQWlyIjoiU3RhdGljIiwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0X1J1bm5pbmciOjYwLCAiYW50aWFpbV94d2F5X0dsb2JhbF8yMCI6MCwgImFudGlhaW1fYmFja3dhcmRfb2Zmc2V0X0V4cGxvaXQtRGVmZW5zaXZlIjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdF9BaXIiOjYwLCAiYW50aWFpbV9ib2R5eWF3X3N0ZXBfUnVubmluZyI6NSwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMSI6MCwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja180IjowLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRfQWlyIjo2MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtaW5fUnVubmluZyI6MSwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMiI6MCwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja181IjowLCAiYW50aWFpbV9ib2R5eWF3X3N0ZXBfQWlyIjo0LCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzIiOjAsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzMiOjAsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfNiI6MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtaW5fQWlyIjoxLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzMiOjAsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzQiOjAsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfNyI6MCwgImFudGlhaW1fcGl0Y2htb2RlX0Nyb3VjaGluZyI6IkRlZmF1bHQiLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzQiOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfMiI6MCwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja184IjowLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtaW5fQWlyIjoxLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzUiOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfMyI6MCwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja185IjowLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfQWlyIjoyMywgImFudGlhaW1fYmZfd2F5X0dsb2JhbF82IjowLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzQiOjAsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfMTAiOjAsICJhbnRpYWltX3BpdGNoMV9Dcm91Y2hpbmciOiJEaXNhYmxlZCIsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfNyI6MCwgImFudGlhaW1feHdheV9TdGFuZGluZ181IjowLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzciOjAsICJhbnRpYWltX2xieV9vcHRpb25fQWlyIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzgiOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfNiI6MCwgImFudGlhaW1feHdheV9BaXItRHVja184IjowLCAiYW50aWFpbV94d2F5X3ZhbHVlX0FpciI6NCwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF85IjowLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzciOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfOSI6MCwgImFudGlhaW1feHdheV9BaXJfMSI6LTQyLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzEwIjowLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzgiOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMTAiOjAsICJhbnRpYWltX3h3YXlfQWlyXzIiOjQyLCAiYW50aWFpbV9iZl93YXlfR2xvYmFsXzExIjowLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzkiOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMTEiOjAsICJhbnRpYWltX3h3YXlfQWlyXzMiOi0yNCwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF8xMiI6MCwgImFudGlhaW1feHdheV9TdGFuZGluZ18xMCI6MCwgImFudGlhaW1feHdheV9BaXItRHVja18xMiI6MCwgImFudGlhaW1feHdheV9BaXJfNCI6MjQsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMTMiOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfMTEiOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMTMiOjAsICJhbnRpYWltX3h3YXlfQWlyXzUiOjAsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMTQiOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfMTIiOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMTQiOjAsICJhbnRpYWltX3h3YXlfQWlyXzYiOjAsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMTUiOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfMTMiOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMTUiOjAsICJhbnRpYWltX3h3YXlfQWlyXzciOjAsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMTYiOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfMTQiOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMTYiOjAsICJhbnRpYWltX3lhd3JpZ2h0X0Zha2UtRHVjayI6MCwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF8xNyI6MCwgImFudGlhaW1feHdheV9TdGFuZGluZ18xNSI6MCwgImFudGlhaW1feHdheV9BaXItRHVja18xNyI6MCwgImFudGlhaW1fc3Bpbm9mZnNldF9GYWtlLUR1Y2siOjAsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMTgiOjAsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfMTYiOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMTgiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX0Zha2UtRHVjayI6IkRpc2FibGVkIiwgImFudGlhaW1fYmZfd2F5X0dsb2JhbF8xOSI6MCwgImFudGlhaW1feHdheV9TdGFuZGluZ18xNyI6MCwgImFudGlhaW1feHdheV9BaXItRHVja18xOSI6MCwgImFudGlhaW1feWF3bW9kaWZpZXJfb2Zmc2V0X0Zha2UtRHVjayI6MCwgImFudGlhaW1feHdheV9TdGFuZGluZ18xOCI6MCwgImFudGlhaW1feHdheV9BaXItRHVja18yMCI6MCwgImFudGlhaW1fYm9keXlhd19GYWtlLUR1Y2siOmZhbHNlLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzE5IjowLCAiYW50aWFpbV9iZl92YWx1ZV9BaXItRHVjayI6MiwgImFudGlhaW1fYm9keXlhd19tb2RlX0Zha2UtRHVjayI6IlN0YXRpYyIsICJhbnRpYWltX3h3YXlfU3RhbmRpbmdfMjAiOjAsICJhbnRpYWltX2JmX3dheV9BaXItRHVja18xIjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdF9GYWtlLUR1Y2siOjEsICJhbnRpYWltX2JmX3ZhbHVlX1N0YW5kaW5nIjo1LCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRfRmFrZS1EdWNrIjoxLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMSI6NDgsICJhbnRpYWltX2JvZHl5YXdfc3RlcF9GYWtlLUR1Y2siOjEsICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ18yIjozMiwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtaW5fRmFrZS1EdWNrIjoxLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMyI6NDQsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWF4X0Zha2UtRHVjayI6MSwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzQiOjYwLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtaW5fRmFrZS1EdWNrIjoxLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfNSI6NDQsICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ182IjowLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfNyI6MCwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzgiOjAsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzIwIjowLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfOSI6MCwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzEwIjowLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMTEiOjAsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0X01hbnVhbC1BQSI6NjAsICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ18xMiI6MCwgImFudGlhaW1fcGl0Y2htb2RlX01hbnVhbC1BQSI6IkRlZmF1bHQiLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMTMiOjAsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfMTIiOjAsICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ18xNCI6MCwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18xMyI6MCwgImFudGlhaW1feHdheV92YWx1ZV9Dcm91Y2hpbmciOjIsICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ18xNSI6MCwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18xNCI6MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMSI6MCwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzE2IjowLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzE1IjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18yIjowLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMTciOjAsICJhbnRpYWltX3JhbmRvbXBpdGNoc19NYW51YWwtQUEiOnt9LCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18zIjowLCAiYW50aWFpbV9iZl93YXlfU3RhbmRpbmdfMTgiOjAsICJhbnRpYWltX2JvZHl5YXdfb3B0aW9uX01hbnVhbC1BQSI6e30sICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzQiOjAsICJhbnRpYWltX2JmX3dheV9TdGFuZGluZ18xOSI6MCwgImFudGlhaW1fYmZfd2F5X0Zha2UtRHVja18xOCI6MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfNSI6MCwgImFudGlhaW1fYmZfd2F5X1N0YW5kaW5nXzIwIjowLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzE5IjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ182IjowLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzIwIjowLCAiYW50aWFpbV9iYWNrd2FyZF9vZmZzZXRfR2xvYmFsIjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ183IjowLCAiYW50aWFpbV95YXdyaWdodF9NYW51YWwtQUEiOjAsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzE4IjowLCAiYW50aWFpbV9waXRjaG1vZGVfR2xvYmFsIjoiRGVmYXVsdCIsICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzgiOjAsICJhbnRpYWltX2JhY2t3YXJkX29mZnNldF9Pbi1QZWVrIjowLCAiYW50aWFpbV9zcGlub2Zmc2V0X01hbnVhbC1BQSI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMTkiOjAsICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzkiOjAsICJhbnRpYWltX3BpdGNobW9kZV9Pbi1QZWVrIjoiRGVmYXVsdCIsICJhbnRpYWltX3lhd21vZGlmaWVyX01hbnVhbC1BQSI6IkRpc2FibGVkIiwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMjAiOjAsICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzEwIjowLCAiYW50aWFpbV9waXRjaF9Pbi1QZWVrIjoiRG93biIsICJhbnRpYWltX3lhd21vZGlmaWVyX29mZnNldF9NYW51YWwtQUEiOjAsICJhbnRpYWltX2JmX3ZhbHVlX1Nsb3ctV2FsayI6MiwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMTEiOjAsICJhbnRpYWltX3BpdGNoc3RlcF9Pbi1QZWVrIjoxLCAiYW50aWFpbV9ib2R5eWF3X01hbnVhbC1BQSI6ZmFsc2UsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMSI6MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMTIiOjAsICJhbnRpYWltX3BpdGNoMV9Pbi1QZWVrIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9ib2R5eWF3X21vZGVfTWFudWFsLUFBIjoiUmFuZG9tIiwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa18yIjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18xMyI6MCwgImFudGlhaW1fcGl0Y2gyX09uLVBlZWsiOiJEaXNhYmxlZCIsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMyI6MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMTQiOjAsICJhbnRpYWltX3JhbmRvbXBpdGNoc19Pbi1QZWVrIjp7fSwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa180IjowLCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18xNSI6MCwgImFudGlhaW1feWF3YmFzZV9Pbi1QZWVrIjoiTG9jYWwgVmlldyIsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfNSI6MCwgImFudGlhaW1feHdheV9SdW5uaW5nXzQiOjQsICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzE2IjowLCAiYW50aWFpbV95YXdtb2RlX09uLVBlZWsiOiJEaXNhYmxlZCIsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfNiI6MCwgImFudGlhaW1feHdheV9SdW5uaW5nXzUiOi0zNiwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMTciOjAsICJhbnRpYWltX3lhd3N0ZXBfT24tUGVlayI6MSwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa183IjowLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfNiI6NjUsICJhbnRpYWltX3h3YXlfQ3JvdWNoaW5nXzE4IjowLCAiYW50aWFpbV95YXdsZWZ0X09uLVBlZWsiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfOCI6MCwgImFudGlhaW1feHdheV9SdW5uaW5nXzciOi01MCwgImFudGlhaW1feHdheV9Dcm91Y2hpbmdfMTkiOjAsICJhbnRpYWltX3lhd3JpZ2h0X09uLVBlZWsiOjAsICJhbnRpYWltX2JmX3dheV9BaXJfOCI6MCwgImFudGlhaW1feHdheV9SdW5uaW5nXzgiOjM5LCAiYW50aWFpbV94d2F5X0Nyb3VjaGluZ18yMCI6MCwgImFudGlhaW1fc3Bpbm9mZnNldF9Pbi1QZWVrIjowLCAiYW50aWFpbV9iZl93YXlfQWlyXzkiOjAsICJhbnRpYWltX2JmX3ZhbHVlX0Nyb3VjaGluZyI6MiwgImFudGlhaW1feWF3bW9kaWZpZXJfT24tUGVlayI6IlNwaW4iLCAiYW50aWFpbV9iZl93YXlfQWlyXzEwIjowLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfMTAiOjY5LCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzEiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX29mZnNldF9Pbi1QZWVrIjoxNSwgImFudGlhaW1fYmZfd2F5X0Fpcl8xMSI6MCwgImFudGlhaW1feHdheV9SdW5uaW5nXzExIjotNTgsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMiI6MCwgImFudGlhaW1fYm9keXlhd19Pbi1QZWVrIjpmYWxzZSwgImFudGlhaW1fYmZfd2F5X0Fpcl8xMiI6MCwgImFudGlhaW1feHdheV9SdW5uaW5nXzEyIjo2NCwgImFudGlhaW1fYmZfd2F5X0Nyb3VjaGluZ18zIjowLCAiYW50aWFpbV9ib2R5eWF3X21vZGVfT24tUGVlayI6IlN0YXRpYyIsICJhbnRpYWltX2JmX3dheV9BaXJfMTMiOjAsICJhbnRpYWltX3h3YXlfUnVubmluZ18xMyI6LTU3LCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzQiOjAsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0X09uLVBlZWsiOjEsICJhbnRpYWltX2JmX3dheV9BaXJfMTQiOjAsICJhbnRpYWltX3h3YXlfUnVubmluZ18xNCI6NjUsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfNSI6MCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0X09uLVBlZWsiOjEsICJhbnRpYWltX2JmX3dheV9BaXJfMTUiOjAsICJhbnRpYWltX3h3YXlfUnVubmluZ18xNSI6LTU0LCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzYiOjAsICJhbnRpYWltX2JvZHl5YXdfc3RlcF9Pbi1QZWVrIjoxLCAiYW50aWFpbV9sYnlfb3B0aW9uX09uLVBlZWsiOiJEaXNhYmxlZCIsICJhbnRpYWltX2JmX3dheV9BaXJfMTYiOjAsICJhbnRpYWltX3h3YXlfUnVubmluZ18xNiI6NDMsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfNyI6MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtYXhfUnVubmluZyI6NjAsICJhbnRpYWltX3h3YXlfdmFsdWVfT24tUGVlayI6MiwgImFudGlhaW1fYmZfd2F5X0Fpcl8xNyI6MCwgImFudGlhaW1feHdheV9SdW5uaW5nXzE3IjotMzksICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfOCI6MCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWluX1J1bm5pbmciOjEsICJhbnRpYWltX3h3YXlfT24tUGVla18xIjowLCAiYW50aWFpbV9iZl93YXlfQWlyXzE4IjowLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfMTgiOjUwLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzkiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1heF9SdW5uaW5nIjo2MCwgImFudGlhaW1feHdheV9Pbi1QZWVrXzIiOjAsICJhbnRpYWltX2JmX3dheV9BaXJfMTkiOjAsICJhbnRpYWltX3h3YXlfUnVubmluZ18xOSI6LTU4LCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzEwIjowLCAiYW50aWFpbV9ib2R5eWF3X29wdGlvbl9SdW5uaW5nIjpbIkppdHRlciJdLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMyI6MCwgImFudGlhaW1fYmZfd2F5X0Fpcl8yMCI6MCwgImFudGlhaW1feHdheV9SdW5uaW5nXzIwIjoyNCwgImFudGlhaW1fbGJ5X29wdGlvbl9SdW5uaW5nIjoiRGlzYWJsZWQiLCAiYW50aWFpbV94d2F5X09uLVBlZWtfNCI6MCwgImFudGlhaW1fb3ZlcnJpZGVfQWlyLUR1Y2siOnRydWUsICJhbnRpYWltX2JmX3ZhbHVlX1J1bm5pbmciOjIsICJhbnRpYWltX3h3YXlfdmFsdWVfUnVubmluZyI6NCwgImFudGlhaW1fYmFja3dhcmRfb2Zmc2V0X0Fpci1EdWNrIjowLCAiYW50aWFpbV9iZl93YXlfUnVubmluZ18xIjowLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfMSI6LTgsICJhbnRpYWltX3BpdGNobW9kZV9BaXItRHVjayI6IkRlZmF1bHQiLCAiYW50aWFpbV9iZl93YXlfUnVubmluZ18yIjowLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfMiI6OCwgImFudGlhaW1fcGl0Y2hfQWlyLUR1Y2siOiJEb3duIiwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMyI6MCwgImFudGlhaW1feHdheV9SdW5uaW5nXzMiOi00LCAiYW50aWFpbV95YXdtb2RlX0Nyb3VjaGluZyI6IkRpc2FibGVkIiwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfNCI6MCwgImFudGlhaW1fcGl0Y2gxX0Fpci1EdWNrIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9iZl93YXlfUnVubmluZ181IjowLCAiYW50aWFpbV9waXRjaDJfQWlyLUR1Y2siOiJEaXNhYmxlZCIsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzYiOjAsICJhbnRpYWltX3JhbmRvbXBpdGNoc19BaXItRHVjayI6e30sICJhbnRpYWltX3BpdGNoMV9HbG9iYWwiOiJEaXNhYmxlZCIsICJhbnRpYWltX2JmX3dheV9BaXItRHVja18zIjowLCAiYW50aWFpbV95YXdiYXNlX0Fpci1EdWNrIjoiQXQgVGFyZ2V0IiwgImFudGlhaW1fcGl0Y2gyX0dsb2JhbCI6IkRpc2FibGVkIiwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzQiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX0Nyb3VjaGluZyI6IkRpc2FibGVkIiwgImFudGlhaW1fYm9keXlhd19vcHRpb25fRXhwbG9pdC1EZWZlbnNpdmUiOnt9LCAiYW50aWFpbV94d2F5X09uLVBlZWtfMTQiOjAsICJhbnRpYWltX3JhbmRvbXBpdGNoc19HbG9iYWwiOnt9LCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1heF9BaXIiOjIzLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfRXhwbG9pdC1EZWZlbnNpdmUiOjEsICJhbnRpYWltX3lhd3N0ZXBfQWlyLUR1Y2siOjIsICJhbnRpYWltX3lhd3JpZ2h0X0Nyb3VjaGluZyI6NywgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWluX0V4cGxvaXQtRGVmZW5zaXZlIjoxLCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfNiI6MCwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV82IjowLCAiYW50aWFpbV94d2F5X09uLVBlZWtfNiI6MCwgImFudGlhaW1fYm9keXlhd19Dcm91Y2hpbmciOmZhbHNlLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE3IjowLCAiYW50aWFpbV9iZl93YXlfTWFudWFsLUFBXzgiOjAsICJhbnRpYWltX3lhd21vZGVfR2xvYmFsIjoiRGlzYWJsZWQiLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzciOjAsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWF4X0V4cGxvaXQtRGVmZW5zaXZlIjoxLCAiYW50aWFpbV9ib2R5eWF3X21vZGVfQ3JvdWNoaW5nIjoiU3RhdGljIiwgImFudGlhaW1fYmZfd2F5X01hbnVhbC1BQV8xNiI6MCwgImFudGlhaW1fYmZfd2F5X01hbnVhbC1BQV8xOCI6MCwgImFudGlhaW1feWF3c3RlcF9HbG9iYWwiOjEsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfOCI6MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtaW5fRXhwbG9pdC1EZWZlbnNpdmUiOjEsICJhbnRpYWltX3NwaW5vZmZzZXRfQWlyLUR1Y2siOjAsICJhbnRpYWltX2JvZHl5YXdfb3B0aW9uX0FpciI6WyJBdm9pZCBPdmVybGFwIl0sICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzMiOjAsICJhbnRpYWltX3lhd2xlZnRfR2xvYmFsIjowLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzkiOjAsICJhbnRpYWltX3JhbmRvbXBpdGNoc19GYWtlLUR1Y2siOnt9LCAiYW50aWFpbV94d2F5X09uLVBlZWtfMTgiOjAsICJhbnRpYWltX2JmX3dheV9BaXItRHVja185IjowLCAiYW50aWFpbV9iZl93YXlfRmFrZS1EdWNrXzE2IjowLCAiYW50aWFpbV95YXdyaWdodF9HbG9iYWwiOjAsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzciOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdF9FeHBsb2l0LURlZmVuc2l2ZSI6NjAsICJhbnRpYWltX2JvZHl5YXdfc3RlcF9Dcm91Y2hpbmciOjEsICJhbnRpYWltX292ZXJyaWRlX1J1bm5pbmciOnRydWUsICJhbnRpYWltX3BpdGNoc3RlcF9NYW51YWwtQUEiOjEsICJhbnRpYWltX3NwaW5vZmZzZXRfR2xvYmFsIjowLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzExIjowLCAiYW50aWFpbV9waXRjaDFfTWFudWFsLUFBIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1pbl9Dcm91Y2hpbmciOjEsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0X0V4cGxvaXQtRGVmZW5zaXZlIjo2MCwgImFudGlhaW1fYm9keXlhd19vcHRpb25fT24tUGVlayI6e30sICJhbnRpYWltX3lhd21vZGlmaWVyX0dsb2JhbCI6IkRpc2FibGVkIiwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfOSI6MCwgImFudGlhaW1fYmZfdmFsdWVfT24tUGVlayI6MiwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtYXhfQ3JvdWNoaW5nIjoxLCAiYW50aWFpbV94d2F5X09uLVBlZWtfOCI6MCwgImFudGlhaW1fbWFudWFsIjoiQmFja3dhcmQiLCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfMTMiOjAsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzEwIjowLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMTMiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdF9TbG93LVdhbGsiOjEsICJhbnRpYWltX2JvZHl5YXdfaW52ZXJ0IjpmYWxzZSwgImFudGlhaW1fYm9keXlhd19tb2RlX0V4cGxvaXQtRGVmZW5zaXZlIjoiU3RhdGljIiwgImFudGlhaW1fYm9keXlhd19HbG9iYWwiOmZhbHNlLCAiYW50aWFpbV9iZl93YXlfUnVubmluZ18xMSI6MCwgImFudGlhaW1fcGl0Y2gyX01hbnVhbC1BQSI6IkRpc2FibGVkIiwgImFudGlhaW1fYm9keXlhd19zdGVwX1Nsb3ctV2FsayI6MSwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzIiOjAsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTgiOjAsICJhbnRpYWltX2JvZHl5YXdfbW9kZV9HbG9iYWwiOiJTdGF0aWMiLCAiYW50aWFpbV9vdmVycmlkZV9HbG9iYWwiOnRydWUsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTMiOjAsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWluX1Nsb3ctV2FsayI6MSwgImFudGlhaW1fb3ZlcnJpZGVfbWFudWFscyI6WyJMZWZ0IiwgIlJpZ2h0Il0sICJhbnRpYWltX2xieV9vcHRpb25fRmFrZS1EdWNrIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdF9HbG9iYWwiOjEsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzEzIjowLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzUiOjAsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWF4X1Nsb3ctV2FsayI6MSwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV80IjowLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzMiOjAsICJhbnRpYWltX2JmX3dheV9BaXItRHVja18xNyI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMTQiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX29mZnNldF9FeHBsb2l0LURlZmVuc2l2ZSI6LTEyMCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWluX1Nsb3ctV2FsayI6MSwgImFudGlhaW1feHdheV92YWx1ZV9FeHBsb2l0LURlZmVuc2l2ZSI6MiwgImFudGlhaW1fbGJ5X29wdGlvbl9FeHBsb2l0LURlZmVuc2l2ZSI6Ik9wcG9zaXRlIiwgImFudGlhaW1fYm9keXlhd19zdGVwX0dsb2JhbCI6MSwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMTUiOjAsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfMSI6MCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWF4X1Nsb3ctV2FsayI6MSwgImFudGlhaW1feWF3bW9kaWZpZXJfRXhwbG9pdC1EZWZlbnNpdmUiOiJDZW50ZXIiLCAiYW50aWFpbV9ib2R5eWF3X3N0ZXBfRXhwbG9pdC1EZWZlbnNpdmUiOjEsICJhbnRpYWltX2JmX3dheV9BaXItRHVja18xOSI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMTYiOjAsICJhbnRpYWltX3lhd2xlZnRfQ3JvdWNoaW5nIjo3LCAiYW50aWFpbV9ib2R5eWF3X29wdGlvbl9TbG93LVdhbGsiOnt9LCAiYW50aWFpbV9iYWNrd2FyZF9vZmZzZXRfTWFudWFsLUFBIjowLCAiYW50aWFpbV9ib2R5eWF3X0V4cGxvaXQtRGVmZW5zaXZlIjpmYWxzZSwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtYXhfR2xvYmFsIjoxLCAiYW50aWFpbV9iZl93YXlfUnVubmluZ18xNyI6MCwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMTciOjAsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMjAiOjAsICJhbnRpYWltX292ZXJyaWRlX0Nyb3VjaGluZyI6dHJ1ZSwgImFudGlhaW1feWF3bW9kaWZpZXJfb2Zmc2V0X0Nyb3VjaGluZyI6MCwgImFudGlhaW1fYmZfdmFsdWVfRXhwbG9pdC1EZWZlbnNpdmUiOjIsICJhbnRpYWltX292ZXJyaWRlX0Zha2UtRHVjayI6ZmFsc2UsICJhbnRpYWltX3lhd2Jhc2VfR2xvYmFsIjoiQXQgVGFyZ2V0IiwgImFudGlhaW1fb3ZlcnJpZGVfU3RhbmRpbmciOnRydWUsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzgiOjAsICJhbnRpYWltX3BsYXllcmNvbmRpdGlvbiI6IlJ1bm5pbmciLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfR2xvYmFsIjoxLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMSI6MCwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa18xMiI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMSI6LTEyLCAiYW50aWFpbV95YXdiYXNlX01hbnVhbC1BQSI6IkxvY2FsIFZpZXciLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdF9Dcm91Y2hpbmciOjEsICJhbnRpYWltX2JvZHl5YXdfb3B0aW9uX0dsb2JhbCI6e30sICJhbnRpYWltX3BpdGNobW9kZV9GYWtlLUR1Y2siOiJEZWZhdWx0IiwgImFudGlhaW1fYmZfd2F5X01hbnVhbC1BQV8yMCI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMiI6MTIsICJhbnRpYWltX3NwaW5vZmZzZXRfQ3JvdWNoaW5nIjowLCAiYW50aWFpbV9iZl93YXlfTWFudWFsLUFBXzE5IjowLCAiYW50aWFpbV9sYnlfb3B0aW9uX0dsb2JhbCI6IkRpc2FibGVkIiwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzMiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdF9Dcm91Y2hpbmciOjEsICJhbnRpYWltX3BpdGNoX1N0YW5kaW5nIjoiRG93biIsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfMTciOjAsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfMTUiOjAsICJhbnRpYWltX3h3YXlfdmFsdWVfR2xvYmFsIjozLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfNCI6MCwgImFudGlhaW1fYmZfd2F5X01hbnVhbC1BQV8xNCI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfNCI6NiwgImFudGlhaW1feHdheV9Pbi1QZWVrXzciOjAsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0X1Nsb3ctV2FsayI6MSwgImFudGlhaW1feHdheV9HbG9iYWxfMSI6MCwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzUiOjAsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfMTMiOjAsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzUiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX29mZnNldF9HbG9iYWwiOjAsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfMTIiOjAsICJhbnRpYWltX3h3YXlfR2xvYmFsXzIiOjAsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV82IjowLCAiYW50aWFpbV9iZl93YXlfTWFudWFsLUFBXzExIjowLCAiYW50aWFpbV9waXRjaDJfU3RhbmRpbmciOiJEaXNhYmxlZCIsICJhbnRpYWltX2JhY2t3YXJkX29mZnNldF9Dcm91Y2hpbmciOjAsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfMTAiOjAsICJhbnRpYWltX3h3YXlfR2xvYmFsXzMiOjAsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV83IjowLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa183IjotMTIsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfOSI6MCwgImFudGlhaW1fYmZfd2F5X01hbnVhbC1BQV83IjowLCAiYW50aWFpbV94d2F5X0dsb2JhbF80IjowLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfOCI6MCwgImFudGlhaW1fb3ZlcnJpZGVfRXhwbG9pdC1EZWZlbnNpdmUiOnRydWUsICJhbnRpYWltX3lhd2Jhc2VfU3RhbmRpbmciOiJBdCBUYXJnZXQiLCAiYW50aWFpbV9vdmVycmlkZV9NYW51YWwtQUEiOnRydWUsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfNiI6MCwgImFudGlhaW1feHdheV9HbG9iYWxfNSI6MCwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzkiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1heF9Dcm91Y2hpbmciOjEsICJhbnRpYWltX3lhd21vZGVfU3RhbmRpbmciOiJEaXNhYmxlZCIsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWluX0dsb2JhbCI6MSwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMTkiOjAsICJhbnRpYWltX3h3YXlfR2xvYmFsXzYiOjAsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV8xMCI6MCwgImFudGlhaW1fYm9keXlhd19vcHRpb25fQ3JvdWNoaW5nIjp7fSwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMTAiOjAsICJhbnRpYWltX2xieV9vcHRpb25fU2xvdy1XYWxrIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtaW5fR2xvYmFsIjoxLCAiYW50aWFpbV94d2F5X0dsb2JhbF83IjowLCAiYW50aWFpbV9iZl93YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTEiOjAsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzkiOi02LCAiYW50aWFpbV95YXdsZWZ0X1N0YW5kaW5nIjowLCAiYW50aWFpbV94d2F5X1J1bm5pbmdfOSI6LTUwLCAiYW50aWFpbV9iYWNrd2FyZF9vZmZzZXRfRmFrZS1EdWNrIjowLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa182IjoxMiwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzEyIjowLCAiYW50aWFpbV9waXRjaHN0ZXBfRmFrZS1EdWNrIjoxLCAiYW50aWFpbV95YXdyaWdodF9TdGFuZGluZyI6MCwgImFudGlhaW1fcGl0Y2hzdGVwX1N0YW5kaW5nIjoxLCAiYW50aWFpbV9waXRjaDFfRmFrZS1EdWNrIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9waXRjaDFfU3RhbmRpbmciOiJEaXNhYmxlZCIsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV8xMyI6MCwgImFudGlhaW1fcGl0Y2gyX0Zha2UtRHVjayI6IkRpc2FibGVkIiwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMTMiOjAsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzMiOi02LCAiYW50aWFpbV95YXdsZWZ0X01hbnVhbC1BQSI6MCwgImFudGlhaW1fcmFuZG9tcGl0Y2hzX1N0YW5kaW5nIjp7fSwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE0IjowLCAiYW50aWFpbV95YXdzdGVwX01hbnVhbC1BQSI6MSwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMTQiOjAsICJhbnRpYWltX3lhd21vZGVfTWFudWFsLUFBIjoiRGlzYWJsZWQiLCAiYW50aWFpbV95YXdsZWZ0X0Fpci1EdWNrIjozMSwgImFudGlhaW1fcGl0Y2hzdGVwX0dsb2JhbCI6MSwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE1IjowLCAiYW50aWFpbV9waXRjaF9NYW51YWwtQUEiOiJEb3duIiwgImFudGlhaW1feHdheV9BaXJfOCI6MCwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMTUiOjAsICJhbnRpYWltX3BpdGNoX0V4cGxvaXQtRGVmZW5zaXZlIjoiRGlzYWJsZWQiLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa18xMiI6MCwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE2IjowLCAiYW50aWFpbV9waXRjaF9HbG9iYWwiOiJEb3duIiwgImFudGlhaW1feHdheV9BaXJfOSI6MCwgImFudGlhaW1feHdheV9Pbi1QZWVrXzIwIjowLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMTkiOjAsICJhbnRpYWltX3BpdGNobW9kZV9FeHBsb2l0LURlZmVuc2l2ZSI6IlJhbmRvbSIsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV8xNyI6MCwgImFudGlhaW1feWF3bW9kaWZpZXJfU3RhbmRpbmciOiJDZW50ZXIiLCAiYW50aWFpbV94d2F5X0Fpcl8xMCI6MCwgImFudGlhaW1feHdheV9Pbi1QZWVrXzE2IjowLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMTUiOjAsICJhbnRpYWltX3h3YXlfT24tUGVla18xMiI6MCwgImFudGlhaW1fYmZfd2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE4IjowLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMTEiOjAsICJhbnRpYWltX3h3YXlfQWlyXzExIjowLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtYXhfT24tUGVlayI6MSwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWluX09uLVBlZWsiOjEsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0bWF4X09uLVBlZWsiOjEsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV8xOSI6MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtaW5fT24tUGVlayI6MSwgImFudGlhaW1feHdheV9BaXJfMTIiOjAsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfMTciOjAsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfMTEiOjAsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzUiOjAsICJhbnRpYWltX2JmX3dheV9FeHBsb2l0LURlZmVuc2l2ZV8yMCI6MCwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfNCI6MCwgImFudGlhaW1feHdheV9BaXJfMTMiOjAsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzIiOjAsICJhbnRpYWltX3h3YXlfRmFrZS1EdWNrXzEiOjAsICJhbnRpYWltX3h3YXlfdmFsdWVfRmFrZS1EdWNrIjoyLCAiYW50aWFpbV9waXRjaHN0ZXBfQ3JvdWNoaW5nIjoxLCAiYW50aWFpbV95YXdsZWZ0X0Zha2UtRHVjayI6MCwgImFudGlhaW1feHdheV9BaXJfMTQiOjAsICJhbnRpYWltX3lhd3N0ZXBfRmFrZS1EdWNrIjoxLCAiYW50aWFpbV95YXdtb2RlX0Zha2UtRHVjayI6IkRpc2FibGVkIiwgImFudGlhaW1feWF3YmFzZV9GYWtlLUR1Y2siOiJMb2NhbCBWaWV3IiwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzIwIjowLCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfMTgiOjAsICJhbnRpYWltX3h3YXlfQWlyXzE1IjowLCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfMTYiOjAsICJhbnRpYWltX2JmX3dheV9BaXItRHVja18xNSI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzE0IjowLCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfMTIiOjAsICJhbnRpYWltX2JmX3dheV9BaXItRHVja18xMSI6MCwgImFudGlhaW1feHdheV9BaXJfMTYiOjAsICJhbnRpYWltX2JmX3dheV9BaXItRHVja18xMCI6MCwgImFudGlhaW1fYmZfd2F5X0Fpci1EdWNrXzgiOjAsICJhbnRpYWltX2JmX3dheV9BaXItRHVja183IjowLCAiYW50aWFpbV9iZl93YXlfQWlyLUR1Y2tfNSI6MCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWF4X1N0YW5kaW5nIjo2MCwgImFudGlhaW1feHdheV9BaXJfMTciOjAsICJhbnRpYWltX2JmX3dheV9BaXItRHVja18yIjowLCAiYW50aWFpbV9iZl92YWx1ZV9BaXIiOjIsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfNiI6MCwgImFudGlhaW1feHdheV9BaXItRHVja181IjowLCAiYW50aWFpbV94d2F5X3ZhbHVlX1N0YW5kaW5nIjoyLCAiYW50aWFpbV94d2F5X0Fpcl8xOCI6MCwgImFudGlhaW1feHdheV9BaXItRHVja180IjowLCAiYW50aWFpbV9yYW5kb21waXRjaHNfQ3JvdWNoaW5nIjp7fSwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMTIiOjAsICJhbnRpYWltX2xieV9vcHRpb25fU3RhbmRpbmciOiJTd2F5IiwgImFudGlhaW1fYmZfd2F5X0Nyb3VjaGluZ18xMSI6MCwgImFudGlhaW1feHdheV9BaXJfMTkiOjAsICJhbnRpYWltX2JhY2t3YXJkX29mZnNldF9TdGFuZGluZyI6MCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0X0Fpci1EdWNrIjoxLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdF9BaXItRHVjayI6MSwgImFudGlhaW1fYm9keXlhd19vcHRpb25fU3RhbmRpbmciOlsiQXZvaWQgT3ZlcmxhcCJdLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzEyIjowLCAiYW50aWFpbV94d2F5X0Fpcl8yMCI6MCwgImFudGlhaW1fYmZfd2F5X0Fpcl80IjowLCAiYW50aWFpbV9ib2R5eWF3X21vZGVfQWlyLUR1Y2siOiJTdGF0aWMiLCAiYW50aWFpbV9ib2R5eWF3X0Fpci1EdWNrIjpmYWxzZSwgImFudGlhaW1fYmZfd2F5X0Fpcl81IjowLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzEzIjowLCAiYW50aWFpbV94d2F5X1N0YW5kaW5nXzEiOjAsICJhbnRpYWltX2JmX3dheV9BaXJfNiI6MCwgImFudGlhaW1feWF3bW9kZV9BaXItRHVjayI6IkppdHRlciIsICJhbnRpYWltX2JmX3dheV9BaXJfNyI6MCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWluX1N0YW5kaW5nIjoxLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzE0IjowLCAiYW50aWFpbV9iZl93YXlfQWlyXzEiOjAsICJhbnRpYWltX3lhd3N0ZXBfQ3JvdWNoaW5nIjoyLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa18xMSI6MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtaW5fU3RhbmRpbmciOjEsICJhbnRpYWltX3BpdGNoX0Zha2UtRHVjayI6IkRpc2FibGVkIiwgImFudGlhaW1fYmZfd2F5X0Nyb3VjaGluZ18xNSI6MCwgImFudGlhaW1fYmZfd2F5X0Fpcl8yIjowLCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzEzIjowLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtaW5fQ3JvdWNoaW5nIjoxLCAiYW50aWFpbV9ib2R5eWF3X3N0ZXBfU3RhbmRpbmciOjM5LCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzExIjowLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzE2IjowLCAiYW50aWFpbV9iZl93YXlfQWlyXzMiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdF9HbG9iYWwiOjEsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMTAiOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdF9TdGFuZGluZyI6NjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfOSI6MCwgImFudGlhaW1fYmZfd2F5X0Nyb3VjaGluZ18xNyI6MCwgImFudGlhaW1feHdheV9NYW51YWwtQUFfMSI6MCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfMTgiOjAsICJhbnRpYWltX2JvZHl5YXdfbGVmdGxpbWl0X1N0YW5kaW5nIjo2MCwgImFudGlhaW1fcGl0Y2hfQ3JvdWNoaW5nIjoiRG93biIsICJhbnRpYWltX3BpdGNoMl9Dcm91Y2hpbmciOiJEaXNhYmxlZCIsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTgiOjAsICJhbnRpYWltX3h3YXlfTWFudWFsLUFBXzIiOjAsICJhbnRpYWltX3lhd21vZGlmaWVyX29mZnNldF9TdGFuZGluZyI6MzYsICJhbnRpYWltX2JvZHl5YXdfbW9kZV9TdGFuZGluZyI6IlN0YXRpYyIsICJhbnRpYWltX2xieV9vcHRpb25fQ3JvdWNoaW5nIjoiRGlzYWJsZWQiLCAiYW50aWFpbV95YXdiYXNlX0Nyb3VjaGluZyI6IkF0IFRhcmdldCIsICJhbnRpYWltX2JmX3dheV9Dcm91Y2hpbmdfMTkiOjAsICJhbnRpYWltX3h3YXlfTWFudWFsLUFBXzMiOjAsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfMiI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMTYiOjAsICJhbnRpYWltX2JvZHl5YXdfc3RlcF9BaXItRHVjayI6MSwgImFudGlhaW1feWF3bW9kaWZpZXJfb2Zmc2V0X0Fpci1EdWNrIjowLCAiYW50aWFpbV9iZl93YXlfQ3JvdWNoaW5nXzIwIjowLCAiYW50aWFpbV94d2F5X01hbnVhbC1BQV80IjowLCAiYW50aWFpbV9ib2R5eWF3X3JpZ2h0bGltaXRtaW5fTWFudWFsLUFBIjozMCwgImFudGlhaW1fYmZfd2F5X1J1bm5pbmdfOCI6MCwgImFudGlhaW1fYm9keXlhd19sZWZ0bGltaXRtaW5fQWlyLUR1Y2siOjEsICJhbnRpYWltX3h3YXlfU2xvdy1XYWxrXzE1IjowLCAiYW50aWFpbV9vdmVycmlkZV9TbG93LVdhbGsiOnRydWUsICJhbnRpYWltX3h3YXlfTWFudWFsLUFBXzUiOjAsICJhbnRpYWltX2JmX3dheV9HbG9iYWxfMSI6MCwgImFudGlhaW1feHdheV92YWx1ZV9TbG93LVdhbGsiOjEwLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1heF9BaXItRHVjayI6MSwgImFudGlhaW1fYmFja3dhcmRfb2Zmc2V0X1Nsb3ctV2FsayI6MCwgImFudGlhaW1fcGl0Y2hzdGVwX0V4cGxvaXQtRGVmZW5zaXZlIjoyLCAiYW50aWFpbV94d2F5X01hbnVhbC1BQV82IjowLCAiYW50aWFpbV94d2F5X0dsb2JhbF84IjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1heF9TdGFuZGluZyI6NjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1pbl9BaXItRHVjayI6MSwgImFudGlhaW1fcGl0Y2htb2RlX1Nsb3ctV2FsayI6IkRlZmF1bHQiLCAiYW50aWFpbV9waXRjaDFfRXhwbG9pdC1EZWZlbnNpdmUiOiJGYWtlIFVwIiwgImFudGlhaW1feHdheV9NYW51YWwtQUFfNyI6MCwgImFudGlhaW1feHdheV9HbG9iYWxfMTIiOjAsICJhbnRpYWltX3NwaW5vZmZzZXRfU3RhbmRpbmciOjAsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1heF9BaXItRHVjayI6MSwgImFudGlhaW1fcGl0Y2hfU2xvdy1XYWxrIjoiRG93biIsICJhbnRpYWltX3BpdGNoMl9FeHBsb2l0LURlZmVuc2l2ZSI6IkRvd24iLCAiYW50aWFpbV94d2F5X01hbnVhbC1BQV84IjowLCAiYW50aWFpbV94d2F5X1Nsb3ctV2Fsa184Ijo2LCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzE3IjowLCAiYW50aWFpbV9ib2R5eWF3X29wdGlvbl9BaXItRHVjayI6e30sICJhbnRpYWltX3BpdGNoc3RlcF9TbG93LVdhbGsiOjEsICJhbnRpYWltX3JhbmRvbXBpdGNoc19FeHBsb2l0LURlZmVuc2l2ZSI6WyJEb3duIiwgIkZha2UgVXAiXSwgImFudGlhaW1feHdheV9NYW51YWwtQUFfOSI6MCwgImFudGlhaW1feHdheV9TbG93LVdhbGtfMTciOjAsICJhbnRpYWltX2JvZHl5YXdfU3RhbmRpbmciOmZhbHNlLCAiYW50aWFpbV9sYnlfb3B0aW9uX0Fpci1EdWNrIjoiRGlzYWJsZWQiLCAiYW50aWFpbV9waXRjaDFfU2xvdy1XYWxrIjoiRGlzYWJsZWQiLCAiYW50aWFpbV95YXdiYXNlX0V4cGxvaXQtRGVmZW5zaXZlIjoiQXQgVGFyZ2V0IiwgImFudGlhaW1feHdheV9NYW51YWwtQUFfMTAiOjAsICJhbnRpYWltX3lhd3N0ZXBfU3RhbmRpbmciOjEsICJhbnRpYWltX3lhd3JpZ2h0X0Fpci1EdWNrIjozMSwgImFudGlhaW1feHdheV92YWx1ZV9BaXItRHVjayI6MiwgImFudGlhaW1fcGl0Y2gyX1Nsb3ctV2FsayI6IkRpc2FibGVkIiwgImFudGlhaW1feWF3bW9kZV9FeHBsb2l0LURlZmVuc2l2ZSI6IkRpc2FibGVkIiwgImFudGlhaW1feHdheV9NYW51YWwtQUFfMTEiOjAsICJhbnRpYWltX2JmX3dheV9SdW5uaW5nXzIwIjowLCAiYW50aWFpbV9vdmVycmlkZV9Pbi1QZWVrIjpmYWxzZSwgImFudGlhaW1feHdheV9BaXItRHVja18xIjowLCAiYW50aWFpbV9yYW5kb21waXRjaHNfU2xvdy1XYWxrIjp7fSwgImFudGlhaW1feWF3c3RlcF9FeHBsb2l0LURlZmVuc2l2ZSI6MiwgImFudGlhaW1feHdheV9NYW51YWwtQUFfMTIiOjAsICJhbnRpYWltX292ZXJyaWRlX0FpciI6dHJ1ZSwgImFudGlhaW1feHdheV9HbG9iYWxfMTYiOjAsICJhbnRpYWltX3h3YXlfQWlyLUR1Y2tfMiI6MCwgImFudGlhaW1feWF3YmFzZV9TbG93LVdhbGsiOiJBdCBUYXJnZXQiLCAiYW50aWFpbV95YXdsZWZ0X0V4cGxvaXQtRGVmZW5zaXZlIjo5MCwgImFudGlhaW1feHdheV9NYW51YWwtQUFfMTMiOjAsICJhbnRpYWltX2JhY2t3YXJkX29mZnNldF9BaXIiOjAsICJhbnRpYWltX3BpdGNobW9kZV9TdGFuZGluZyI6IkRlZmF1bHQiLCAiYW50aWFpbV94d2F5X0Fpci1EdWNrXzMiOjAsICJhbnRpYWltX3lhd21vZGVfU2xvdy1XYWxrIjoiSml0dGVyIiwgImFudGlhaW1feWF3cmlnaHRfRXhwbG9pdC1EZWZlbnNpdmUiOjkwLCAiYW50aWFpbV94d2F5X01hbnVhbC1BQV8xNCI6MCwgImFudGlhaW1feHdheV9HbG9iYWxfMTQiOjAsICJhbnRpYWltX3h3YXlfR2xvYmFsXzExIjowLCAiYW50aWFpbV94d2F5X09uLVBlZWtfMTciOjAsICJhbnRpYWltX3lhd3N0ZXBfU2xvdy1XYWxrIjoxLCAiYW50aWFpbV9zcGlub2Zmc2V0X0V4cGxvaXQtRGVmZW5zaXZlIjozMiwgImFudGlhaW1feHdheV9NYW51YWwtQUFfMTUiOjAsICJhbnRpYWltX2JmX3dheV9GYWtlLUR1Y2tfMyI6MCwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMTEiOjAsICJhbnRpYWltX2xieV9vcHRpb25fTWFudWFsLUFBIjoiRGlzYWJsZWQiLCAiYW50aWFpbV95YXdsZWZ0X1Nsb3ctV2FsayI6MzYsICJhbnRpYWltX2JvZHl5YXdfcmlnaHRsaW1pdG1heF9GYWtlLUR1Y2siOjEsICJhbnRpYWltX3h3YXlfTWFudWFsLUFBXzE2IjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1pbl9NYW51YWwtQUEiOjMwLCAiYW50aWFpbV94d2F5X3ZhbHVlX01hbnVhbC1BQSI6MiwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0X01hbnVhbC1BQSI6NjAsICJhbnRpYWltX3lhd3JpZ2h0X1Nsb3ctV2FsayI6MzYsICJhbnRpYWltX2JvZHl5YXdfb3B0aW9uX0Zha2UtRHVjayI6e30sICJhbnRpYWltX3h3YXlfTWFudWFsLUFBXzE3IjowLCAiYW50aWFpbV9iZl93YXlfT24tUGVla18xMiI6MCwgImFudGlhaW1fYm9keXlhd19yaWdodGxpbWl0bWF4X01hbnVhbC1BQSI6NjAsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzE5IjowLCAiYW50aWFpbV9zcGlub2Zmc2V0X1Nsb3ctV2FsayI6MCwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa18xNCI6MCwgImFudGlhaW1feHdheV9NYW51YWwtQUFfMTgiOjAsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTkiOjAsICJhbnRpYWltX3h3YXlfT24tUGVla185IjowLCAiYW50aWFpbV9ib2R5eWF3X2xlZnRsaW1pdG1heF9NYW51YWwtQUEiOjYwLCAiYW50aWFpbV95YXdtb2RpZmllcl9TbG93LVdhbGsiOiJTcGluIiwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa18xNSI6MCwgImFudGlhaW1feHdheV9NYW51YWwtQUFfMTkiOjAsICJhbnRpYWltX3h3YXlfR2xvYmFsXzkiOjAsICJhbnRpYWltX2JvZHl5YXdfc3RlcF9NYW51YWwtQUEiOjEsICJhbnRpYWltX3h3YXlfR2xvYmFsXzEwIjowLCAiYW50aWFpbV95YXdtb2RpZmllcl9vZmZzZXRfU2xvdy1XYWxrIjoxMiwgImFudGlhaW1fYmZfd2F5X1Nsb3ctV2Fsa18xNiI6MCwgImFudGlhaW1feHdheV9NYW51YWwtQUFfMjAiOjAsICJhbnRpYWltX3h3YXlfR2xvYmFsXzEzIjowLCAiYW50aWFpbV9ib2R5eWF3X1Nsb3ctV2FsayI6ZmFsc2UsICJhbnRpYWltX3h3YXlfR2xvYmFsXzE1IjowLCAiYW50aWFpbV9iZl92YWx1ZV9HbG9iYWwiOjIsICJhbnRpYWltX2JmX3ZhbHVlX01hbnVhbC1BQSI6MiwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfNiI6MCwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfNyI6MCwgImFudGlhaW1fYm9keXlhd19tb2RlX1Nsb3ctV2FsayI6IlN0YXRpYyIsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzkiOjAsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzEwIjowLCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzE4IjowLCAiYW50aWFpbV9iZl93YXlfTWFudWFsLUFBXzEiOjAsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzEzIjowLCAiYW50aWFpbV9iZl93YXlfT24tUGVla18xNCI6MCwgImFudGlhaW1fYmZfd2F5X09uLVBlZWtfMTYiOjAsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzE4IjowLCAiYW50aWFpbV9iZl93YXlfU2xvdy1XYWxrXzE5IjowLCAiYW50aWFpbV9iZl93YXlfTWFudWFsLUFBXzIiOjAsICJhbnRpYWltX2JmX3dheV9Pbi1QZWVrXzUiOjAsICJhbnRpYWltX3N3aXRjaCI6dHJ1ZSwgImFudGlhaW1feWF3bW9kaWZpZXJfQWlyLUR1Y2siOiJEaXNhYmxlZCIsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfMjAiOjAsICJhbnRpYWltX2JmX3dheV9TbG93LVdhbGtfMjAiOjAsICJhbnRpYWltX2JmX3dheV9NYW51YWwtQUFfMyI6MCwgImFudGlhaW1fYm9keXlhd19SdW5uaW5nIjpmYWxzZSwgImFudGlhaW1feHdheV9Pbi1QZWVrXzUiOjAsICJhbnRpYWltX2JhY2t3YXJkX29mZnNldF9SdW5uaW5nIjowLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzE2IjowLCAiYW50aWFpbV94d2F5X0Zha2UtRHVja182IjowLCAiYW50aWFpbV9iZl93YXlfTWFudWFsLUFBXzQiOjAsICJhbnRpYWltX3h3YXlfRXhwbG9pdC1EZWZlbnNpdmVfMTUiOjAsICJhbnRpYWltX3h3YXlfT24tUGVla18xMCI6MCwgImFudGlhaW1fcGl0Y2htb2RlX1J1bm5pbmciOiJEZWZhdWx0IiwgImFudGlhaW1feHdheV9FeHBsb2l0LURlZmVuc2l2ZV8xNCI6MCwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfNyI6MCwgImFudGlhaW1fYmZfd2F5X01hbnVhbC1BQV81IjowLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzEyIjowLCAiYW50aWFpbV94d2F5X0V4cGxvaXQtRGVmZW5zaXZlXzEwIjowLCAiYW50aWFpbV9waXRjaF9SdW5uaW5nIjoiRG93biIsICJhbnRpYWltX3BpdGNoc3RlcF9BaXItRHVjayI6MSwgImFudGlhaW1feHdheV9GYWtlLUR1Y2tfOCI6MH0==",
    username = common_get_username(),
    useravatar = render.load_image(network_get("https://en.neverlose.cc/static/avatars/" .. common_get_username() .. ".png"), vector(18, 18)),
    screen_size = render_screen_size(),

    fonts = {
        calibri24ba = render_load_font("Calibri", 24, "ba") or error('Fonts Error: Calibri Not Found'),
        calibri14a = render_load_font("Calibri", 14, "a") or error('Fonts Error: Calibri Not Found'),
        verdana14au = render_load_font("Verdana", 14, "au") or error('Fonts Error: Verdana Not Found'),
        pixel14odu = render_load_font("nl\\Crow\\Fonts\\smallest_pixel-7.ttf", 14, "odu") or error('Fonts Error: Smallest Pixel-7 Not Found'),
        pixel14od = render_load_font("nl\\Crow\\Fonts\\smallest_pixel-7.ttf", 14, "od") or error('Fonts Error: Smallest Pixel-7 Not Found'),
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

    keybinds = {
        ["Double Tap"] = "双发",
        ["Hide Shots"] = "不抬头",
        ["Slow Walk"] = "慢走",
        ["Peek Assist"] = "自动拉回",
        ["Manual Anti-Aim"] = "手动AA",
        ["Force Thirdperson"] = "第三人称",
        ["Fake Duck"] = "假蹲",
        ["Override Key"] = "伤害覆盖",
        ["Body Aim"] = "打击身体",
        ["Safe Points"] = "打击安全点",
        ["Hitboxs"] = "打击部位",
        ["Multipoint"] = "多点",
        ["Hit Chance"] = "命中率",
        ["Minimum Damage"] = "最小伤害",



        ["on"] = "开启",
        ["off"] = "关闭",
        ["override"] = "覆盖",
        ["Right"] = "向右",
        ["Left"] = "向左",
        ["Forward"] = "向前",
        ["Backward"] = "向后",
        ["Default"] = "默认",
        ["Prefer"] = "优先",
        ["Force"] = "强制",
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
        misc = ui_create(G8.defs.tabs.visual, ui_get_icon("eye") .. G8.funs.gradient_text(42, 245, 152, 255, 0, 158, 253, 255, " Misc")),
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
    elseif G8.vars.defensive_tick > 0 then
        G8.vars.defensive_tick = 0
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
            cmd.send_packet = false
            G8.refs.antiaim.body_yaw.switch:override(false)
            cvar["sv_maxusrcmdprocessticks"]:int(1)
        end
        G8.vars.send_tick = G8.vars.send_tick - 1
    elseif G8.vars.send_tick > 0 and G8.vars.send_tick <= 2 then
        cmd.no_choke = false
        cmd.send_packet = false
        G8.vars.send_tick = G8.vars.send_tick - 1
        if not G8.refs.ragebot.double_tap.switch:get() and not G8.refs.ragebot.hide_shot.switch:get() then
            cvar["sv_maxusrcmdprocessticks"]:int(20)
        end
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

    if UI.contains("visual_solusui", "Keybinds") then
        local position = G8.ui_handler.get("Keybinds")
        local cheatbinds = ui.get_binds()
        local active_bind_list = {}
        local max_x = 165

        for i = #cheatbinds, 1, -1 do
            local binds = cheatbinds[i]
            local bind_name = binds.name
            local bind_value = binds.value

            if bind_value == true then
                bind_value = 'on'
            end

            if bind_value == false then
                bind_value = 'Off'
            end

            if type(bind_value) == "number" then
                bind_value = tostring(bind_value)
            end

            if type(bind_value) == "table" then
                bind_value = 'override'
            end

            if UI.get("visual_solusui_language") == "zh_CN" then
                bind_value = G8.defs.keybinds[bind_value] or bind_value
                bind_name = G8.defs.keybinds[bind_name] or bind_name
            end

            bind_value = "[" .. bind_value .. "]"


            local bind_name_size = render.measure_text(1, 'o', bind_name)
            local bind_value_size = render.measure_text(G8.defs.fonts.verdana14au, 'o', bind_value)

            local width_k = bind_value_size.x + bind_name_size.x + 25

            if width_k > 155 then
                if width_k > max_x then
                    max_x = width_k
                end
            end

            if binds.active then
                table.insert(active_bind_list, {name = bind_name, value = bind_value, value_size = bind_value_size})
            end
        end

        if ui_get_alpha() > 0.3 or #active_bind_list > 0 then
            render.rect(position, vector(position.x + max_x, position.y + 26), color(0,0,0,220), 5)
            render.text(G8.defs.fonts.verdana14au, vector(position.x + (max_x / 2), position.y + 13), color(255, 255, 255, 255), "c", "Keybinds")

            local add_y = 0
            local width = position.x + max_x

            for i = 1, #active_bind_list do
                render.rect(vector(position.x, position.y + 28 + (add_y * 22)), vector(width, position.y + 48 + (add_y * 22)), color(0,0,0,120), 4)
                render.text(G8.defs.fonts.verdana14au, vector(position.x + 2, position.y + 30 + (add_y * 22)), color(255, 255, 255, 255), nil, active_bind_list[i].name)
                render.text(G8.defs.fonts.verdana14au, vector(width - active_bind_list[i].value_size.x - 2, position.y + 30 + (add_y * 22)), color(255, 255, 255, 255), nil, active_bind_list[i].value)
                add_y = add_y + 1
            end
            G8.ui_handler.update("Keybinds", max_x, add_y * 22 + 26)
        end
    end

    if UI.contains("visual_solusui", "Spectators") then
        local position = G8.ui_handler.get("Spectators")
        local localplayer = entity_get_local_player()

        local spectators_list
        local spectators = {}
        local max_x = 165

        if globals.is_in_game then
            if not localplayer:is_alive() then
                local target = localplayer.m_hObserverTarget
                if target == nil then return end
                spectators_list = target:get_spectators()
                table.insert(spectators_list, localplayer)
            else
                spectators_list = localplayer:get_spectators()
            end

            for i = 1, #spectators_list do
                local v = spectators_list[i]
                local name = v:get_name()
                local name_size = render_measure_text(G8.defs.fonts.verdana14au, nil, name).x

                if name_size + 22 > max_x then
                    if name_size + 22 < 220 then
                        max_x = name_size + 22
                    else
                        local should_size = string.len(name) * (198 / name_size) - 4
                        name = string.sub(name, 1, should_size) .. "..."
                        max_x = 198
                    end
                end

                table.insert(spectators, {avatar = v:get_steam_avatar(), name = name})
            end
        end


        if ui_get_alpha() > 0.3 or #spectators > 0 then
            render.rect(position, vector(position.x + max_x, position.y + 26), color(0,0,0,220), 5)
            render.text(G8.defs.fonts.verdana14au, vector(position.x + (max_x / 2), position.y + 13), color(255, 255, 255, 255), "c", "Spectators")

            local add_y = 0
            local width = position.x + max_x

            for i = 1, #spectators do
                render.rect(vector(position.x, position.y + 28 + (add_y * 22)), vector(width, position.y + 48 + (add_y * 22)), color(0,0,0,120), 4)
                render.texture(spectators[i].avatar, vector(position.x + 1, position.y + 29 + (add_y * 22)), vector(17, 17), color(), 'f', 5)
                render.text(G8.defs.fonts.verdana14au, vector(position.x + 21, position.y + 30 + (add_y * 22)), color(255, 255, 255, 255), nil, spectators[i].name)
                add_y = add_y + 1
            end
            G8.ui_handler.update("Spectators", max_x, add_y * 22 + 26)
        end
    end
end

G8.feat.line = function ()
    if not UI.get("visual_line") then return end
    local me = entity_get_local_player()
    if not me or not me:is_alive() then return end

    local player
    local dist = 999999
    me = me:get_origin()
    entity_get_players(true, false, function(ent)
        if me:dist(ent:get_origin()) < dist and ent:is_alive() then
            dist = me:dist(ent:get_origin())
            player = ent:get_origin()
        end
    end)

    if dist ~= 999999 then
        render.line(render_world_to_screen(me), render_world_to_screen(player), color(255, 255, 255, 255))
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
        local local_player_address = ffi_helpers.get_entity_address(local_player_index)

        if not local_player_address or G8.vars.hooked_function then
            return
        end

        local new_point = ffi_helpers.vmt_hook.new(local_player_address)
        G8.vars.hooked_function = new_point.hookMethod("void(__fastcall*)(void*, void*)", G8.funs.inside_updateCSA, 224)
    end
end

G8.feat.move_lean = function (cmd)
    if UI.contains("animbreaker_list", "Move Lean") then
    	cmd.animate_move_lean = true
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
    G8.feat.choked_list(cmd)
    G8.feat.move_lean(cmd)
end

G8.regs.createmove_run = function (cmd)
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
    G8.feat.aa_defensive_weaponfire(info)
    G8.feat.fl_fix_weaponfire(info)
end

G8.regs.bullet_impact = function (info)
    G8.feat.attacked(info)
end

G8.regs.render = function ()
    G8.ui_handler.render_callback()
    G8.feat.view_model()
    G8.feat.solusui()
    G8.feat.crosshair()
    G8.feat.skeet_indicator()
    G8.feat.line()
    G8.feat.log_render()
end

G8.regs.mouse_input = function ()
    if not UI.get("visual_lockmouse") then
        return
    end

    if ui_get_alpha() > 0.3 then
        return false
    end
end

G8.regs.shutdown = function ()
	for _, unhookFunction in ipairs(ffi_helpers.vmt_hook.hooks) do
		unhookFunction()
	end

	for _, free in ipairs(ffi_helpers.buff.free) do
		free()
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

