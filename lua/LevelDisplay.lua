local show_person_joining_original = MenuManager.show_person_joining
function MenuManager:show_person_joining( id, nick, ... )
	local peer = managers.network:session():peer(id)
	if peer and EIVHUD.Options:GetValue("HUD/LevelDisplay") then
		local level_string, _ = managers.experience:gui_string(peer:level(), peer:rank())
		nick = "(" .. level_string .. ") " .. nick
	end
	return show_person_joining_original(self, id, nick, ...)
end