local appName="Throttle cut, dual input" 
local appDescription1="To get out of throttle cut requires" 
local appDescription2="throttle control to be at idle position" 
local cut = 1
local ctrlOutCreated
local switchIn
local stickIn


local function switchChanged(value)
  switchIn=value
  system.pSave("_CUT_switchIn",value)
end

local function stickChanged(value)
  stickIn=value
  system.pSave("_CUT_stickIn",value)
end


local function initForm(subform)
  form.addLabel({label=appDescription1})
  form.addLabel({label=appDescription2})

  form.addLabel({label=""})
  
  form.addRow(2)
  form.addLabel({label="Throttle cut switch"})
  form.addInputbox(switchIn,true,switchChanged)
  
  form.addRow(2)
  form.addLabel({label="Throttle stick/switch"})
  form.addInputbox(stickIn,true,stickChanged)
  
  form.addLabel({label="(if stick set to proportional)"})

end

local function printForm()
	lcd.drawText(10, 120, "Throttle cut active")
	
	if (string.find (system.getDeviceType(),"24")) then 
	  if (cut==1) then
	    lcd.drawImage (140,120,":okBig") 
	  else
	    lcd.drawImage (140,120,":crossBig") 
      end
	else
	  if (cut==1) then
        lcd.drawText(140,120,"YES", FONT_BOLD) 
	  else
	    lcd.drawText(140,120,"no", FONT_BOLD) 
      end
	end

end

-- Init function
local function init() 
  system.registerForm(1,MENU_ADVANCED,appName,initForm,nil,printForm) 

  switchIn = system.pLoad("_CUT_switchIn")
  stickIn = system.pLoad("_CUT_stickIn")

  
--  local ctrlNumber = 1
--  while (not ctrlOutCreated) do
--  ctrlOutCreated = system.registerControl(ctrlNumber, "ThrCut, stick at idle for reset","CUT")
--    ctrlNumber = ctrlNumber + 1
--  end

-- Use fixed control number, might collide with other scripts, but ensures control always is on the specific number and not dependant on script loading order.
  ctrlOutCreated = system.registerControl(1, "ThrCut, stick at idle for reset","CUT")
end

-- Loop function
local function loop()   
  if(ctrlOutCreated and switchIn and stickIn) then
    -- Get position of inputs
    local switch, stick = system.getInputsVal( switchIn, stickIn)
    -- if switch is ON (1) then set cut switch ON (1)
    if (switch==1) then
      cut = 1
    end
    -- if switch is OFF (-1) AND stick at idle position, then set cut switch OFF (-1)   
    if(switch == -1 and stick <= -0.99) then
      cut = -1
    end
    -- send status of cut switch  (to control CUT created in the init function)
    system.setControl(ctrlOutCreated, cut,0,0)
    end
end


return { init=init, loop=loop, author="ClausT on JetiForum.de", version="1.02",name=appName}