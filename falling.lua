--[[
Falling - Based on Tetris by Alexey Pajitnov
This version written by Gopher, at the request of Dan200, for
ComputerCraft v1.6. No particular rights are reserved.
--]]

--Color picker between RGB and monochrome
local function colorass(c,bw)
    return term.isColor() and c or bw
  end
  
--clockwise rotation
local function rotateCoords(coordsTable, amount)
  for i=1,amount do
    coordsTable = {-coordsTable[2], coordsTable[1]} --
  end
  return coordsTable
end

local PIECES = {"l", "j", "s", "z", "o", "t", "i"}

local TPEZ = {l= {{0, 0}, {-1, 0}, {1, 0}, {1, -1}},
        j= {{0, 0}, {-1, 0}, {1, 0}, {-1, -1}},
        o= {{0, 0}, {0, -1}, {1, 0}, {1, -1}},
        s= {{0, 0}, {-1, 0}, {0, -1}, {1, -1}},
        z= {{0, 0}, {-1, -1}, {0, -1}, {1, 0}},
        t= {{0, 0}, {-1, 0}, {1, 0}, {0, -1}},
        i= {{0, 0}, {-1, 0}, {1, 0}, {2, 0}}}

local TPCLR = {l = colorass(colors.orange, colors.white),
         j = colorass(colors.blue, colors.white),
         o = colorass(colors.yellow, colors.white),
         s = colorass(colors.green, colors.white),
         z = colorass(colors.red, colors.white),
         t = colorass(colors.purple, colors.white),
         i = colorass(colors.lightBlue, colors.white)}

local SRS = {["0>>1"] = {{0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2}},
       ["1>>0"]= {{0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2}},
       ["1>>2"]= {{0, 0}, {1, 0}, {1, 1}, {0, -2}, {1, -2}},
       ["2>>1"]= {{0, 0}, {-1, 0}, {-1, -1}, {0, 2}, {-1, 2}},
       ["2>>3"]= {{0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2}},
       ["3>>2"]= {{0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}},
       ["3>>0"]= {{0, 0}, {-1, 0}, {-1, 1}, {0, -2}, {-1, -2}},
       ["0>>3"]= {{0, 0}, {1, 0}, {1, -1}, {0, 2}, {1, 2}},
       }

local ISRS = {["1>>0"]= {{0, 0}, {-2, 0}, {1, 0}, {-2, 1}, {1, -2}},
       ["0>>1"]= {{0, 0}, {2, 0}, {-1, 0}, {2, -1}, {-1, 2}},
       ["1>>2"]= {{0, 0}, {-1, 0}, {2, 0}, {-1, -2}, {2, 1}},
       ["2>>1"]= {{0, 0}, {1, 0}, {-2, 0}, {1, 2}, {-2, -1}},
       ["3>>2"]= {{0, 0}, {2, 0}, {-1, -0}, {2, -1}, {-1, 2}},
       ["2>>3"]= {{0, 0}, {-2, 0}, {1, 0}, {-2, 1}, {1, -2}},
       ["3>>0"]= {{0, 0}, {1, 0}, {-2, 0}, {1, 2}, {-2, 1}},
       ["0>>3"]= {{0, 0}, {-1, 0}, {2, 0}, {-1, -2}, {2, 1}},
}

  local points={4,10,30,120}
  
  --get only the first 'amt' letters of a text
  local function lpad(text,amt)
    text=tostring(text)
    return string.rep(" ",amt-#text)..text
  end
  
  local width,height=term.getSize()
  
  if height<19 or width<26 then
    print("Your screen is too small to play :(")
    return
  end
  
  
  local speedsByLevel={
    1.2,
    1.0,
     .8,
     .65,
     .5,
     .4,
     .3,
     .25,
     .2,
     .15,
     .1,
     .05,}
  
  local level=1
  
  local function playGame()
    local score=0
    local lines=0
    local initialLevel=level
    local tbag = {"i"}
    local function bagGetNext()
      local returnLetter = nil
      if #tbag > 0 then
        local chosen_num = math.random(1,#tbag)
        returnLetter = tbag[chosen_num]
        table.remove(tbag, chosen_num)
      end
      if #tbag == 0 then
        for i=1,#PIECES do
          table.insert(tbag,PIECES[i])
        end
      end
      return returnLetter
    end
    bagGetNext()
    local next=bagGetNext()
    local place_soon = true
    local pit={}
  
  
    local heightAdjust=0
  
    if height<=19 then
      heightAdjust=1
    end
  
  
  
    local function drawScreen()
      term.setTextColor(colors.white)
      term.setBackgroundColor(colors.black)
      term.clear()
  
      term.setTextColor(colors.black)
      term.setBackgroundColor(colorass(colors.lightGray, colors.white))
      term.setCursorPos(22,2)
      term.write("Score") --score
      term.setCursorPos(22,5)
      term.write("Level")  --level
      term.setCursorPos(22,8)
      term.write("Lines")  --lines
      term.setCursorPos(22,12)
      term.write("Next") --next
  
      term.setCursorPos(21,1)
      term.write("      ")
      term.setCursorPos(21,2)
      term.write(" ") --score
      term.setCursorPos(21,3)
      term.write(" ")
      term.setCursorPos(21,4)
      term.write("      ")
      term.setCursorPos(21,5)
      term.write(" ")  --level
      term.setCursorPos(21,6)
      term.write(" ")
      term.setCursorPos(21,7)
      term.write("      ")
      term.setCursorPos(21,8)
      term.write(" ")  --lines
      term.setCursorPos(21,9)
      term.write(" ")
      term.setCursorPos(21,10)
      term.write("      ")
      term.setCursorPos(21,11)
      term.write("      ")
      term.setCursorPos(21,12)
      term.write(" ") --next
      term.setCursorPos(26,12)
      term.write(" ") --next
      term.setCursorPos(21,13)
      term.write("      ")
      term.setCursorPos(21,14)
      term.write(" ")
      term.setCursorPos(21,15)
      term.write(" ")
      term.setCursorPos(21,16)
      term.write(" ")
      term.setCursorPos(21,17)
      term.write(" ")
      term.setCursorPos(21,18)
      term.write(" ")
      term.setCursorPos(21,19)
      term.write("      ")
      term.setCursorPos(21,20)
      term.write("      ")
    end
  
    local function updateNumbers()
      term.setTextColor(colors.white)
      term.setBackgroundColor(colors.black)
  
      term.setCursorPos(22,3)
      term.write(lpad(score,5)) --score
      term.setCursorPos(22,6)
      term.write(lpad(level,5))  --level
      term.setCursorPos(22,9)
      term.write(lpad(lines,5))  --lines
    end
  
    local function drawBlockAt(block,xp,yp,rot)
      term.setTextColor(TPCLR[block])
      term.setBackgroundColor(TPCLR[block])
      for i=1,4 do
        local loc = rotateCoords(TPEZ[block][i],rot)
        term.setCursorPos((xp+loc[1])*2-3,yp+loc[2]-1-heightAdjust)
        term.write("  ") --ADD colorless support {}
      end
    end
  
    local function eraseBlockAt(block,xp,yp,rot)
      term.setTextColor(colors.white)
      term.setBackgroundColor(colors.black)
      for i=1,4 do
        local loc = rotateCoords(TPEZ[block][i],rot)
        term.setCursorPos((xp+loc[1])*2-3,yp+loc[2]-1-heightAdjust)
        term.write("  ") --ADD colorless support {}
      end
    end
  
    local function testBlockAt(block,xp,yp,rot)
      for i=1,4 do
        local loc = rotateCoords(TPEZ[block][i],rot)
        local tx, ty = xp + loc[1] - 1, yp + loc[2] - 1
        if ty < 1 then -- skip over checks which are above bounds.
        elseif tx>10 or tx<1 or ty>20 or pit[ty][tx]~=0 then
          return true
        end
      end
    end
  
    local function pitBlock(block,xp,yp,rot)
      for i=1,4 do
        local loc = rotateCoords(TPEZ[block][i],rot)
        pit[yp+loc[2]-1][xp+loc[1]-1]=block
      end
    end
  
  
    local function clearPit()
      for row=1,20 do
        pit[row]={}
        for col=1,10 do
          pit[row][col]=0
        end
      end
    end
  
  
  
    drawScreen()
    updateNumbers()
  
    --declare & init the pit
    clearPit()
  
  
  
    local halt=false
    local dropSpeed=speedsByLevel[math.min(level,12)]
  
  
    local curBlock=next
    next=bagGetNext()
  
    local curX, curY, curRot=5, 2, 0
    local dropTimer=os.startTimer(dropSpeed)
  
    drawBlockAt(next,13,16+heightAdjust,1)
    drawBlockAt(curBlock,curX,curY,curRot)
  
    local function redrawPit()
      for r=1+heightAdjust,20 do
        term.setCursorPos(1,r-heightAdjust)
        for c=1,10 do
          if pit[r][c]==0 then
            term.setTextColor(colors.black)
            term.setBackgroundColor(colors.black)
            term.write("  ")
          else
            term.setTextColor(TPCLR[pit[r][c]])
            term.setBackgroundColor(TPCLR[pit[r][c]])
            term.write("  ")--bring back tetris
          end
        end
      end
    end
  
    local function hidePit()
      for r=1+heightAdjust,20 do
        term.setCursorPos(1,r-heightAdjust)
        term.setTextColor(colors.black)
        term.setBackgroundColor(colors.black)
        term.write("                    ")
      end
    end
  
    local function msgBox(message)
      local x=math.floor((17-#message)/2)
      term.setBackgroundColor(colorass(colors.lightGray,colors.white))
      term.setTextColor(colors.black)
      term.setCursorPos(x,9)
      term.write("+"..string.rep("-",#message+2).."+")
      term.setCursorPos(x,10)
      term.write("|")
      term.setCursorPos(x+#message+3,10)
      term.write("|")
      term.setCursorPos(x,11)
      term.write("+"..string.rep("-",#message+2).."+")
      term.setTextColor(colors.white)
      term.setBackgroundColor(colors.black)
      term.setCursorPos(x+1,10)
      term.write(" "..message.." ")
    end
  
    local function clearRows()
      local rows={}
      for r=1,20 do
        local count=0
        for c=1,10 do
          if pit[r][c]~=0 then
            count=count+1
          else
            break
          end
        end
        if count==10 then
          rows[#rows+1]=r
        end
      end
  
      if #rows>0 then
        for i=1,4 do
          sleep(.1)
          for r=1,#rows do
            r=rows[r]
            term.setCursorPos(1,r-heightAdjust)
            for c=1,10 do
              term.setTextColor(TPCLR[pit[r][c]])
              term.setBackgroundColor(TPCLR[pit[r][c]])
              term.write("  ") --char
            end
          end
          sleep(.1)
          for r=1,#rows do
            r=rows[r]
            term.setCursorPos(1,r-heightAdjust)
            for c=1,10 do
              term.setTextColor(TPCLR[pit[r][c]])
              term.setBackgroundColor(TPCLR[pit[r][c]])
              term.write("  ") --char
            end
          end
        end
        --now remove the rows and drop everythign else
        term.setBackgroundColor(colors.black)
        for r=1,#rows do
          r=rows[r]
          term.setCursorPos(1,r-heightAdjust)
          term.write("                    ")
        end
        sleep(.25)
        for r=1,#rows do
          table.remove(pit,rows[r])
          table.insert(pit,1,{0,0,0,0,0,0,0,0,0,0})
        end
        redrawPit()
        lines=lines+#rows
        score=score+points[#rows]*math.min(level,20)
        level=math.floor(lines/10)+initialLevel
        dropSpeed=speedsByLevel[math.min(level,12)]
        updateNumbers()
      end
      sleep(.25)
    end
  
    local function blockFall()
      local result = false
      if testBlockAt(curBlock,curX,curY+1,curRot) then --TODO STALL
        if place_soon then
          pitBlock(curBlock,curX,curY,curRot)
          --detect rows that clear
          clearRows()
    
          curBlock=next
          curX=5
          curY=3
          curRot=0
          if testBlockAt(curBlock,curX,curY,curRot) then
            halt=true
          end
          drawBlockAt(curBlock,curX,curY,curRot)
          eraseBlockAt(next,11.5,15+heightAdjust,1)
          next=bagGetNext()
          drawBlockAt(next,13.5,16+heightAdjust,1)
          return true
        else
          place_soon = true
        end
      else
        eraseBlockAt(curBlock,curX,curY,curRot)
        curY=curY+1
        drawBlockAt(curBlock,curX,curY,curRot)
        return false
      end
    end
  
  
    while not halt do
      local e={os.pullEvent()}
      if e[1]=="timer" then
        if e[2]==dropTimer then
          blockFall()
          dropTimer=os.startTimer(dropSpeed)
        end
      elseif e[1]=="key" then
        local key=e[2]
        local dx,dy,dr=0,0,0
        place_soon = false -- TODO only stall for actual movement keys.
        if key==keys.left or key==keys.a then --TODO fixelseif?
          dx=-1
        elseif key==keys.right or key==keys.d then
          dx=1
        elseif key==keys.up or key==keys.w then
          while not blockFall() do end
          dropTimer=os.startTimer(dropSpeed)
        elseif key==keys.down or key==keys.s then
          blockFall()
          dropTimer = os.startTimer(dropSpeed)
        elseif key==keys.z or key==keys.j then
          dr=-1
        elseif key==keys.x or key==keys.k then
          dr=1
        elseif key==keys.space then
          hidePit()
          msgBox("Paused")
          while ({os.pullEvent("key")})[2]~=keys.space do end
          redrawPit()
          drawBlockAt(curBlock,curX,curY,curRot)
          dropTimer=os.startTimer(dropSpeed)
        end
        if dr ~= 0 then
          local spinstr =  (curRot%4)..">>"..(curRot+dr)%4
          local srstype = {}
          if curBlock == "i" then srstype = ISRS[spinstr] else srstype = SRS[spinstr] end
          for i=1,#srstype do
            if not testBlockAt(curBlock,curX+dx+srstype[i][1],curY+dy+srstype[i][2],(curRot+dr)%4) then
              eraseBlockAt(curBlock,curX,curY,curRot)
              curX=curX+dx+srstype[i][1]
              curY=curY+dy+srstype[i][2]
              curRot = (curRot+dr)%4
              drawBlockAt(curBlock,curX,curY,curRot)
              break
            end
          end
        else
          if not testBlockAt(curBlock,curX+dx,curY+dy,curRot) then
            eraseBlockAt(curBlock,curX,curY,curRot)
            curX=curX+dx
            curY=curY+dy
            drawBlockAt(curBlock,curX,curY,curRot)
          end
        end
      elseif e[1]=="term_resize" then
        local w,h=term.getSize()
        if h==20 then
          heightAdjust=0
        else
          heightAdjust=1
        end
        redrawPit()
        drawBlockAt(curBlock,curX,curY,curRot)
      end
    end
  
    msgBox("Game Over!")
    while true do
      local _,k=os.pullEvent("key")
      if k==keys.space or k==keys.enter then
        break
      end
    end
  
    level = math.min(level,9)
  end
  
  
  local selected=1
  local playersDetected=false
  
  local function drawMenu()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colorass(colors.red,colors.white))
    term.clear()
  
    local cx,cy=math.floor(width/2),math.floor(height/2)
  
    term.setCursorPos(cx-6,cy-2)
    term.write("F A L L I N G")
  
    if playersDetected then
      if selected==0 then
        term.setTextColor(colorass(colors.blue,colors.black))
        term.setBackgroundColor(colorass(colors.gray,colors.white))
      else
        term.setTextColor(colorass(colors.lightBlue,colors.white))
        term.setBackgroundColor(colors.black)
      end
      term.setCursorPos(cx-12,cy)
      term.write(" Play head-to-head game! ")
    end
  
    term.setCursorPos(cx-10,cy+1)
    if selected==1 then
      term.setTextColor(colorass(colors.blue,colors.black))
      term.setBackgroundColor(colorass(colors.lightGray,colors.white))
    else
      term.setTextColor(colorass(colors.lightBlue,colors.white))
      term.setBackgroundColor(colors.black)
    end
    term.write(" Play from level: <" .. level .. "> ")
  
    term.setCursorPos(cx-3,cy+3)
    if selected==2 then
      term.setTextColor(colorass(colors.blue,colors.black))
      term.setBackgroundColor(colorass(colors.lightGray,colors.white))
    else
      term.setTextColor(colorass(colors.lightBlue,colors.white))
      term.setBackgroundColor(colors.black)
    end
    term.write(" Quit ")
  end
  
  
  local function runMenu()
    drawMenu()
  
    while true do
      local event={os.pullEvent()}
      if event[1]=="key" then
        local key=event[2]
        if key==keys.right or key==keys.d and selected==1 then
          level=math.min(level+1,9)
          drawMenu()
        elseif key==keys.left or key==keys.a and selected==1 then
          level=math.max(level-1,1)
          drawMenu()
        elseif key>=keys.one and key<=keys.nine and selected==1 then
          level=(key-keys.one) + 1
          drawMenu()
        elseif key==keys.up or key==keys.w then
          selected=selected-1
          if selected==0 then
            selected=2
          end
          drawMenu()
        elseif key==keys.down or key==keys.s then
          selected=selected%2+1
          drawMenu()
        elseif key==keys.enter or key==keys.space then
          break --begin play!
        end
      end
    end
  end
  
  while true do
    runMenu()
    if selected==2 then
      break
    end
  
    playGame()
  end
  
  
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
  term.clear()
  term.setCursorPos(1,1)