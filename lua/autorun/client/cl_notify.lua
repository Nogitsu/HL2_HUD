if HL2_HUD.Disabled[ "Notify" ] then return end

surface.CreateFont( "HUD:Notify", {
    font = "Verdana",
    size = ScreenScale( 5 ),
    weight = 900
})

local Notifs, LastNotif = {}, 0
hook.Add( "OnGamemodeLoaded", "HL2_HUD:AddNotify", function()
    function GAMEMODE:AddNotify( message, type, duration )
        local notif = {}
        notif.time 		= CurTime()
        notif.name 		= language.GetPhrase( message )
        notif.holdtime 	= duration
        notif.font 		= "HUD:Notify"
    
        surface.SetFont( notif.font )
        local w, h = surface.GetTextSize( notif.name )
        notif.height		= h + 10
        notif.width		= w + 20
        
        notif.lastx = ScrW() + notif.width
        notif.visualx = ScrW() - notif.width - 5

        notif.x = notif.lastx
        notif.y = ScrH() / 1.5 + notif.height + 5
    
        if (LastNotif >= notif.time) then
            notif.time = LastNotif + 0.1
        end
    
        table.insert( Notifs, 1, notif )
        LastNotif = notif.time
    end
end )

hook.Add( "HUDPaint", "HL2_HUD:Notify", function()
    if HL2_HUD.Disabled[ "Notify" ] then return end

    for k, v in pairs( Notifs ) do
        local passed = CurTime() >= v.time + v.holdtime

        if passed then
            v.x = Lerp( FrameTime(), v.x, v.lastx )
            if v.x >= v.lastx - 5 then
                Notifs[ k ] = nil
            end
        else
            v.x = Lerp( FrameTime()*5, v.x, v.visualx )
        end

        local y = ScrH() / 1.25 - (v.height + 5) * (k - 1)
        if v.y ~= y then
            v.y = Lerp( FrameTime()*6, v.y, y )
        end
        
        draw.RoundedBox( 10, v.x, v.y, v.width, v.height, HL2_HUD.Colors.back )
        draw.SimpleText( v.name, v.font, v.x + v.width / 2, v.y + v.height / 2, HL2_HUD.Colors.main, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
end)