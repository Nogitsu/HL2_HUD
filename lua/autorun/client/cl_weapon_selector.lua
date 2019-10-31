surface.CreateFont( "HUD:WeaponSelector", {
    font = "Verdana",
    size = ScreenScale( 5 ),
    weight = 900
} )

local function GetSweps()
    local sweps, for_count = {}, {}
    local weaps = LocalPlayer():GetWeapons()

    table.sort( weaps, function( a, b )
        return a:GetPrintName() < b:GetPrintName()
    end )

    for _, swep in pairs( weaps ) do
        local slot = (swep.Slot or 0) + 1

        sweps[ slot ] = sweps[ slot ] or {}

        --table.insert( sweps[ slot ], (swep.SlotPos or 9) + 1, swep )
        local sweps_count = #sweps[ slot ]
        sweps[ slot ][ sweps_count + 1 ] = swep
    end

    for _, columns in pairs( sweps ) do
        for _, swep in pairs( columns ) do
            for_count[ #for_count + 1 ] = swep
        end
    end

    return sweps, for_count
end

local sweps, for_count = {}, {}
local last_selected, selected, open_time = nil, 0, 0

hook.Add( "PlayerBindPress", "HL2_HUD:SelectorNavigation", function( ply, bind, pressed )
    if HL2_HUD.Disabled[ "WeaponSelector" ] then return end
    if input.IsButtonDown( MOUSE_LEFT ) then return end -- Prevents switching on physgun use

    if bind == "invprev" then
        selected = selected - 1
        if selected < 0 then selected = #for_count - 1 end

        surface.PlaySound( "common/wpn_select.wav" )

        open_time = CurTime()
    elseif bind == "invnext" then
        selected = selected + 1
        if selected > #for_count - 1 then selected = 0 end

        surface.PlaySound( "common/wpn_select.wav" )

        open_time = CurTime()
    elseif bind == "lastinv" and last_selected then
        local last = LocalPlayer():GetActiveWeapon()

        input.SelectWeapon( last_selected )
        surface.PlaySound( "punchies/miss" .. math.random( 1, 2 ) .. ".mp3" )

        last_selected = last
    end
end )

hook.Add( "StartCommand", "HL2_HUD:SelectorConfirmation", function( ply, cmd )
    if HL2_HUD.Disabled[ "WeaponSelector" ] then return end

    if cmd:KeyDown( IN_ATTACK ) then
        if open_time + 2 < CurTime() or not LocalPlayer():Alive() then return end
        cmd:ClearButtons()

        surface.PlaySound( "common/wpn_hudoff.wav" )

        last_selected = ply:GetActiveWeapon()
        input.SelectWeapon( for_count[ selected + 1 ] )

        open_time = 0
    end
end )

hook.Add( "HUDPaint", "HL2_HUD:WeaponSelector", function()
    if HL2_HUD.Disabled[ "WeaponSelector" ] then return end
    if open_time + 2 < CurTime() or not LocalPlayer():Alive() then return end

    sweps, for_count = GetSweps()

    local w, h = 175, 30
    local y = 0

    for i = 0, 5 do
        draw.RoundedBox( 2, ScrW() / 2 - ( ( w + 10 ) * 6 / 2 ) + i * (w + 10), 15, w, 10, (for_count[ selected + 1 ] and for_count[ selected + 1 ].Slot or 0) == i and HL2_HUD.Colors.main or HL2_HUD.Colors.back )
    end

    local id = 0
    for x, columns in pairs( sweps ) do
        y = 0
        for _, swep in pairs( columns ) do
            local pos_x = ScrW() / 2 - ( ( w + 10 ) * 6 / 2 ) + (x - 1) * (w + 10)
            local pos_y = 30 + y * (h + 5)
            y = y + ( selected == id and 1 or 0.25 )

            local cur_h = ( selected == id and h or 5 )

            draw.RoundedBox( cur_h / 3, pos_x, pos_y, w, ( selected == id and cur_h or 5 ), HL2_HUD.Colors.back )

            if selected == id then
                draw.SimpleText( swep:GetPrintName(), "HUD:WeaponSelector", pos_x + w / 2, pos_y + cur_h / 2, HL2_HUD.Colors.main, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end

            id = id + 1
        end
    end
end )
