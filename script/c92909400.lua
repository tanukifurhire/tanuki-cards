--Rio, Arrow Fur Hire
--Tanuki Fur Hire
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
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
	--pop
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCost(s.descost)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
s.listed_series={0x114}
s.listed_names={66023650}, {id}
function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentPropertyBinary(Card.GetAttribute,lc,sumtype,tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x114) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.linkfilter(c,e,tp)
	return c:IsSetCard(0x114)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone(tp)&0x1f
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp,zone) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc = Duel.GetFirstTarget()
	local zone=e:GetHandler():GetLinkedZone(tp)&0x1f
	if tc and tc:IsRelateToEffect(e) and zone~=0 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end

function s.sprfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsCode(66023650) and c:IsFaceup()
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_TOGRAVE,nil,nil,true)
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

function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rt=math.min(2,Duel.GetTargetCount(aux.TRUE,tp,0,LOCATION_ONFIELD,nil))
	return (rt > 0)
end

function s.costfilter(c, e, tp)
	return c:IsSetCard(0x114) and c:IsAbleToGraveAsCost()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local cg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,rt,nil,lg)
	local count = Duel.SendtoGrave(cg, REASON_COST)
	
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) and Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_ONFIELD,nil)>=count end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,count,count,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,count,0,0) 
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards(e)
	    Duel.Destroy(tc,REASON_EFFECT)
end
