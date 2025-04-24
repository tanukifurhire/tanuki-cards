--Fenrir, Challenger Fur Hire
--Tanuki Fur Hire
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	--Special summon procedure
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetValue(SUMMON_TYPE_LINK)
	e3:SetCondition(s.sprcon)
	e3:SetTarget(s.sprtg)
	e3:SetOperation(s.sprop)
	c:RegisterEffect(e3)
end
s.listed_series={0x114}
s.listed_names={66023650}, {id}

function s.linkfilter(c,e,tp)
	return c:IsSetCard(0x114) and c:IsFaceup()
end

function s.sprfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsCode(66023650) and c:IsFaceup()
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	local rg2=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_MZONE,0,nil)
	return #rg>0 and #rg2>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0) and aux.SelectUnselectGroup(rg2,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	local rg2=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	local g2=aux.SelectUnselectGroup(rg2,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	AddCard(g, g2)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
end
