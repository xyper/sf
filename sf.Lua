local shadowFiend = {}

shadowFiend.optionEnable = Menu.AddOption({"Hero Specific", "Shadow Fiend"}, "Enable Ult", "On/Off")
shadowFiend.optionWait = Menu.AddOption({"Hero Specific","Shadow Fiend"}, "Correct Ult", "ms", 10, 500, 10)
shadowFiend.optionComboKey = Menu.AddKeyOption({ "Hero Specific","Shadow Fiend"}, "Key COMBO", Enum.ButtonCode.KEY_T)
shadowFiend.optionWith = Menu.AddOption({"Hero Specific", "Shadow Fiend"}, "Use ult with: ", "Eul or RoA")
shadowFiend.optionBkb = Menu.AddOption({"Hero Specific", "Shadow Fiend"}, "Use BKB?", "On/Off")
shadowFiend.font = Renderer.LoadFont("Tahoma", 20, Enum.FontWeight.EXTRABOLD)

time = 0
lastcasttime = 0
wait_for_ult = 0.84
casttime = 0
bCombo = false
bWait_for_ult = false
local count = 0

function shadowFiend.OnUpdate()
	if not Menu.IsEnabled(shadowFiend.optionEnable) then return end
	local myHero = Heroes.GetLocal()
	Menu.SetValueName(shadowFiend.optionWith, 1, "RoA")
	Menu.SetValueName(shadowFiend.optionWith, 0, "EuL")
	if not Menu.IsKeyDown(shadowFiend.optionComboKey) then
		casttime = 0
		lastcasttime = 0
		bCombo = false
	end
	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_nevermore" or not Menu.IsKeyDown(shadowFiend.optionComboKey) then return end
	shadowFiendUlt(myHero)
end

function shadowFiendUlt(myHero)
	local blinkDagger = NPC.GetItem( myHero, "item_blink", true)
	local phase = NPC.GetItem( myHero, "item_phase_boots", true)
	local eul = NPC.GetItem( myHero, "item_cyclone", true)
	local BKB = NPC.GetItem( myHero, "item_black_king_bar", true)
	local RoA = NPC.GetItem( myHero, "item_rod_of_atos", true)
	local ultimate = NPC.GetAbilityByIndex(myHero, 5)
	local myMana = NPC.GetMana(myHero)
	
	if blinkDagger == nil or ultimate == nil or myMana == nil then return end
	
	local mousePos = Input.GetWorldCursorPos()
	local castRange = Ability.GetLevelSpecialValueFor(blinkDagger, "blink_range") - 1 --+ NPC.GetCastRangeBonus(myHero) - 1 
	local castRangeEul = 575 - 1-- + NPC.GetCastRangeBonus(myHero) - 1 
	local castRangeRoa = 1000 - 1-- + NPC.GetCastRangeBonus(myHero) - 1 
	local enemy = Input.GetNearestHeroToCursor( Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
	if enemy == nil then return end
	local pos_enemy = Entity.GetAbsOrigin(enemy)
	
	if NPC.IsPositionInRange(myHero, pos_enemy, castRange, 0) and Ability.IsCastable(ultimate, myMana) and not bCombo then
		if Menu.IsEnabled(shadowFiend.optionWith) then
			if RoA ~= nil and blinkDagger ~= nil and NPC.IsPositionInRange(myHero, pos_enemy, castRangeRoa, 0) then
				if Ability.IsCastable(blinkDagger, myMana) then
					if Ability.IsCastable(RoA, myMana) then
						Ability.CastTarget(RoA, enemy, true)
						casttime = os.clock() + 0.600 + NetChannel.GetAvgLatency (Enum.Flow.FLOW_OUTGOING)
					end
					if os.clock() >= casttime then
						if Menu.IsEnabled(shadowFiend.optionBkb) and BKB ~= nil then
							if Ability.IsCastable(BKB, myMana) then
								Ability.CastNoTarget(BKB,true)
							end
						end
						if phase ~= nil then
							if Ability.IsCastable(phase, myMana) then
								Ability.CastNoTarget(phase, true)
							end
						end
						Ability.CastPosition(blinkDagger, pos_enemy, true)
						Ability.CastNoTarget(ultimate, true)
						Log.Write("ROA: Use Atos")
						bCombo = true
					end
				end
				elseif blinkDagger ~= nil and RoA == nil then
					if Ability.IsCastable(blinkDagger, myMana) then
						if Menu.IsEnabled(shadowFiend.optionBkb) and BKB ~= nil then
							if Ability.IsCastable(BKB, myMana) then
								Ability.CastNoTarget(BKB,true)
							end
						end
						if phase ~= nil then
							if Ability.IsCastable(phase, myMana) then
								Ability.CastNoTarget(phase, true)
							end
						end
						Ability.CastPosition(blinkDagger, pos_enemy, true)
						Ability.CastNoTarget(ultimate, true)
						Log.Write("ROA: Only Blink")
						bCombo = true
					end
				end
		-- Eul
		elseif not Menu.IsEnabled(shadowFiend.optionWith) then
			if eul ~= nil and blinkDagger ~= nil then
				if Ability.IsCastable(blinkDagger, myMana) then
					if NPC.IsPositionInRange(myHero, pos_enemy, castRangeEul, 0) then
						if Ability.IsCastable(eul, myMana) then
							Ability.CastTarget(eul, enemy, true)
							lastcasttime = os.clock() + (Menu.GetValue(shadowFiend.optionWait)/1000) - NetChannel.GetAvgLatency (Enum.Flow.FLOW_OUTGOING)
							casttime = os.clock() + 0.100
							Log.Write("HAVE EUL (EUL FIRST)")
							Log.Write("Start eul: " .. os.clock()+2.500)
							Log.Write("Ping: " .. math.ceil(NetChannel.GetAvgLatency (Enum.Flow.FLOW_OUTGOING)))
						end
						if os.clock() >= casttime then
							if Menu.IsEnabled(shadowFiend.optionBkb) and BKB ~= nil then
								if Ability.IsCastable(BKB, myMana) then
									Ability.CastNoTarget(BKB,true)
								end
							end
							if phase ~= nil then
								if Ability.IsCastable(phase, myMana) then
									Ability.CastNoTarget(phase, true)
								end
							end
							Ability.CastPosition(blinkDagger, pos_enemy, true)
							Log.Write("Blink after Eul")
							bCombo = true
						end
					else
						if Ability.IsCastable(eul, myMana) then
							if Menu.IsEnabled(shadowFiend.optionBkb) and BKB ~= nil then
								if Ability.IsCastable(BKB, myMana) then
									Ability.CastNoTarget(BKB,true)
								end
							end
							if phase ~= nil then
								if Ability.IsCastable(phase, myMana) then
									Ability.CastNoTarget(phase, true)
								end
							end
							Ability.CastPosition(blinkDagger, pos_enemy, true)
							Ability.CastTarget(eul, enemy, true)
							lastcasttime = os.clock() + (Menu.GetValue(shadowFiend.optionWait)/1000) - NetChannel.GetAvgLatency (Enum.Flow.FLOW_OUTGOING)
							casttime = os.clock()
							Log.Write("HAVE EUL (BLINK FIRST)")
							Log.Write("Start eul: " .. os.clock()+2.500)
							Log.Write("Ping: " .. math.ceil(NetChannel.GetAvgLatency (Enum.Flow.FLOW_OUTGOING)))
							bCombo = true
						end
					end
				end
			elseif blinkDagger ~= nil and eul == nil then 
				if Ability.IsCastable(blinkDagger, myMana) then
					if Menu.IsEnabled(shadowFiend.optionBkb) and BKB ~= nil then
						if Ability.IsCastable(BKB, myMana) then
							Ability.CastNoTarget(BKB,true)
						end
					end
					if phase ~= nil then
						if Ability.IsCastable(phase, myMana) then
							Ability.CastNoTarget(phase, true)
						end
					end
					Ability.CastPosition(blinkDagger, pos_enemy, true)
					Ability.CastNoTarget(ultimate, true)
					Log.Write("EUL: Only Blink")
				end
			end
		end
	end

	if (os.clock() - lastcasttime) > wait_for_ult and (os.clock() - lastcasttime) < wait_for_ult + 0.300 and not bWait_for_ult then
		Log.Write("End eul: " .. os.clock()+1.670+casttime-lastcasttime)
		Ability.CastNoTarget(ultimate, true)
		bCombo = false
		bWait_for_ult = true
	elseif (os.clock() - lastcasttime) > wait_for_ult + 0.300 then
		bCombo = false
		bWait_for_ult = false
	end	
end

function shadowFiend.OnPrepareUnitOrders(orders)
	local myHero = Heroes.GetLocal()
	if NPC.GetUnitName(myHero) ~= orders.player then return true end
	
	--if bCombo then
		if orders.order == Enums.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION or orders.order == Enums.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET then
			return false
		end
	--end
end


return shadowFiend
