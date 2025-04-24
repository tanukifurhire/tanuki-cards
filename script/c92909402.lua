--Fenrir, Challenger Fur Hire
--Tanuki Fur Hire
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
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

function s.spfilter(c,e,tp,zone)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetLinkedZone(tp)) or Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,c:GetLinkedZone(1-tp)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	local enemyzone=c:GetLinkedZone(1-tp)

	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	local eft=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,enemyzone)

	Debug.Message(ft)
	Debug.Message(eft)

	if c:IsRelateToEffect(e) and c:IsFaceup() and (zone>0 or enemyzone>0) and (ft>0 or eft>0) then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then eft=0 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,ft,ft,nil,e,tp,zone)
		local g2=Duel.SelectMatchingCard(tp,s.spfilter,tp,0,LOCATION_GRAVE,eft,eft,nil,e,tp,enemyzone)
		if #g>0 then
			local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
		end
		if #g2>0 then
			local ect=Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP,enemyzone)
		end
	end
end

function s.linkfilter(c,e,tp)
	return c:IsSetCard(0x114) and c:IsFaceup() and not c:IsCode(66023650)
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
	g.AddCard(g,g2)
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
