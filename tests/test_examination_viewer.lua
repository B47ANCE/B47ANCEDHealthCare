package.loaded["medWorks/init"]={}
local clock=1000;getTimestampMs=function()return clock end
local Completed=require "medWorks/CompletedExaminations"
local Viewer=require "medWorks/ExaminationViewer"
local examiner,other,patient={},{},{}
getSpecificPlayer=function(index)return index==0 and examiner or other end
getPlayerScreenWidth=function()return 600 end;getPlayerScreenHeight=function()return 400 end
getPlayerScreenLeft=function(index)return index*600 end;getPlayerScreenTop=function()return 0 end
local focus={};getJoypadFocus=function(i)return focus[i]end;setJoypadFocus=function(i,value)focus[i]=value end
local created={};local speedChanges=0
ISPanelJoypad={update=function()end}
package.loaded["ISUI/ISModalRichText"]=true
local methods={}
function methods:getWidth()return self.width end;function methods:getHeight()return self.height end
function methods:setWidth(v)self.width=v end;function methods:setHeight(v)self.height=v end
function methods:setX(v)self.x=v end;function methods:setY(v)self.y=v end
function methods:ignoreHeightChange()end;function methods:updateButtons()self.ok.y=self.height-35 end
function methods:setVisible(v)self.visible=v end;function methods:removeFromUIManager()self.removed=true end
function methods:addToUIManager()self.added=true end
function methods:initialise()
    self.ok={width=100,y=self.height-35,getWidth=methods.getWidth,getY=function(s)return s.y end,setX=methods.setX}
    self.chatText={setHeight=methods.setHeight,setWidth=methods.setWidth,paginate=function()end,updateScrollbars=function()end}
end
ISModalRichText={new=function(_,x,y,w,h,text,yesno,target,callback,player)
    local modal=setmetatable({x=x,y=y,width=w,height=h,text=text,player=player},{__index=methods})
    -- The real modal destroy changes speed; viewer must replace that behavior.
    modal.destroy=function()speedChanges=speedChanges+1 end
    created[#created+1]=modal;return modal
end}
local options={};local menu={addOption=function(_,label,target,fn,...)options[#options+1]={label,target,fn,...}end}
assert(not Viewer.addHealthPanelOption(menu,0,examiner,patient)and #options==0,"no option without a completed observation")
assert(Completed.publish(examiner,patient,{sections={{providerId="<LINE>bad",data={injuredPartCount=1,parts={{type="Hand_L",bleeding=true}}}}}}))
assert(Viewer.addHealthPanelOption(menu,0,examiner,patient)and #options==1)
assert(not Viewer.open(1,examiner,patient)and not Viewer.open(0,other,patient),"different local player cannot read the examiner's report")
assert(Viewer.open(0,examiner,patient));local first=created[1]
assert(first.player==0 and first.width==560 and first.height==360 and first.text:find("Read-only",1,true))
assert(not first.text:find("<LINE>bad",1,true)and first.text:find("Left hand: bleeding",1,true))
assert(Viewer.open(0,examiner,patient)and first.removed and #created==2,"one window per local player")
local current=created[2];getPlayerScreenWidth=function()return 320 end;getPlayerScreenHeight=function()return 240 end
current:update();assert(current.width==280 and current.height==200 and current.chatText.height>0,"resize stays inside selected viewport")
clock=301001
assert(not Viewer.open(0,examiner,patient),"stale menu callback cannot reopen expired observations")
current:destroy();assert(current.removed and focus[0]==nil and speedChanges==0,"close restores focus without changing speed")
clock=1000
assert(Completed.publish(other,patient,{sections={{data={injuredPartCount=0}}}}))
assert(Viewer.open(1,other,patient));local split=created[#created]
assert(split.player==1 and split.x>=600 and focus[0]==nil and focus[1]==split,"second local player has an independent window/focus")
assert(not Viewer.open(1,other,{}),"recreated patient must not alias the old observation")
getSpecificPlayer=function()return{}end
split:update();assert(split.removed and focus[1]==nil,"local examiner replacement closes its old window")
print("Examination viewer availability, exact local observer, escaped text, replacement, resize, expiry and non-mutating close checks passed")
