local function get_room_at_location(shipManager, location, includeWalls)
	return Hyperspace.ShipGraph.GetShipInfo(shipManager.iShipId):GetSelectedRoom(location.x, location.y, includeWalls)
end

local function worldToPlayerLocation(location)
	local cApp = Hyperspace.App
	local combatControl = cApp.gui.combatControl
	local playerPosition = combatControl.playerShipPosition
	return Hyperspace.Point(location.x - playerPosition.x, location.y - playerPosition.y)
end

local randomStart = {on = Hyperspace.Resources:CreateImagePrimitiveString("bg_rss_toggle.png", 0, 0, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false),
	hover = Hyperspace.Resources:CreateImagePrimitiveString("bg_rss_toggle_hover.png", 0, 0, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false)}
local randomStartActive = {on = Hyperspace.Resources:CreateImagePrimitiveString("bg_rss_toggle_active.png", 0, 0, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false),
	hover = Hyperspace.Resources:CreateImagePrimitiveString("bg_rss_toggle_active_hover.png", 0, 0, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false)}

local atStartBeacon = false
script.on_game_event("START_BEACON_PREP_LOAD", false, function()
	atStartBeacon = true
end)

local buttonRect = {x = 351, y = 0, w = 312, h = 447}
local jumpRect = {x = 530, y = 28, w = 86, h = 43}
local shipRect = {x = 631, y = 28, w = 62, h = 43}

local function checkMouseHover(mousePos, rect)
	return mousePos.x >= rect.x and mousePos.x < (rect.x + rect.w) and mousePos.y >= rect.y and mousePos.y < (rect.y + rect.h)
end

local hover = false
script.on_render_event(Defines.RenderEvents.LAYER_BACKGROUND, function() end, function()
	if atStartBeacon then
		hover = false
		local mousePos = Hyperspace.Mouse.position
		local commandGui = Hyperspace.App.gui
		if checkMouseHover(mousePos, buttonRect) and (get_room_at_location(Hyperspace.ships.player, worldToPlayerLocation(mousePos), true ) < 0) and (not checkMouseHover(mousePos, jumpRect)) and (not checkMouseHover(mousePos, shipRect)) and (not (commandGui.event_pause or commandGui.menu_pause)) then
			hover = true
		end
		if hover and Hyperspace.metaVariables.rss_active == 1 then
			Hyperspace.Mouse.tooltip = "Toggle Random Starting Sector: On -> Off."
			Graphics.CSurface.GL_PushMatrix()
			Graphics.CSurface.GL_Translate(buttonRect.x, buttonRect.y, 0)
			Graphics.CSurface.GL_RenderPrimitive(randomStartActive.hover)
			Graphics.CSurface.GL_PopMatrix()
		elseif hover then
			Hyperspace.Mouse.tooltip = "Toggle Random Starting Sector: Off -> On."
			Graphics.CSurface.GL_PushMatrix()
			Graphics.CSurface.GL_Translate(buttonRect.x, buttonRect.y, 0)
			Graphics.CSurface.GL_RenderPrimitive(randomStart.hover)
			Graphics.CSurface.GL_PopMatrix()
		elseif Hyperspace.metaVariables.rss_active == 1 then
			Graphics.CSurface.GL_PushMatrix()
			Graphics.CSurface.GL_Translate(buttonRect.x, buttonRect.y, 0)
			Graphics.CSurface.GL_RenderPrimitive(randomStartActive.on)
			Graphics.CSurface.GL_PopMatrix()
		else
			Graphics.CSurface.GL_PushMatrix()
			Graphics.CSurface.GL_Translate(buttonRect.x, buttonRect.y, 0)
			Graphics.CSurface.GL_RenderPrimitive(randomStart.on)
			Graphics.CSurface.GL_PopMatrix()
		end
	end
end)

script.on_internal_event(Defines.InternalEvents.ON_MOUSE_L_BUTTON_DOWN, function(x,y)
	if atStartBeacon then
		local worldManager = Hyperspace.App.world
		if hover and Hyperspace.metaVariables.rss_active == 1 then
			Hyperspace.CustomEventsParser.GetInstance():LoadEvent(worldManager,"RSS_TOGGLE_OFF",false,-1)
		elseif hover then
			Hyperspace.CustomEventsParser.GetInstance():LoadEvent(worldManager,"RSS_TOGGLE_ON",false,-1)
		end
	end
	return Defines.Chain.CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.JUMP_ARRIVE, function(shipManager)
	local map = Hyperspace.App.world.starMap
	if atStartBeacon then
		atStartBeacon = false
		if map.bOpen then map.bOpen = false end
	end
end)