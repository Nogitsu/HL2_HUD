if HL2_HUD.Disabled[ "DeathNotices" ] then return end

surface.CreateFont( "HUD:Death", {
    font = "Verdana",
    size = ScreenScale( 7 ),
    weight = 900
})

local Deaths, LastDeath = {}, 0
local reasons = {
    ["suicide"] = "%victim% committed a suicide.",
    ["worldspawn"] = "%victim% tried to fly.",
    ["prop_physics"] = "%victim% tasted a prop.",
    ["prop_vehicle_jeep"] = "%victim% didn't look before crossing the road."
}

local function FormatDeath( attacker, inflictor, victim )
    local reason = reasons[ inflictor ] or "%victim% died in mysterious circumstances."

    if list.Get( "Weapon" )[ inflictor ] then
        local name = list.Get( "Weapon" )[ inflictor ] and list.Get( "Weapon" )[ inflictor ].PrintName
        return ( language.GetPhrase( attacker ) or attacker ) .. " killed " .. victim .. " with " .. (name or inflictor)
    end

    return reason:Replace( "%attacker%", attacker ):Replace( "%inflictor%", inflictor ):Replace( "%victim%", victim )
end

hook.Add( "OnGamemodeLoaded", "HL2_HUD:AddDeathNotice", function()
    function GAMEMODE:AddDeathNotice( attacker, attackerTeam, inflictor, victim, victimTeam )
        local death = {}
        death.time 		= CurTime()
        death.text 		= FormatDeath( attacker, inflictor, victim )
        death.holdtime 	= 5
        death.font 		= "HUD:Death"
    
        surface.SetFont( death.font )
        local w, h = surface.GetTextSize( death.text )
        death.height = h + 10
        death.width = w + 20
        
        death.lastx = - death.width
        death.visualx = 15

        death.x = death.lastx
        death.y = 15
    
        if (LastDeath >= death.time) then
            death.time = LastDeath + 0.1
        end
    
        table.insert( Deaths, 1, death )
        LastDeath = death.time
    end
end )

hook.Add( "HUDPaint", "HL2_HUD:DeathNotices", function()
    if HL2_HUD.Disabled[ "DeathNotices" ] then return end

    for k, v in pairs( Deaths ) do
        local passed = CurTime() >= v.time + v.holdtime

        if passed then
            v.x = Lerp( FrameTime() * 3, v.x, v.lastx - 15 )
            if v.x <= v.lastx - 10 then
                Deaths[ k ] = nil
            end
        else
            v.x = Lerp( FrameTime() * 2, v.x, v.visualx )
        end

        local y = (v.height + 5) * (k - 1) + 15
        if v.y ~= y then
            v.y = Lerp( FrameTime() * 6, v.y, y )
        end
        
        draw.RoundedBox( 10, v.x, v.y, v.width, v.height, HL2_HUD.Colors.back )
        draw.SimpleText( v.text, v.font, v.x + v.width / 2, v.y + v.height / 2, HL2_HUD.Colors.main, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
end )

if GAMEMODE then
    function GAMEMODE:AddDeathNotice( attacker, attackerTeam, inflictor, victim, victimTeam )
        local death = {}
        death.time 		= CurTime()
        death.text 		= FormatDeath( attacker, inflictor, victim )
        death.holdtime 	= 5
        death.font 		= "HUD:Death"
    
        surface.SetFont( death.font )
        local w, h = surface.GetTextSize( death.text )
        death.height = h + 10
        death.width = w + 20
        
        death.lastx = - death.width
        death.visualx = 15

        death.x = death.lastx
        death.y = 15
    
        if (LastDeath >= death.time) then
            death.time = LastDeath + 0.1
        end
    
        table.insert( Deaths, 1, death )
        LastDeath = death.time
    end
end