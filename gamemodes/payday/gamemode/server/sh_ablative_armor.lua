hook.Add("EntityTakeDamage", "ZAblativeArmor", function(ent, dmg)
    if dmg:GetDamage() == DMG_DIRECT then return end

    if ent:IsPlayer() then
        local d = dmg:GetDamage()
        if ent:Armor() >= d then
            ent:SetArmor(ent:Armor() - d)
            return true
        elseif ent:Armor() > 0 then
            dmg:SetDamage(d - ent:Armor())
            ent:SetArmor(0)
            ent:TakeDamageInfo(dmg)
            return true
        end
    end
end)