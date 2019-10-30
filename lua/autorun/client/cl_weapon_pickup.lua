surface.CreateFont( "HUD:WeaponPickUp", {
    font = "Verdana",
    size = ScreenScale( 8 )
})

local PickupHistory, PickupHistoryLast = {}, 0

hook.Add( "HUDItemPickedUp", "HL2_HUD:HUDItemPickedUp", function( name )
    if HL2_HUD.Disabled[ "PickUP" ] then return end
    if (!LocalPlayer():Alive()) then return end
 
	local pickup = {}
	pickup.time 		= CurTime()
	pickup.name 		= language.GetPhrase( name ) or name
	pickup.holdtime 	= 3
	pickup.font 		= "HUD:WeaponPickUp"
 
	surface.SetFont( pickup.font )
	local w, h = surface.GetTextSize( pickup.name )
	pickup.height		= h + 10
    pickup.width		= w + 20
    
    pickup.lastx = ScrW() + pickup.width
    pickup.visualx = ScrW() - pickup.width - 5

    pickup.x = pickup.lastx
    pickup.y = ScrH() / 3 + pickup.height + 5
 
    if (PickupHistoryLast >= pickup.time) then
		pickup.time = PickupHistoryLast + 0.1
    end
 
	table.insert( PickupHistory, 1, pickup )
    PickupHistoryLast = pickup.time
    
    return false
end )

hook.Add( "HUDAmmoPickedUp", "HL2_HUD:HUDAmmoPickedUp", function( name, amount )
    if HL2_HUD.Disabled[ "PickUP" ] then return end
    if (!LocalPlayer():Alive()) then return end
 
	local pickup = {}
	pickup.time 		= CurTime()
	pickup.name 		= amount .. "x " .. name
	pickup.holdtime 	= 3
	pickup.font 		= "HUD:WeaponPickUp"
 
	surface.SetFont( pickup.font )
	local w, h = surface.GetTextSize( pickup.name )
	pickup.height		= h + 10
    pickup.width		= w + 20
    
    pickup.lastx = ScrW() + pickup.width
    pickup.visualx = ScrW() - pickup.width - 5

    pickup.x = pickup.lastx
    pickup.y = ScrH() / 3 + pickup.height + 5
 
    if (PickupHistoryLast >= pickup.time) then
		pickup.time = PickupHistoryLast + 0.1
    end
 
	table.insert( PickupHistory, 1, pickup )
    PickupHistoryLast = pickup.time
    
    return false
end )

hook.Add( "HUDWeaponPickedUp", "HL2_HUD:HUDWeaponPickedUp", function( wep )
    if HL2_HUD.Disabled[ "PickUP" ] then return end
	if (!LocalPlayer():Alive()) then return end
 
	local pickup = {}
	pickup.time 		= CurTime()
	pickup.name 		= wep:GetPrintName()
	pickup.holdtime 	= 3
	pickup.font 		= "HUD:WeaponPickUp"
 
	surface.SetFont( pickup.font )
	local w, h = surface.GetTextSize( pickup.name )
	pickup.height		= h + 10
    pickup.width		= w + 20
    
    pickup.lastx = ScrW() + pickup.width
    pickup.visualx = ScrW() - pickup.width - 5

    pickup.x = pickup.lastx
    pickup.y = ScrH() / 3 + pickup.height + 5
 
    if (PickupHistoryLast >= pickup.time) then
		pickup.time = PickupHistoryLast + 0.1
    end
 
	table.insert( PickupHistory, 1, pickup )
    PickupHistoryLast = pickup.time
    
    return false
end )

hook.Add( "HUDPaint", "HL2_HUD:WeaponPickedUp", function()
    if HL2_HUD.Disabled[ "PickUP" ] then return end

    for k, v in pairs( PickupHistory ) do
        local passed = CurTime() >= v.time + v.holdtime

        if passed then
            v.x = Lerp( FrameTime(), v.x, v.lastx )
            if v.x >= v.lastx - 5 then
                PickupHistory[ k ] = nil
            end
        else
            v.x = Lerp( FrameTime()*5, v.x, v.visualx )
        end

        local y = ScrH() / 8 - (v.height + 5) * (k - 1)
        if v.y ~= y then
            v.y = Lerp( FrameTime()*6, v.y, y )
        end
        
        draw.RoundedBox( 10, v.x, v.y, v.width, v.height, HL2_HUD.Colors.back )
        draw.SimpleText( v.name, v.font, v.x + v.width / 2, v.y + v.height / 2, HL2_HUD.Colors.main, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
end)