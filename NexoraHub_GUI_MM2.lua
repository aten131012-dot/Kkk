--[[
 NEXORA HUB v2  BLACK-WHITE LIGHTNING EDITION (ไฟล์เดียวรวมทุกส่วน)
 แก้ค่าตั้งต้นได้ที่ CFG ด้านล่าง โดยเฉพาะ DISCORD_LINK
]]
local CFG={
 LOGO_ID="91144361769901",
 LOGO_DARK=Color3.fromRGB(255,255,255), -- 255=สีเดิมของรูป (ยิ่งน้อยยิ่งเข้ม)
 DISCORD_ICON_ID="17056354182",
 DISCORD_LINK="https://discord.gg/YOUR_INVITE", -- <<< ใส่ลิงก์ดิสคอสของคุณตรงนี้
 NAME="NEXORA HUB",
 SETTINGS_FILE="NexoraHub_Settings_v2.json",
}

local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local LIN=Enum.EasingStyle.Linear
local SINE=Enum.EasingStyle.Sine
local IO=Enum.EasingDirection.InOut

local COL={
 Bg=Color3.fromRGB(6,6,6),
 Side=Color3.fromRGB(22,22,22),
 Chip=Color3.fromRGB(34,34,34),
 Purple=Color3.fromRGB(110,110,110),
 Pink=Color3.fromRGB(245,245,245),
 Text=Color3.fromRGB(245,245,245),
 Sub=Color3.fromRGB(165,165,165),
 Red=Color3.fromRGB(255,80,110),
 Green=Color3.fromRGB(90,230,160),
}
-- ธีมสี: 1=ขาว(ปกติ) 2=ม่วง 3=ฟ้า 4=แดง
local PRESETS={
 {Color3.fromRGB(110,110,110),Color3.fromRGB(245,245,245)},
 {Color3.fromRGB(140,80,255),Color3.fromRGB(215,125,255)},
 {Color3.fromRGB(50,130,255),Color3.fromRGB(110,220,255)},
 {Color3.fromRGB(235,50,70),Color3.fromRGB(255,130,150)},
}
local function make(c,p,par)
 local o=Instance.new(c)
 for k,v in pairs(p) do o[k]=v end
 o.Parent=par
 return o
end
local function round(o,r) return make("UICorner",{CornerRadius=UDim.new(0,r)},o) end

-- โหลดรูปจากไอดี: แข่งโหลดหลายแหล่งพร้อมกัน ใครเสร็จก่อนใช้อันนั้น (เร็วขึ้นมาก)
local CP=game:GetService("ContentProvider")
local imgCache={}
local function resolveImg(id)
 if imgCache[id] then return imgCache[id] end
 local c={}
 imgCache[id]=c
 for _,u in ipairs({"rbxassetid://"..id,"rbxthumb://type=Asset&id="..id.."&w=420&h=420"}) do
  task.spawn(function()
   local p=Instance.new("ImageLabel")
   p.Image=u
   pcall(function() CP:PreloadAsync({p}) end)
   if not c.url and p.IsLoaded then c.url=u end
   p:Destroy()
  end)
 end
 return c
end
local function setImg(o,id)
 local c=resolveImg(id)
 o.Image=c.url or ("rbxassetid://"..id)
 if c.url then return end
 task.spawn(function()
  local t=0
  while not c.url and t<8 do task.wait(.05) t+=.05 end
  if c.url then o.Image=c.url end
 end)
end
-- เริ่มโหลดรูปทันทีตั้งแต่บรรทัดแรก ก่อนสร้าง GUI
resolveImg(CFG.LOGO_ID)
resolveImg(CFG.DISCORD_ICON_ID)

-- ระบบเปลี่ยนสีธีม
local accents={}
local function onAccent(fn) accents[#accents+1]=fn fn(COL.Purple,COL.Pink) end
local function setAccent(a,b) COL.Purple=a COL.Pink=b for _,fn in ipairs(accents) do fn(a,b) end end
local function glow(o,t)
 local s=make("UIStroke",{Thickness=t or 1.5,Color=Color3.new(1,1,1),ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o)
 local g=make("UIGradient",{},s)
 onAccent(function(a,b) g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,a),ColorSequenceKeypoint.new(.5,b),ColorSequenceKeypoint.new(1,a)}) end)
 TS:Create(g,TweenInfo.new(4,LIN,Enum.EasingDirection.In,-1),{Rotation=360}):Play()
 return s
end

-- สายฟ้าสีขาว: วาดจากเส้นหักมุม + ชั้นเรืองแสง แล้วค่อยๆ จางหาย
local WHITE=Color3.new(1,1,1)
local function bolt(par,x0,y0,x1,y1,o)
 o=o or {}
 local segs,jit,th=o.segs or 9,o.jit or 26,o.th or 2
 local z=o.z or 6
 local list={}
 local function line(ax,ay,bx,by,t)
  local dx,dy=bx-ax,by-ay
  local len=math.sqrt(dx*dx+dy*dy)
  local ang=math.deg(math.atan2(dy,dx))
  for _,l in ipairs({{t*4,.82},{t,0}}) do
   local f=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset((ax+bx)/2,(ay+by)/2),Size=UDim2.fromOffset(len+l[1]*.5,l[1]),Rotation=ang,BackgroundColor3=WHITE,BackgroundTransparency=l[2],BorderSizePixel=0,ZIndex=z},par)
   list[#list+1]={f,l[2]}
  end
 end
 local px,py=x0,y0
 for i=1,segs do
  local t=i/segs
  local nx=x0+(x1-x0)*t
  local ny=y0+(y1-y0)*t
  if i<segs then nx+=math.random(-jit,jit) ny+=math.random(-jit,jit)*.25 end
  line(px,py,nx,ny,th)
  if (o.branch~=false) and i>1 and i<segs and math.random()<.35 then
   line(nx,ny,nx+math.random(-jit*2,jit*2),ny+math.random(jit,jit*3)*((y1>=y0) and 1 or -1),math.max(th*.6,1))
  end
  px,py=nx,ny
 end
 task.delay(o.hold or .08,function()
  local fade=o.fade or .35
  for _,v in ipairs(list) do
   if v[1].Parent then TS:Create(v[1],TweenInfo.new(fade),{BackgroundTransparency=1}):Play() end
  end
  task.delay(fade+.05,function() for _,v in ipairs(list) do v[1]:Destroy() end end)
 end)
end

local parent=(gethui and gethui()) or game:GetService("CoreGui")
if parent:FindFirstChild("NexoraHubUI") then parent.NexoraHubUI:Destroy() end
if parent:FindFirstChild("NexoraLoading") then parent.NexoraLoading:Destroy() end

-- อ่านภาษาที่บันทึกไว้ (ไว้ใช้กับหน้าโหลด)
local savedLang="TH"
pcall(function()
 if isfile and isfile(CFG.SETTINGS_FILE) then
  local d=game:GetService("HttpService"):JSONDecode(readfile(CFG.SETTINGS_FILE))
  if d.lang=="EN" or d.lang=="TH" then savedLang=d.lang end
  if type(d.accent)=="number" and PRESETS[d.accent] then COL.Purple=PRESETS[d.accent][1] COL.Pink=PRESETS[d.accent][2] end
 end
end)

------------------------------------------------------------------
-- หน้าโหลด
------------------------------------------------------------------
local Loader={ready=false,done=false}
function Loader.finish(cb) Loader.cb=cb Loader.ready=true end
do
 local TH=(savedLang=="TH")
 local cam=workspace.CurrentCamera
 local vp=cam and cam.ViewportSize or Vector2.new(800,500)
 local kk=math.clamp(math.min(vp.X/820,vp.Y/520),.6,1.15)
 local CY=.42
 local ld=make("ScreenGui",{Name="NexoraLoading",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=999999,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)
 pcall(function() ld.ScreenInsets=Enum.ScreenInsets.None end)
 local root=make("CanvasGroup",{Position=UDim2.fromScale(0,0),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0},ld)
 local bgl=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Active=true},root)
 make("UIGradient",{Color=ColorSequence.new(COL.Purple:Lerp(Color3.new(),.76),Color3.new(0,0,0)),Rotation=90},bgl)

 -- เนบิวลา
 local function neb(x,y,s,col,dx,dy,t)
  local h=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(x,y),Size=UDim2.fromOffset(s,s),BackgroundTransparency=1},root)
  for i=1,4 do
   local k=1-(i-1)*.2
   local f=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(k,k),BackgroundColor3=col,BackgroundTransparency=.93,BorderSizePixel=0},h)
   make("UICorner",{CornerRadius=UDim.new(.5,0)},f)
  end
  TS:Create(h,TweenInfo.new(t,SINE,IO,-1,true),{Position=UDim2.fromScale(x+dx,y+dy)}):Play()
 end
 neb(.2,.25,520,COL.Pink:Lerp(Color3.new(),.38),.06,.08,8)
 neb(.8,.75,560,COL.Purple:Lerp(Color3.new(),.18),-.07,-.06,10)
 neb(.75,.15,380,COL.Pink:Lerp(Color3.new(),.14),-.05,.08,7)

 -- ดาว
 for i=1,90 do
  local sz=math.random(1,3)
  local s=make("Frame",{Position=UDim2.fromScale(math.random(),math.random()),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(math.random()<.3) and COL.Pink or Color3.new(1,1,1),BackgroundTransparency=math.random(30,70)/100,BorderSizePixel=0},root)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},s)
  TS:Create(s,TweenInfo.new(math.random(8,25)/10,SINE,IO,-1,true),{BackgroundTransparency=.95}):Play()
 end

 -- ลำแสงหมุนด้านหลัง
 local rayHold=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,CY),Size=UDim2.fromOffset(10,10),BackgroundTransparency=1},root)
 for i=1,12 do
  local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset((i%2==0) and 3 or 2,1800),BackgroundColor3=(i%2==0) and COL.Pink or COL.Purple,BorderSizePixel=0,Rotation=i*15},rayHold)
  make("UIGradient",{Rotation=90,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.5,.8),NumberSequenceKeypoint.new(1,1)})},r)
 end
 TS:Create(rayHold,TweenInfo.new(20,LIN,Enum.EasingDirection.In,-1),{Rotation=360}):Play()

 -- อนุภาคลอยขึ้น
 task.spawn(function()
  while ld.Parent do
   local sz=math.random(2,4)
   local x=math.random()
   local p=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(x,0,1,10),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(math.random()<.5) and COL.Pink or Color3.new(1,1,1),BackgroundTransparency=.3,BorderSizePixel=0},root)
   make("UICorner",{CornerRadius=UDim.new(.5,0)},p)
   local dur=math.random(30,60)/10
   TS:Create(p,TweenInfo.new(dur,LIN),{Position=UDim2.new(math.clamp(x+(math.random()-.5)*.1,0,1),0,-.05,0),BackgroundTransparency=1}):Play()
   task.delay(dur+.1,function() p:Destroy() end)
   task.wait(.1)
  end
 end)

 -- สายฟ้าขาวฟาดทั้งหน้าจอ + แฟลช
 local lflash=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=WHITE,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=2},root)
 task.spawn(function()
  task.wait(.4)
  while ld.Parent do
   local W,H=vp.X,vp.Y
   local x=math.random(math.floor(W*.1),math.floor(W*.9))
   bolt(root,x,-10,x+math.random(-120,120),H*math.random(45,85)/100,{segs=11,jit=34,th=2.5,z=4,hold=.1,fade=.4})
   lflash.BackgroundTransparency=.9
   TS:Create(lflash,TweenInfo.new(.35),{BackgroundTransparency=1}):Play()
   task.wait(math.random(6,15)/10)
  end
 end)

 -- มุมกรอบ HUD
 local function bracket(ax,ay)
  local f=make("Frame",{AnchorPoint=Vector2.new(ax,ay),Position=UDim2.new(ax,(ax==0) and 20 or -20,ay,(ay==0) and 20 or -20),Size=UDim2.fromOffset(34,34),BackgroundTransparency=1,ZIndex=3},root)
  make("Frame",{AnchorPoint=Vector2.new(ax,ay),Position=UDim2.fromScale(ax,ay),Size=UDim2.new(1,0,0,2),BackgroundColor3=COL.Pink,BorderSizePixel=0},f)
  make("Frame",{AnchorPoint=Vector2.new(ax,ay),Position=UDim2.fromScale(ax,ay),Size=UDim2.new(0,2,1,0),BackgroundColor3=COL.Pink,BorderSizePixel=0},f)
  TS:Create(f,TweenInfo.new(1.2,SINE,IO,-1,true),{BackgroundTransparency=1}):Play()
 end
 bracket(0,0) bracket(1,0) bracket(0,1) bracket(1,1)

 -- กลุ่มกลาง
 local ctr=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,CY),Size=UDim2.fromOffset(340,340),BackgroundTransparency=1,ZIndex=5},root)
 local csc=make("UIScale",{Scale=kk},ctr)
 for i=1,4 do
  local sz=150+i*38
  local h=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(i%2==0) and COL.Pink or COL.Purple,BackgroundTransparency=.9},ctr)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},h)
  TS:Create(h,TweenInfo.new(1.4+i*.25,SINE,IO,-1,true),{Size=UDim2.fromOffset(sz+30,sz+30),BackgroundTransparency=.96}):Play()
 end
 local function ring(sz,th,c1,c2,speed,rev)
  local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(sz,sz),BackgroundTransparency=1},ctr)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
  local s=make("UIStroke",{Thickness=th,Color=Color3.new(1,1,1)},r)
  local g=make("UIGradient",{Color=ColorSequence.new(c1,c2),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.5,.15),NumberSequenceKeypoint.new(.62,1),NumberSequenceKeypoint.new(1,1)})},s)
  TS:Create(g,TweenInfo.new(speed,LIN,Enum.EasingDirection.In,-1),{Rotation=rev and -360 or 360}):Play()
 end
 ring(170,4,COL.Pink,COL.Purple,1.5,false)
 ring(208,2.5,COL.Pink,COL.Purple,2.4,true)
 ring(250,1.5,COL.Purple,COL.Pink,4,false)

 -- จุดโคจร
 local dots={}
 for i=1,8 do
  local sz=(i%2==0) and 6 or 4
  local d=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(i%2==0) and COL.Pink or Color3.new(1,1,1),BorderSizePixel=0},ctr)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},d)
  dots[i]=d
 end
 local orb=RS.RenderStepped:Connect(function()
  local t=os.clock()
  for i,d in ipairs(dots) do
   local a=t*(.9+(i%3)*.35)*((i%2==0) and 1 or -1)+i*(math.pi*2/8)
   local r=130+math.sin(t*1.5+i)*8
   d.Position=UDim2.new(.5,math.cos(a)*r,.5,math.sin(a)*r)
  end
 end)

 -- โลโก้กลาง
 local lgo=make("ImageLabel",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(128,128),BackgroundColor3=COL.Side},ctr)
 round(lgo,64)
 make("UIStroke",{Color=Color3.new(1,1,1),Thickness=2,Transparency=.5},lgo)
 setImg(lgo,CFG.LOGO_ID)
 lgo.ImageColor3=CFG.LOGO_DARK
 local ls=make("UIScale",{Scale=0},lgo)
 TS:Create(ls,TweenInfo.new(.8,Enum.EasingStyle.Back),{Scale=1}):Play()
 task.delay(.9,function()
  if ld.Parent then TS:Create(ls,TweenInfo.new(1.1,SINE,IO,-1,true),{Scale=1.07}):Play() end
 end)

 -- ระลอกคลื่น
 task.spawn(function()
  task.wait(.5)
  while ld.Parent do
   local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(128,128),BackgroundTransparency=1},ctr)
   make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
   local s=make("UIStroke",{Color=COL.Pink,Thickness=2,Transparency=.2},r)
   TS:Create(r,TweenInfo.new(1.8,Enum.EasingStyle.Quint),{Size=UDim2.fromOffset(330,330)}):Play()
   TS:Create(s,TweenInfo.new(1.8),{Transparency=1}):Play()
   task.delay(1.9,function() r:Destroy() end)
   task.wait(.9)
  end
 end)
 local function shock()
  local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(128,128),BackgroundTransparency=1},ctr)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
  local s=make("UIStroke",{Color=Color3.new(1,1,1),Thickness=4},r)
  TS:Create(r,TweenInfo.new(.7,Enum.EasingStyle.Quint),{Size=UDim2.fromOffset(1800,1800)}):Play()
  TS:Create(s,TweenInfo.new(.7),{Transparency=1}):Play()
 end

 -- ชื่อ + แถบโหลด
 local bot=make("Frame",{AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,CY,math.floor(168*kk)),Size=UDim2.fromOffset(340,90),BackgroundTransparency=1,ZIndex=5},root)
 make("UIScale",{Scale=kk},bot)
 local spaced=(CFG.NAME:gsub("(.)","%1 "))
 local ttl=make("TextLabel",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,Text=spaced,MaxVisibleGraphemes=0,Font=Enum.Font.GothamBlack,TextSize=26,TextColor3=Color3.new(1,1,1)},bot)
 local tg=make("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,COL.Purple),ColorSequenceKeypoint.new(.5,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,COL.Pink)}),Offset=Vector2.new(-1,0)},ttl)
 TS:Create(tg,TweenInfo.new(1.6,LIN,Enum.EasingDirection.In,-1),{Offset=Vector2.new(1,0)}):Play()
 task.spawn(function()
  for i=0,#spaced do
   if not ld.Parent then return end
   ttl.MaxVisibleGraphemes=i
   task.wait(.07)
  end
 end)
 local barBg=make("Frame",{Position=UDim2.fromOffset(0,42),Size=UDim2.new(1,0,0,8),BackgroundColor3=COL.Chip,BorderSizePixel=0},bot)
 round(barBg,4)
 make("UIStroke",{Color=COL.Pink,Thickness=1,Transparency=.6},barBg)
 local barFill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ClipsDescendants=true},barBg)
 round(barFill,4)
 make("UIGradient",{Color=ColorSequence.new(COL.Purple,COL.Pink)},barFill)
 local bsh=make("Frame",{Size=UDim2.fromScale(.3,1),Position=UDim2.fromScale(-.4,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.55,BorderSizePixel=0},barFill)
 TS:Create(bsh,TweenInfo.new(1,Enum.EasingStyle.Quad,IO,-1),{Position=UDim2.fromScale(1.2,0)}):Play()
 local st=make("TextLabel",{Position=UDim2.fromOffset(0,56),Size=UDim2.new(1,-60,0,14),BackgroundTransparency=1,Text="",Font=Enum.Font.Gotham,TextSize=11,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Left},bot)
 local pc=make("TextLabel",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,56),Size=UDim2.fromOffset(56,14),BackgroundTransparency=1,Text="0%",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=COL.Pink,TextXAlignment=Enum.TextXAlignment.Right},bot)

 local flash=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=20},root)

 local texts=TH and {"กำลังเริ่มระบบ...","กำลังโหลดทรัพยากร...","กำลังสร้างหน้าต่าง...","กำลังเชื่อมต่อ...","ใกล้เสร็จแล้ว..."} or {"Initializing...","Loading assets...","Building interface...","Connecting services...","Almost ready..."}
 task.spawn(function()
  local t0=os.clock()
  local cur=0
  while ld.Parent do
   local dt=RS.RenderStepped:Wait()
   local el=os.clock()-t0
   local goal=math.min(el/3,1)*92
   if (Loader.ready and el>=3) or el>25 then goal=100 end
   cur+=(goal-cur)*math.min(dt*5,1)
   if goal==100 and cur>99.5 then cur=100 end
   barFill.Size=UDim2.fromScale(cur/100,1)
   pc.Text=math.floor(cur).."%"
   st.Text=texts[math.clamp(math.floor(cur/20)+1,1,5)]
   if cur>=100 then break end
  end
  st.Text=TH and "พร้อมแล้ว ✔" or "Ready ✔"
  task.wait(.35)
  Loader.done=true
  shock()
  TS:Create(flash,TweenInfo.new(.15),{BackgroundTransparency=.6}):Play()
  TS:Create(csc,TweenInfo.new(.7,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Scale=kk*1.6}):Play()
  task.wait(.15)
  TS:Create(flash,TweenInfo.new(.5),{BackgroundTransparency=1}):Play()
  TS:Create(root,TweenInfo.new(.6,Enum.EasingStyle.Quad),{GroupTransparency=1}):Play()
  task.wait(.7)
  orb:Disconnect()
  ld:Destroy()
  if Loader.cb then task.spawn(Loader.cb) end
 end)
end

------------------------------------------------------------------
-- หน้าต่างหลัก
------------------------------------------------------------------
local state={scale=.9,alpha=0,key=true,lang=savedLang,fx=true}

local gui=make("ScreenGui",{Name="NexoraHubUI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)

local win=make("CanvasGroup",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(540,376),Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1,GroupTransparency=1,Visible=false},gui)
round(win,26)
local bgf=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1)},win)
round(bgf,26) glow(bgf,1.5)
local bgg=make("UIGradient",{Rotation=90},bgf)
onAccent(function(a) bgg.Color=ColorSequence.new(a:Lerp(Color3.new(),.8),a:Lerp(Color3.new(),.97)) end)
local sc=make("UIScale",{Scale=.05},win)

local lang=savedLang
local labels={}
local langHooks={}
local function L(o,en,th)
 labels[#labels+1]={o,en,th}
 o.Text=(lang=="TH" and th) and th or en
 return o
end

-- ===== เอฟเฟกต์อวกาศ =====
local space=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ClipsDescendants=true},bgf)
local spaceOn=true
do
 local function blob(x,y,s,col,dx,dy,t)
  local h=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(x,y),Size=UDim2.fromOffset(s,s),BackgroundTransparency=1},space)
  local cs={}
  for i=1,4 do
   local k=1-(i-1)*.2
   local c=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(k,k),BackgroundTransparency=.93,BorderSizePixel=0},h)
   make("UICorner",{CornerRadius=UDim.new(.5,0)},c)
   cs[i]=c
  end
  onAccent(function(a,b) local cc=col(a,b) for _,c in ipairs(cs) do c.BackgroundColor3=cc end end)
  TS:Create(h,TweenInfo.new(t,SINE,IO,-1,true),{Position=UDim2.fromScale(x+dx,y+dy)}):Play()
 end
 blob(.15,.25,280,function(a,b) return b:Lerp(Color3.new(),.38) end,.08,.1,9)
 blob(.85,.8,320,function(a,b) return a:Lerp(Color3.new(),.18) end,-.1,-.08,11)
 blob(.6,.1,220,function(a,b) return b:Lerp(Color3.new(),.14) end,-.06,.12,8)

 for i=1,52 do
  local sz=math.random(1,2)+((math.random()<.12) and 1 or 0)
  local s=make("Frame",{Position=UDim2.fromScale(math.random(),math.random()),Size=UDim2.fromOffset(sz,sz),BackgroundColor3=(math.random()<.3) and COL.Pink or Color3.new(1,1,1),BackgroundTransparency=math.random(30,70)/100,BorderSizePixel=0},space)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},s)
  TS:Create(s,TweenInfo.new(math.random(8,25)/10,SINE,IO,-1,true),{BackgroundTransparency=.95}):Play()
 end

 local planet=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.95,.07),Size=UDim2.fromOffset(60,60),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.3},space)
 make("UICorner",{CornerRadius=UDim.new(.5,0)},planet)
 local pg=make("UIGradient",{Rotation=45},planet)
 onAccent(function(a,b) pg.Color=ColorSequence.new(b:Lerp(Color3.new(1,1,1),.1),a:Lerp(Color3.new(),.82)) end)
 local ringp=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(104,26),BackgroundTransparency=1,Rotation=-22},planet)
 make("UICorner",{CornerRadius=UDim.new(.5,0)},ringp)
 local rps=make("UIStroke",{Color=COL.Pink,Thickness=2,Transparency=.5},ringp)
 onAccent(function(_,b) rps.Color=b end)
 TS:Create(planet,TweenInfo.new(7,SINE,IO,-1,true),{Position=UDim2.fromScale(.95,.1)}):Play()

 task.spawn(function()
  while gui:IsDescendantOf(game) do
   task.wait(math.random(25,60)/10)
   if spaceOn and win.Visible then
    local x,y=math.random(5,60)/100,math.random(0,30)/100
    local s=make("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.fromScale(x,y),Size=UDim2.fromOffset(64,2),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Rotation=35},space)
    make("UIGradient",{Transparency=NumberSequence.new(1,0)},s)
    TS:Create(s,TweenInfo.new(.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.fromScale(x+.35,y+.4)}):Play()
    task.delay(.9,function() s:Destroy() end)
   end
  end
 end)
end
task.spawn(function()
 while gui:IsDescendantOf(game) do
  task.wait(math.random(15,40)/10)
  if spaceOn and win.Visible then
   local x=math.random(40,500)
   bolt(space,x,-6,x+math.random(-70,70),math.random(120,300),{segs=8,jit=22,th=1.6,z=2,hold=.07,fade=.3})
  end
 end
end)
local function setSpace(v) spaceOn=v space.Visible=v end

-- ===== แถบบน =====
local top=make("Frame",{Size=UDim2.new(1,0,0,46),BackgroundTransparency=1},win)
local lg=make("ImageLabel",{Size=UDim2.fromOffset(30,30),Position=UDim2.fromOffset(14,8),BackgroundColor3=COL.Side},top)
round(lg,15) glow(lg,1.5)
setImg(lg,CFG.LOGO_ID)
lg.ImageColor3=CFG.LOGO_DARK
local title=make("TextLabel",{Position=UDim2.fromOffset(52,4),Size=UDim2.fromOffset(150,20),BackgroundTransparency=1,Text=CFG.NAME,Font=Enum.Font.GothamBlack,TextSize=16,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Left},top)
local tg=make("UIGradient",{Offset=Vector2.new(-1,0)},title)
onAccent(function(a,b) tg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,a),ColorSequenceKeypoint.new(.5,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,b)}) end)
TS:Create(tg,TweenInfo.new(2.2,LIN,Enum.EasingDirection.In,-1,false,1.2),{Offset=Vector2.new(1,0)}):Play()
local sub=make("TextLabel",{Position=UDim2.fromOffset(52,24),Size=UDim2.new(1,-260,0,12),BackgroundTransparency=1,Text=game.Name,Font=Enum.Font.Gotham,TextSize=10,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},top)

-- ตัวสลับภาษา (ใหญ่ ชัด มีไอคอนโลก)
local langF=make("Frame",{Size=UDim2.fromOffset(112,26),Position=UDim2.new(1,-190,0,10),BackgroundColor3=COL.Side},top)
round(langF,13)
local lfs=make("UIStroke",{Color=COL.Pink,Thickness=1,Transparency=.4},langF)
onAccent(function(a,b) lfs.Color=b end)
make("TextLabel",{Position=UDim2.fromOffset(6,0),Size=UDim2.fromOffset(18,26),BackgroundTransparency=1,Text="🌐",TextSize=13},langF)
local function lbtn(x,t)
 local b=make("TextButton",{Position=UDim2.fromOffset(x,3),Size=UDim2.fromOffset(40,20),BackgroundColor3=COL.Chip,Text=t,Font=Enum.Font.GothamBlack,TextSize=11,TextColor3=COL.Sub,AutoButtonColor=false},langF)
 round(b,10)
 return b
end
local thB=lbtn(26,"ไทย")
local enB=lbtn(68,"EN")
local curAcc=COL.Purple
local function paintLang()
 local th=(lang=="TH")
 TS:Create(thB,TweenInfo.new(.2),{BackgroundColor3=th and curAcc or COL.Chip,TextColor3=th and Color3.new(1,1,1) or COL.Sub}):Play()
 TS:Create(enB,TweenInfo.new(.2),{BackgroundColor3=(not th) and curAcc or COL.Chip,TextColor3=(not th) and Color3.new(1,1,1) or COL.Sub}):Play()
end
onAccent(function(a) curAcc=a paintLang() end)
local function setLang(l)
 lang=l state.lang=l
 for _,v in ipairs(labels) do v[1].Text=(l=="TH" and v[3]) and v[3] or v[2] end
 paintLang()
 for _,fn in ipairs(langHooks) do pcall(fn,l) end
 local n=getgenv().NX
 if n and n.save then n.save() end
end
thB.MouseButton1Click:Connect(function() setLang("TH") end)
enB.MouseButton1Click:Connect(function() setLang("EN") end)

local function tbtn(x,txt,col)
 local b=make("TextButton",{Size=UDim2.fromOffset(26,26),Position=UDim2.new(1,x,0,10),BackgroundColor3=col,Text=txt,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=Color3.new(1,1,1),AutoButtonColor=false},top)
 round(b,13)
 b.MouseEnter:Connect(function() TS:Create(b,TweenInfo.new(.15),{Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,x-2,0,8)}):Play() end)
 b.MouseLeave:Connect(function() TS:Create(b,TweenInfo.new(.15),{Size=UDim2.fromOffset(26,26),Position=UDim2.new(1,x,0,10)}):Play() end)
 return b
end
local minB=tbtn(-68,"–",COL.Purple)
local clsB=tbtn(-36,"X",COL.Red)
onAccent(function(a) minB.BackgroundColor3=a end)

-- ===== เมนูข้าง + หน้า =====
local side=make("Frame",{Position=UDim2.fromOffset(10,50),Size=UDim2.new(0,112,1,-60),BackgroundColor3=COL.Side,BackgroundTransparency=.45},win)
round(side,20)
local menu=make("ScrollingFrame",{Size=UDim2.new(1,0,1,-56),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y},side)
make("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},menu)
make("UIPadding",{PaddingTop=UDim.new(0,10),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},menu)
local content=make("Frame",{Position=UDim2.fromOffset(130,50),Size=UDim2.new(1,-140,1,-60),BackgroundTransparency=1,ClipsDescendants=true},win)

local pages,btns,ord={}, {},0
local TI=TweenInfo.new(.3,Enum.EasingStyle.Quint)
local function selectPage(name)
 for n,p in pairs(pages) do
  if n==name then
   if not p.Visible then
    p.Visible=true p.Position=UDim2.fromOffset(18,0)
    TS:Create(p,TI,{Position=UDim2.new()}):Play()
   end
  else p.Visible=false end
 end
 for n,b in pairs(btns) do TS:Create(b,TI,{BackgroundTransparency=(n==name) and 0 or 1}):Play() end
end
local function section(en,th)
 ord+=1
 L(make("TextLabel",{LayoutOrder=ord,Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Left},menu),en,th)
end
local function addPage(name,icon,en,th)
 ord+=1
 local b=make("TextButton",{LayoutOrder=ord,Size=UDim2.new(1,0,0,32),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false},menu)
 round(b,16)
 local g=make("UIGradient",{},b)
 onAccent(function(a,c2) g.Color=ColorSequence.new(a,c2) end)
 make("TextLabel",{Position=UDim2.fromOffset(8,0),Size=UDim2.fromOffset(20,32),BackgroundTransparency=1,Text=icon,TextSize=14},b)
 L(make("TextLabel",{Position=UDim2.fromOffset(32,0),Size=UDim2.new(1,-36,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Left},b),en,th)
 local p=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},content)
 pages[name]=p btns[name]=b
 b.MouseButton1Click:Connect(function() selectPage(name) end)
 return p
end
section("MAIN","หลัก")
addPage("home","⌂","HOME","HOME")
section("MM2","MM2")
addPage("mm_radar","◐","RADAR","เรดาร์")
addPage("mm_warp","➤","WARP","วาร์ป")
addPage("mm_fling","✹","FLING","ฟลิ้ง")
addPage("mm_hunter","✂","HUNTER","โหมดล่า")
addPage("mm_player","♟","PLAYER","ตัวละคร")
addPage("mm_farm","✪","COIN FARM","ฟาร์ม")
addPage("mm_event","✿","EVENT","อีเวนท์")
section("SYSTEM","ระบบ")
addPage("settings","☼","SETTINGS","SETTINGS")
selectPage("home")

-- ===== โลโก้ลอย + เอฟเฟกต์ =====
local LS=52
local logo=make("ImageButton",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(0,0),Position=UDim2.new(0,42,.5,0),BackgroundColor3=COL.Bg,Image="",AutoButtonColor=false},gui)
round(logo,26)
glow(logo,1.5)
setImg(logo,CFG.LOGO_ID)
logo.ImageColor3=CFG.LOGO_DARK
TS:Create(make("UIScale",{},logo),TweenInfo.new(1.8,SINE,IO,-1,true),{Scale=1.06}):Play()

local fxOn=true
local fxObjs={}
-- วงแหวนนีออนหมุนรอบโลโก้ (เห็นชัด เข้าใจง่าย)
local function fxRing(extra,th,speed,rev)
 local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.new(1,extra,1,extra),BackgroundTransparency=1},logo)
 make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
 local s=make("UIStroke",{Thickness=th,Color=Color3.new(1,1,1)},r)
 local g=make("UIGradient",{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(.45,.1),NumberSequenceKeypoint.new(.6,1),NumberSequenceKeypoint.new(1,1)})},s)
 onAccent(function(a,b) g.Color=ColorSequence.new(b,a) end)
 TS:Create(g,TweenInfo.new(speed,LIN,Enum.EasingDirection.In,-1),{Rotation=rev and -360 or 360}):Play()
 fxObjs[#fxObjs+1]=r
end
fxRing(12,3,1.4,false)
fxRing(26,2,2.2,true)
local function setLogoFx(v)
 fxOn=v
 for _,r in ipairs(fxObjs) do r.Visible=v end
end
logo.MouseEnter:Connect(function() TS:Create(logo,TweenInfo.new(.2,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(LS+8,LS+8)}):Play() end)
logo.MouseLeave:Connect(function() TS:Create(logo,TweenInfo.new(.2,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(LS,LS)}):Play() end)

local function ripple()
 local r=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(1,1),BackgroundTransparency=1},logo)
 make("UICorner",{CornerRadius=UDim.new(.5,0)},r)
 local s=make("UIStroke",{Color=COL.Pink,Thickness=1.5,Transparency=.2},r)
 TS:Create(r,TweenInfo.new(1.4,Enum.EasingStyle.Quint),{Size=UDim2.fromScale(2.4,2.4)}):Play()
 TS:Create(s,TweenInfo.new(1.4),{Transparency=1}):Play()
 task.delay(1.5,function() r:Destroy() end)
end
local function burst()
 for i=1,10 do
  local a=math.rad(i*36)
  local d=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(5,5),BackgroundColor3=(i%2==0) and COL.Pink or COL.Purple},logo)
  make("UICorner",{CornerRadius=UDim.new(.5,0)},d)
  TS:Create(d,TweenInfo.new(.7,Enum.EasingStyle.Quint),{Position=UDim2.new(.5,math.cos(a)*48,.5,math.sin(a)*48),BackgroundTransparency=1,Size=UDim2.fromOffset(2,2)}):Play()
  task.delay(.8,function() d:Destroy() end)
 end
end

local open,busy=false,false
local winPos=UDim2.new(.5,0,.5,0)
local function setOpen(v)
 if busy or v==open then return end
 busy=true open=v
 burst()
 logo.Rotation=0
 TS:Create(logo,TweenInfo.new(.6,Enum.EasingStyle.Back),{Rotation=360}):Play()
 task.delay(.65,function() logo.Rotation=0 busy=false end)
 if v then
  -- จำตำแหน่งเดิม และกันหลุดนอกจอ
  local av=gui.AbsoluteSize
  local hw,hh=540*state.scale/2,376*state.scale/2
  local ax=math.clamp(winPos.X.Scale*av.X+winPos.X.Offset,math.min(hw,av.X/2),math.max(av.X-hw,av.X/2))
  local ay=math.clamp(winPos.Y.Scale*av.Y+winPos.Y.Offset,math.min(hh,av.Y/2),math.max(av.Y-hh,av.Y/2))
  winPos=UDim2.fromOffset(ax,ay)
  win.Visible=true
  win.Position=logo.Position
  sc.Scale=.05 win.GroupTransparency=1
  local ti=TweenInfo.new(.55,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
  TS:Create(win,ti,{Position=winPos,GroupTransparency=state.alpha}):Play()
  TS:Create(sc,ti,{Scale=state.scale}):Play()
 else
  local ti=TweenInfo.new(.38,Enum.EasingStyle.Quint,Enum.EasingDirection.In)
  TS:Create(win,ti,{Position=logo.Position,GroupTransparency=1}):Play()
  TS:Create(sc,ti,{Scale=.05}):Play()
  task.delay(.4,function() if not open then win.Visible=false end end)
 end
end
local function resetPos()
 winPos=UDim2.new(.5,0,.5,0)
 logo.Position=UDim2.new(0,42,.5,0)
 if open then win.Position=winPos end
end

local function drag(handle,target,onClick,onEnd)
 local d,ds,sp,moved
 handle.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   d=true moved=false ds=i.Position sp=target.Position
   i.Changed:Connect(function()
    if i.UserInputState==Enum.UserInputState.End then
     d=false
     if onEnd then onEnd() end
     if onClick and not moved then onClick() end
    end
   end)
  end
 end)
 UIS.InputChanged:Connect(function(i)
  if d and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
   local v=i.Position-ds
   if v.Magnitude>6 then moved=true end
   target.Position=UDim2.new(sp.X.Scale,sp.X.Offset+v.X,sp.Y.Scale,sp.Y.Offset+v.Y)
  end
 end)
end
drag(top,win,nil,function() if open and not busy then winPos=win.Position end end)
drag(logo,logo,function() setOpen(not open) end)
minB.MouseButton1Click:Connect(function() setOpen(false) end)
clsB.MouseButton1Click:Connect(function() gui:Destroy() end)
UIS.InputBegan:Connect(function(i,gp)
 if not gp and state.key and i.KeyCode==Enum.KeyCode.RightShift then setOpen(not open) end
end)

task.spawn(function()
 while gui:IsDescendantOf(game) do
  if not open and fxOn then
   ripple()
   local a=math.rad(math.random(0,359))
   local c=LS/2
   bolt(logo,c+math.cos(a)*c*.9,c+math.sin(a)*c*.9,c+math.cos(a)*(c+34),c+math.sin(a)*(c+34),{segs=4,jit=8,th=1.4,z=3,hold=.06,fade=.25,branch=false})
  end
  task.wait(2.4)
 end
end)

getgenv().NX={COL=COL,make=make,round=round,glow=glow,L=L,setLang=setLang,getLang=function() return lang end,
 onLang=function(fn) langHooks[#langHooks+1]=fn end,
 content=content,sub=sub,side=side,pages=pages,onAccent=onAccent,setAccent=setAccent,setSpace=setSpace,
 setLogoFx=setLogoFx,resetPos=resetPos,setImg=setImg,CFG=CFG,gui=gui,
 state=state,win=win,sc=sc,setOpen=setOpen,isOpen=function() return open end}

------------------------------------------------------------------
-- หน้า HOME
------------------------------------------------------------------
do
local NX=getgenv().NX
local COL,make,round,glow,L=NX.COL,NX.make,NX.round,NX.glow,NX.L
local Players=game:GetService("Players")
local TS=game:GetService("TweenService")
local RS=game:GetService("RunService")
local Stats=game:GetService("Stats")
local MPS=game:GetService("MarketplaceService")
local lp=Players.LocalPlayer
local TI=TweenInfo.new(.35,Enum.EasingStyle.Quint)
local c=NX.pages.home
local CEN=Enum.TextXAlignment.Center
local function T(en,th) return (NX.getLang()=="TH") and th or en end

local function txt(p,props)
 props.BackgroundTransparency=1
 props.Font=props.Font or Enum.Font.GothamBold
 props.TextColor3=props.TextColor3 or COL.Text
 props.TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left
 return make("TextLabel",props,p)
end
local function pop(o,d)
 local s=make("UIScale",{Scale=0},o)
 task.delay(d,function() TS:Create(s,TweenInfo.new(.45,Enum.EasingStyle.Back),{Scale=1}):Play() end)
end
local function tag(p,props)
 props.AutomaticSize=Enum.AutomaticSize.X
 props.Size=UDim2.fromOffset(0,16)
 props.BackgroundColor3=COL.Bg
 props.BackgroundTransparency=.35
 props.Font=Enum.Font.GothamBold
 props.TextSize=9
 props.TextColor3=COL.Text
 local t=make("TextLabel",props,p)
 round(t,8)
 make("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},t)
 return t
end

-- แถวหัวข้อ + แท็ก
local th=make("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},c)
local tl=L(txt(th,{Position=UDim2.fromOffset(2,0),Size=UDim2.fromOffset(110,20),Font=Enum.Font.GothamBlack,TextSize=17,TextColor3=Color3.new(1,1,1)}),"HOME","หน้าหลัก")
local tlg=make("UIGradient",{},tl)
NX.onAccent(function(a,b) tlg.Color=ColorSequence.new(a,b) end)
local tr=make("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,2),Size=UDim2.new(.7,0,0,16),BackgroundTransparency=1},th)
make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},tr)
L(tag(tr,{LayoutOrder=1}),"🎂 "..lp.AccountAge.." days","🎂 "..lp.AccountAge.." วัน")
tag(tr,{LayoutOrder=2,Text="🆔 "..lp.UserId})

-- โปรไฟล์
local pg=make("Frame",{Position=UDim2.fromOffset(0,26),Size=UDim2.new(1,-156,0,58),BackgroundTransparency=1},c)
local ring=make("Frame",{Position=UDim2.fromOffset(0,2),Size=UDim2.fromOffset(54,54),BackgroundTransparency=1},pg)
round(ring,27) glow(ring,1.5)
TS:Create(make("UIScale",{},ring),TweenInfo.new(1.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Scale=1.07}):Play()
local av=make("ImageLabel",{Size=UDim2.fromOffset(46,46),Position=UDim2.fromOffset(4,6),BackgroundColor3=COL.Side},pg)
round(av,23)
task.spawn(function()
 local ok,img=pcall(function() return Players:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end)
 if ok then av.Image=img end
end)
local nm=txt(pg,{Position=UDim2.fromOffset(66,4),Size=UDim2.new(1,-66,0,18),Text=lp.DisplayName,Font=Enum.Font.GothamBlack,TextSize=15,TextColor3=Color3.new(1,1,1),TextTruncate=Enum.TextTruncate.AtEnd})
local ng=make("UIGradient",{},nm)
NX.onAccent(function(a,b) ng.Color=ColorSequence.new(b,a) end)
txt(pg,{Position=UDim2.fromOffset(66,22),Size=UDim2.new(1,-66,0,12),Text="@"..lp.Name,Font=Enum.Font.Gotham,TextSize=10,TextColor3=COL.Sub,TextTruncate=Enum.TextTruncate.AtEnd})
local hpBack=make("Frame",{Position=UDim2.fromOffset(66,38),Size=UDim2.new(1,-66,0,16),BackgroundColor3=COL.Chip,BackgroundTransparency=.3},pg)
round(hpBack,8)
local fill=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=COL.Green,ClipsDescendants=true},hpBack)
round(fill,8)
local shine=make("Frame",{Size=UDim2.fromScale(.25,1),Position=UDim2.fromScale(-.3,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.7,BorderSizePixel=0},fill)
round(shine,8)
TS:Create(shine,TweenInfo.new(1.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,false,1),{Position=UDim2.fromScale(1.05,0)}):Play()
local hpTxt=txt(hpBack,{Size=UDim2.fromScale(1,1),Text="❤ -- / --",TextSize=10,TextColor3=Color3.new(1,1,1),TextXAlignment=CEN,ZIndex=2})
pop(pg,.05)

local function bindChar(ch)
 local hum=ch:WaitForChild("Humanoid",5)
 if not hum then return end
 local function upd()
  local r=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
  TS:Create(fill,TI,{Size=UDim2.fromScale(r,1),BackgroundColor3=COL.Red:Lerp(COL.Green,r)}):Play()
  hpTxt.Text="❤ "..math.floor(hum.Health).." / "..math.floor(hum.MaxHealth)
 end
 hum.HealthChanged:Connect(upd)
 hum:GetPropertyChangedSignal("MaxHealth"):Connect(upd)
 upd()
end
if lp.Character then task.spawn(bindChar,lp.Character) end
lp.CharacterAdded:Connect(bindChar)

-- ข้อมูลตัวละครฝั่งขวา
local rp=make("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,26),Size=UDim2.fromOffset(148,58),BackgroundTransparency=1},c)
local function pill(y,icon)
 local p=make("Frame",{Position=UDim2.fromOffset(0,y),Size=UDim2.new(1,0,0,26),BackgroundColor3=COL.Chip,BackgroundTransparency=.4},rp)
 round(p,13) glow(p,1)
 return txt(p,{Size=UDim2.fromScale(1,1),TextSize=10,TextXAlignment=CEN,Text=icon.." --"})
end
local spdL=pill(0,"🏃")
local posL=pill(32,"📍")
pop(rp,.1)

-- กราฟ FPS / Ping
local N,W,H=26,144,30
local function chart(i,en,th2,unit,maxLbl,midLbl)
 local f=make("Frame",{Position=UDim2.new(i*.5,i*4,0,90),Size=UDim2.new(.5,-4,0,78),BackgroundColor3=COL.Chip,BackgroundTransparency=.35},c)
 round(f,18) glow(f,1.6)
 L(txt(f,{Position=UDim2.fromOffset(12,6),Size=UDim2.new(.5,0,0,10),TextSize=9,TextColor3=COL.Sub}),en,th2)
 local avg=txt(f,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,6),Size=UDim2.new(.5,0,0,10),TextSize=9,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Right})
 local v=txt(f,{Position=UDim2.fromOffset(12,15),Size=UDim2.new(.7,0,0,18),TextSize=16,Text="--"})
 local gf=make("Frame",{Position=UDim2.fromOffset(10,36),Size=UDim2.new(1,-20,0,38),BackgroundColor3=COL.Bg,BackgroundTransparency=.2},f)
 round(gf,10)
 local gs=make("UIStroke",{Color=COL.Pink,Thickness=1.4,Transparency=.05},gf)
 NX.onAccent(function(a,b) gs.Color=b end)
 local area=make("Frame",{Position=UDim2.fromOffset(26,4),Size=UDim2.fromOffset(W,H),BackgroundTransparency=1},gf)
 for g=0,2 do
  make("Frame",{Position=UDim2.new(0,0,g/2,g==2 and -1 or 0),Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.78,BorderSizePixel=0},area)
  txt(gf,{Position=UDim2.fromOffset(3,4+g*H/2-5),Size=UDim2.fromOffset(22,10),Font=Enum.Font.Gotham,TextSize=7,TextColor3=COL.Sub,TextXAlignment=Enum.TextXAlignment.Right,Text=(g==0) and maxLbl or ((g==1) and midLbl or "0")})
 end
 for g=1,3 do
  make("Frame",{Position=UDim2.new(g/4,0,0,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.9,BorderSizePixel=0},area)
 end
 local cols,segs={},{}
 for k=1,N do
  cols[k]=make("Frame",{AnchorPoint=Vector2.new(.5,1),Position=UDim2.fromOffset((k-1)/(N-1)*W,H),Size=UDim2.fromOffset(math.ceil(W/N),0),BackgroundColor3=COL.Purple,BorderSizePixel=0},area)
  make("UIGradient",{Rotation=90,Transparency=NumberSequence.new(.5,1)},cols[k])
 end
 for k=1,N-1 do
  segs[k]=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(0,2),BackgroundColor3=COL.Purple,BorderSizePixel=0},area)
 end
 local dot=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(7,7),Position=UDim2.fromOffset(W,H),BackgroundColor3=Color3.new(1,1,1)},area)
 round(dot,4)
 pop(f,.15+i*.1)
 local vals,norm={},{}
 for k=1,N do vals[k]=0 norm[k]=0 end
 local ti=TweenInfo.new(.35,Enum.EasingStyle.Quint)
 return function(val,n,good)
  table.remove(vals,1) table.insert(vals,val)
  table.remove(norm,1) table.insert(norm,n)
  local s,cnt=0,0
  for _,x in ipairs(vals) do if x>0 then s+=x cnt+=1 end end
  avg.Text="avg "..math.floor(s/math.max(cnt,1))
  v.Text=val..unit
  local col=COL.Red:Lerp(COL.Green,good)
  TS:Create(v,ti,{TextColor3=col}):Play()
  local px,py={},{}
  for k=1,N do
   px[k]=(k-1)/(N-1)*W
   py[k]=H-math.max(norm[k],.05)*H
   cols[k].BackgroundColor3=col
   TS:Create(cols[k],ti,{Size=UDim2.fromOffset(math.ceil(W/N),H-py[k])}):Play()
  end
  for k=1,N-1 do
   local dx,dy=px[k+1]-px[k],py[k+1]-py[k]
   segs[k].BackgroundColor3=col
   TS:Create(segs[k],ti,{Position=UDim2.fromOffset(px[k]+dx/2,py[k]+dy/2),Size=UDim2.fromOffset(math.sqrt(dx*dx+dy*dy)+1.5,2),Rotation=math.deg(math.atan2(dy,dx))}):Play()
  end
  dot.BackgroundColor3=col
  TS:Create(dot,ti,{Position=UDim2.fromOffset(W,py[N])}):Play()
 end
end
local updFps=chart(0,"⚡ FPS","⚡ FPS","","60","30")
local updPing=chart(1,"📡 Ping","📡 ปิง"," ms","300","150")

local frames,acc=0,0
local conn
conn=RS.RenderStepped:Connect(function(dt)
 if not c:IsDescendantOf(game) then conn:Disconnect() return end
 frames+=1 acc+=dt
 if acc<.6 then return end
 local fps=math.floor(frames/acc+.5)
 frames,acc=0,0
 local r=math.clamp(fps/60,0,1)
 updFps(fps,r,r)
 local ok,ms=pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
 if ok and ms then
  ms=math.floor(ms)
  local q=math.clamp(ms/300,0,1)
  updPing(ms,q,1-q)
 end
end)

-- ปกแมพ
local mp=make("Frame",{Position=UDim2.fromOffset(0,174),Size=UDim2.new(1,0,0,64),BackgroundTransparency=1,ClipsDescendants=true},c)
round(mp,20) glow(mp,1.6)
local aur=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0},mp)
round(aur,20)
local ag=make("UIGradient",{},aur)
NX.onAccent(function(a,b) ag.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,a:Lerp(Color3.new(),.35)),ColorSequenceKeypoint.new(.5,a:Lerp(Color3.new(),.87)),ColorSequenceKeypoint.new(1,b:Lerp(Color3.new(),.18))}) end)
TS:Create(ag,TweenInfo.new(6,Enum.EasingStyle.Linear,Enum.EasingDirection.In,-1),{Rotation=360}):Play()
local img=make("ImageLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ImageTransparency=1,ScaleType=Enum.ScaleType.Crop},mp)
round(img,20)
local ov=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0},mp)
round(ov,20)
make("UIGradient",{Rotation=90,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.8),NumberSequenceKeypoint.new(.5,.6),NumberSequenceKeypoint.new(1,.1)})},ov)
local sh=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(-.2,0,.5,0),Size=UDim2.new(0,28,2,0),Rotation=20,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.88,BorderSizePixel=0},mp)
TS:Create(sh,TweenInfo.new(2.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,false,1.5),{Position=UDim2.new(1.2,0,.5,0)}):Play()
L(txt(mp,{Position=UDim2.fromOffset(14,8),Size=UDim2.new(1,-190,0,12),Font=Enum.Font.Gotham,TextSize=10,TextColor3=COL.Pink}),"🗺 Current map","🗺 แมพที่เล่นอยู่")
local mn=txt(mp,{Position=UDim2.fromOffset(14,28),Size=UDim2.new(1,-28,0,28),Text=game.Name,Font=Enum.Font.GothamBlack,TextSize=17,TextTruncate=Enum.TextTruncate.AtEnd})
local mt=make("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,0,7),Size=UDim2.new(0,180,0,16),BackgroundTransparency=1},mp)
make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},mt)
local pl=tag(mt,{LayoutOrder=1,Text="👥 -- / --"})
local tm=tag(mt,{LayoutOrder=2,Text="⏱ 00:00:00"})
pop(mp,.3)

local srcs={
 "rbxthumb://type=GameIcon&id="..game.GameId.."&w=256&h=256",
 "rbxthumb://type=GameIcon&id="..game.GameId.."&w=150&h=150",
 "rbxthumb://type=Asset&id="..game.PlaceId.."&w=420&h=420",
}
task.spawn(function()
 for _,s in ipairs(srcs) do
  img.Image=s
  local t=0
  while not img.IsLoaded and t<3 do task.wait(.2) t+=.2 end
  if img.IsLoaded then TS:Create(img,TweenInfo.new(.8),{ImageTransparency=0}):Play() return end
 end
 img.Image=""
end)
task.spawn(function()
 local ok,info=pcall(function() return MPS:GetProductInfo(game.PlaceId) end)
 if ok and info then mn.Text=info.Name NX.sub.Text=info.Name end
end)

-- ชิปข้อมูลด้านล่าง (กดคัดลอกได้)
local cr=make("Frame",{Position=UDim2.fromOffset(0,244),Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},c)
make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},cr)
local function chipBtn(i,text,copyVal)
 local b=make("TextButton",{LayoutOrder=i,Size=UDim2.new(1/3,-3,1,0),BackgroundColor3=COL.Chip,BackgroundTransparency=.4,AutoButtonColor=false,Text=text,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=COL.Text},cr)
 round(b,11) glow(b,1)
 if copyVal then
  b.MouseButton1Click:Connect(function()
   pcall(function() setclipboard(copyVal) end)
   local old=b.Text
   b.Text="✔ copied"
   task.delay(1,function() b.Text=old end)
  end)
 end
 pop(b,.4+i*.05)
 return b
end
local memB=chipBtn(1,"🧠 -- MB")
chipBtn(2,"📍 "..game.PlaceId,tostring(game.PlaceId))
chipBtn(3,"🔗 "..string.sub(game.JobId,1,8),game.JobId)

-- ปุ่มคัดลอกลิงก์ Discord
local dc=make("TextButton",{Position=UDim2.fromOffset(0,272),Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.new(1,1,1),AutoButtonColor=false,Text="",ClipsDescendants=true},c)
round(dc,14)
local dcg=make("UIGradient",{Rotation=0},dc)
NX.onAccent(function(a,b) dcg.Color=ColorSequence.new(a:Lerp(Color3.new(),.73),a) end)
make("UIStroke",{Color=Color3.new(1,1,1),Transparency=.75,Thickness=1},dc)
local dci=make("ImageLabel",{Position=UDim2.fromOffset(9,5),Size=UDim2.fromOffset(28,28),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit},dc)
NX.setImg(dci,NX.CFG.DISCORD_ICON_ID)
txt(dc,{Position=UDim2.fromOffset(46,4),Size=UDim2.new(1,-140,0,16),Text="Discord",Font=Enum.Font.GothamBlack,TextSize=14,TextColor3=Color3.new(1,1,1)})
local dsub=L(txt(dc,{Position=UDim2.fromOffset(46,21),Size=UDim2.new(1,-140,0,12),Font=Enum.Font.Gotham,TextSize=9,TextColor3=Color3.fromRGB(225,225,225),TextTruncate=Enum.TextTruncate.AtEnd}),"Copy invite link","คัดลอกลิงก์เชิญ")
local dp=make("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-8,.5,0),Size=UDim2.fromOffset(84,24),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.55},dc)
round(dp,12)
local dbl=L(txt(dp,{Size=UDim2.fromScale(1,1),TextSize=10,TextColor3=Color3.new(1,1,1),TextXAlignment=CEN}),"Copy","คัดลอก")
local dsh=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(-.2,0,.5,0),Size=UDim2.new(0,26,2,0),Rotation=20,BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.8,BorderSizePixel=0},dc)
TS:Create(dsh,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,false,2),{Position=UDim2.new(1.2,0,.5,0)}):Play()
dc.MouseButton1Click:Connect(function()
 local ok=pcall(function() setclipboard(NX.CFG.DISCORD_LINK) end)
 dbl.Text=ok and T("✔ Copied","✔ คัดลอกแล้ว") or T("✖ Failed","✖ ไม่รองรับ")
 if not ok then dsub.Text=NX.CFG.DISCORD_LINK end
 task.delay(1.6,function()
  dbl.Text=T("Copy","คัดลอก")
  dsub.Text=T("Copy invite link","คัดลอกลิงก์เชิญ")
 end)
end)
pop(dc,.55)

-- สถานะใต้เมนูข้าง
local st=make("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,8,1,-8),Size=UDim2.new(1,-16,0,42),BackgroundColor3=COL.Chip,BackgroundTransparency=.4},NX.side)
round(st,16)
local dot=make("Frame",{Position=UDim2.fromOffset(10,8),Size=UDim2.fromOffset(7,7),BackgroundColor3=COL.Green},st)
round(dot,4)
TS:Create(dot,TweenInfo.new(.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=.8}):Play()
L(txt(st,{Position=UDim2.fromOffset(22,4),Size=UDim2.new(1,-26,0,14),TextSize=10,TextColor3=COL.Green}),"Online","ออนไลน์")
local clk=txt(st,{Position=UDim2.fromOffset(10,20),Size=UDim2.new(1,-14,0,16),TextSize=14,Text=os.date("%H:%M:%S")})

-- ลูปอัปเดตสด
task.spawn(function()
 while c:IsDescendantOf(game) do
  local t=math.floor(workspace.DistributedGameTime)
  tm.Text=string.format("⏱ %02d:%02d:%02d",math.floor(t/3600),math.floor(t%3600/60),t%60)
  pl.Text="👥 "..#Players:GetPlayers().." / "..Players.MaxPlayers
  clk.Text=os.date("%H:%M:%S")
  local ok,mem=pcall(function() return math.floor(Stats:GetTotalMemoryUsageMb()) end)
  if ok then memB.Text="🧠 "..mem.." MB" end
  task.wait(1)
 end
end)
task.spawn(function()
 while c:IsDescendantOf(game) do
  local ch=lp.Character
  local hum=ch and ch:FindFirstChildOfClass("Humanoid")
  local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
  if hum then spdL.Text="🏃 "..(math.floor(hum.WalkSpeed*10)/10).." speed" end
  if hrp then
   local p=hrp.Position
   posL.Text=string.format("📍 %d, %d, %d",math.floor(p.X),math.floor(p.Y),math.floor(p.Z))
  end
  task.wait(.25)
 end
end)
end

------------------------------------------------------------------
-- หน้า SETTINGS
------------------------------------------------------------------
do
local NX=getgenv().NX
local COL,make,round,L=NX.COL,NX.make,NX.round,NX.L
local TS=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local HttpService=game:GetService("HttpService")
local TeleportService=game:GetService("TeleportService")
local Lighting=game:GetService("Lighting")
local Players=game:GetService("Players")
local lp=Players.LocalPlayer
local TI=TweenInfo.new(.2,Enum.EasingStyle.Quint)
local S=NX.state
local DEF={scale=.9,alpha=0,accent=1,space=true,afk=false,fps=0,key=true,fx=true,fov=70,fovOn=false,fullbright=false,boost=false}
for k,v in pairs(DEF) do if S[k]==nil then S[k]=v end end

-- โหลด/บันทึกการตั้งค่า (ถ้า executor รองรับ)
local FILE=NX.CFG.SETTINGS_FILE
pcall(function()
 if isfile and isfile(FILE) then
  for k,v in pairs(HttpService:JSONDecode(readfile(FILE))) do S[k]=v end
 end
end)
S.scale=.9 -- เริ่มที่ 90% ทุกครั้ง
local function save() pcall(function() if writefile then writefile(FILE,HttpService:JSONEncode(S)) end end) end
NX.save=save
local function T(en,th) return (NX.getLang()=="TH") and th or en end

local sf=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=COL.Pink,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},NX.pages.settings)
make("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},sf)
make("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},sf)
local ord=0
local ctrls={}

local function txt(p,props)
 props.BackgroundTransparency=1
 props.Font=props.Font or Enum.Font.GothamBold
 props.TextColor3=props.TextColor3 or COL.Text
 props.TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left
 return make("TextLabel",props,p)
end
local function header(en,th,big)
 ord+=1
 local l=txt(sf,{LayoutOrder=ord,Size=UDim2.new(1,0,0,big and 22 or 16),Font=big and Enum.Font.GothamBlack or Enum.Font.GothamBold,TextSize=big and 17 or 10,TextColor3=big and Color3.new(1,1,1) or COL.Pink})
 if big then
  local g=make("UIGradient",{},l)
  NX.onAccent(function(a,b) g.Color=ColorSequence.new(a,b) end)
 end
 L(l,en,th)
end
local function row(h)
 ord+=1
 local r=make("Frame",{LayoutOrder=ord,Size=UDim2.new(1,0,0,h),BackgroundColor3=COL.Chip,BackgroundTransparency=.4},sf)
 round(r,14)
 local s=make("UIStroke",{Color=COL.Pink,Transparency=.65,Thickness=1},r)
 NX.onAccent(function(a,b) s.Color=b end)
 return r
end
local function titles(r,en,th,dEn,dTh,w)
 L(txt(r,{Position=UDim2.fromOffset(14,6),Size=UDim2.new(1,w or -80,0,16),TextSize=12}),en,th)
 if dEn then L(txt(r,{Position=UDim2.fromOffset(14,22),Size=UDim2.new(1,w or -80,0,14),Font=Enum.Font.Gotham,TextSize=9,TextColor3=COL.Sub}),dEn,dTh) end
end

local function toggle(key,en,th,dEn,dTh,cb)
 local r=row(42)
 titles(r,en,th,dEn,dTh)
 local sw=make("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.fromOffset(38,20),Position=UDim2.new(1,-52,.5,-10),BackgroundColor3=COL.Bg},r)
 round(sw,10)
 local knob=make("Frame",{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1)},sw)
 round(knob,7)
 local function set(v,fire)
  S[key]=v
  TS:Create(sw,TI,{BackgroundColor3=v and COL.Purple or COL.Bg}):Play()
  TS:Create(knob,TI,{Position=v and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)}):Play()
  if fire then cb(v) save() end
 end
 sw.MouseButton1Click:Connect(function() set(not S[key],true) end)
 set(S[key],false)
 NX.onAccent(function() sw.BackgroundColor3=S[key] and COL.Purple or COL.Bg end)
 ctrls[key]=set
end

local function button(en,th,dEn,dTh,bEn,bTh,cb,dyn)
 local r=row(42)
 L(txt(r,{Position=UDim2.fromOffset(14,6),Size=UDim2.new(1,-110,0,16),TextSize=12}),en,th)
 local d=txt(r,{Position=UDim2.fromOffset(14,22),Size=UDim2.new(1,-110,0,14),Font=Enum.Font.Gotham,TextSize=9,TextColor3=COL.Sub,TextTruncate=Enum.TextTruncate.AtEnd})
 if dyn then d.Text=T(dEn,dTh) else L(d,dEn,dTh) end
 local b=make("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(84,26),BackgroundColor3=COL.Purple,Text="",AutoButtonColor=false},r)
 round(b,13)
 NX.onAccent(function(a) b.BackgroundColor3=a end)
 local bl=L(txt(b,{Size=UDim2.fromScale(1,1),TextSize=10,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Center}),bEn,bTh)
 b.MouseButton1Click:Connect(function() cb(d,bl,b) end)
 return d,bl
end

local function slider(key,en,th,min,max,fmt,onRelease,cb)
 local r=row(50)
 titles(r,en,th,nil,nil,-90)
 local vl=txt(r,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,6),Size=UDim2.fromOffset(70,16),TextSize=11,TextColor3=COL.Pink,TextXAlignment=Enum.TextXAlignment.Right})
 local track=make("Frame",{Position=UDim2.new(0,14,0,34),Size=UDim2.new(1,-28,0,6),BackgroundColor3=COL.Bg},r)
 round(track,3)
 local fill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=COL.Purple},track)
 round(fill,3)
 local knob=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=Color3.new(1,1,1)},track)
 round(knob,7)
 NX.onAccent(function(a) fill.BackgroundColor3=a end)
 local hit=make("TextButton",{Text="",BackgroundTransparency=1,Position=UDim2.new(0,14,0,22),Size=UDim2.new(1,-28,0,26)},r)
 local function show(v)
  local t=(v-min)/(max-min)
  fill.Size=UDim2.fromScale(t,1) knob.Position=UDim2.fromScale(t,.5)
  vl.Text=fmt(v)
 end
 local function set(v,fire)
  v=math.clamp(v,min,max) S[key]=v show(v)
  if fire then cb(v) end
 end
 local dragging=false
 local function fromX(x)
  local t=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
  local v=min+(max-min)*t
  S[key]=v show(v)
  if not onRelease then cb(v) end
 end
 local function isPtr(i) return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
 hit.InputBegan:Connect(function(i) if isPtr(i) then dragging=true fromX(i.Position.X) end end)
 UIS.InputChanged:Connect(function(i)
  if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then fromX(i.Position.X) end
 end)
 UIS.InputEnded:Connect(function(i)
  if dragging and isPtr(i) then
   dragging=false
   if onRelease then cb(S[key]) end
   save()
  end
 end)
 show(S[key])
 ctrls[key]=set
end

-- ตัวเลือกหลายปุ่ม (ล็อก FPS)
local function segmented(key,en,th,opts,cb)
 local r=row(56)
 titles(r,en,th)
 local holder=make("Frame",{Position=UDim2.fromOffset(14,26),Size=UDim2.new(1,-28,0,24),BackgroundTransparency=1},r)
 make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,5)},holder)
 local bs={}
 local function mark()
  for v,b in pairs(bs) do
   TS:Create(b,TI,{BackgroundColor3=(S[key]==v) and COL.Purple or COL.Bg}):Play()
  end
 end
 for _,o in ipairs(opts) do
  local b=make("TextButton",{Size=UDim2.new(1/#opts,-4,1,0),BackgroundColor3=COL.Bg,Text=o[2],Font=Enum.Font.GothamBold,TextSize=10,TextColor3=COL.Text,AutoButtonColor=false},holder)
  round(b,12)
  bs[o[1]]=b
  b.MouseButton1Click:Connect(function() S[key]=o[1] mark() cb(o[1]) save() end)
 end
 mark()
 NX.onAccent(function() mark() end)
 ctrls[key]=function(v,fire) S[key]=v mark() if fire then cb(v) end end
end

-- เลือกภาษา (ปุ่มใหญ่ ชัดเจน)
local function langRow()
 local r=row(60)
 titles(r,"Language","ภาษา (Language)")
 local holder=make("Frame",{Position=UDim2.fromOffset(14,26),Size=UDim2.new(1,-28,0,28),BackgroundTransparency=1},r)
 make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8)},holder)
 local bs={}
 local function mark()
  for v,b in pairs(bs) do
   local on=(NX.getLang()==v)
   TS:Create(b,TI,{BackgroundColor3=on and COL.Purple or COL.Bg,TextColor3=on and Color3.new(1,1,1) or COL.Sub}):Play()
  end
 end
 for _,o in ipairs({{"TH","🌐 ไทย"},{"EN","🌐 English"}}) do
  local b=make("TextButton",{Size=UDim2.new(.5,-4,1,0),BackgroundColor3=COL.Bg,Text=o[2],Font=Enum.Font.GothamBlack,TextSize=12,TextColor3=COL.Sub,AutoButtonColor=false},holder)
  round(b,14)
  bs[o[1]]=b
  b.MouseButton1Click:Connect(function() NX.setLang(o[1]) end)
 end
 NX.onLang(mark)
 NX.onAccent(function() mark() end)
end

-- เลือกสีธีม
local function colorRow()
 local r=row(56)
 titles(r,"Theme color","สีธีม")
 local holder=make("Frame",{Position=UDim2.fromOffset(14,26),Size=UDim2.new(1,-28,0,24),BackgroundTransparency=1},r)
 make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,10)},holder)
 local sts={}
 local function mark()
  for i,s in ipairs(sts) do s.Transparency=(S.accent==i) and 0 or 1 end
 end
 for i,p in ipairs(PRESETS) do
  local b=make("TextButton",{Size=UDim2.fromOffset(24,24),BackgroundColor3=p[1],Text="",AutoButtonColor=false},holder)
  round(b,12)
  make("UIGradient",{Color=ColorSequence.new(p[1],p[2]),Rotation=45},b)
  sts[i]=make("UIStroke",{Color=Color3.new(1,1,1),Thickness=2,Transparency=1},b)
  b.MouseButton1Click:Connect(function() S.accent=i mark() NX.setAccent(p[1],p[2]) save() end)
 end
 mark()
 ctrls.accent=function(i) if not PRESETS[i] then i=1 end S.accent=i mark() NX.setAccent(PRESETS[i][1],PRESETS[i][2]) end
end

-- ===== ค้นหาเซิร์ฟเวอร์ =====
local function httpGet(url)
 local ok,res=pcall(function() return game:HttpGet(url) end)
 if ok and res and #res>0 then return res end
 local req=(syn and syn.request) or (http and http.request) or http_request or request
 if req then
  local ok2,r=pcall(req,{Url=url,Method="GET"})
  if ok2 and r and r.Body then return r.Body end
 end
end
local function findLow(status)
 local best,cursor
 for page=1,5 do
  status("🔎 "..T("Searching... page ","กำลังค้นหา... หน้า ")..page)
  local url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"..(cursor and ("&cursor="..cursor) or "")
  local body=httpGet(url)
  if not body then return nil,"http" end
  local ok,data=pcall(function() return HttpService:JSONDecode(body) end)
  if not ok or not data or not data.data then return nil,"parse" end
  for _,s in ipairs(data.data) do
   if s.id~=game.JobId and s.playing and s.playing<s.maxPlayers then
    if s.playing<=1 then return s end
    if not best or s.playing<best.playing then best=s end
   end
  end
  cursor=data.nextPageCursor
  if not cursor then break end
  task.wait(.5)
 end
 return nil,"none",best
end
local function findRandom()
 local body=httpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
 if not body then return nil,"http" end
 local ok,data=pcall(function() return HttpService:JSONDecode(body) end)
 if not ok or not data or not data.data then return nil,"parse" end
 local list={}
 for _,s in ipairs(data.data) do
  if s.id~=game.JobId and s.playing and s.playing<s.maxPlayers then list[#list+1]=s end
 end
 if #list==0 then return nil,"none" end
 return list[math.random(#list)]
end

-- ===== ฟังก์ชันเสริม =====
local afkConn
local function setAFK(v)
 if afkConn then afkConn:Disconnect() afkConn=nil end
 if v then
  local VU=game:GetService("VirtualUser")
  afkConn=lp.Idled:Connect(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end)
 end
end

local lightBackup
local function setFull(v)
 pcall(function()
  if v then
   if not lightBackup then
    lightBackup={Brightness=Lighting.Brightness,ClockTime=Lighting.ClockTime,FogEnd=Lighting.FogEnd,GlobalShadows=Lighting.GlobalShadows,Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient}
   end
   Lighting.Brightness=2
   Lighting.ClockTime=14
   Lighting.FogEnd=1e6
   Lighting.GlobalShadows=false
   Lighting.Ambient=Color3.fromRGB(180,180,180)
   Lighting.OutdoorAmbient=Color3.fromRGB(180,180,180)
  elseif lightBackup then
   for k,val in pairs(lightBackup) do Lighting[k]=val end
   lightBackup=nil
  end
 end)
end

local boostedFx,boostQ={},nil
local function setBoost(v)
 if v then
  pcall(function()
   if not boostQ then boostQ=settings().Rendering.QualityLevel end
   settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
  end)
  pcall(function()
   for _,o in ipairs(workspace:GetDescendants()) do
    if (o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") or o:IsA("Beam")) and o.Enabled then
     o.Enabled=false
     boostedFx[#boostedFx+1]=o
    end
   end
  end)
 else
  pcall(function()
   if boostQ then settings().Rendering.QualityLevel=boostQ boostQ=nil end
  end)
  for _,o in ipairs(boostedFx) do pcall(function() o.Enabled=true end) end
  boostedFx={}
 end
end

local origFov
local function applyFov(v)
 local cam=workspace.CurrentCamera
 if cam then cam.FieldOfView=v end
end
local function setFovOn(v)
 local cam=workspace.CurrentCamera
 if not cam then return end
 if v then
  origFov=origFov or cam.FieldOfView
  cam.FieldOfView=S.fov
 elseif origFov then
  cam.FieldOfView=origFov
  origFov=nil
 end
end

------------------------------------------------------------------
-- สร้างเมนูตั้งค่า
------------------------------------------------------------------
header("SETTINGS","ตั้งค่า",true)

header("LANGUAGE","ภาษา")
langRow()

header("SERVER","เซิร์ฟเวอร์")
local pending,searching
button("Find empty server","หาเซิร์ฟเวอร์คนน้อย","Find a server with 0-1 players and join","ค้นหาเซิร์ฟที่มี 0–1 คน แล้ววาร์ปไป","Search","ค้นหา",function(d,bl)
 if searching then return end
 if pending then
  d.Text="🚀 "..T("Teleporting...","กำลังวาร์ป...")
  pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,pending.id,lp) end)
  return
 end
 searching=true
 task.spawn(function()
  local s,err,best=findLow(function(t) d.Text=t end)
  searching=false
  if s then
   d.Text="✅ "..T("Found ","พบเซิร์ฟ ")..s.playing..T(" player, joining..."," คน กำลังวาร์ป...")
   pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,lp) end)
  elseif best then
   pending=best
   d.Text="⚠ "..T("None with 0-1. Lowest: ","ไม่พบ 0–1 คน ต่ำสุดคือ ")..best.playing..T(" - press again to join"," คน กดอีกครั้งเพื่อไป")
   bl.Text=T("Join","ไป")
  else
   d.Text="❌ "..((err=="none") and T("No server found","ไม่พบเซิร์ฟเวอร์") or T("Request failed (HttpGet blocked?)","เรียกข้อมูลไม่ได้ (executor อาจไม่รองรับ)"))
  end
 end)
end,true)
local hopping
button("Server hop","สุ่มเปลี่ยนเซิร์ฟเวอร์","Join a random different server","สุ่มเข้าเซิร์ฟเวอร์อื่น","Hop","สลับ",function(d)
 if hopping then return end
 hopping=true
 d.Text="🔎 "..T("Searching...","กำลังค้นหา...")
 task.spawn(function()
  local s,err=findRandom()
  hopping=false
  if s then
   d.Text="🚀 "..T("Teleporting...","กำลังวาร์ป...")
   pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,lp) end)
  else
   d.Text="❌ "..((err=="none") and T("No server found","ไม่พบเซิร์ฟเวอร์") or T("Request failed","เรียกข้อมูลไม่ได้"))
  end
 end)
end,true)
button("Rejoin","รีจอยเซิร์ฟเวอร์นี้","Rejoin the current server","เข้าเซิร์ฟเวอร์เดิมใหม่","Rejoin","รีจอย",function()
 if #Players:GetPlayers()<=1 then
  pcall(function() TeleportService:Teleport(game.PlaceId,lp) end)
 else
  pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,lp) end)
 end
end)
button("Copy Job ID","คัดลอก Job ID","Copy this server's ID","คัดลอกไอดีเซิร์ฟเวอร์นี้","Copy","คัดลอก",function(d,bl)
 pcall(function() setclipboard(game.JobId) end)
 local o=bl.Text bl.Text="✔"
 task.delay(1,function() bl.Text=o end)
end)
button("Copy game link","คัดลอกลิงก์เกม","Copy this game's Roblox link","คัดลอกลิงก์เกมนี้","Copy","คัดลอก",function(d,bl)
 pcall(function() setclipboard("https://www.roblox.com/games/"..game.PlaceId) end)
 local o=bl.Text bl.Text="✔"
 task.delay(1,function() bl.Text=o end)
end)

header("APPEARANCE","หน้าตา GUI")
slider("scale","GUI size","ขนาด GUI",.7,1.3,function(v) return math.floor(v*100+.5).."%" end,true,function(v)
 if NX.isOpen() then TS:Create(NX.sc,TweenInfo.new(.25,Enum.EasingStyle.Quint),{Scale=v}):Play() end
end)
slider("alpha","Transparency","ความโปร่งใส",0,.6,function(v) return math.floor(v*100+.5).."%" end,false,function(v)
 if NX.isOpen() then NX.win.GroupTransparency=v end
end)
colorRow()
toggle("space","Space effects","เอฟเฟกต์อวกาศ","Stars, nebula, shooting stars","ดาว เนบิวลา ดาวตก",function(v) NX.setSpace(v) end)
toggle("fx","Logo effects","เอฟเฟกต์โลโก้","Orbit, shine and ripple on the logo","วงโคจร แสงวิบ และระลอกที่โลโก้",function(v) NX.setLogoFx(v) end)
button("Reset GUI position","รีเซ็ตตำแหน่ง GUI","Move window and logo back to default","ย้ายหน้าต่างและโลโก้กลับที่เดิม","Reset","รีเซ็ต",function(d,bl)
 NX.resetPos()
 local o=bl.Text bl.Text="✔"
 task.delay(1,function() bl.Text=o end)
end)

header("GRAPHICS","กราฟิก")
do
 local r=row(58)
 L(txt(r,{Position=UDim2.fromOffset(14,6),Size=UDim2.new(1,-150,0,16),TextSize=12}),"Field of view (FOV)","มุมมอง (FOV)")
 local vl=txt(r,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-100,0,6),Size=UDim2.fromOffset(50,16),TextSize=11,TextColor3=COL.Pink,TextXAlignment=Enum.TextXAlignment.Right})
 local st=txt(r,{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-58,0,7),Size=UDim2.fromOffset(30,14),Font=Enum.Font.GothamBlack,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right})
 local sw=make("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.fromOffset(38,20),Position=UDim2.new(1,-52,0,5),BackgroundColor3=COL.Bg},r)
 round(sw,10)
 local sk=make("Frame",{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1)},sw)
 round(sk,7)
 local track=make("Frame",{Position=UDim2.new(0,14,0,40),Size=UDim2.new(1,-28,0,6),BackgroundColor3=COL.Bg},r)
 round(track,3)
 local fill=make("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=COL.Purple},track)
 round(fill,3)
 local knob=make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),Size=UDim2.fromOffset(14,14),BackgroundColor3=Color3.new(1,1,1)},track)
 round(knob,7)
 NX.onAccent(function(a) fill.BackgroundColor3=a if S.fovOn then sw.BackgroundColor3=a end end)
 local hit=make("TextButton",{Text="",BackgroundTransparency=1,Position=UDim2.new(0,14,0,28),Size=UDim2.new(1,-28,0,26)},r)
 local function showV(v)
  local t=(v-50)/70
  fill.Size=UDim2.fromScale(t,1) knob.Position=UDim2.fromScale(t,.5)
  vl.Text=math.floor(v+.5).."°"
 end
 local function setV(v,fire)
  v=math.clamp(v,50,120) S.fov=v showV(v)
  if fire and S.fovOn then applyFov(v) end
 end
 local function setOn(v,fire)
  S.fovOn=v
  TS:Create(sw,TI,{BackgroundColor3=v and COL.Purple or COL.Bg}):Play()
  TS:Create(sk,TI,{Position=v and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)}):Play()
  TS:Create(fill,TI,{BackgroundTransparency=v and 0 or .6}):Play()
  st.Text=v and "ON" or "OFF"
  st.TextColor3=v and COL.Green or COL.Sub
  if fire then setFovOn(v) save() end
 end
 sw.MouseButton1Click:Connect(function() setOn(not S.fovOn,true) end)
 local dragging=false
 local function isPtr(i) return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
 local function fromX(x)
  local t=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
  setV(50+70*t,true)
 end
 hit.InputBegan:Connect(function(i) if isPtr(i) then dragging=true fromX(i.Position.X) end end)
 UIS.InputChanged:Connect(function(i)
  if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then fromX(i.Position.X) end
 end)
 UIS.InputEnded:Connect(function(i)
  if dragging and isPtr(i) then dragging=false save() end
 end)
 setV(S.fov,false) setOn(S.fovOn,false)
 ctrls.fov=setV ctrls.fovOn=setOn
end
toggle("fullbright","Fullbright","แสงสว่างเต็มที่","Remove darkness and fog","ลบความมืดและหมอก",setFull)
toggle("boost","FPS booster","เพิ่ม FPS","Lower quality + disable particles","ลดกราฟิกและปิดพาร์ติเคิล",setBoost)

header("GENERAL","ทั่วไป")
toggle("afk","Anti-AFK","กันหลุดเมื่อ AFK","Prevents idle kick (20 min)","กันโดนเตะเมื่อไม่ขยับ",setAFK)
segmented("fps","FPS cap","ล็อก FPS",{{30,"30"},{60,"60"},{120,"120"},{240,"240"},{0,"∞"}},function(v)
 pcall(function() if setfpscap then setfpscap(v==0 and 999 or v) end end)
end)
toggle("key","Hotkey (RightShift)","คีย์ลัด (RightShift)","Show / hide GUI with RightShift","ซ่อน/แสดง GUI ด้วย RightShift",function(v) S.key=v end)
button("Reset character","รีเซ็ตตัวละคร","Respawn your character","เกิดใหม่","Reset","รีเซ็ต",function()
 local ch=lp.Character
 local h=ch and ch:FindFirstChildOfClass("Humanoid")
 if h then h.Health=0 end
end)

header("COMMUNITY","ชุมชน")
button("Discord","ดิสคอส","Copy the Discord invite link","คัดลอกลิงก์เชิญดิสคอส","Copy","คัดลอก",function(d,bl)
 local ok=pcall(function() setclipboard(NX.CFG.DISCORD_LINK) end)
 local o=bl.Text bl.Text=ok and "✔" or "✖"
 task.delay(1,function() bl.Text=o end)
end)

header("MANAGE","จัดการ")
button("Reset settings","รีเซ็ตการตั้งค่า","Restore default GUI settings","คืนค่าตั้งต้นของ GUI","Reset","รีเซ็ต",function()
 for k,v in pairs(DEF) do S[k]=v end
 for k,v in pairs(DEF) do
  if ctrls[k] then ctrls[k](v,true) end
 end
 save()
end)
button("Unload GUI","ปิดสคริปต์","Remove the GUI and undo changes","ลบ GUI และคืนค่าที่แก้ไว้","Unload","ปิด",function()
 setFull(false) setBoost(false) setAFK(false) setFovOn(false)
 NX.gui:Destroy()
end)

-- ใช้ค่าที่บันทึกไว้ตอนเริ่ม
ctrls.accent(S.accent)
NX.setSpace(S.space)
NX.setLogoFx(S.fx)
setAFK(S.afk)
pcall(function() if setfpscap and S.fps~=0 then setfpscap(S.fps) end end)
if S.fullbright then setFull(true) end
if S.boost then setBoost(true) end
if S.fovOn then setFovOn(true) end
task.spawn(function()
 while NX.gui.Parent do
  if S.fovOn and S.fov then applyFov(S.fov) end
  task.wait(.5)
 end
end)
end


------------------------------------------------------------------
-- หมวด MM2 (RADAR / WARP / FLING / HUNTER / PLAYER / COIN FARM / EVENT)
-- ตัวเชื่อม: สร้างสวิตช์/ปุ่ม/รายการเลือก ในสไตล์ GUI นี้ แล้วให้โมดูล MM2 ใช้
------------------------------------------------------------------
do
local NX=getgenv().NX
local COL,make,round,L=NX.COL,NX.make,NX.round,NX.L
local TS=game:GetService("TweenService")
local TI=TweenInfo.new(.2,Enum.EasingStyle.Quint)

local TR={
 ["mm2_legend"]={"● Innocent   ● Murderer   ● Sheriff   ● Gun","● คนธรรมดา   ● ฆาตกร   ● นายอำเภอ   ● ปืน"},
 ["mm2_secRadar"]={"Radar (ESP)","เรดาร์ (ESP)"},
 ["mm2_espRoles"]={"👁️ Role radar (through walls)","👁️ เรดาร์บทบาท (มองทะลุกำแพง)"},
 ["mm2_espGun"]={"🔫 Dropped gun scan","🔫 สแกนปืนตก"},
 ["mm2_espLine"]={"📏 Target lines","📏 เส้นล็อกเป้า"},
 ["mm2_espBox"]={"🟥 Target box + health bar","🟥 กรอบเป้าหมาย + หลอดเลือด"},
 ["mm2_xray"]={"🩻 X-ray (see-through map)","🩻 X-RAY มองทะลุแมพ"},
 ["mm2_secWarp"]={"Warp","วาร์ป"},
 ["mm2_wGun"]={"🔫 Auto grab gun (as innocent)","🔫 ดูดปืนอัตโนมัติ (คนธรรมดา)"},
 ["mm2_wMurder"]={"🔪 TP to murderer","🔪 ไปหาฆาตกร"},
 ["mm2_wSheriff"]={"🔫 TP to sheriff","🔫 ไปหานายอำเภอ"},
 ["mm2_wList"]={"👥 Select player","👥 เลือกผู้เล่น"},
 ["mm2_wGo"]={"🌀 TP to selected","🌀 วาร์ปไปหาเป้าหมาย"},
 ["mm2_secFling"]={"Fling","ฟลิ้ง"},
 ["mm2_fSheriff"]={"💥 Fling sheriff","💥 ฟลิ้ง นายอำเภอ"},
 ["mm2_fMurder"]={"💥 Fling murderer","💥 ฟลิ้ง ฆาตกร"},
 ["mm2_fGo"]={"💥 Fling selected","💥 ฟลิ้งเป้าหมาย"},
 ["mm2_secHunter"]={"Hunter mode","โหมดล่า"},
 ["mm2_mAuto"]={"🗡️ Auto kill (stab each player)","🗡️ ออโต้ฆ่า (แทงทีละคน)"},
 ["mm2_mAll"]={"💀 Kill all (pull in front)","💀 ฆ่าทั้งแมพ (ลากมาหน้า)"},
 ["mm2_mThrow"]={"🎯 Knife button (right side)","🎯 ปุ่มปามีด (ขวาจอ)"},
 ["mm2_sShoot"]={"🔫 Shoot button (right side)","🔫 ปุ่มยิงฆาตกร (ขวาจอ)"},
 ["mm2_aThrow"]={"🔪 Auto throw (visible only)","🔪 ปามีดอัตโนมัติ (เห็นตัวเท่านั้น)"},
 ["mm2_aShoot"]={"🎯 Auto shoot (visible only)","🎯 ยิงอัตโนมัติ (เห็นตัวเท่านั้น)"},
 ["mm2_secPlayer"]={"Player","ตัวละคร"},
 ["mm2_pNoclip"]={"👻 Ghost mode (noclip)","👻 โหมดผี (ทะลุ)"},
 ["mm2_pSpeed"]={"⚡ Speed +100","⚡ สปีด +100"},
 ["mm2_pJump"]={"🦘 Jump +100","🦘 กระโดด +100"},
 ["mm2_pFly"]={"🕊️ Fly mode","🕊️ โหมดบิน"},
 ["mm2_pTp"]={"📍 Click TP (TP NEXORA tool)","📍 วาร์ปจิ้มจอ (เครื่องมือ TP NEXORA)"},
 ["mm2_pAnti"]={"🛡️ Anti-fling","🛡️ กันฟลิ้ง"},
 ["mm2_secFarm"]={"Farm","ฟาร์ม"},
 ["mm2_cfCoin"]={"🪙 Coin float farm (speed 20, max 40)","🪙 ฟาร์มเหรียญลอย (ความเร็ว 20 ครบ 40)"},
 ["mm2_afk"]={"💤 Anti-AFK","💤 ANTI-AFK กันโดนเตะ"},
 ["mm2_candy"]={"🍬 Auto collect candy","🍬 ออโต้เก็บแคนดี้"},
 ["mm2_secAuto"]={"Auto event","ออโต้อีเวนท์"},
 ["mm2_claim"]={"🎁 Auto claim event rewards","🎁 ออโต้รับรางวัลอีเวนท์"},
 ["mm2_buy"]={"🛒 Auto buy event shop items","🛒 ออโต้ซื้อของอีเวนท์ในร้าน"},
 ["mm2_box"]={"📦 Auto open event mystery box","📦 ออโต้เปิดกล่องสุ่มอีเวนท์"},
 ["mm2_secSpots"]={"Lobby spots","จุดร้านค้าในล็อบบี้"},
 ["mm2_pCraft"]={"🔨 Open crafting","🔨 เปิดหน้าคราฟต์"},
 ["mm2_pBox"]={"📦 Open mystery box shop","📦 เปิดร้านกล่องสุ่ม"},
 ["mm2_pBundle"]={"🎒 Open item bundle shop","🎒 เปิดร้านชุดไอเทม"},
 ["mm2_pKnife"]={"🔪 Open knife shop","🔪 เปิดร้านมีด"},
 ["mm2_pGun"]={"🔫 Open gun shop","🔫 เปิดร้านปืน"},
 ["mm2_secEvent"]={"Event","อีเวนท์"},
 ["mm2_evHint"]={"Event items found on the map get their own switch here. Empty = no event right now.","ของอีเวนท์ที่เจอในแมพจะมีสวิตช์ให้ที่นี่ ถ้าว่าง = ตอนนี้ไม่มีอีเวนท์"},
}

local function txt(p,props)
 props.BackgroundTransparency=1
 props.Font=props.Font or Enum.Font.GothamBold
 props.TextColor3=props.TextColor3 or COL.Text
 props.TextXAlignment=props.TextXAlignment or Enum.TextXAlignment.Left
 return make("TextLabel",props,p)
end
-- ชื่อที่มีคำแปลใน TR จะสลับภาษาตามปุ่ม TH/EN ถ้าไม่มีก็โชว์ตามตัวอักษร
local function lbl(parent,key,props)
 local o=txt(parent,props)
 local v=TR[key]
 if v then L(o,v[1],v[2]) else o.Text=key end
 return o
end

local function newTab(pageName)
 local page=NX.pages[pageName]
 local sf=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=COL.Pink,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},page)
 make("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},sf)
 make("UIPadding",{PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,8)},sf)
 local ord=0
 local tab={}

 local function row(h,parent)
  local r=make("Frame",{Size=UDim2.new(1,0,0,h),BackgroundColor3=COL.Chip,BackgroundTransparency=.4},parent or sf)
  if parent then r.LayoutOrder=1 else ord+=1 r.LayoutOrder=ord end
  round(r,14)
  local s=make("UIStroke",{Color=COL.Pink,Transparency=.65,Thickness=1},r)
  NX.onAccent(function(a,b) s.Color=b end)
  return r
 end

 function tab:Section(o)
  ord+=1
  lbl(sf,o.Title,{LayoutOrder=ord,Size=UDim2.new(1,0,0,16),TextSize=10,TextColor3=COL.Pink})
  return {}
 end

 function tab:Paragraph(o)
  local r=row(34)
  local l=lbl(r,o.Title,{Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-28,1,0),TextSize=11,TextWrapped=true})
  return {SetTitle=function(_,s) l.Text=s end}
 end

 function tab:Toggle(o)
  local r=row(36)
  lbl(r,o.Title,{Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-70,1,0),TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd})
  local sw=make("TextButton",{Text="",AutoButtonColor=false,Size=UDim2.fromOffset(38,20),Position=UDim2.new(1,-52,.5,-10),BackgroundColor3=COL.Bg},r)
  round(sw,10)
  local knob=make("Frame",{Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(3,3),BackgroundColor3=Color3.new(1,1,1)},sw)
  round(knob,7)
  local val=o.Value and true or false
  local function paint()
   TS:Create(sw,TI,{BackgroundColor3=val and COL.Purple or COL.Bg}):Play()
   TS:Create(knob,TI,{Position=val and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3)}):Play()
  end
  sw.MouseButton1Click:Connect(function()
   val=not val paint()
   if o.Callback then pcall(o.Callback,val) end
  end)
  NX.onAccent(function() sw.BackgroundColor3=val and COL.Purple or COL.Bg end)
  paint()
  return {Set=function(_,v) val=v and true or false paint() end}
 end

 function tab:Button(o)
  local r=row(36)
  lbl(r,o.Title,{Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-90,1,0),TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd})
  local danger=(o.Variant=="Danger")
  local b=make("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(56,24),BackgroundColor3=danger and COL.Red or COL.Purple,Text="",AutoButtonColor=false},r)
  round(b,12)
  if not danger then NX.onAccent(function(a) b.BackgroundColor3=a end) end
  L(txt(b,{Size=UDim2.fromScale(1,1),TextSize=10,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Center}),"GO","ทำ")
  b.MouseButton1Click:Connect(function() if o.Callback then pcall(o.Callback) end end)
  return {}
 end

 function tab:Dropdown(o)
  ord+=1
  local box=make("Frame",{LayoutOrder=ord,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},sf)
  make("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},box)
  local r=row(36,box)
  lbl(r,o.Title,{Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-160,1,0),TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd})
  local sel=make("TextButton",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-10,.5,0),Size=UDim2.fromOffset(130,24),BackgroundColor3=COL.Bg,Text="—",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=COL.Text,AutoButtonColor=false,TextTruncate=Enum.TextTruncate.AtEnd},r)
  round(sel,12)
  local list=make("ScrollingFrame",{LayoutOrder=2,Size=UDim2.new(1,0,0,8),BackgroundColor3=COL.Chip,BackgroundTransparency=.4,Visible=false,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=COL.Pink,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},box)
  round(list,12)
  make("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},list)
  make("UIPadding",{PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4),PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4)},list)
  local obj={Value=nil}
  local function build(values)
   for _,c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
   for i,v in ipairs(values) do
    local b=make("TextButton",{LayoutOrder=i,Size=UDim2.new(1,0,0,24),BackgroundColor3=COL.Bg,Text=tostring(v),Font=Enum.Font.GothamBold,TextSize=11,TextColor3=COL.Text,AutoButtonColor=false},list)
    round(b,10)
    b.MouseButton1Click:Connect(function()
     obj.Value=v sel.Text=tostring(v) list.Visible=false
     if o.Callback then pcall(o.Callback,v) end
    end)
   end
   list.Size=UDim2.new(1,0,0,math.min(#values,5)*27+8)
  end
  build(o.Values or {})
  sel.MouseButton1Click:Connect(function() list.Visible=not list.Visible end)
  function obj:Refresh(values) build(values) end
  return obj
 end

 return tab
end

local Tabs={
 MRadar=newTab("mm_radar"),
 MWarp=newTab("mm_warp"),
 MFling=newTab("mm_fling"),
 MHunter=newTab("mm_hunter"),
 MPlayer=newTab("mm_player"),
 MFarm=newTab("mm_farm"),
 MEvent=newTab("mm_event"),
}

-- ====================================================================
-- NEXORA | MM2 : ฟังก์ชันที่ย้ายมาจาก MM2 V8.1 (ยกเว้นหน้าหลัก/ตั้งค่า)
-- หมวดใหม่ในเมนูข้าง: RADAR / WARP / FLING / HUNTER / PLAYER / FARM / EVENT
-- ====================================================================
do
local okM, errM = pcall(function()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local NXH = getgenv().NX
local env = getgenv()

local function T(en, th) return (NXH.getLang() == "TH") and th or en end

local MM = { dead = false }
local conns, cleanups = {}, {}
local function bind(sig, fn)
    local c = sig:Connect(fn)
    conns[#conns + 1] = c
    return c
end
local function onUnload(fn) cleanups[#cleanups + 1] = fn end
local function unload()
    if MM.dead then return end
    MM.dead = true
    for _, f in ipairs(cleanups) do pcall(f) end
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    if env.NX_MM2_UNLOAD == unload then env.NX_MM2_UNLOAD = nil end
end
if env.NX_MM2_UNLOAD then pcall(env.NX_MM2_UNLOAD) end
env.NX_MM2_UNLOAD = unload
pcall(function() if NXH.gui then NXH.gui.Destroying:Connect(unload) end end)

local function mk(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end
local function corner(o, r) return mk("UICorner", { CornerRadius = UDim.new(0, r) }, o) end

-- ชั้นแสดงผลของ MM2 (ปุ่มขวาจอ + เส้น/กรอบ ESP + ข้อความแจ้งเตือน)
local oldUi = playerGui:FindFirstChild("NEXORA_MM2_UI")
if oldUi then oldUi:Destroy() end
local overlay = mk("ScreenGui", {
    Name = "NEXORA_MM2_UI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 998,
}, playerGui)
onUnload(function() overlay:Destroy() end)

local toastL = mk("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -60),
    Size = UDim2.fromOffset(280, 30), BackgroundColor3 = Color3.fromRGB(14, 10, 26),
    BackgroundTransparency = 0.1, TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold,
    TextSize = 12, Visible = false, ZIndex = 50, Text = "",
}, overlay)
corner(toastL, 12)
local toastId = 0
local function toast(en, th)
    toastId += 1
    local id = toastId
    toastL.Text = T(en, th)
    toastL.Visible = true
    task.delay(1.8, function()
        if id == toastId then toastL.Visible = false end
    end)
end

local ESP = { roles = false, gun = false, lines = false, boxes = false }
local K = { auto = false, all = false, throw = false, shoot = false, aThrow = false, aShoot = false }
local P = { noclip = false, speed = false, jump = false, fly = false, tp = false, anti = false }
local FLAGS = { flinging = false, floating = false, warpGun = false }

local function myParts()
    local c = player.Character
    return c, c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end

local function hasTag(inst, tag)
    local ok, r = pcall(function() return inst:HasTag(tag) end)
    return ok and r
end

---------------------------------------------------------------- ข้อมูลบทบาท
local playerData = {}
local pEsp, gEsp, known, roleCache, vis = {}, {}, {}, {}, {}
local ev, fn

local function setData(d)
    if type(d) == "table" then playerData = d end
end

local function findRemote(names, class)
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA(class) and names[d.Name] then return d end
    end
end

local function fetchNow()
    if fn then
        local ok, d = pcall(function() return fn:InvokeServer() end)
        if ok then setData(d) end
    end
end

task.spawn(function()
    for _ = 1, 40 do
        ev = ev or findRemote({ PlayerDataChanged = true }, "RemoteEvent")
        fn = fn or findRemote({ GetCurrentPlayerData = true, GetPlayerData = true }, "RemoteFunction")
        if (ev and fn) or MM.dead then break end
        task.wait(0.5)
    end
    if ev then bind(ev.OnClientEvent, setData) end
    while not MM.dead do
        if fn and (ESP.roles or ESP.gun or ESP.lines or ESP.boxes or FLAGS.warpGun) then
            fetchNow()
        end
        task.wait(1.5)
    end
end)

local function roleFromText(r)
    r = tostring(r or ""):lower()
    if r:find("murder") then return "Murderer" end
    if r:find("sheriff") or r:find("hero") then return "Sheriff" end
    return nil
end

local function toolRole(parent)
    for _, t in ipairs(parent:GetChildren()) do
        if t:IsA("Tool") then
            local n = t.Name:lower()
            if hasTag(t, "Weapon_Knife") or n:find("knife") then return "Murderer" end
            if hasTag(t, "Weapon_Gun") or n == "gun" or n:find("revolver") then return "Sheriff" end
        end
    end
    return nil
end

local function getRole(plr)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum or hum.Health <= 0 then return nil end
    local d = playerData[plr.Name]
    if type(d) == "table" then
        if d.Dead == true then return nil end
        local r = roleFromText(d.Role)
        if r then return r end
    end
    local r = toolRole(char)
    if not r and plr:FindFirstChild("Backpack") then r = toolRole(plr.Backpack) end
    return r or "Innocent"
end

local function distTo(pos)
    local _, hrp = myParts()
    return hrp and math.floor((hrp.Position - pos).Magnitude) or 0
end

---------------------------------------------------------------- ESP engine
local RC = {
    Innocent = Color3.fromRGB(60, 255, 90),
    Murderer = Color3.fromRGB(255, 40, 40),
    Sheriff = Color3.fromRGB(60, 140, 255),
}
local GUN_COL = Color3.fromRGB(255, 220, 0)
local ROLE_TXT = {
    TH = { Innocent = "คนธรรมดา", Murderer = "ฆาตกร", Sheriff = "นายอำเภอ" },
    EN = { Innocent = "Innocent", Murderer = "Murderer", Sheriff = "Sheriff" },
}

local function makeTag(adornee, parent, w, h, offset)
    local g = mk("BillboardGui", {
        Name = "NX_TAG", Adornee = adornee, AlwaysOnTop = true, Size = UDim2.fromOffset(w, h),
        StudsOffset = offset, ResetOnSpawn = false,
    }, parent)
    local l = mk("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
        TextSize = 14, TextStrokeTransparency = 0.15, TextStrokeColor3 = Color3.new(0, 0, 0),
        TextWrapped = true, Text = "",
    }, g)
    return g, l
end

local function makeHL(target, color, fillT)
    return mk("Highlight", {
        Name = "NX_HL", Adornee = target, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        FillColor = color, OutlineColor = color, FillTransparency = fillT, OutlineTransparency = 0,
    }, target)
end

local function clearPlayer(plr)
    local e = pEsp[plr]
    if e then
        pcall(function() e.hl:Destroy() end)
        pcall(function() e.gui:Destroy() end)
        pEsp[plr] = nil
    end
end

local function applyPlayer(plr, role)
    local char = plr.Character
    local head = char and char:FindFirstChild("Head")
    if not (char and head) then clearPlayer(plr) return end
    local e = pEsp[plr]
    if e and (e.char ~= char or not e.hl.Parent or not e.gui.Parent) then
        clearPlayer(plr)
        e = nil
    end
    if not e then
        local hl = makeHL(char, RC[role], 0.55)
        local g, l = makeTag(head, head, 170, 40, Vector3.new(0, 2.6, 0))
        e = { char = char, hl = hl, gui = g, label = l }
        pEsp[plr] = e
    end
    local c = RC[role]
    e.hl.FillColor = c
    e.hl.OutlineColor = c
    e.label.TextColor3 = c
    local rt = ROLE_TXT[NXH.getLang() == "TH" and "TH" or "EN"][role]
    e.label.Text = plr.DisplayName .. "\n" .. rt .. " [" .. distTo(head.Position) .. "m]"
end

local function clearAllPlayers()
    for plr in pairs(pEsp) do clearPlayer(plr) end
end

local function getVis(plr)
    local v = vis[plr]
    if v then return v end
    local line = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, Visible = false }, overlay)
    local box = mk("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false }, overlay)
    local bs = mk("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1, 1, 1), Thickness = 2 }, box)
    local hpBg = mk("Frame", { BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderSizePixel = 0, Visible = false }, overlay)
    local hpFill = mk("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = RC.Innocent, BorderSizePixel = 0,
    }, hpBg)
    v = { line = line, box = box, bs = bs, hpBg = hpBg, hpFill = hpFill }
    vis[plr] = v
    return v
end

local function hideVis(v)
    v.line.Visible = false
    v.box.Visible = false
    v.hpBg.Visible = false
end

local function clearVis(plr)
    local v = vis[plr]
    if v then
        v.line:Destroy()
        v.box:Destroy()
        v.hpBg:Destroy()
        vis[plr] = nil
    end
end

local function drawPlayer(cam, plr, v, origin)
    local role = roleCache[plr]
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (role and hrp) then hideVis(v) return end
    local p, onScreen = cam:WorldToViewportPoint(hrp.Position)
    if not (onScreen and p.Z > 0) then hideVis(v) return end

    local c = RC[role]
    if ESP.lines then
        local d = Vector2.new(p.X, p.Y) - origin
        v.line.BackgroundColor3 = c
        v.line.Size = UDim2.fromOffset(d.Magnitude, 2)
        v.line.Position = UDim2.fromOffset(origin.X + d.X / 2, origin.Y + d.Y / 2)
        v.line.Rotation = math.deg(math.atan2(d.Y, d.X))
        v.line.Visible = true
    else
        v.line.Visible = false
    end

    if ESP.boxes then
        local t = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0))
        local b = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.2, 0))
        local h = math.abs(b.Y - t.Y)
        local w = h * 0.55
        v.box.Position = UDim2.fromOffset(p.X - w / 2, t.Y)
        v.box.Size = UDim2.fromOffset(w, h)
        v.bs.Color = c
        v.box.Visible = true
        local frac = hum and math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1) or 1
        v.hpBg.Position = UDim2.fromOffset(p.X - w / 2 - 7, t.Y)
        v.hpBg.Size = UDim2.fromOffset(4, h)
        v.hpFill.Size = UDim2.fromScale(1, frac)
        v.hpFill.BackgroundColor3 = Color3.fromHSV(frac * 0.33, 1, 1)
        v.hpBg.Visible = true
    else
        v.box.Visible = false
        v.hpBg.Visible = false
    end
end

local wasVis = false
bind(RunService.RenderStepped, function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    if not (ESP.lines or ESP.boxes) then
        if wasVis then
            for _, v in pairs(vis) do hideVis(v) end
            wasVis = false
        end
        return
    end
    wasVis = true
    local origin = Vector2.new(vp.X / 2, 0)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then drawPlayer(cam, plr, getVis(plr), origin) end
    end
    for plr in pairs(vis) do
        if not plr.Parent then clearVis(plr) end
    end
end)

---------------------------------------------------------------- ปืนที่ตก
local lastGunScan = 0

local function isDrop(inst)
    local n = inst.Name:lower()
    if (n:find("gundrop") or n:find("droppedgun")) and (inst:IsA("BasePart") or inst:IsA("Model")) then
        return true
    end
    if inst:IsA("Tool") and hasTag(inst, "Weapon_Gun") and not Players:GetPlayerFromCharacter(inst.Parent) then
        return true
    end
    return false
end

local function adorneePart(inst)
    if inst:IsA("BasePart") then return inst end
    return inst:FindFirstChildWhichIsA("BasePart", true)
end

local function pretty(s) return (tostring(s):gsub("(%l)(%u)", "%1 %2")) end

local function gunName()
    for _, d in pairs(playerData) do
        if type(d) == "table" and roleFromText(d.Role) == "Sheriff" and d.Gun then return pretty(d.Gun) end
    end
    for _, d in pairs(playerData) do
        if type(d) == "table" and d.Gun then return pretty(d.Gun) end
    end
    return nil
end

local function clearGun(inst)
    local e = gEsp[inst]
    if e then
        pcall(function() e.hl:Destroy() end)
        pcall(function() e.gui:Destroy() end)
        gEsp[inst] = nil
    end
end

local function gunGone(inst)
    return not inst:IsDescendantOf(workspace)
        or (inst:IsA("Tool") and Players:GetPlayerFromCharacter(inst.Parent) ~= nil)
end

local function updateGuns()
    local name = gunName() or "Gun"
    for inst in pairs(known) do
        if gunGone(inst) then
            clearGun(inst)
            known[inst] = nil
        else
            local part = adorneePart(inst)
            if part then
                local e = gEsp[inst]
                if e and (not e.hl.Parent or not e.gui.Parent) then
                    clearGun(inst)
                    e = nil
                end
                if not e then
                    local hl = makeHL(inst, GUN_COL, 0.3)
                    local g, l = makeTag(part, part, 170, 40, Vector3.new(0, 2, 0))
                    l.TextColor3 = GUN_COL
                    l.TextSize = 15
                    e = { hl = hl, gui = g, label = l }
                    gEsp[inst] = e
                end
                e.label.Text = "🔫 " .. name .. "\n[" .. distTo(part.Position) .. "m]"
            end
        end
    end
end

local function clearAllGuns()
    for inst in pairs(gEsp) do clearGun(inst) end
end

bind(workspace.DescendantAdded, function(d)
    if isDrop(d) then known[d] = true end
end)

local function scanDrops()
    local d = workspace:FindFirstChild("GunDrop", true)
    if d and isDrop(d) then known[d] = true end
end

local function gunPart()
    for inst in pairs(known) do
        if gunGone(inst) then
            known[inst] = nil
        else
            local p = adorneePart(inst)
            if p then return p end
        end
    end
    if os.clock() - lastGunScan > 2 then
        lastGunScan = os.clock()
        scanDrops()
    end
    return nil
end

-- ลูปหลักของ ESP
task.spawn(function()
    local gunWas, lastScan = false, 0
    while not MM.dead do
        task.wait(0.2)
        local ok, err = pcall(function()
            if ESP.roles or ESP.lines or ESP.boxes then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player then roleCache[plr] = getRole(plr) end
                end
            end
            for plr in pairs(roleCache) do
                if not plr.Parent then roleCache[plr] = nil end
            end
            if ESP.roles then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player then
                        local role = roleCache[plr]
                        if role then applyPlayer(plr, role) else clearPlayer(plr) end
                    end
                end
                for plr in pairs(pEsp) do
                    if not plr.Parent then clearPlayer(plr) end
                end
            else
                clearAllPlayers()
            end
            if ESP.gun then
                if not gunWas or os.clock() - lastScan > 3 then
                    scanDrops()
                    lastScan = os.clock()
                end
                updateGuns()
            else
                clearAllGuns()
            end
            gunWas = ESP.gun
        end)
        if not ok then warn("[NXMM2 ESP]", err) end
    end
end)

onUnload(function()
    ESP.roles, ESP.gun, ESP.lines, ESP.boxes = false, false, false, false
    clearAllPlayers()
    clearAllGuns()
    for plr in pairs(vis) do clearVis(plr) end
end)

---------------------------------------------------------------- รายชื่อผู้เล่น (ใช้ร่วมกันหลายหมวด)
local dropdowns = {}
local function playerNames()
    local l = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then l[#l + 1] = p.Name end
    end
    table.sort(l)
    return l
end
local function refreshAllDropdowns()
    local n = playerNames()
    for _, d in ipairs(dropdowns) do pcall(function() d:Refresh(n) end) end
end
bind(Players.PlayerAdded, function() task.delay(0.3, refreshAllDropdowns) end)
bind(Players.PlayerRemoving, function() task.delay(0.3, refreshAllDropdowns) end)

---------------------------------------------------------------- หมวด RADAR
do
    local tab = Tabs.MRadar
    tab:Paragraph({ Title = "mm2_legend" })
    tab:Section({ Title = "mm2_secRadar" })
    tab:Toggle({ Title = "mm2_espRoles", Value = false, Callback = function(v) ESP.roles = v end })
    tab:Toggle({ Title = "mm2_espGun", Value = false, Callback = function(v) ESP.gun = v end })
    tab:Toggle({ Title = "mm2_espLine", Value = false, Callback = function(v) ESP.lines = v end })
    tab:Toggle({ Title = "mm2_espBox", Value = false, Callback = function(v) ESP.boxes = v end })

    -- X-RAY : ทำให้ทุกอย่างในแมพใส (ฝั่งเราเท่านั้น)
    local XR = { on = false, parts = setmetatable({}, { __mode = "k" }) }

    local function isChar(d)
        local a = d.Parent
        while a and a ~= workspace do
            if a:IsA("Model") and Players:GetPlayerFromCharacter(a) then return true end
            a = a.Parent
        end
        return false
    end

    local function xrPart(d)
        if d:IsA("BasePart") and not d:IsA("Terrain") and not XR.parts[d]
            and not d.Name:lower():find("coin") and not isChar(d) then
            XR.parts[d] = true
            d.LocalTransparencyModifier = 0.7
        end
    end

    bind(workspace.DescendantAdded, function(d)
        if XR.on then xrPart(d) end
    end)

    local function xrOn()
        XR.on = true
        task.spawn(function()
            local n = 0
            for _, d in ipairs(workspace:GetDescendants()) do
                if not XR.on then return end
                xrPart(d)
                n += 1
                if n % 400 == 0 then task.wait() end
            end
        end)
    end

    local function xrOff()
        XR.on = false
        for p in pairs(XR.parts) do
            pcall(function() p.LocalTransparencyModifier = 0 end)
            XR.parts[p] = nil
        end
    end

    tab:Toggle({ Title = "mm2_xray", Value = false, Callback = function(v)
        if v then xrOn() else xrOff() end
    end })
    onUnload(xrOff)
end

---------------------------------------------------------------- หมวด WARP
do
    local tab = Tabs.MWarp

    local function warpTo(plr)
        local c = player.Character
        local tc = plr and plr.Character
        local th = tc and tc:FindFirstChild("HumanoidRootPart")
        if c and th and c:FindFirstChild("HumanoidRootPart") then
            c:PivotTo(th.CFrame * CFrame.new(0, 0, 3))
            return true
        end
        return false
    end

    local function warpToRole(role, missEn, missTh)
        fetchNow()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and getRole(plr) == role then
                if not warpTo(plr) then toast("Failed (no character)", "ทำไม่ได้ (ไม่พบตัวละคร)") end
                return
            end
        end
        toast(missEn, missTh)
    end

    tab:Section({ Title = "mm2_secWarp" })
    tab:Toggle({ Title = "mm2_wGun", Value = false, Callback = function(v) FLAGS.warpGun = v end })
    tab:Button({ Title = "mm2_wMurder", Callback = function()
        warpToRole("Murderer", "Murderer not found", "ไม่พบฆาตกร")
    end })
    tab:Button({ Title = "mm2_wSheriff", Callback = function()
        warpToRole("Sheriff", "Sheriff not found", "ไม่พบนายอำเภอ")
    end })

    local sel
    dropdowns[#dropdowns + 1] = tab:Dropdown({ Title = "mm2_wList", Values = playerNames(), Callback = function(v) sel = v end })
    tab:Button({ Title = "mm2_wGo", Callback = function()
        local plr = sel and Players:FindFirstChild(sel)
        if not plr then toast("No player selected", "ยังไม่ได้เลือกผู้เล่น") return end
        if not warpTo(plr) then toast("Failed (no character)", "ทำไม่ได้ (ไม่พบตัวละคร)") end
    end })

    -- ดูดปืนอัตโนมัติ (ตอนเป็นคนธรรมดา)
    task.spawn(function()
        local busy = false
        while not MM.dead do
            task.wait(0.4)
            if FLAGS.warpGun and not busy and getRole(player) == "Innocent" then
                local part = gunPart()
                local c = player.Character
                if part and c and c:FindFirstChild("HumanoidRootPart") then
                    busy = true
                    local back = c:GetPivot()
                    c:PivotTo(part.CFrame)
                    task.wait(0.4)
                    c = player.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then c:PivotTo(back) end
                    task.wait(2)
                    busy = false
                end
            end
        end
    end)
end

---------------------------------------------------------------- หมวด HUNTER
do
    local tab = Tabs.MHunter
    local RANGE_GUN, RANGE_KNIFE = 250, 150 -- ระยะสูงสุดของโหมดอัตโนมัติ (แก้เลขได้)

    local function alive(plr)
        local ch = plr.Character
        local h = ch and ch:FindFirstChildOfClass("Humanoid")
        local r = ch and ch:FindFirstChild("HumanoidRootPart")
        if h and r and h.Health > 0 then return ch, r end
        return nil
    end

    local function hasRemote(t, words)
        for _, d in ipairs(t:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                local n = d.Name:lower()
                for _, w in ipairs(words) do
                    if n:find(w, 1, true) then return true end
                end
            end
        end
        return false
    end

    local function isKnife(t)
        if not t:IsA("Tool") then return false end
        return t.Name:lower():find("knife") ~= nil or hasTag(t, "Weapon_Knife") or hasRemote(t, { "throw" })
    end

    local function isGun(t)
        if not t:IsA("Tool") or isKnife(t) then return false end
        local n = t.Name:lower()
        return n:find("gun") ~= nil or n:find("revolver") ~= nil or hasTag(t, "Weapon_Gun")
            or hasRemote(t, { "shoot", "createbeam" })
    end

    local function findTool(test)
        local c = player.Character
        if c then
            for _, t in ipairs(c:GetChildren()) do if test(t) then return t end end
        end
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, t in ipairs(bp:GetChildren()) do if test(t) then return t end end
        end
        return nil
    end

    -- ถืออยู่แล้วก็ใช้เลย ถ้ายังไม่ถือ รอจนสวมเสร็จ (สูงสุด 1 วินาที)
    local function equip(t)
        if not t then return nil end
        local c, _, hum = myParts()
        if not (c and hum) then return nil end
        if t.Parent ~= c then
            pcall(function() hum:EquipTool(t) end)
            local t0 = os.clock()
            while t.Parent ~= c and os.clock() - t0 < 1 do task.wait(0.05) end
        end
        if t.Parent == c then return t end
        return nil
    end
    local function equipKnife() return equip(findTool(isKnife)) end
    local function equipGun() return equip(findTool(isGun)) end

    local function pickRemote(tool, names)
        local list = {}
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then list[#list + 1] = d end
        end
        for _, w in ipairs(names) do
            for _, d in ipairs(list) do
                if d.Name:lower() == w then return d end
            end
        end
        for _, w in ipairs(names) do
            for _, d in ipairs(list) do
                if d.Name:lower():find(w, 1, true) then return d end
            end
        end
        return nil
    end

    local function dumpRemotes(tag, tool)
        local names = {}
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
                names[#names + 1] = d.Name
                print("[NX " .. tag .. "]", d:GetFullName(), d.ClassName)
            end
        end
        return #names > 0 and table.concat(names, ",") or "-"
    end

    local function fire(remote, ...)
        local a = table.pack(...)
        if remote:IsA("RemoteFunction") then
            task.spawn(function() pcall(function() remote:InvokeServer(table.unpack(a, 1, a.n)) end) end)
        else
            pcall(function() remote:FireServer(table.unpack(a, 1, a.n)) end)
        end
    end

    local function handPos()
        local c, hrp = myParts()
        local hand = c and (c:FindFirstChild("RightHand") or c:FindFirstChild("Right Arm"))
        local p = hand or hrp
        return p and p.Position
    end

    -- เล็งนำเป้าเล็กน้อยตามความเร็วที่เดิน
    local function aimPoint(r, from)
        local v = r.AssemblyLinearVelocity
        local lead = Vector3.new(v.X, 0, v.Z)
        if lead.Magnitude > 60 then lead = lead.Unit * 60 end
        local t = math.clamp((r.Position - from).Magnitude / 140, 0, 0.35)
        return r.Position + lead * t
    end

    -- เห็นตัวจริงไหม: ยิงเส้นจากหัวเราไปหาเป้า ถ้ากำแพงหรือผู้เล่นอื่นบังจะไม่เห็น
    local function canSee(targetChar, part)
        local c, hrp = myParts()
        if not (c and hrp and part and part.Parent) then return false end
        local origin = (c:FindFirstChild("Head") or hrp).Position
        local dir = part.Position - origin
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.IgnoreWater = true
        local ignore = { c }
        for _ = 1, 8 do
            params.FilterDescendantsInstances = ignore
            local res = workspace:Raycast(origin, dir, params)
            if not res then return true end
            local hit = res.Instance
            if hit:IsDescendantOf(targetChar) then return true end
            local m = hit:FindFirstAncestorOfClass("Model")
            if m and m:FindFirstChildOfClass("Humanoid") then return false end
            if hit.CanCollide then return false end
            ignore[#ignore + 1] = hit
        end
        return false
    end

    local function throwAt(r, silent)
        local knife = equipKnife()
        if not knife then
            if not silent then toast("No knife found", "ไม่พบมีดในตัว") end
            return false
        end
        local from = handPos()
        if not from then return false end
        local aim = aimPoint(r, from)
        local rem = pickRemote(knife, { "throw", "knifethrown", "throwknife" })
        if rem then
            fire(rem, CFrame.new(from), CFrame.new(aim))
            return true
        end
        local list = dumpRemotes("KNIFE", knife)
        if not silent then
            toast("Weapon remote not found: " .. list, "ไม่พบรีโมตอาวุธ: " .. list)
            pcall(function() knife:Activate() end)
        end
        return false
    end

    local function shootAt(r, silent)
        local gun = equipGun()
        if not gun then
            if not silent then toast("No gun found", "ไม่พบปืนในตัว") end
            return false
        end
        local from = handPos()
        if not from then return false end
        local aim = aimPoint(r, from)
        local rem = pickRemote(gun, { "shoot" })
        if rem then
            fire(rem, CFrame.new(from), CFrame.new(aim)) -- ปืนรุ่นใหม่
            return true
        end
        rem = pickRemote(gun, { "createbeam", "fire", "shot" })
        if rem then
            fire(rem, 1, aim, "AH2") -- ปืนรุ่นเก่า
            return true
        end
        local list = dumpRemotes("GUN", gun)
        if silent then return false end
        toast("Weapon remote not found: " .. list, "ไม่พบรีโมตอาวุธ: " .. list)
        local cam = workspace.CurrentCamera
        if cam then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, r.Position) end
        pcall(function() gun:Activate() end)
        return true
    end

    local function murdererTarget(fresh)
        if fresh then fetchNow() end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and getRole(plr) == "Murderer" then
                local ch, r = alive(plr)
                if ch then return r, ch end
            end
        end
        return nil
    end

    local function nearest(rangeMax, needVisible)
        local _, hrp = myParts()
        if not hrp then return nil end
        local best, bch, bd
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local ch, r = alive(plr)
                if ch then
                    local d = (r.Position - hrp.Position).Magnitude
                    if (not rangeMax or d <= rangeMax) and (not bd or d < bd) then
                        if not needVisible or canSee(ch, r) then
                            best, bch, bd = r, ch, d
                        end
                    end
                end
            end
        end
        return best, bch
    end

    local function stab(knife, targetRoot)
        pcall(function() knife:Activate() end)
        local handle = knife:FindFirstChild("Handle")
        if firetouchinterest and handle then
            pcall(firetouchinterest, targetRoot, handle, 0)
            pcall(firetouchinterest, targetRoot, handle, 1)
        end
    end

    -- ออโต้ฆ่า
    task.spawn(function()
        while not MM.dead do
            task.wait(0.15)
            if K.auto then
                local ok, err = pcall(function()
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if not K.auto then break end
                        if plr ~= player then
                            local ch, r = alive(plr)
                            local _, hrp = myParts()
                            if ch and hrp then
                                local knife = equipKnife()
                                if not knife then toast("No knife found", "ไม่พบมีดในตัว") task.wait(1) break end
                                local pos = (r.CFrame * CFrame.new(0, 0, 3)).Position
                                hrp.CFrame = CFrame.lookAt(pos, r.Position)
                                task.wait(0.12)
                                stab(knife, r)
                                task.wait(0.35)
                            end
                        end
                    end
                end)
                if not ok then warn("[NXMM2 KILL]", err) end
            end
        end
    end)

    -- ฆ่าทั้งแมพ (ลากมาข้างหน้าเฉพาะฝั่งเรา)
    bind(RunService.Heartbeat, function()
        if not K.all then return end
        local _, hrp = myParts()
        if not hrp then return end
        local n = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local ch, r = alive(plr)
                if ch then
                    n += 1
                    local col = (n - 1) % 5 - 2
                    local row = math.floor((n - 1) / 5)
                    r.CFrame = hrp.CFrame * CFrame.new(col * 2, 0, -4 - row * 2)
                    r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end)

    task.spawn(function()
        while not MM.dead do
            task.wait(0.3)
            if K.all then
                pcall(function()
                    local knife = equipKnife()
                    if not knife then return end
                    pcall(function() knife:Activate() end)
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= player then
                            local ch, r = alive(plr)
                            if ch then stab(knife, r) end
                        end
                    end
                end)
            end
        end
    end)

    -- ปุ่มปามีด / ปุ่มยิง ข้างขวาจอ
    local function sideButton(y, textEn, textTh, color, bg)
        local b = mk("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.45, y),
            Size = UDim2.fromOffset(70, 70), BackgroundColor3 = bg, TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold, TextSize = 13, Text = "", AutoButtonColor = false,
            Visible = false, ZIndex = 20,
        }, overlay)
        corner(b, 16)
        mk("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = color, Thickness = 2.5 }, b)
        local function setText() b.Text = T(textEn, textTh) end
        setText()
        pcall(function() NXH.onLang(setText) end)
        return b
    end

    local throwBtn = sideButton(0, "🔪\nTHROW", "🔪\nปามีด", Color3.fromRGB(255, 70, 85), Color3.fromRGB(70, 16, 30))
    local shootBtn = sideButton(84, "🔫\nSHOOT", "🔫\nยิง", Color3.fromRGB(60, 140, 255), Color3.fromRGB(16, 40, 90))

    local busyT = false
    throwBtn.Activated:Connect(function()
        if busyT then return end
        busyT = true
        local ok, err = pcall(function()
            local r = nearest(nil, true)
            if not r then r = nearest(nil, false) end
            if not r then toast("No target found", "ไม่พบเป้าหมาย") return end
            if throwAt(r, false) then toast("🔪 Thrown", "🔪 ปาแล้ว") end
        end)
        if not ok then warn("[NXMM2 THROW]", err) end
        busyT = false
    end)

    local busyS = false
    shootBtn.Activated:Connect(function()
        if busyS then return end
        busyS = true
        local ok, err = pcall(function()
            local r = murdererTarget(true)
            if not r then toast("Murderer not found", "ไม่พบฆาตกร") return end
            if shootAt(r, false) then toast("🔫 Shot", "🔫 ยิงแล้ว") end
        end)
        if not ok then warn("[NXMM2 SHOOT]", err) end
        busyS = false
    end)

    -- ปามีด/ยิง อัตโนมัติ: ทำงานเฉพาะตอนมองเห็นเป้าจริง
    local lastFetch = 0
    task.spawn(function()
        local lastS, lastT = 0, 0
        while not MM.dead do
            task.wait(0.1)
            if (K.aShoot or K.aThrow) and not FLAGS.flinging then
                pcall(function()
                    local c, hrp, hum = myParts()
                    if not (c and hrp and hum and hum.Health > 0) then return end

                    if K.aShoot and os.clock() - lastS > 0.4 and findTool(isGun) then
                        if os.clock() - lastFetch > 1.5 then
                            lastFetch = os.clock()
                            fetchNow()
                        end
                        local r, ch = murdererTarget(false)
                        if r and (r.Position - hrp.Position).Magnitude <= RANGE_GUN and canSee(ch, r) then
                            if shootAt(r, true) then lastS = os.clock() else lastS = os.clock() + 2 end
                        end
                    end

                    if K.aThrow and os.clock() - lastT > 0.8 and findTool(isKnife) then
                        local r = nearest(RANGE_KNIFE, true)
                        if r then
                            if throwAt(r, true) then lastT = os.clock() else lastT = os.clock() + 2 end
                        end
                    end
                end)
            end
        end
    end)

    tab:Section({ Title = "mm2_secHunter" })
    tab:Toggle({ Title = "mm2_mAuto", Value = false, Callback = function(v) K.auto = v end })
    tab:Toggle({ Title = "mm2_mAll", Value = false, Callback = function(v) K.all = v end })
    tab:Toggle({ Title = "mm2_mThrow", Value = false, Callback = function(v) K.throw = v throwBtn.Visible = v end })
    tab:Toggle({ Title = "mm2_sShoot", Value = false, Callback = function(v) K.shoot = v shootBtn.Visible = v end })
    tab:Toggle({ Title = "mm2_aThrow", Value = false, Callback = function(v) K.aThrow = v end })
    tab:Toggle({ Title = "mm2_aShoot", Value = false, Callback = function(v) K.aShoot = v end })

    onUnload(function()
        for k in pairs(K) do K[k] = false end
    end)
end

---------------------------------------------------------------- หมวด FLING
do
    local tab = Tabs.MFling
    local busy = false
    local TIMEOUT, ROUNDS = 2.5, 3

    local function hb() RunService.Heartbeat:Wait() end

    local function zeroAll(c)
        for _, d in ipairs(c:GetChildren()) do
            if d:IsA("BasePart") then
                d.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                d.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end
    end

    local function flingPlayer(plr)
        if busy then toast("Already flinging", "กำลังฟลิ้งอยู่") return end
        local c = player.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        local tch = plr and plr.Character
        local troot = tch and tch:FindFirstChild("HumanoidRootPart")
        local thum = tch and tch:FindFirstChildOfClass("Humanoid")
        if not (hrp and hum and hum.Health > 0 and troot and thum and thum.Health > 0) then
            toast("Failed (no character)", "ทำไม่ได้ (ไม่พบตัวละคร)")
            return
        end

        busy = true
        FLAGS.flinging = true
        local homeCF = hrp.CFrame
        local startPos = troot.Position
        local cam = workspace.CurrentCamera
        local oldSubject = cam and cam.CameraSubject
        local oldFall = workspace.FallenPartsDestroyHeight
        pcall(function() workspace.FallenPartsDestroyHeight = 0 / 0 end)
        pcall(function() cam.CameraSubject = thum end)

        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(9e8, 9e8, 9e8)
        bv.Parent = hrp

        local function pose(offset, ang)
            local cf = CFrame.new(troot.Position) * offset * ang
            pcall(function() c:PivotTo(cf) end)
            hrp.AssemblyLinearVelocity = Vector3.new(9e7, 9e8, 9e7)
            hrp.AssemblyAngularVelocity = Vector3.new(9e8, 9e8, 9e8)
            hb()
        end

        local function targetGone()
            return not (plr.Parent and plr.Character == tch and troot.Parent) or thum.Health <= 0
        end

        local flung = false
        local ok, err = pcall(function()
            for _ = 1, ROUNDS do
                local t0 = os.clock()
                local angle = 0
                while true do
                    if targetGone() or hum.Health <= 0 or not hrp.Parent then break end
                    local spd = troot.AssemblyLinearVelocity.Magnitude
                    if spd > 500 or (troot.Position - startPos).Magnitude > 300 then
                        flung = true
                        break
                    end
                    if os.clock() - t0 > TIMEOUT then break end
                    if spd < 50 then
                        angle += 100
                        local lead = CFrame.new(thum.MoveDirection * spd / 10)
                        local a = CFrame.Angles(math.rad(angle), 0, 0)
                        pose(CFrame.new(0, 1.5, 0) * lead, a)
                        pose(CFrame.new(0, -1.5, 0) * lead, a)
                        pose(CFrame.new(2.25, 1.5, -2.25) * lead, a)
                        pose(CFrame.new(-2.25, -1.5, 2.25) * lead, a)
                        pose(CFrame.new(0, 1.5, 0) * CFrame.new(thum.MoveDirection), a)
                        pose(CFrame.new(0, -1.5, 0) * CFrame.new(thum.MoveDirection), a)
                    else
                        local ws = thum.WalkSpeed
                        pose(CFrame.new(0, 1.5, ws), CFrame.Angles(math.rad(90), 0, 0))
                        pose(CFrame.new(0, -1.5, -ws), CFrame.Angles(0, 0, 0))
                        pose(CFrame.new(0, 1.5, ws), CFrame.Angles(math.rad(90), 0, 0))
                        pose(CFrame.new(0, 1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        pose(CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                        pose(CFrame.new(0, 1.5, 0), CFrame.Angles(0, 0, 0))
                    end
                end
                if flung or targetGone() or hum.Health <= 0 then break end
            end
        end)
        if not ok then warn("[NXMM2 FLING]", err) end

        bv:Destroy()
        pcall(function() cam.CameraSubject = oldSubject or hum end)
        for i = 1, 90 do
            if not (hrp.Parent and c.Parent) then break end
            pcall(function() c:PivotTo(homeCF * CFrame.new(0, 0.5, 0)) end)
            zeroAll(c)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            hb()
            if i >= 12 and (hrp.Position - homeCF.Position).Magnitude < 15 then break end
        end
        pcall(function() workspace.FallenPartsDestroyHeight = oldFall end)
        FLAGS.flinging = false
        busy = false
        toast("Fling finished ✓", "ฟลิ้งเสร็จแล้ว ✓")
    end

    local function flingRole(role, missEn, missTh)
        fetchNow()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and getRole(plr) == role then
                task.spawn(flingPlayer, plr)
                return
            end
        end
        toast(missEn, missTh)
    end

    tab:Section({ Title = "mm2_secFling" })
    tab:Button({ Title = "mm2_fSheriff", Variant = "Secondary", Callback = function()
        flingRole("Sheriff", "Sheriff not found", "ไม่พบนายอำเภอ")
    end })
    tab:Button({ Title = "mm2_fMurder", Variant = "Danger", Callback = function()
        flingRole("Murderer", "Murderer not found", "ไม่พบฆาตกร")
    end })

    local sel
    dropdowns[#dropdowns + 1] = tab:Dropdown({ Title = "mm2_wList", Values = playerNames(), Callback = function(v) sel = v end })
    tab:Button({ Title = "mm2_fGo", Callback = function()
        local plr = sel and Players:FindFirstChild(sel)
        if not plr then toast("No player selected", "ยังไม่ได้เลือกผู้เล่น") return end
        task.spawn(flingPlayer, plr)
    end })

    onUnload(function() FLAGS.flinging = false end)
end

---------------------------------------------------------------- หมวด PLAYER
do
    local tab = Tabs.MPlayer
    local WALK_BASE, WALK_ADD = 16, 100
    local JUMP_BASE, JUMP_ADD = 50, 100
    local FLY_SPEED = 66

    local orig = setmetatable({}, { __mode = "k" })
    local noclipWas = false
    bind(RunService.Stepped, function()
        local c = player.Character
        if not c then return end
        if P.noclip and not FLAGS.flinging then
            noclipWas = true
            for _, d in ipairs(c:GetDescendants()) do
                if d:IsA("BasePart") then
                    if orig[d] == nil then orig[d] = d.CanCollide end
                    d.CanCollide = false
                end
            end
        elseif noclipWas then
            noclipWas = false
            for part, v in pairs(orig) do
                if part.Parent then part.CanCollide = v end
                orig[part] = nil
            end
        end
    end)

    bind(RunService.Heartbeat, function()
        local _, _, hum = myParts()
        if not hum then return end
        if P.speed then hum.WalkSpeed = WALK_BASE + WALK_ADD end
        if P.jump then
            hum.UseJumpPower = true
            hum.JumpPower = JUMP_BASE + JUMP_ADD
        end
    end)

    local flyBV, flyBG
    local function stopFly()
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
        local _, _, hum = myParts()
        if hum then hum.AutoRotate = true end
    end

    local function startFly()
        local _, hrp, hum = myParts()
        if not hrp then return end
        stopFly()
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.P = 9e4
        flyBG.CFrame = hrp.CFrame
        flyBG.Parent = hrp
        if hum then hum.AutoRotate = false end
    end

    bind(RunService.RenderStepped, function()
        if not P.fly then return end
        if FLAGS.flinging or FLAGS.floating then
            if flyBV then stopFly() end
            return
        end
        local _, hrp, hum = myParts()
        local cam = workspace.CurrentCamera
        if not (hrp and hum and cam) then return end
        if not (flyBV and flyBV.Parent == hrp) then startFly() end
        if not flyBV then return end
        local look = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local fl = Vector3.new(look.X, 0, look.Z)
        local fr = Vector3.new(right.X, 0, right.Z)
        local vel = Vector3.new(0, 0, 0)
        local md = hum.MoveDirection
        if md.Magnitude > 0.05 and fl.Magnitude > 0.01 and fr.Magnitude > 0.01 then
            vel = (look * md:Dot(fl.Unit) + right * md:Dot(fr.Unit)) * FLY_SPEED
        end
        flyBV.Velocity = vel
        if flyBG and fl.Magnitude > 0.01 then
            flyBG.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + fl)
        end
    end)

    local tpTool
    local function giveTool()
        if tpTool and tpTool.Parent then return end
        local bp = player:FindFirstChild("Backpack")
        if not bp then return end
        tpTool = Instance.new("Tool")
        tpTool.Name = "TP NEXORA"
        tpTool.ToolTip = "TP NEXORA"
        tpTool.RequiresHandle = false
        tpTool.CanBeDropped = false
        tpTool.Activated:Connect(function()
            local c = player.Character
            local mouse = player:GetMouse()
            if c and mouse and mouse.Hit then
                c:PivotTo(CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)))
            end
        end)
        tpTool.Parent = bp
    end

    task.spawn(function()
        while not MM.dead do
            task.wait(1)
            if P.tp then giveTool() end
        end
    end)

    bind(RunService.Stepped, function()
        if not P.anti or FLAGS.flinging then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                for _, d in ipairs(plr.Character:GetDescendants()) do
                    if d:IsA("BasePart") then d.CanCollide = false end
                end
            end
        end
    end)

    bind(RunService.Heartbeat, function()
        if not P.anti or FLAGS.flinging then return end
        local _, hrp = myParts()
        if hrp and (hrp.AssemblyLinearVelocity.Magnitude > 250 or hrp.AssemblyAngularVelocity.Magnitude > 60) then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end)

    tab:Section({ Title = "mm2_secPlayer" })
    tab:Toggle({ Title = "mm2_pNoclip", Value = false, Callback = function(v) P.noclip = v end })
    tab:Toggle({ Title = "mm2_pSpeed", Value = false, Callback = function(v)
        P.speed = v
        if not v then
            local _, _, hum = myParts()
            if hum then hum.WalkSpeed = WALK_BASE end
        end
    end })
    tab:Toggle({ Title = "mm2_pJump", Value = false, Callback = function(v)
        P.jump = v
        if not v then
            local _, _, hum = myParts()
            if hum then hum.JumpPower = JUMP_BASE end
        end
    end })
    tab:Toggle({ Title = "mm2_pFly", Value = false, Callback = function(v)
        P.fly = v
        if not v then stopFly() end
    end })
    tab:Toggle({ Title = "mm2_pTp", Value = false, Callback = function(v)
        P.tp = v
        if v then giveTool() elseif tpTool then tpTool:Destroy() tpTool = nil end
    end })
    tab:Toggle({ Title = "mm2_pAnti", Value = false, Callback = function(v) P.anti = v end })

    onUnload(function()
        for k in pairs(P) do P[k] = false end
        stopFly()
        local _, _, hum = myParts()
        if hum then
            hum.WalkSpeed = WALK_BASE
            hum.JumpPower = JUMP_BASE
        end
        for part, v in pairs(orig) do
            if part.Parent then part.CanCollide = v end
            orig[part] = nil
        end
        if tpTool then tpTool:Destroy() tpTool = nil end
    end)
end

---------------------------------------------------------------- หมวด FARM
do
    local tab = Tabs.MFarm
    local LIMIT = 40
    local SPEED = 20 -- ความเร็วลอย (แก้เลขนี้ได้)
    local FARM = { on = false }
    local collected, lastCont, lastFind = 0, nil, 0
    local done, target, tStart, tLimit, arrT = {}, nil, 0, 3, nil
    local lastTouch = 0
    local fv, fg = nil, nil
    local floating = false
    local orig = setmetatable({}, { __mode = "k" })
    local toastedDone = false

    tab:Section({ Title = "mm2_secFarm" })
    local countP = tab:Paragraph({ Title = "🪙 0 / " .. LIMIT })

    local function coinPart(o)
        if o:IsA("BasePart") then return o end
        return o:FindFirstChildWhichIsA("BasePart", true)
    end

    local function nextCoin(cont, hrp)
        local best, bd
        for _, o in ipairs(cont:GetChildren()) do
            local p = coinPart(o)
            if p and p.Parent and not done[p] then
                local d = (p.Position - hrp.Position).Magnitude
                if not bd or d < bd then best, bd = p, d end
            end
        end
        return best, bd
    end

    local function release()
        if fv then fv:Destroy() fv = nil end
        if fg then fg:Destroy() fg = nil end
        for part, v in pairs(orig) do
            if part.Parent then part.CanCollide = v end
            orig[part] = nil
        end
        if floating then
            floating = false
            FLAGS.floating = false
            local _, _, hum = myParts()
            if hum then
                hum.PlatformStand = false
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            end
        end
    end

    local function engage(hrp, hum)
        if not (fv and fv.Parent == hrp) then
            if fv then fv:Destroy() end
            fv = Instance.new("BodyVelocity")
            fv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
            fv.Velocity = Vector3.new(0, 0, 0)
            fv.Parent = hrp
        end
        if not (fg and fg.Parent == hrp) then
            if fg then fg:Destroy() end
            fg = Instance.new("BodyGyro")
            fg.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
            fg.P = 1e5
            fg.D = 1e3
            fg.CFrame = hrp.CFrame
            fg.Parent = hrp
        end
        floating = true
        FLAGS.floating = true
        hum.PlatformStand = true
    end

    local function resetRound()
        release()
        collected = 0
        done = {}
        target, arrT = nil, nil
        toastedDone = false
    end
    bind(player.CharacterAdded, resetRound)

    local function setCount()
        pcall(function()
            countP:SetTitle("🪙 " .. collected .. " / " .. LIMIT
                .. (collected >= LIMIT and "  ✓" or (floating and "  ☁️" or "")))
        end)
    end
    task.spawn(function()
        while not MM.dead do
            task.wait(0.5)
            setCount()
        end
    end)

    bind(RunService.Stepped, function()
        if not floating then return end
        local c = player.Character
        if not c then return end
        for _, d in ipairs(c:GetDescendants()) do
            if d:IsA("BasePart") then
                if orig[d] == nil then orig[d] = d.CanCollide end
                d.CanCollide = false
            end
        end
    end)

    bind(RunService.Heartbeat, function()
        if not FARM.on or FLAGS.flinging then release() return end
        local c, hrp, hum = myParts()
        if not (c and hrp and hum and hum.Health > 0) then release() return end

        if os.clock() - lastFind > 1 or (lastCont and not lastCont.Parent) then
            lastFind = os.clock()
            local f = workspace:FindFirstChild("CoinContainer", true)
            if f ~= lastCont then
                lastCont = f
                resetRound()
            end
        end
        local cont = lastCont

        if collected >= LIMIT then
            release()
            if not toastedDone then
                toastedDone = true
                toast("All coins collected ✓", "เก็บเหรียญครบแล้ว ✓")
            end
            return
        end
        if not cont then release() return end

        if target then
            if not target.Parent then
                done[target] = true
                collected += 1
                target, arrT = nil, nil
            elseif os.clock() - tStart > tLimit then
                done[target] = true
                target, arrT = nil, nil
            end
        end
        if not target then
            local coin, d0 = nextCoin(cont, hrp)
            if not coin then release() return end
            target = coin
            tStart = os.clock()
            tLimit = 1.5 + (d0 / SPEED) * 1.5
        end

        engage(hrp, hum)
        local to = target.Position - hrp.Position
        local dist = to.Magnitude
        if dist < 1.2 then
            fv.Velocity = Vector3.new(0, 0, 0)
        else
            fv.Velocity = to.Unit * math.min(SPEED, math.max(dist * 6, 12))
            local flat = Vector3.new(to.X, 0, to.Z)
            if flat.Magnitude > 0.5 then
                fg.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + flat)
            end
        end

        if dist < 2.5 then
            arrT = arrT or os.clock()
            if os.clock() - arrT > 0.4 then
                done[target] = true
                collected += 1
                target, arrT = nil, nil
            end
        else
            arrT = nil
        end

        if target and dist < 6 and firetouchinterest and os.clock() - lastTouch > 0.15 then
            lastTouch = os.clock()
            pcall(firetouchinterest, hrp, target, 0)
            pcall(firetouchinterest, hrp, target, 1)
        end
    end)

    tab:Toggle({ Title = "mm2_cfCoin", Value = false, Callback = function(v)
        FARM.on = v
        if not v then release() end
    end })
    onUnload(function() FARM.on = false release() end)

    local afkOn = false
    bind(player.Idled, function()
        if afkOn then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end
    end)
    tab:Toggle({ Title = "mm2_afk", Value = false, Callback = function(v) afkOn = v end })
end

---------------------------------------------------------------- หมวด EVENT
-- สแกนหาของอีเวนท์ในแมพเอง แล้วสร้างสวิตช์ให้ทีละชนิดอัตโนมัติ (ไม่มีอีเวนท์ = หมวดว่าง)
do
    local tab = Tabs.MEvent
    local EV = { active = {}, groups = {} }

    -- คำที่ใช้เดาว่าเป็นของอีเวนท์ (เติมเองได้ถ้าแอดมินตั้งชื่อแปลก)
    local KEYWORDS = {
        "shell", "seashell", "clam", "pearl", "candy", "pumpkin", "egg", "snowflake",
        "gift", "present", "token", "orb", "crystal", "gem", "collect", "event",
        "star", "ticket", "treat", "candies", "halloween", "spooky",
    }

    local function matchName(n)
        n = n:lower()
        if n:find("coin") then return false end
        for _, k in ipairs(KEYWORDS) do
            if n:find(k, 1, true) then return true end
        end
        return false
    end

    local function candyLike(s) return tostring(s):lower():find("cand", 1, true) ~= nil end
    local CANDY_COLORS = { Purple = true, Green = true, Cyan = true, Orange = true, Pink = true }
    local function attrId(d)
        for _, k in ipairs({ "CoinID", "CoinType", "ItemType", "Type", "EventItem" }) do
            local v = d:GetAttribute(k)
            if type(v) == "string" and v ~= "" then return v end
        end
        return nil
    end

    local function inChar(d)
        local a = d.Parent
        while a and a ~= workspace do
            if (a:IsA("Model") and Players:GetPlayerFromCharacter(a)) or a:IsA("Tool") then
                return true
            end
            a = a.Parent
        end
        return false
    end

    local SPEED = 20
    local release
    local fv, fg, floating = nil, nil, false
    local orig = setmetatable({}, { __mode = "k" })
    local done = setmetatable({}, { __mode = "k" })
    local target, tStart, tLimit, arrT, lastTouch = nil, 0, 3, nil, 0

    tab:Section({ Title = "mm2_secEvent" })
    tab:Toggle({ Title = "mm2_candy", Value = false, Callback = function(v)
        EV.active["Candy"] = v or nil
        if not v and not next(EV.active) then release() end
    end })
    tab:Paragraph({ Title = "mm2_evHint" })

    function release()
        if fv then fv:Destroy() fv = nil end
        if fg then fg:Destroy() fg = nil end
        for p, v in pairs(orig) do
            if p.Parent then p.CanCollide = v end
            orig[p] = nil
        end
        if floating then
            floating = false
            FLAGS.floating = false
            local _, _, hum = myParts()
            if hum then
                hum.PlatformStand = false
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            end
        end
        target, arrT = nil, nil
    end

    local function addGroup(name)
        EV.groups[name] = { items = setmetatable({}, { __mode = "k" }) }
        if name == "Candy" then return end
        tab:Toggle({ Title = "🎁 " .. name, Value = false, Callback = function(v)
            EV.active[name] = v or nil
            if not v and not next(EV.active) then release() end
        end })
    end

    local function consider(d)
        if not d:IsA("BasePart") or d:IsA("Terrain") then return end
        local inCont = d:FindFirstAncestor("CoinContainer") ~= nil
        if not inCont and not d:FindFirstChildWhichIsA("TouchTransmitter") then return end
        if inChar(d) then return end
        local id = attrId(d)
        local name
        if candyLike(d.Name) or (d.Parent and candyLike(d.Parent.Name)) or (id and candyLike(id))
            or (inCont and CANDY_COLORS[d.Name]) then
            name = "Candy"
        elseif inCont and id and id:lower() ~= "coin" then
            name = id
        elseif matchName(d.Name) then
            name = d.Name
        elseif d.Parent and d.Parent ~= workspace and matchName(d.Parent.Name) then
            name = d.Parent.Name
        end
        if not name then return end
        if not EV.groups[name] then addGroup(name) end
        EV.groups[name].items[d] = true
    end

    bind(workspace.DescendantAdded, function(d) task.defer(consider, d) end)

    task.spawn(function()
        local n = 0
        for _, d in ipairs(workspace:GetDescendants()) do
            if MM.dead then return end
            pcall(consider, d)
            n += 1
            if n % 300 == 0 then task.wait() end
        end
    end)

    local function nextItem(hrp)
        local best, bd
        for name in pairs(EV.active) do
            local g = EV.groups[name]
            if g then
                for p in pairs(g.items) do
                    if p.Parent and p:IsDescendantOf(workspace) and not done[p] then
                        local d = (p.Position - hrp.Position).Magnitude
                        if not bd or d < bd then best, bd = p, d end
                    end
                end
            end
        end
        return best, bd
    end

    bind(RunService.Stepped, function()
        if not floating then return end
        local c = player.Character
        if not c then return end
        for _, d in ipairs(c:GetDescendants()) do
            if d:IsA("BasePart") then
                if orig[d] == nil then orig[d] = d.CanCollide end
                d.CanCollide = false
            end
        end
    end)

    bind(RunService.Heartbeat, function()
        if not next(EV.active) or FLAGS.flinging then
            if floating then release() end
            return
        end
        if FLAGS.floating and not floating then return end -- ฟาร์มเหรียญกำลังลอยอยู่

        local c, hrp, hum = myParts()
        if not (c and hrp and hum and hum.Health > 0) then release() return end

        if target then
            if not target.Parent or os.clock() - tStart > tLimit then
                done[target] = true
                target, arrT = nil, nil
            end
        end
        if not target then
            local item, d0 = nextItem(hrp)
            if not item then release() return end
            target = item
            tStart = os.clock()
            tLimit = 1.5 + (d0 / SPEED) * 1.5
        end

        if not (fv and fv.Parent == hrp) then
            if fv then fv:Destroy() end
            fv = Instance.new("BodyVelocity")
            fv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
            fv.Velocity = Vector3.new(0, 0, 0)
            fv.Parent = hrp
        end
        if not (fg and fg.Parent == hrp) then
            if fg then fg:Destroy() end
            fg = Instance.new("BodyGyro")
            fg.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
            fg.P = 1e5
            fg.D = 1e3
            fg.CFrame = hrp.CFrame
            fg.Parent = hrp
        end
        floating = true
        FLAGS.floating = true
        hum.PlatformStand = true

        local to = target.Position - hrp.Position
        local dist = to.Magnitude
        if dist < 1.2 then
            fv.Velocity = Vector3.new(0, 0, 0)
        else
            fv.Velocity = to.Unit * math.min(SPEED, math.max(dist * 6, 12))
        end

        if dist < 2.5 then
            arrT = arrT or os.clock()
            if os.clock() - arrT > 0.4 then
                done[target] = true
                target, arrT = nil, nil
            end
        else
            arrT = nil
        end

        if target and dist < 6 and firetouchinterest and os.clock() - lastTouch > 0.15 then
            lastTouch = os.clock()
            pcall(firetouchinterest, hrp, target, 0)
            pcall(firetouchinterest, hrp, target, 1)
        end
    end)

    onUnload(function()
        EV.active = {}
        release()
    end)
end


---------------------------------------------------------------- EVENT : ออโต้รับรางวัล / ซื้อของ / เปิดกล่อง (ผ่านปุ่มใน UI ของเกม)
do
    local tab = Tabs.MEvent
    local AUTO = { claim = false, buy = false, box = false }

    -- กดปุ่มใน UI ของเกมโดยเรียกการเชื่อมต่อของปุ่มตรงๆ (ต้องใช้ตัวรันที่รองรับ getconnections หรือ firesignal)
    local function clickBtn(b)
        local fired = false
        if getconnections then
            for _, sig in ipairs({ b.Activated, b.MouseButton1Click }) do
                pcall(function()
                    for _, c in ipairs(getconnections(sig)) do
                        pcall(function() c:Fire() end)
                        fired = true
                    end
                end)
                if fired then break end
            end
        end
        if not fired and firesignal then
            pcall(function() firesignal(b.Activated) fired = true end)
            if not fired then pcall(function() firesignal(b.MouseButton1Click) fired = true end) end
        end
        return fired
    end

    local function isBtn(o) return o:IsA("TextButton") or o:IsA("ImageButton") end

    local function cross() return playerGui:FindFirstChild("CrossPlatform") end
    local function evRoot()
        local c = cross()
        return c and c:FindFirstChild("Halloween2026")
    end

    -- แถวที่เป็นของแลกด้วย Robux จะไม่กด (กันเด้งหน้าต่างซื้อ)
    local function robuxRow(btn)
        local a = btn.Parent
        for _ = 1, 4 do
            if not a then break end
            local r = a:FindFirstChild("RobuxCost", true) or a:FindFirstChild("RobuxIcon", true)
            if r then return true end
            a = a.Parent
        end
        return false
    end

    local function path(root, ...)
        local o = root
        for _, n in ipairs({ ... }) do
            o = o and o:FindFirstChild(n)
        end
        return o
    end

    -- ออโต้รับรางวัล: เพลงบัตรผ่าน (Battle Pass) + เควสอีเวนท์
    local function claimAll()
        local ev = evRoot()
        if not ev then return end
        local spots = {
            path(ev, "MainEvent", "Main", "BattlePass", "Rewards"),
            path(ev, "MainEvent", "Main", "Quests"),
            path(ev, "MainEvent", "Main", "QuestBoard"),
            path(ev, "Event", "Main", "Rewards"),
        }
        for _, root in pairs(spots) do
            for _, d in ipairs(root:GetDescendants()) do
                if not (AUTO.claim and not MM.dead) then return end
                if isBtn(d) and d.Name == "ActionButton" and d.Visible and not robuxRow(d) then
                    clickBtn(d)
                    task.wait(0.15)
                end
            end
        end
    end

    -- ออโต้ซื้อของอีเวนท์ในร้าน (เฉพาะแถวที่เป็นของอีเวนท์ ไม่เอาแถว Robux)
    local function buyAll()
        local c = cross()
        local shop = c and c:FindFirstChild("Shop")
        if not shop then return end
        for _, d in ipairs(shop:GetDescendants()) do
            if not (AUTO.buy and not MM.dead) then return end
            if isBtn(d) and d.Name == "ActionButton" and d.Visible then
                local row = d.Parent and d.Parent.Parent
                local isEvent = row and (row:GetAttribute("ItemType") == "Event" or row.Name:find("Halloween2026"))
                if isEvent and not robuxRow(d) then
                    clickBtn(d)
                    task.wait(0.4)
                end
            end
        end
    end

    -- ออโต้เปิดกล่องสุ่มอีเวนท์ (ปุ่มจ่ายด้วยเหรียญอีเวนท์)
    local function openBox()
        local ev = evRoot()
        local btn = path(ev, "MainEvent", "Main", "MysteryBox", "BuyFrame", "Currency", "Button")
        if btn and isBtn(btn) then clickBtn(btn) end
    end

    task.spawn(function()
        while not MM.dead do
            task.wait(3)
            if AUTO.claim then pcall(claimAll) end
            if AUTO.buy then pcall(buyAll) end
        end
    end)
    task.spawn(function()
        while not MM.dead do
            task.wait(1.5)
            if AUTO.box then pcall(openBox) end
        end
    end)

    tab:Section({ Title = "mm2_secAuto" })
    tab:Toggle({ Title = "mm2_claim", Value = false, Callback = function(v) AUTO.claim = v end })
    tab:Toggle({ Title = "mm2_buy", Value = false, Callback = function(v) AUTO.buy = v end })
    tab:Toggle({ Title = "mm2_box", Value = false, Callback = function(v) AUTO.box = v end })

    onUnload(function() for k in pairs(AUTO) do AUTO[k] = false end end)

    -- ปุ่มลัดจุดร้านค้าในล็อบบี้ (ใช้พร็อมต์ของเกมโดยตรง)
    local function usePrompt(partName)
        local part = workspace:FindFirstChild(partName, true)
        local pp = part and part:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not pp then toast("Spot not found (go to lobby)", "ไม่พบจุดนี้ (ต้องอยู่ล็อบบี้)") return end
        if fireproximityprompt then
            pcall(function() pp.HoldDuration = 0 end)
            pcall(fireproximityprompt, pp)
        else
            local c = player.Character
            if c and part:IsA("BasePart") then c:PivotTo(part.CFrame * CFrame.new(0, 0, 4)) end
        end
    end

    tab:Section({ Title = "mm2_secSpots" })
    tab:Button({ Title = "mm2_pCraft", Callback = function() usePrompt("CraftingPrompt") end })
    tab:Button({ Title = "mm2_pBox", Callback = function() usePrompt("MysteryBoxPrompt") end })
    tab:Button({ Title = "mm2_pBundle", Callback = function() usePrompt("ItemBundlePrompt") end })
    tab:Button({ Title = "mm2_pKnife", Callback = function() usePrompt("KnifePrompt") end })
    tab:Button({ Title = "mm2_pGun", Callback = function() usePrompt("GunPrompt") end })
end

end) -- pcall MM2
if not okM then warn("[Nexora] MM2 module error: " .. tostring(errM)) end
end

end

------------------------------------------------------------------
-- เริ่มทำงาน: รอหน้าโหลดจบ แล้วเด้งโลโก้ + เปิดหน้าต่าง
------------------------------------------------------------------
do
 local NX=getgenv().NX
 NX.setLang(NX.state.lang or "TH")
 Loader.finish(function()
  if not NX.gui.Parent then return end
  TS:Create(logo,TweenInfo.new(.5,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(LS,LS)}):Play()
  task.delay(.6,function() NX.setOpen(true) end)
 end)
end
