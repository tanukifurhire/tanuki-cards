--Gren, High Tactician of Dark World
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,nil)
	--cannot be effect target
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetValue(aux.tgoval)
	c:RegisterEffect(e0)
	--change atk target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.ctcon)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(s.sdcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--copy name and atk
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.copytg)
	e3:SetOperation(s.copyop)
	c:RegisterEffect(e3)
end
s.listed_series={0x6}
s.listed_names={51232472}, {id}

function s.sdcon(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	local g=c:GetMaterial()
	return g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_LINK,tp,51232472) or g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_LINK,tp,id)
end
	
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x6,lc,sumtype,tp) 
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x6) and c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_GRAVE)
end
function s.sfilter(c,e,tp)
	return c:IsSetCard(0x6) and c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
end

function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,c)
end
function s.copyop(e,tp,eg,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_GRAVE) then
		local code=tc:GetOriginalCode()
		local atk=tc:GetAttack()
		if atk<0 then atk=0 end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(atk)
		c:RegisterEffect(e2)
	end
end

function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bt=eg:GetFirst()
	local g=c:GetMaterial()
	return r~=REASON_REPLACE and bt~=e:GetHandler() and bt:IsControler(tp) and (g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_LINK,tp,51232472) or g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_LINK,tp,id))
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.sfilter,tp,0,LOCATION_MZONE,1,nil)
	end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local at=Duel.GetAttacker()
		if at:CanAttack() and not at:IsImmuneToEffect(e) and not c:IsImmuneToEffect(e) then
			local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_MZONE,0,1,nil)
				if #g>0 then local tg=g:GetMinGroup(Card.GetAttack)
					if #tg>1 then
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
						local sg=tg:Select(tp,1,1,nil)
						Duel.HintSelection(sg)
						local atk=sg:GetAttack()
						if atk<0 then atk = 0 end
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
						e1:SetCode(EFFECT_UPDATE_ATTACK)
						e1:SetValue(atk)
						c:RegisterEffect(e1)
					else 
						local atk=tg:GetAttack()
						if atk<0 then atk=0 end
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
						e1:SetCode(EFFECT_UPDATE_ATTACK)
						e1:SetValue(atk)
						c:RegisterEffect(e1)
					end
				end
			Duel.CalculateDamage(at,c)
		end
	end
end		


