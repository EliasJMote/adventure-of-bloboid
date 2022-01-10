pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- check if a map cell is solid
function solid(x,y)
	
	if(fget(mget(flr(x/8),flr(y/8)),0)) then
		return true
	end
	return false
end

-- check if the area is solid
function solid_area(x,y,w,h)
	return solid(x+w,y) or solid(x+w,y+h) or solid(x,y) or solid(x,y+h)
end

-- player keyboard commands
function player_controls(p)
	local spd = 1

	-- player horizontal movement
	if(btn(0) and p.x > 0) then
		p.dx = -spd
		p.dir = "left"
	elseif(btn(1)) then
		p.dx = spd
		p.dir = "right"
	else
		p.dx = 0
	end

	-- player jump
	if(btnp(5) and not p.is_jumping and not p.is_falling) then
		p.dy = -3.75
		p.is_jumping = true
		p.is_falling = false
	end

	if(p.is_jumping and not btn(5)) then
		p.dy = 0
		p.is_falling = true
	end

	return p
end

-- move the player, an npc or an enemy
function move_actor(act, is_solid)
	
	if(act.dy >= 0 and act.dy <= 0.3 and act.is_jumping) then
		act.is_jumping = false
		act.is_falling = true
	end

	-- gravity
	if(act.is_falling or act.is_jumping) then
		act.dy += 0.3
	end

	if(is_solid) then
		if not solid_area(act.x+act.dx,act.y,act.w,act.h) then
			act.x += act.dx
		else
			act.dx = 0
		end

		if not solid_area(act.x,act.y+act.dy,act.w,act.h) then
			act.y += act.dy
		else
			act.dy = 0
			if(act.is_falling) then
				act.is_falling = false

				-- temporary fix for ground blocks only. will need to use the solid block's y value later
				act.y = 112

				-- buggy. player sometimes moves through floor
				--act.y = act.y+act.dy - ((act.y+act.dy) % 8) + 8

				--[[else
					act.is_falling = true]]
			end
		end
	else
		act.x += act.dx
		act.y += act.dy
	end

	return act
end