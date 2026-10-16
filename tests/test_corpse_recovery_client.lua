local sent=0
sendClientCommand=function()sent=sent+1 end
local Client=require "medWorks/CorpseRecoveryClient"
assert(not Client.request({}, {}, "leftArm", {})and sent==0)
assert(not Client.request(nil,nil,nil,nil)and sent==0)
print("Deprecated recovery client request cannot send an alternate mutation command")
