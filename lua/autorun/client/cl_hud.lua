local hide = {
	["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudCrosshair"] = true,
}

hook.Add( "HUDShouldDraw", "HUD_HL2:HUDShouldDraw", function( name )
    if ( hide[ name ] ) and not HL2_HUD.Disabled[ "HUD" ] then return false end

    if not HL2_HUD.Disabled[ "WeaponSelector" ] and name == "CHudWeaponSelection" then return false end
end )

surface.CreateFont( "HUD:HL2", {
    font = "HalfLife2",
    size = ScreenScale( 20 )
})

surface.CreateFont( "HUD:HL2_Small", {
    font = "HalfLife2",
    size = ScreenScale( 12 )
})

surface.CreateFont( "HUD:Text", {
    font = "Verdana",
    size = ScreenScale( 12 ),
    weight = 900
})

surface.CreateFont( "HUD:3D2D", {
    font = "Verdana",
    size = 50
})

local ammo_logo = {
    ["357"] = "p",
    ["Pistol"] = "q",
    ["SMG1"] = "r",
    ["Buckshot"] = "s",
    ["SMG1_Grenade"] = "t",
    ["AR2"] = "u",
    ["Grenade"] = "v",
    ["XBowBolt"] = "w",
    ["RPG_Round"] = "x",
    ["AR2AltFire"] = "z",
}

local health, armor, money = 0, 0, 0
local mat = Material( "vgui/avatar_default" )

hook.Add( "HUDPaint", "HUD_HL2:HUDPaint", function()
    if HL2_HUD.Disabled[ "HUD" ] then return end

    local w, h = ScrW(), ScrH()
    local ply = LocalPlayer()
    local swep = ply:GetActiveWeapon()

    surface.SetFont( "HUD:HL2" )

    if not ply or not ply:IsValid() or not ply:Alive() then return end
    -- Health
    local health_w, health_h = surface.GetTextSize( "+ 100" )
    if health ~= ply:Health() then
        health = Lerp( FrameTime() * 2, health, ply:Health() )
    end
    draw.RoundedBox( 20, 5, h - health_h - 15, health_w + 20, health_h + 10, HL2_HUD.Colors.back )
    draw.SimpleText( "+ " .. math.Round( health ), "HUD:HL2", 15, h - health_h/2 - 12.5, HL2_HUD.Colors.main, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

    -- Armor
    local armor_w, armor_h = surface.GetTextSize( "* 100" )
    if armor ~= ply:Armor() then
        armor = Lerp( FrameTime() * 2, armor, ply:Armor() )
    end
    if math.Round( armor ) > 0 then
        draw.RoundedBox( 20, health_w + 30, h - armor_h - 15, armor_w + 20, armor_h + 10, HL2_HUD.Colors.back )
        draw.SimpleText( "* " .. math.Round( armor ), "HUD:HL2", 40 + health_w, h - armor_h/2 - 12.5, HL2_HUD.Colors.main, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    end

    if not swep or not swep:IsValid() then return end

    if swep.DrawCrosshair or not swep:IsScripted() then
        draw.SimpleText( "O", "HUD:HL2", w/2, h/2, HL2_HUD.Colors.main, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    local clip1_w, clip1_h = 0, 0
    -- Clip1
    if swep:GetClass() ~= "weapon_physcannon" and swep:Clip1() and swep:Clip1() >= 0 then
        local ammo_type = game.GetAmmoName( swep:GetPrimaryAmmoType() )
        clip1_w, clip1_h = surface.GetTextSize( swep:Clip1() .. " " .. ( ammo_logo[ ammo_type ] or "" ) )

        draw.RoundedBox( 20, w - clip1_w - 65, h - clip1_h - 15, clip1_w + 60, clip1_h + 10, HL2_HUD.Colors.back )
        draw.SimpleText( swep:Clip1() .. " " .. ( ammo_logo[ ammo_type ] or "" ), "HUD:HL2", w - 10, h - clip1_h/2 - 12.5, HL2_HUD.Colors.main, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    
        local ammo = LocalPlayer():GetAmmoCount( swep:GetPrimaryAmmoType() )

        surface.SetFont( "HUD:HL2_Small" )
        local ammo_w, ammo_h = surface.GetTextSize( ammo )
        
        draw.RoundedBox( 8, w - clip1_w - ammo_w - 80, h - ammo_h - 15, ammo_w + 10, ammo_h + 10, HL2_HUD.Colors.back )
        draw.SimpleText( ammo, "HUD:HL2_Small", w - clip1_w - 75, h - ammo_h/2 - 12.5, HL2_HUD.Colors.main, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    end

    -- Clip2
    local ammo_type = game.GetAmmoName( swep:GetSecondaryAmmoType() )

    surface.SetFont( "HUD:HL2" )
    if swep:IsScripted() then
        if swep:Clip2() and swep:Clip2() >= 0 and ammo_type then
            local clip2_w, clip2_h = surface.GetTextSize( swep:Clip2() .. " " .. ( ammo_logo[ ammo_type ] or "" ) )
            draw.RoundedBox( 20, w - clip2_w - 35, h - clip2_h*2 - 30, clip2_w + 30, clip2_h + 10, HL2_HUD.Colors.back )
            draw.SimpleText( swep:Clip2() .. " " .. ( ammo_logo[ ammo_type ] or "" ), "HUD:HL2", w - 10, h - clip1_h - 25 - clip2_h/2, HL2_HUD.Colors.main, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
        end
    else
        if ammo_type then
            local clip2_w, clip2_h = surface.GetTextSize( ply:GetAmmoCount( ammo_type ) .. " " .. ( ammo_logo[ ammo_type ] or "" ) )
            draw.RoundedBox( 20, w - clip2_w - 35, h - clip2_h*2 - 30, clip2_w + 30, clip2_h + 10, HL2_HUD.Colors.back )
            draw.SimpleText( ply:GetAmmoCount( ammo_type ) .. " " .. ( ammo_logo[ ammo_type ] or "" ), "HUD:HL2", w - 10, h - clip1_h - 27.5 - clip2_h/2, HL2_HUD.Colors.main, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
        end
    end
    
    --  > Voice icon
    if LocalPlayer():IsSpeaking() then 
        draw.SimpleText( "Z", "HUD:HL2", health_w + 30 + (armor >= 0.5 and armor_w + 25 or 0), h - 15 - health_h / 2, HL2_HUD.Colors.main, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    --  Money
    local money_w, money_h = 0, -15
    if not HL2_HUD.Disabled[ "Money" ] then
        if money ~= ply:Health() then
            money = Lerp( FrameTime() * 2, money, ply:getDarkRPVar( "money" ) )
        end

        surface.SetFont( "HUD:Text" )
        local money_text = engine.ActiveGamemode() == "darkrp" and DarkRP.formatMoney( math.Round( money ) ) or "0 Tokens"
        money_w, money_h = surface.GetTextSize( money_text )

        draw.RoundedBox( 20, 5, h - health_h - money_h - 30, money_w + 20, money_h + 10, HL2_HUD.Colors.back )
        draw.SimpleText( money_text, "HUD:Text", 15, h - health_h - money_h / 2 - 27.5, HL2_HUD.Colors.main, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    end

    --  Name
    if not HL2_HUD.Disabled[ "Name" ] then
        surface.SetFont( "HUD:Text" )
        local name = ply:Name()
        local name_w, name_h = surface.GetTextSize( name )

        draw.RoundedBox( 20, 5, h - health_h - money_h - name_h - 45, name_w + 20, name_h + 10, HL2_HUD.Colors.back )
        draw.SimpleText( name, "HUD:Text", 15, h - health_h - money_h - name_h / 2 - 42.5, HL2_HUD.Colors.main, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    end
end )

hook.Add( "PostPlayerDraw", "HUD_HL2:PostPlayerDraw", function( ply )
    if HL2_HUD.Disabled[ "OverHead" ] then return end

    if ply:GetPos():DistToSqr( LocalPlayer():GetPos() ) > 10^5.5 or ply == LocalPlayer() then return end
    
    local ang = ply:GetAngles()
    ang:RotateAroundAxis( ang:Forward(), 90 )
    ang.y = LocalPlayer():EyeAngles().y - 90
    
    local pos = ply:GetPos() + ply:GetUp() * 80

    local text = ply:Name() .. (ply:IsSpeaking() and " •" or "" )

    surface.SetFont( "HUD:3D2D" )
    local w, h = surface.GetTextSize( text )

    cam.Start3D2D( pos, ang, .12 )
        draw.RoundedBox( 29, -w/2, 0, w + 20, h + 10, HL2_HUD.Colors.back )
        draw.SimpleText( text, "HUD:3D2D", 10, h/2 + 5, HL2_HUD.Colors.main, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    cam.End3D2D()
end )

local function DisplayNotify( msg )
    local txt = msg:ReadString()
    GAMEMODE:AddNotify( txt, msg:ReadShort(), msg:ReadLong() )
    surface.PlaySound( "buttons/lightswitch2.wav" )

    MsgC( Color(255, 20, 20, 255), "[DarkRP] ", Color(200, 200, 200, 255), txt, "\n" )
end
usermessage.Hook( "_Notify", DisplayNotify )