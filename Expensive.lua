--[=[
    @EXPENSIVE Powered Crow
    @Discord InkCrow#2173
]=]

_DEBUG = true

-- EXTERN
local ui, common, utils, render, network, panorama, entity, globals, events, rage, json = ui, common, utils, render, network, panorama, entity, globals, events, rage, json
local printchat, printraw = print_chat, print_raw
local vector, color = vector, color
local _IS_MARKET = _IS_MARKET


local ffi = require ("ffi")
local bit = require ("bit")
-- local clipboard = require("neverlose/clipboard")
-- local base64 = require("neverlose/base64")

local urlmon = ffi.load "UrlMon"
local wininet = ffi.load "WinInet"

local ui_handler = { list = {} }


-- TABLES
local gdefs = {}
local funs = {}
local refs = {}
local gvars = {}
local ui_groups = {}
local antiaim = {}
local fakelag = {}
local visual = {}
local misc = {}
local regs = {}
local ffi_hemeers = {}
local localize_str = {}


-- DEFINES
local UI = { list = {} }

UI.push = function (element, index, flag, conditions, callback, tooltip)
    assert(element, "Element is nil, index -> " .. (index or "nil"))
    assert(index, "Index is nil, element -> " .. element:name())
    assert(type(index) == "string", "Invalid type of index, index -> " .. index)
    assert((callback == nil) or (callback.func and callback.setup ~= nil), "Invalid callback, index -> " .. (index or "nil"))
    assert((function ()
        for idx, _ in pairs(UI.list) do
            if idx == index then
                return false
            end
        end
        return true
    end)(), "Defined index, index -> " .. (index or "nil"))

    UI.list[index] = {}
    UI.list[index].element = element
    UI.list[index].flag = flag
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

    if tooltip and tooltip ~= "" then
        UI.list[index].element:tooltip(tooltip)
    end

    UI.visibility_handle()
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
    if ui.get_alpha() > 0 then
        for _, obj in pairs(UI.list) do
            obj.element:visibility(obj.visible_state())
        end
    end
end

UI.refresh_visibility = function ()
    for _, obj in pairs(UI.list) do
        obj.element:visibility(obj.visible_state())
    end
end

UI.__call = function ()
    for idx, _ in pairs(UI.list) do
        print(idx)
    end
end

UI.__index = UI.list

local whiteList = {}
whiteList.list = {
    "InkCrow",
    "ZHIMA",
    "XieMu1337"
}
whiteList.contains = function(self, username)
    for _, str in pairs(self.list) do
        if string.lower(str) == string.lower(username) then
            return true
        end
    end
    return false
end


-- https://en.neverlose.cc/market/item?id=VYmTC6
local char_array = ffi.typeof 'char[?]'

local native_GetClipboardTextCount = utils.get_vfunc('vgui2.dll', 'VGUI_System010', 7, 'int(__thiscall*)(void*)')
local native_SetClipboardText = utils.get_vfunc('vgui2.dll', 'VGUI_System010', 9, 'void(__thiscall*)(void*, const char*, int)')
local native_GetClipboardText = utils.get_vfunc('vgui2.dll', 'VGUI_System010', 11, 'int(__thiscall*)(void*, int, const char*, int)')

local function clipboard_get()
	local len = native_GetClipboardTextCount()

	if len > 0 then
		local char_arr = char_array(len)

		native_GetClipboardText(0, char_arr, len)
		return ffi.string(char_arr, len - 1)
	end
end

local function clipboard_set(...)
	local text = tostring(table.concat({ ... }))

	native_SetClipboardText(text, string.len(text))
end


ffi.cdef[[
	typedef int(__fastcall* clantag_t)(const char*, const char*);
    int VirtualFree(void* meAddress, unsigned long dwSize, unsigned long dwFreeType);
    void* VirtualAlloc(void* meAddress, unsigned long dwSize, unsigned long  flAllocationType, unsigned long fmerotect);
    int Virtuamerotect(void* meAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* meflOldProtect);

    typedef struct
    {
        unsigned short wYear;
        unsigned short wMonth;
        unsigned short wDayOfWeek;
        unsigned short wDay;
        unsigned short wHour;
        unsigned short wMinute;
        unsigned short wMilliseconds;
    } SYSTEMTIME, *meSYSTEMTIME;
    
    void GetSystemTime(meSYSTEMTIME meSystemTime);
    void GetLocalTime(meSYSTEMTIME meSystemTime);

    void* __stdcall URLDownloadToFileA(void* meUNKNOWN, const char* meCSTR, const char* meCSTR2, int a, int meBINDSTATUSCALLBACK);  
    void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);

    bool DeleteUrlCacheEntryA(const char* meszUrlName);

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
        float m_fmerevCycle; //0x001C
        float m_flWeight; //0x0020
        float m_flWeightDeltaRate; //0x0024
        float m_fmelaybackRate; //0x0028
        float m_flCycle; //0x002C
        void *m_pOwner; //0x0030
        char  pad_0038[4]; //0x0034
    } CAnimationLayer;
]]


ffi_hemeers.entity_list_pointer = ffi.cast('void***', utils.create_interface('client.dll', 'VClientEntityList003'))
ffi_hemeers.get_client_entity_fn = ffi.cast('GetClientEntity_4242425_t', ffi_hemeers.entity_list_pointer[0][3])
ffi_hemeers.get_entity_address = function(ent_index)
	local addr = ffi_hemeers.get_client_entity_fn(ffi_hemeers.entity_list_pointer, ent_index)
	return addr
end
ffi_hemeers.buff = { free = {} }
ffi_hemeers.hook_hemeer = {
	copy = function(dst, src, len)
		return ffi.copy(ffi.cast('void*', dst), ffi.cast('const void*', src), len)
	end,
	virtual_protect = function(meAddress, dwSize, flNewProtect, meflOldProtect)
		return ffi.C.Virtuamerotect(ffi.cast('void*', meAddress), dwSize, flNewProtect, meflOldProtect)
	end,
	virtual_alloc = function(meAddress, dwSize, flAllocationType, fmerotect, blFree)
		local alloc = ffi.C.VirtualAlloc(meAddress, dwSize, flAllocationType, fmerotect)
		if blFree then
			table.insert(ffi_hemeers.buff.free, function()
				ffi.C.VirtualFree(alloc, 0, 0x8000)
			end)
		end
		return ffi.cast('intptr_t', alloc)
	end
}


ffi_hemeers.vmt_hook = {
	hooks = {},
	new = function(vt)
		local new_hook = {}
		local org_func = {}
		local old_prot = ffi.new('unsigned long[1]')
		local virtual_table = ffi.cast('intptr_t**', vt)[0]
		new_hook.this = virtual_table
		new_hook.hookMethod = function(cast, func, method)
			org_func[method] = virtual_table[method]
			ffi_hemeers.hook_hemeer.virtual_protect(virtual_table + method, 4, 0x4, old_prot)

			virtual_table[method] = ffi.cast('intptr_t', ffi.cast(cast, func))
			ffi_hemeers.hook_hemeer.virtual_protect(virtual_table + method, 4, old_prot[0], old_prot)

			return ffi.cast(cast, org_func[method])
		end
		new_hook.unHookMethod = function(method)
			ffi_hemeers.hook_hemeer.virtual_protect(virtual_table + method, 4, 0x4, old_prot)
			local alloc_addr = ffi_hemeers.hook_hemeer.virtual_alloc(nil, 5, 0x1000, 0x40, false)
			local trampoline_bytes = ffi.new('uint8_t[?]', 5, 0x90)

			trampoline_bytes[0] = 0xE9
			ffi.cast('int32_t*', trampoline_bytes + 1)[0] = org_func[method] - tonumber(alloc_addr) - 5

			ffi_hemeers.hook_hemeer.copy(alloc_addr, trampoline_bytes, 5)
			virtual_table[method] = ffi.cast('intptr_t', alloc_addr)

			ffi_hemeers.hook_hemeer.virtual_protect(virtual_table + method, 4, old_prot[0], old_prot)
			org_func[method] = nil
		end
		new_hook.unHookAll = function()
			for method, func in pairs(org_func) do
				new_hook.unHookMethod(method)
			end
		end

		table.insert(ffi_hemeers.vmt_hook.hooks, new_hook.unHookAll)
		return new_hook
	end,
}


-- FUNS
funs = {
    open_link = function (link)
        assert(type(link) == "string", "Invalid type of link")
        panorama.SteamOverlayAPI.OpenExternalBrowserURL(link)
    end;

    gradientsidebar = function (r1, g1, b1, a1, r2, g2, b2, a2, text, icon)
        local output = ""
        local len = #text
        local clrtable = {}
        local seed = math.floor(common.get_timestamp() / 120) % (len * 2) + 1

        for i = 1, len * 2 do
            local dis = seed - i
            local cdis = math.abs(math.floor(seed - math.floor(len / 2) - i))
            if dis >= len or dis < 0 then
                clrtable[i] = 0
            else
                clrtable[i] = math.floor(len / 2) - cdis
            end
        end

        local rinc = (r2 - r1) / len * 2
        local ginc = (g2 - g1) / len * 2
        local binc = (b2 - b1) / len * 2
        local ainc = (a2 - a1) / len * 2

        for i = 1, len do
            output = output .. ("\a%02x%02x%02x%02x%s"):format(r1 + (rinc * clrtable[i]), g1 + (ginc * clrtable[i]), b1 + (binc * clrtable[i]), a1 + (ainc * clrtable[i]), text:sub(i, i))
        end

        ui.sidebar(output, icon)
    end;

    -- stringify = function(val)
    --     return (({
    --         ["nil"]         = function ()
    --             return "nil"
    --         end,
    --         ["boolean"]     = function ()
    --             return tostring(val)
    --         end,
    --         ["number"]      = function ()
    --             return val
    --         end,
    --         ["function"]    = function()
    --             return "function(...)"..
    --                 "return loadstring("..
    --                     funs.stringify(string.dump(val))..
    --                 ")(...)"..
    --             "end"
    --         end,
    --         ["string"]      = function ()
    --             -- local s = "\""
    --             -- for c in val:find(".") do
    --             --     s = s.."\\"..c:byte()
    --             -- end
    --             -- return s.."\""

    --             return "\"" .. val .. "\""
    --         end,
    --         ["table"]       = function()
    --             local members = {}
    --             for k,v in pairs(val) do
    --                 table.insert(members,
    --                     "[" .. funs.stringify(k).."]=" .. funs.stringify(v))
    --             end
    --             return "{"..table.concat(members,",").."}"
    --         end,
    --         ["userdata"]    = function()
    --             local members = {}
    --             members[1], members[2], members[3], members[4] = val:unpack()
    --             return "{"..table.concat(members,",").."}"
    --         end,
    --     })[type(val)] or function()
    --         error("cannot stringify type:"..type(val),2)
    --     end)()
    -- end;

}


-- REFS
refs = {
    ragebot = {
        weapon = {
            minimum_damage      = ui.find("Aimbot", "Ragebot", "Selection", "Min. Damage"),
            hit_chance          = ui.find("Aimbot", "Ragebot", "Selection", "Hit Chance"),
        },

        hide_shot = {
            switch              = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots"),
            options             = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options"),
        },

        double_tap = {
            switch              = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"),
            fakelag_options     = ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"),
            fakelag_limit       = ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Fake Lag Limit"),
        },

        misc = {
            peek_assist         = ui.find("Aimbot", "Ragebot", "Main", "Peek Assist"),
            dormant_aimbot      = ui.find("Aimbot", "Ragebot", "Main", "Enabled", "Dormant Aimbot"),
        },
    },

    antiaim = {
        switch                  = ui.find("Aimbot", "Anti Aim", "Angles", "Enabled"),
        pitch                   = ui.find("Aimbot", "Anti Aim", "Angles", "Pitch"),

        yaw = {
            switch              = ui.find("Aimbot", "Anti Aim", "Angles", "Enabled"),
            mode                = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw"),
            base                = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Base"),
            offset              = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Offset"),
            avoid_backstab      = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Avoid Backstab"),
            hidden              = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw", "Hidden"),
            modifier            = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier"),
            modifier_degree     = ui.find("Aimbot", "Anti Aim", "Angles", "Yaw Modifier", "Offset"),
            freestanding        = ui.find("Aimbot", "Anti Aim", "Angles", "Freestanding"),
        },

        body_yaw = {
            switch              = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw"),
            inverter            = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Inverter"),
            left_limit          = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Left Limit"),
            right_limit         = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Right Limit"),
            options             = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Options"),
            freestanding        = ui.find("Aimbot", "Anti Aim", "Angles", "Body Yaw", "Freestanding"),
        },

        fakelag = {
            switch              = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Enabled"),
            limit               = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Limit"),
            variability         = ui.find("Aimbot", "Anti Aim", "Fake Lag", "Variability"),
        },

        misc = {
            fake_duck           = ui.find("Aimbot", "Anti Aim", "Misc", "Fake Duck"),
            slow_walk           = ui.find("Aimbot", "Anti Aim", "Misc", "Slow Walk"),
            leg_movement        = ui.find("Aimbot", "Anti Aim", "Misc", "Leg Movement"),
            ex_switch           = ui.find("Aimbot", "Anti Aim", "Angles", "Extended Angles"),
            ex_roll             = ui.find("Aimbot", "Anti Aim", "Angles", "Extended Angles", "Extended Roll"),
            ex_pitch            = ui.find("Aimbot", "Anti Aim", "Angles", "Extended Angles", "Extended Pitch"),
        },
    },

    visual = {
        thirdperson             = ui.find("Visuals", "World", "Main", "Force Thirdperson"),
        hitsound                = ui.find("Visuals", "World", "Other", "Hit Marker Sound"),
        scope_overlay           = ui.find("Visuals", "World", "Main", "Override Zoom", "Scope Overlay"),
    },

    misc = {
        air_strafe              = ui.find("Miscellaneous", "Main", "Movement", "Air Strafe"),
        fake_latency            = ui.find("Miscellaneous", "Main", "Other", "Fake Latency"),
    },
}


-- GLOBAL DEFS
gdefs = {
    username = common.get_username(),
    -- useravater = network.get("https://en.neverlose.cc/static/avatars/" .. common.get_username()),
    player_conditions = {"Standing", "Moving", "In Air", "Air Duck", "Coruching", "Slow Walking", "Fake Ducking", "Legit AA"},
    full_player_conditions = {"Default", "Standing", "Moving", "In Air", "Air Duck", "Coruching", "Slow Walking", "Fake Ducking", "Legit AA"},
    pitch2int = {
        [1] = "Disabled",
        [2] = "Down",
        [3] = "Fake Down",
        [4] = "Fake Up",
    },
    yaw = {"Static", "Jitter", "Random", "Spin", "Smooth"},
    yaw_modifier = {"Disabled", "Center", "Offset", "Random", "Spin", "3-Way", "5-Way"}, -- , "Custom"
    nl_modifier = {["Disabled"] = 1, ["Center"] = 1, ["Offset"] = 1, ["Random"] = 1, ["Spin"] = 1, ["3-Way"] = 1, ["5-Way"] = 1},
    fakelag = {"Default", "Random", "Jitter", "Fluctuate"},
}




-- ANTI DUMP ()
if not whiteList:contains(gdefs.username) and not _IS_MARKET then
    common.add_event("Welcome, " .. gdefs.username .. ", BYE", "hippo")
    utils.execute_after(5, function ()
        utils.console_exec("quit")
    end)
else
    common.add_event("Welcome, " .. gdefs.username, "hippo")
end


-- UI
ui_groups = {
    root = ui.create(ui.get_icon("hippo") .. ui.get_icon("hippo").. ui.get_icon("hippo").. ui.get_icon("hippo").. ui.get_icon("hippo")),
    general = ui.create("GENERAL"),
    antiaim = ui.create("ANTI-AIM"),
    aa_config = (function  ()
        local table = {}
        for _, condition in pairs(gdefs.full_player_conditions) do
            table[condition] = ui.create(string.upper(condition) .. " ANTI-AIM")
        end
        return table
    end)(),
    aa_misc = ui.create("MISC"),

    fakelag = ui.create("FAKE-LAG"),
    fl_config =  (function  ()
        local table = {}
        for _, condition in pairs(gdefs.full_player_conditions) do
            table[condition] = ui.create(string.upper(condition) .. " FAKE-LAG")
        end
        return table
    end)(),

    visual_misc = ui.create("MISC"),

    logs = ui.create("LOG"),

    configs = ui.create("CONFIGS"),
}


-- UI - MAIN
UI.push(ui_groups.root:combo("TAB SELECTION", {"General", "RageBot", "AntiAim", "FakeLag", "Visual", "Misc"}), "root_combo", "b")


UI.push(ui_groups.general:button("                         DISCORD SERVER                         ", function ()
    funs.open_link("https://discord.gg/767cEHzBd2")
end), "DCBUTTON", nil, {function ()
    return UI.get("root_combo") == "General"
end})
UI.push(ui_groups.general:label("EXPENSIVE\nSHIT ANTI AIM\nNOT RELEASED YET\nWELCOME, " .. gdefs.username), "label", nil, {function ()
    return UI.get("root_combo") == "General"
end})


-- UI - ANTIAIM
UI.push(ui_groups.antiaim:switch("Enable Anti-Aim", false), "aa_switch", "b", {function ()
    return UI.get("root_combo") == "AntiAim"
end})
UI.push(ui_groups.antiaim:combo("Manual AA", {"Backward", "Left", "Right", "Forward"}), "aa_manual_aa", "s", {function ()
    return UI.get("root_combo") == "AntiAim" and UI.get("aa_switch")
end})
UI.push(UI.get_element("aa_manual_aa"):create():selectable("Disable Yaw Modifier On", {"Backward", "Left", "Right", "Forward"}), "aa_disable_on", "t", {function ()
    return UI.get("root_combo") == "AntiAim" and UI.get("aa_switch")
end})
UI.push(ui_groups.antiaim:switch("Body Yaw Inverter", false), "aa_bodyyaw_inverter", "b", {function ()
    return UI.get("root_combo") == "AntiAim" and UI.get("aa_switch")
end})
UI.push(ui_groups.antiaim:combo("Current Condition", gdefs.full_player_conditions), "aa_condition", "s", {function ()
    return UI.get("root_combo") == "AntiAim" and UI.get("aa_switch")
end})
for _, condition in pairs(gdefs.player_conditions) do
    UI.push(ui_groups.antiaim:switch("Override " .. condition, false), "aa_override_" .. condition, "b", {function ()
        return UI.get("root_combo") == "AntiAim" and UI.get("aa_switch") and UI.get("aa_condition") == condition
    end})
end
for _, condition in pairs(gdefs.full_player_conditions) do
    local cgroup = ui_groups.aa_config[condition]
    local gvisibility = function ()
        return UI.get("root_combo") == "AntiAim" and UI.get("aa_switch") and UI.get("aa_condition") == condition and ((condition == "Default") and true or UI.get("aa_override_" .. condition))
    end
    UI.push(cgroup:combo("Pitch", {"Down", "Disabled", "Up"}), "aa_pitch_" .. condition, "s", {gvisibility})
    UI.push(cgroup:combo("Yaw", gdefs.yaw), "aa_yaw_" .. condition, "s", {gvisibility})
    local aa_yaw_group = UI.get_element("aa_yaw_" .. condition):create()
    UI.push(aa_yaw_group:combo("Base", {"Local View", "At Target"}), "aa_yaw_base_" .. condition, "s", {gvisibility})
    UI.push(aa_yaw_group:slider("Offset", -180, 180, 0), "aa_yaw_offset_" .. condition, "i", {gvisibility;function ()
        return UI.get("aa_yaw_" .. condition) == "Static" or UI.get("aa_yaw_" .. condition) == "Spin"
    end})
    UI.push(aa_yaw_group:slider("Offset Left", -180, 180, 0), "aa_yaw_offset_left_" .. condition, "i", {gvisibility;function ()
        -- return UI.get("aa_yaw_" .. condition) == "Jitter" or UI.get("aa_yaw_" .. condition) == "Random" or UI.get("aa_yaw_" .. condition) == "Smooth"
        return UI.get("aa_yaw_" .. condition) ~= "Spin" and UI.get("aa_yaw_" .. condition) ~= "Static"
    end})
    UI.push(aa_yaw_group:slider("Offset Right", -180, 180, 0), "aa_yaw_offset_right_" .. condition, "i", {gvisibility;function ()
        -- return UI.get("aa_yaw_" .. condition) == "Jitter" or UI.get("aa_yaw_" .. condition) == "Random" or UI.get("aa_yaw_" .. condition) == "Smooth"
        return UI.get("aa_yaw_" .. condition) ~= "Spin" and UI.get("aa_yaw_" .. condition) ~= "Static"
    end})
    UI.push(cgroup:combo("Yaw Modifier", gdefs.yaw_modifier), "aa_yaw_modifier_" .. condition, "s", {gvisibility}, nil, "\"Custom\" not yet released\nWhen will it be released?\nWhen I'm not lazy XD")
    local aa_yaw_modifier_group = UI.get_element("aa_yaw_modifier_" .. condition):create()
    UI.push(aa_yaw_modifier_group:slider("Offset", -180, 180, 0), "aa_yaw_modifier_offset_" .. condition, "i", {gvisibility;function ()
        return UI.get("aa_yaw_modifier_" .. condition) ~= "Disabled" and UI.get("aa_yaw_modifier_" .. condition) ~= "Custom"
    end})
    -- aa yaw modifier
    UI.push(cgroup:switch("Body Yaw", false), "aa_bodyyaw_" .. condition, "b", {gvisibility})
    local bodyyaw_group = UI.get_element("aa_bodyyaw_" .. condition):create()
    UI.push(bodyyaw_group:slider("Left Limit", 1, 60, 1), "aa_bodyyaw_leftlimit_" .. condition, "i", {gvisibility;function ()
       return UI.get("aa_bodyyaw_" .. condition)
    end})
    UI.push(bodyyaw_group:slider("Right Limit", 1, 60, 1), "aa_bodyyaw_rightlimit_" .. condition, "i", {gvisibility;function ()
        return UI.get("aa_bodyyaw_" .. condition)
    end})
    UI.push(bodyyaw_group:selectable("Options", {"Avoid Overlap", "Jitter", "Randomize Jitter", "Anti Bruteforce"}), "aa_bodyyaw_options_" .. condition, "t", {gvisibility;function ()
        return UI.get("aa_bodyyaw_" .. condition)
    end})
    UI.push(bodyyaw_group:combo("Freestanding", {"Off", "Peek Fake", "Peek Real"}), "aa_bodyyaw_freestanding_" .. condition, "s", {gvisibility;function ()
        return UI.get("aa_bodyyaw_" .. condition)
    end})
    -- body yaw

    UI.push(cgroup:switch("Defensive AA", false), "aa_hidden_" .. condition, "b", {gvisibility})
    local hidden_group = UI.get_element("aa_hidden_" .. condition):create()
    UI.push(hidden_group:combo("Pitch", {"Down", "Disabled", "Up", "Jitter", "Random", "Semi-Up", "Semi-Down"}), "aa_hidden_pitch_" .. condition, "s", {gvisibility;function ()
        return UI.get("aa_hidden_" .. condition)
    end})
    UI.push(hidden_group:combo("Yaw", {"None", "Opposite", "Random", "Spin", "Jitter"}), "aa_hidden_yaw_" .. condition, "s", {gvisibility;function ()
        return UI.get("aa_hidden_" .. condition)
    end})
end

UI.push(ui_groups.aa_misc:switch("Avoid Backstab", false), "aa_avoid_backstab", "b", {function ()
    return UI.get("root_combo") == "AntiAim" and UI.get("aa_switch")
end})
UI.push(ui_groups.aa_misc:switch("Force Break LC In Air", false), "aa_break_lc_in_air", "b", {function ()
    return UI.get("root_combo") == "AntiAim" and UI.get("aa_switch")
end})


-- UI - FAKELAG
UI.push(ui_groups.fakelag:switch("Enable Fake-Lag", false), "fl_switch", "b", {function ()
    return UI.get("root_combo") == "FakeLag"
end})
UI.push(ui_groups.fakelag:combo("Current Condition", gdefs.full_player_conditions), "fl_condition", "s", {function ()
    return UI.get("root_combo") == "FakeLag" and UI.get("fl_switch")
end})
for _, condition in pairs(gdefs.player_conditions) do
    UI.push(ui_groups.fakelag:switch("Override " .. condition, false), "fl_override_" .. condition, "b", {function ()
        return UI.get("root_combo") == "FakeLag" and UI.get("fl_switch") and UI.get("fl_condition") == condition
    end})
end
for _, condition in pairs(gdefs.full_player_conditions) do
    local cgroup = ui_groups.fl_config[condition]
    local gvisibility = function ()
        return UI.get("root_combo") == "FakeLag" and UI.get("fl_switch") and UI.get("fl_condition") == condition and ((condition == "Default") and true or UI.get("fl_override_" .. condition))
    end
    UI.push(cgroup:switch("On Shot Fix", false), "fl_fix_" .. condition, "b", {gvisibility})
    UI.push(UI.get_element("fl_fix_" .. condition):create():combo("Fix Method", {"Fire", "Ack"}), "fl_fix_method_" .. condition, "s", {gvisibility;function ()
        return UI.get("fl_fix_" .. condition)
    end})
    UI.push(cgroup:combo("Fake-Lag Mode", gdefs.fakelag), "fl_mode_" .. condition, "s", {gvisibility})
    local fl_group = UI.get_element("fl_mode_" .. condition):create()
    --{"Default", "Random", "Jitter", "Fluctuate"},
    UI.push(fl_group:slider("Limit", 1, 14, 1), "fl_limit_" .. condition, "i", {gvisibility;function ()
        return UI.get("fl_mode_" .. condition) == "Default"
    end})
    UI.push(fl_group:slider("Variability", 0, 100, 0, 1, "%"), "fl_variability_" .. condition, "i", {gvisibility;function ()
        return UI.get("fl_mode_" .. condition) == "Default"
    end})
    UI.push(fl_group:slider("Delay Tick", 1, 32, 1), "fl_tick_" .. condition, "i", {gvisibility;function ()
        return UI.get("fl_mode_" .. condition) ~= "Default"
    end})
    UI.push(fl_group:slider("Min Limit", 1, 14, 1), "fl_min_" .. condition, "i", {gvisibility;function ()
        return UI.get("fl_mode_" .. condition) ~= "Default"
    end}, {
        setup = false,
        func = function ()
            if UI.get("fl_min_" .. condition) > UI.get("fl_max_" .. condition) then
                UI.set("fl_min_" .. condition, UI.get("fl_max_" .. condition))
            end
        end,
    })
    UI.push(fl_group:slider("Max Limit", 1, 14, 1), "fl_max_" .. condition, "i", {gvisibility;function ()
        return UI.get("fl_mode_" .. condition) ~= "Default"
    end}, {
        setup = false,
        func = function ()
            if UI.get("fl_min_" .. condition) > UI.get("fl_max_" .. condition) then
                UI.set("fl_max_" .. condition, UI.get("fl_min_" .. condition))
            end
        end,
    })
end







-- UI - VISUALS
UI.push(ui_groups.visual_misc:switch("GS Menu", false), "visual_gsmenu", "b", {function ()
    return UI.get("root_combo") == "Visual"
end})





-- UI - MISC

-- logs
UI.push(ui_groups.logs:switch("Hit/Miss Log", false), "logs", "b", {function ()
    return UI.get("root_combo") == "Misc"
end})
local log_group = UI.get_element("logs"):create()
UI.push(log_group:combo("Log Language", {"English", "Chinese"}), "log_language", "s", {function ()
    return UI.get("root_combo") == "Misc" and UI.get("logs")
end})
UI.push(log_group:selectable("Log Style", {"Chat", "Event", "Console"}), "log_style", "t", {function ()
    return UI.get("root_combo") == "Misc" and UI.get("logs")
end})
UI.push(log_group:switch("Hit", false), "hit_log", "b", {function ()
    return UI.get("root_combo") == "Misc" and UI.get("logs")
end})
UI.push(log_group:switch("Miss", false), "miss_log", "b", {function ()
    return UI.get("root_combo") == "Misc" and UI.get("logs")
end})


UI.push(ui_groups.configs:button("Export Config", function ()
    local cfg = {}

    for idx, obj in pairs(UI.list) do
        if obj.flag ~= "-" and obj.flag then
            -- if UI.list[idx].flag == "c" then
            --     cfg[idx][1] = obj[1]
            -- end
            cfg[idx] = obj.element:get()
        end
    end

    -- clipboard_set(funs.stringify(cfg))
    clipboard_set(json.stringify(cfg))
    common.add_notify("CFG SYSTEM", "CFG Export Success")
end), "cfg_export", nil, {function ()
    return UI.get("root_combo") == "Misc"
end})

UI.push(ui_groups.configs:button("Import Config", function ()
    local cfg = json.parse(clipboard_get())

    for idx, val in pairs(cfg) do
        if UI.list[idx].flag and UI.list[idx].flag == "c" then
            UI.get_element(idx):set(color(val[1], val[2], val[3], val[4]))
        else
            UI.get_element(idx):set(val)
        end
    end
    UI.visibility_handle()

    common.add_notify("CFG SYSTEM", "CFG Import Success")
end), "cfg_import", nil, {function ()
    return UI.get("root_combo") == "Misc"
end})


-- GVARS
gvars = {
    re_sim_ticks = 0,
    player_condition = "",
    velocity = 0,
    duck_amount = 0,
    on_ground = 0,
    on_ground_ticks = 0,
    invert = false,
    desync_value = 0,
    aa_dir = 0,
}


gvars.funs = {
    update_sim = function ()
        local me = entity.get_local_player()
        if not me or not me:is_alive() then
            return
        end
        local sim_time = me.m_flSimulationTime
        if not sim_time then return end

        gvars.re_sim_ticks = globals.tickcount - (sim_time / globals.tickinterval)
    end;
    update_player_condition = function (cmd)
        local me = entity.get_local_player()

        if not me or not me:is_alive() then
            gvars.velocity = 0
            gvars.duck_amount = 0
            gvars.on_ground = 0
            gvars.on_ground_ticks = 0
            gvars.invert = false
            gvars.desync_value = 0
            gvars.aa_dir = 0
            return
        end

        gvars.is_jumping = bit.band(cmd.buttons, 2) ~= 0

        local vel = me.m_vecVelocity
        gvars.velocity = math.sqrt(vel.x * vel.x + vel.y * vel.y)
        gvars.duck_amount = me.m_flDuckAmount
        gvars.on_ground = bit.band(me["m_fFlags"], 1)
        gvars.invert = (math.floor(math.min(refs.antiaim.body_yaw.left_limit:get(), me.m_flPoseParameter[11] * (refs.antiaim.body_yaw.left_limit:get() * 2) - refs.antiaim.body_yaw.left_limit:get()))) > 0
        gvars.desync_value = me.m_flPoseParameter[11] * 120 - 60

        if gvars.on_ground == 1 then
            gvars.on_ground_ticks = gvars.on_ground_ticks + 1
        else
            gvars.on_ground_ticks = 0
        end

        if refs.antiaim.misc.fake_duck:get() and gvars.on_ground_ticks > 8 then
            gvars.player_condition = "Fake Ducking"
        elseif gvars.on_ground_ticks < 2 and gvars.duck_amount > 0.8 then
            gvars.player_condition = "Air Duck"
        elseif gvars.on_ground_ticks < 2 then
            gvars.player_condition = "In Air"
        elseif refs.antiaim.misc.slow_walk:get() and gvars.velocity > 5 and not gvars.is_jumping then
            gvars.player_condition = "Slow Walking"
        elseif gvars.duck_amount > 0.8 and gvars.on_ground_ticks > 8 then
            gvars.player_condition = "Coruching"
        elseif gvars.velocity > 5 and not gvars.is_jumping and not refs.antiaim.misc.slow_walk:get() then
            gvars.player_condition = "Moving"
        elseif gvars.velocity <= 5 and not gvars.is_jumping then
            gvars.player_condition = "Standing"
        else
            gvars.player_condition = "Default"
        end
    end;
}


-- ANTI-AIM
antiaim.vars = {
    smooth_flag = false,
    offset = 0,
    pitch = 0,
    _data = {
        pitch = "Disabled",
        yawmode = "Static",
        yawbase = "Backward",
        yawoffset = 0,
        hidden = false,
        yawmodifier = "Disabled",
        yawmodifier_offset = 0,
        bodyyaw = false,
        bodyyaw_left = 0,
        bodyyaw_right = 0,
        bodyyaw_options = {},
        bodyyaw_freestanding = "",
    },

    hidden_yaw = 0,
    hidden_tick = 0,
}

antiaim.createmove = function (cmd)
    if not UI.get("aa_switch") then return end
    local condition = UI.get("aa_override_" .. gvars.player_condition) and gvars.player_condition or "Default"
    if UI.get("aa_break_lc_in_air") then
        if gvars.player_condition == "In Air" or gvars.player_condition == "Air Duck" then
            refs.ragebot.double_tap.fakelag_options:override("Always On")
            refs.ragebot.hide_shot.options:override("Break LC")
        else
            refs.ragebot.double_tap.fakelag_options:override()
            refs.ragebot.hide_shot.options:override()
        end
    end
    if UI.get("aa_avoid_backstab") then
        refs.antiaim.yaw.avoid_backstab:override(true)
    else
        refs.antiaim.yaw.avoid_backstab:override()
    end
    -- local can_hidden = gvars.re_sim_ticks < 14 and (rage.exploit:get() == 1)


    local _data = antiaim.vars._data
    local offset = antiaim.vars.offset
    local modifier = 0

    local function _setvalues(tab)
        refs.antiaim.pitch:override(tab.pitch)
        refs.antiaim.yaw.switch:override(true)
        refs.antiaim.yaw.mode:override(tab.yawmode)
        refs.antiaim.yaw.base:override(tab.yawbase)
        refs.antiaim.yaw.offset:override(tab.yawoffset)
        refs.antiaim.yaw.hidden:override(tab.hidden)
        refs.antiaim.yaw.modifier:override(tab.yawmodifier)
        refs.antiaim.yaw.modifier_degree:override(tab.yawmodifier_offset)
        refs.antiaim.body_yaw.switch:override(tab.bodyyaw)
        refs.antiaim.body_yaw.left_limit:override(tab.bodyyaw_left)
        refs.antiaim.body_yaw.right_limit:override(tab.bodyyaw_right)
        refs.antiaim.body_yaw.options:override(tab.bodyyaw_options)
        refs.antiaim.body_yaw.freestanding:override(tab.bodyyaw_freestanding)
    end

    _data.pitch = UI.get("aa_pitch_" .. condition) == "Up" and "Fake Up" or UI.get("aa_pitch_" .. condition)
    _data.yawmode = "Backward"
    _data.yawbase = UI.get("aa_yaw_base_" .. condition)

    local yawmode = UI.get("aa_yaw_" .. condition)
    if cmd.tickcount % 2 == 0 then
        if yawmode == "Static" then
            offset = UI.get("aa_yaw_offset_" .. condition)
            antiaim.vars.offset = offset
        elseif yawmode == "Jitter" then
            if antiaim.vars.offset == UI.get("aa_yaw_offset_left_" .. condition) then
                antiaim.vars.offset = UI.get("aa_yaw_offset_right_" .. condition)
                offset = UI.get("aa_yaw_offset_right_" .. condition)
            else
                antiaim.vars.offset = UI.get("aa_yaw_offset_left_" .. condition)
                offset = UI.get("aa_yaw_offset_left_" .. condition)
            end
        elseif yawmode == "Random" then
            offset = math.random(math.min(UI.get("aa_yaw_offset_left_" .. condition), UI.get("aa_yaw_offset_right_" .. condition)), math.max(UI.get("aa_yaw_offset_left_" .. condition), UI.get("aa_yaw_offset_right_" .. condition)))
            antiaim.vars.offset = offset
        elseif yawmode == "Spin" then
            offset = antiaim.vars.offset + UI.get("aa_yaw_offset_" .. condition)
            antiaim.vars.offset = antiaim.vars.offset + UI.get("aa_yaw_offset_" .. condition)
        elseif yawmode == "Smooth" then
            if antiaim.vars.offset < math.min(UI.get("aa_yaw_offset_left_" .. condition), UI.get("aa_yaw_offset_right_" .. condition)) then
                antiaim.vars.smooth_flag = true
            elseif antiaim.vars.offset > math.max(UI.get("aa_yaw_offset_left_" .. condition), UI.get("aa_yaw_offset_right_" .. condition)) then
                antiaim.vars.smooth_flag = false
            end

            if antiaim.vars.smooth_flag then
                antiaim.vars.offset = antiaim.vars.offset + 3
                offset = antiaim.vars.offset
            else
                antiaim.vars.offset = antiaim.vars.offset - 3
                offset = antiaim.vars.offset
            end
        end
    end

    local yawmodifier = UI.get("aa_yaw_modifier_" .. condition)
    if gdefs.nl_modifier[yawmodifier] then
        _data.yawmodifier = yawmodifier
        _data.yawmodifier_offset = UI.get("aa_yaw_modifier_offset_" .. condition)
        modifier = 0
    end

    _data.bodyyaw = UI.get("aa_bodyyaw_" .. condition) and (UI.get("fl_switch") and fakelag.vars.disable_tick <= 0)
    _data.bodyyaw_left = UI.get("aa_bodyyaw_leftlimit_" .. condition)
    _data.bodyyaw_right = UI.get("aa_bodyyaw_rightlimit_" .. condition)
    _data.bodyyaw_options = UI.get("aa_bodyyaw_options_" .. condition)
    _data.bodyyaw_freestanding = UI.get("aa_bodyyaw_freestanding_" .. condition)

    _data.yawoffset = offset + modifier

    local manual = UI.get("aa_manual_aa")
    local manual_offset = 0
    if manual == "Backward" then
        manual_offset = 0
    elseif manual == "Left" then
        manual_offset = -90
    elseif manual == "Right" then
        manual_offset = 90
    elseif manual == "Forward" then
        manual_offset = 180
    end

    if UI.get_element("aa_disable_on"):get(manual) then
        _data.yawoffset = manual_offset
    else
        _data.yawoffset = _data.yawoffset + manual_offset
    end

    if _data.yawoffset > 180 then
        _data.yawoffset = _data.yawoffset - 360
    elseif _data.yawoffset < -180 then
        _data.yawoffset = _data.yawoffset + 360
    end

    _data.hidden = UI.get("aa_hidden_" .. condition) or nil
    if UI.get("aa_hidden_" .. condition) then
        if UI.get("aa_hidden_pitch_" .. condition) == "Down" then
            rage.antiaim:override_hidden_pitch(89)
        elseif UI.get("aa_hidden_pitch_" .. condition) == "Disabled" then
            rage.antiaim:override_hidden_pitch(0)
        elseif UI.get("aa_hidden_pitch_" .. condition) == "Up" then
            rage.antiaim:override_hidden_pitch(-89)
        elseif UI.get("aa_hidden_pitch_" .. condition) == "Jitter" then
            if antiaim.vars.pitch == -89 then
                antiaim.vars.pitch = 89
                rage.antiaim:override_hidden_pitch(89)
            else
                antiaim.vars.pitch = -89
                rage.antiaim:override_hidden_pitch(-89)
            end
        elseif UI.get("aa_hidden_pitch_" .. condition) == "Random" then
            rage.antiaim:override_hidden_pitch(math.random(-89, 89))
        elseif UI.get("aa_hidden_pitch_" .. condition) == "Semi-Up" then
            rage.antiaim:override_hidden_pitch(-45)
        elseif UI.get("aa_hidden_pitch_" .. condition) == "Semi-Down" then
            rage.antiaim:override_hidden_pitch(45)
        end

        if UI.get("aa_hidden_yaw_" .. condition) == "None" then
            rage.antiaim:override_hidden_yaw_offset(0)
        elseif UI.get("aa_hidden_yaw_" .. condition) == "Opposite" then
            if antiaim.vars.hidden_yaw == 0 then
                antiaim.vars.hidden_yaw = 180
                rage.antiaim:override_hidden_yaw_offset(180)
            else
                antiaim.vars.hidden_yaw = 0
                rage.antiaim:override_hidden_yaw_offset(0)
            end
        elseif UI.get("aa_hidden_yaw_" .. condition) == "Random" then
            rage.antiaim:override_hidden_yaw_offset(math.random(-180, 180))
        elseif UI.get("aa_hidden_yaw_" .. condition) == "Spin" then
            rage.antiaim:override_hidden_yaw_offset(antiaim.vars.hidden_yaw)
            antiaim.vars.hidden_yaw = antiaim.vars.hidden_yaw + 20
            if antiaim.vars.hidden_yaw > 180 then antiaim.vars.hidden_yaw = antiaim.vars.hidden_yaw - 360 end
            if antiaim.vars.hidden_yaw < -180 then antiaim.vars.hidden_yaw = antiaim.vars.hidden_yaw + 360 end
        elseif UI.get("aa_hidden_yaw_" .. condition) == "Jitter" then
            if antiaim.vars.hidden_yaw == 70 then
                antiaim.vars.hidden_yaw = -70
                rage.antiaim:override_hidden_yaw_offset(-70)
            else
                antiaim.vars.hidden_yaw = 70
                rage.antiaim:override_hidden_yaw_offset(70)
            end
        end
    end

    antiaim.vars._data = _data
    _setvalues(_data)
end


-- FAKE-LAG
fakelag.vars = {
    _data = {
        switch = false,
        limit = 1,
        variability = 0,
    },
    disable_tick = 0,
}

fakelag.createmove = function (cmd)
    if not UI.get("fl_switch") then return end
    local condition = UI.get("fl_override_" .. gvars.player_condition) and gvars.player_condition or "Default"

    local function _setvalues(teb)
        refs.antiaim.fakelag.switch:override(teb.switch)
        refs.antiaim.fakelag.limit:override(teb.limit)
        refs.antiaim.fakelag.variability:override(teb.variability)
    end

    local _data = fakelag.vars._data
    _data.switch = true
    if UI.get("fl_mode_" .. condition) == "Default" then
        _data.limit = UI.get("fl_limit_" .. condition)
        _data.variability = UI.get("fl_variability_" .. condition)
    elseif UI.get("fl_mode_" .. condition) == "Random" then
        _data.variability = 0
        if cmd.tickcount % UI.get("fl_tick_" .. condition) == 0 then
            _data.limit = math.random(UI.get("fl_min_" .. condition), UI.get("fl_max_" .. condition))
        end
    elseif UI.get("fl_mode_" .. condition) == "Jitter" then
        _data.variability = 0
        if cmd.tickcount % UI.get("fl_tick_" .. condition) == 0 then
            if _data.limit == UI.get("fl_min_" .. condition) then
                _data.limit = UI.get("fl_max_" .. condition)
            else
                _data.limit = UI.get("fl_min_" .. condition)
            end
        end
    elseif UI.get("fl_mode_" .. condition) == "Fluctuate" then
        _data.variability = 0
        if cmd.tickcount % UI.get("fl_tick_" .. condition) == 0 then
            _data.limit = _data.limit + 1
            if _data.limit > UI.get("fl_max_" .. condition) then
                _data.limit = UI.get("fl_min_" .. condition)
            end
        end
    end

    if fakelag.vars.disable_tick > 0 then
        fakelag.vars.disable_tick = fakelag.vars.disable_tick - 1
        _data.switch = false
    end

    fakelag.vars._data = _data
    _setvalues(_data)
end

fakelag.aim_fire = function ()
    if UI.get("fl_fix_" .. gvars.player_condition) and UI.get("fl_fix_method_" .. gvars.player_condition) == "Fire" then
        fakelag.vars.disable_tick = 2
    end
end

fakelag.weapon_fire = function (info)
    if info.userid ~= entity.get_local_player():get_player_info().userid then return end
    if UI.get("fl_fix_" .. gvars.player_condition) and UI.get("fl_fix_method_" .. gvars.player_condition) == "Ack" then
        fakelag.vars.disable_tick = 2
    end
end




-- VISUALS -> MISC
visual.misc = {}

visual.misc.func = function ()
    if UI.get("visual_gsmenu") then
        local Menu = {
            Pos = ui.get_position() - vector(3, 3),
            Size = ui.get_size() + vector(3, 3),
        };
        local Color1 = color(96,227,231);
        local Color2 = color(130,0,150);
        if ui.get_alpha() > 0.3 then
            render.rect(Menu.Pos - vector(6, 6), Menu.Pos + Menu.Size + vector(3, 3) + vector(6, 6), color("0A0A0AFF"));
            render.rect(Menu.Pos - vector(5, 5), Menu.Pos + Menu.Size + vector(3, 3) + vector(5, 5), color("3C3C3CFF"));
            render.rect(Menu.Pos - vector(4, 4), Menu.Pos + Menu.Size + vector(3, 3) + vector(4, 4), color("282828FF"));
            render.rect(Menu.Pos - vector(1, 1), Menu.Pos + Menu.Size + vector(3, 3) + vector(1, 1), color("3C3C3CFF"));
            render.rect(Menu.Pos, Menu.Pos + Menu.Size + vector(3, 3), color("141414FF"));
            render.gradient(Menu.Pos + vector(1, 1), Menu.Pos + vector(Menu.Size.x, 0) + vector(1, 2), Color1, Color2, Color1, Color2);
        end
    end
end





-- MISC -> LOGS
misc.logs = {}

misc.logs.defs = {
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
                ["hit"] = "\x01 \x06[EXPENSIVE]\x01 击中\x01 \x06%s\x01 的\x01 \x06%s\x01 伤害\x01 \x06%i(%i)\x01 剩余\x01 \x06%i\x01 命中率\x01 \x06%i\x01",
                ["miss"] = "\x01 \x07[EXPENSIVE]\x01 空了\x01 \x07%s\x01 的\x01 \x07%s\x01 原因\x01 \x07%s\x01 命中率\x01 \x07%i\x01 回溯\x01 \x07%i\x01",
            },

            ["Console"] = {
                ["hit"] = "\a90ED89[EXPENSIVE]\aFFFFFF 击中 \a90ED89%s\aFFFFFF 的 \a90ED89%s\aFFFFFF 伤害 \a90ED89%i(%i)\aFFFFFF 剩余 \a90ED89%i\aFFFFFF 命中率 \a90ED89%i\aFFFFFF 回溯 \a90ED89%i",
                ["miss"] = "\aFF0000[EXPENSIVE]\aFFFFFF 空了 \aFF0000%s\aFFFFFF 的 \aFF0000%s\aFFFFFF 原因 \aFF0000%s\aFFFFFF 命中率 \aFF0000%i\aFFFFFF 回溯 \aFF0000%i",
            },

            ["Screen"] = {
                ["hit"] = "击中 %s 的 %s 伤害 %i(%i) 剩余 %i 命中率 %i",
                ["miss"] = "空了 %s 的 %s 原因 %s 命中率 %i 回溯 %i",
            },
        },

        ["en_US"] = {
            ["Chat"] = {
                ["hit"] = "\x01 \x06[EXPENSIVE]\x01 Fired at\x01 \x06%s\x01's\x01 \x06%s\x01 dmg\x01 \x06%i(%i)\x01 remaining\x01 \x06%i\x01 hc\x01 \x06%i\x01",
                ["miss"] = "\x01 \x07[EXPENSIVE]\x01 Miss\x01 \x07%s\x01's\x01 \x07%s\x01 due to\x01 \x07%s\x01 hc\x01 \x07%i\x01 bt\x01 \x07%i\x01",
            },

            ["Console"] = {
                ["hit"] = "\a90ED89[EXPENSIVE]\aFFFFFF Fired at \a90ED89%s\aFFFFFF's \a90ED89%s\aFFFFFF dmg \a90ED89%i(%i)\aFFFFFF remaining \a90ED89%i\aFFFFFF hc \a90ED89%i\aFFFFFF bt \a90ED89%i",
                ["miss"] = "\aFF0000[EXPENSIVE]\aFFFFFF Miss \aFF0000%s\aFFFFFF's \aFF0000%s\aFFFFFF due to \aFF0000%s\aFFFFFF hc \aFF0000%i\aFFFFFF bt \aFF0000%i\aFFFFFF",
            },

            ["Screen"] = {
                ["hit"] = "Fired at %s's %s dmg %i(%i) remaining %i hc %i",
                ["miss"] = "Miss %s's %s due to %s hc %i bt %i",
            },
        },
    },

    missreason = {
        ["spread"] = "扩散",
        ["correction"] = "解析修正",
        ["misprediction"] = "预判错误",
        ["prediction error"] = "预判失败",
        ["backtrack failure"] = "回溯失败",
        ["damage rejection"] = "伤害被回收",
        ["unregistered shot"] = "未注册射击",
        ["player death"] = "目标死亡",
        ["death"] = "死亡",
    },
}

misc.logs.aim_ack = function (info)
    if not info.target then return end
    -- local language = UI.get("log_language")
    local language = UI.get("log_language") == "English" and "en_US" or "zh_CN"
    if info.state and UI.get("miss_log") then
        local name = info.target:get_name()
        local wanted_hitgroup = misc.logs.defs.hitgroups[language][info.wanted_hitgroup]
        local state = language == "en_US" and info.state or misc.logs.defs.missreason[info.state]
        local hitchance = info.hitchance
        local backtrack = info.backtrack
        if UI.contains("log_style", "Chat") then
            printchat(string.format(misc.logs.defs.hitlogstr[language]["Chat"]["miss"], name, wanted_hitgroup, state, hitchance, backtrack))
        end
        if UI.contains("log_style", "Event") then
            common.add_event(string.format(misc.logs.defs.hitlogstr[language]["Screen"]["miss"], name, wanted_hitgroup, state, hitchance, backtrack))
        end
        if UI.contains("log_style", "Console") then
            printraw(string.format(misc.logs.defs.hitlogstr[language]["Console"]["miss"], name, wanted_hitgroup, state, hitchance, backtrack))
        end
    elseif not info.state and UI.get("hit_log") then
        local name = info.target:get_name()
        local hitgroups = misc.logs.defs.hitgroups[language][info.hitgroup]
        local damage = info.damage
        local wanted_damage = info.wanted_damage
        local remaining = info.target.m_iHealth
        local hitchance = info.hitchance
        local backtrack = info.backtrack
        if UI.contains("log_style", "Chat") then
            printchat(string.format(misc.logs.defs.hitlogstr[language]["Chat"]["hit"], name, hitgroups, damage, wanted_damage, remaining, hitchance))
        end
        if UI.contains("log_style", "Event") then
            common.add_event(string.format(misc.logs.defs.hitlogstr[language]["Screen"]["hit"], name, hitgroups, damage, wanted_damage, remaining, hitchance, backtrack))
        end
        if UI.contains("log_style", "Console") then
            printraw(string.format(misc.logs.defs.hitlogstr[language]["Console"]["hit"], name, hitgroups, damage, wanted_damage, remaining, hitchance, backtrack))
        end
    end
end




-- REGS DEFINITION
regs.createmove = function (cmd)
    gvars.funs.update_sim()
    gvars.funs.update_player_condition(cmd)
    antiaim.createmove(cmd)
    fakelag.createmove(cmd)
end

regs.render = function ()
    (function ()
        funs.gradientsidebar(166, 192, 254, 255, 224, 195, 252, 255, "Expensive", "sack-dollar")
    end)() -- gradient sidebar
    visual.misc.func()
end

regs.aim_ack = function (info)
    misc.logs.aim_ack(info)
end

regs.aim_fire = function ()
    fakelag.aim_fire()
end

regs.weapon_fire = function (info)
    fakelag.weapon_fire(info)
end

regs.shutdown = function ()
    for _, unhookFunction in ipairs(ffi_hemeers.vmt_hook.hooks) do
		unhookFunction()
	end

	for _, free in ipairs(ffi_hemeers.buff.free) do
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




localize_str = {
    ["TAB SELECTION"] = "选项",
    ["General"] = "全局",
    ["RageBot"] = "暴力",
    ["AntiAim"] = "反自瞄",
    ["FakeLag"] = "假卡",
    ["Visual"] = "视觉",
    ["Misc"] = "杂项",
    ["                         DISCORD SERVER                         "] = "                      加入我的不和谐服务器                      ",
    ["Enable Anti-Aim"] = "开启反自瞄",
    ["Manual AA"] = "反自瞄方向",
    ["Body Yaw Inverter"] = "切换假身方向",
    ["Current Condition"] = "玩家状态",
}




for event, element in pairs(regs) do
    events[tostring(event)]:set(element)
end


for o, t in pairs(localize_str) do
    ui.localize("cn", o, t)
end















--------------------------------------------------------Trash--------------------------------------------------------


-- UI - GENERAL
-- UI.push(ui_groups.general:button("                       Load Default Config                       ", function ()
    
-- end), "cfg_load_default", nil, {function ()
--     return UI.get("root_combo") == "General"
-- end})
-- UI.push(ui_groups.general:button("                    Import From Clipboard                    ", function ()
    
-- end), "cfg_import", nil, {function ()
--     return UI.get("root_combo") == "General"
-- end})
-- UI.push(ui_groups.general:button("                       Export To Clipboard                       ", function ()
    
-- end), "cfg_export", nil, {function ()
--     return UI.get("root_combo") == "General"
-- end})

-- local ui_create, ui_find, utils_create_interface, files_write, files_read, printdev, printraw, printchat, entity_get_local_player, utils_console_exec, render_load_image_from_file, common_add_notify, common_get_username, render_texture, render_world_to_screen , is_button_down, render_screen_size, render_load_font, render_text, render_poly_blur, utils_execute_after, render_circle_outline, entity_get_game_rules, render_gradient, render_measure_text, rage_exploit, ui_get_icon, files_get_crc32, ui_get_ameha, common_reload_script, files_create_folder, utils_random_int, entity_get_players, utils_net_channel, utils_get_vfunc, bit_band, bit_lshift, entity_get, entity_get_entities, render_camera_angles, common_get_unixtime, network_get, common_get_system_time, render_load_image, panorama = ui.create, ui.find, utils.create_interface, files.write, files.read, print_dev, print_raw, print_chat, entity.get_local_player, utils.console_exec, render.load_image_from_file, common.add_notify, common.get_username, render.texture, render.world_to_screen, common.is_button_down, render.screen_size, render.load_font, render.text, render.poly_blur, utils.execute_after, render.circle_outline, entity.get_game_rules, render.gradient, render.measure_text, rage.exploit, ui.get_icon, files.get_crc32, ui.get_ameha, common.reload_script, files.create_folder, utils.random_int, entity.get_players, utils.net_channel, utils.get_vfunc, bit.band, bit.lshift, entity.get, entity.get_entities, render.camera_angles, common.get_unixtime, network.get, common.get_system_time, render.load_image, panorama