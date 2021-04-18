function width(x)
 return x/1920*ScrW()
end

function height(y)
 return y/1080*ScrH()
end


if CLIENT then
    surface.CreateFont("timer_font",{font="Payday2",size=50,weight=800,antialias=true,italic=true,shadow=true} )
    surface.CreateFont("timer_font_text",{font="Payday2",size=35,weight=1000,antialias=true,italic=true,shadow=true} )

    function TimerDisplay()
        local timer_tab = string.FormattedTime( CurTime() - timertime)
        local timer_t = string.format("%02d:%02d:%02d", timer_tab.h, timer_tab.m, timer_tab.s)
        local offset = 0
        if LocalPlayer():GetNWBool("timer_text_offset") then offset = height(0.015) end
        draw.RoundedBox( 8, ScrW()/100*47.5,0, ScrW()/5,ScrH()/10, Color(48,48,48,95) )
        surface.SetDrawColor(24,24,24,127)
        surface.DrawOutlinedRect( width(0.475), 0 , width(0.2), height(0.1), 8 )
        draw.SimpleText( timer_t, "timer_font", width(0.51), height(0.025)-offset, Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
    end

end

hook.Add("HUDPaint","TimerPD2",TimerDisplay)