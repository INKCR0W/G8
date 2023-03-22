_DEBUG = true

-- EXTERN BEGIN
local ui_create, ui_find, utils_create_interface, files_write, files_read, printdev, printraw, printchat, entity_get_local_player, utils_console_exec, render_load_image_from_file, common_add_notify, common_get_username, render_texture, render_world_to_screen , is_button_down, render_screen_size, render_load_font, render_text, render_poly_blur, utils_execute_after, render_circle_outline, entity_get_game_rules, render_gradient, render_measure_text, rage_exploit, ui_get_icon, files_get_crc32, ui_get_alpha, common_reload_script, files_create_folder, utils_random_int, entity_get_players, utils_net_channel, utils_get_vfunc, bit_band, bit_lshift, entity_get, entity_get_entities, render_camera_angles, common_get_unixtime, network_get, common_get_system_time, render_load_image = ui.create, ui.find, utils.create_interface, files.write, files.read, print_dev, print_raw, print_chat, entity.get_local_player, utils.console_exec, render.load_image_from_file, common.add_notify, common.get_username, render.texture, render.world_to_screen, common.is_button_down, render.screen_size, render.load_font, render.text, render.poly_blur, utils.execute_after, render.circle_outline, entity.get_game_rules, render.gradient, render.measure_text, rage.exploit, ui.get_icon, files.get_crc32, ui.get_alpha, common.reload_script, files.create_folder, utils.random_int, entity.get_players, utils.net_channel, utils.get_vfunc, bit.band, bit.lshift, entity.get, entity.get_entities, render.camera_angles, common.get_unixtime, network.get, common.get_system_time, render.load_image

local ffi = require ("ffi")
local bit = require ("bit")
local clipboard = require("neverlose/clipboard")
local base64 = require("neverlose/base64")
local get_lc = require("neverlose/get_lc")
local json = require("neverlose/better_json")

local urlmon = ffi.load "UrlMon"
local wininet = ffi.load "WinInet"

local ui_handler = { list = {} }

local UI = { list = {} }

UI.new = function (element, index, flag, conditions, callback, tooltip)
    assert(element, "Element is nil, index -> " .. (index or "nil"))
    assert(index, "Index is nil")
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

UI.__index = UI.list


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


-- TABLES BEGIN
local defs = {}
local refs = {}
local regs = {}
-- TABLES END



-- REFS BEGIN
refs = {
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


-- DEFS BEGIN
defs = {
    username = common_get_username(),
    useravater = network_get("https://en.neverlose.cc/static/avatars/" .. common_get_username()),
}
-- DEFS END


-- REGS DEFINITION BEGIN
regs.shutdown = function ()
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

    _reset(refs)
end
-- REGS DEFINITION END