-- ========================================================
-- 🥚 Ultimate Egg Stealer Pro (New UI/UX)
-- Features: ค้นหาไข่แพงสุด/ใหญ่สุด, วาร์ปทันที, กันบัคเกมค้าง
-- ========================================================

-- โหลด UI Library ที่ทันสมัยที่สุด (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🥚 Egg Stealer Pro | V1",
   LoadingTitle = "กำลังโหลดระบบขโมยไข่...",
   LoadingSubtitle = "by YourName",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("🚀 เมนูหลัก", 4483362458) -- รหัสไอคอน

-- ========================================================
-- ตัวแปรระบบ
-- ========================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local _G = {}
_G.AutoSteal = false
_G.TeleportSpeed = "Instant" -- โหมดวาร์ป (Instant = ทันที)

-- ========================================================
-- ฟังก์ชันหลัก: ค้นหาไข่ที่แพงที่สุดและใหญ่ที่สุด
-- ========================================================
local function GetBestEgg()
    local bestEgg = nil
    local highestValue = -1
    local maxVolume = -1

    -- ⚠️ สำคัญ: เปลี่ยน "workspace" เป็นโฟลเดอร์ที่เก็บไข่ในแมพของคุณเพื่อลดอาการแลค
    -- เช่น workspace.Eggs หรือ workspace.Map.Spawns
    local searchFolder = workspace 

    for _, obj in ipairs(searchFolder:GetDescendants()) do
        pcall(function()
            -- เช็คว่าเป็นไข่ (ปรับชื่อ "Egg" ให้ตรงกับชื่อโมเดลไข่ในแมพ)
            if obj:IsA("Model") or obj:IsA("BasePart") then
                if string.match(string.lower(obj.Name), "egg") or obj:FindFirstChild("IsEgg") then
                    
                    -- สมมติว่าไข่มีค่า $ เก็บอยู่ใน NumberValue, IntValue หรือ Attribute
                    local eggValue = 0
                    if obj:FindFirstChild("Price") then
                        eggValue = obj.Price.Value
                    elseif obj:GetAttribute("Value") then
                        eggValue = obj:GetAttribute("Value")
                    end

                    -- คำนวณขนาดของไข่ (กว้าง x ยาว x สูง)
                    local eggSize = 0
                    if obj:IsA("BasePart") then
                        eggSize = obj.Size.X * obj.Size.Y * obj.Size.Z
                    elseif obj:IsA("Model") and obj.PrimaryPart then
                        eggSize = obj.PrimaryPart.Size.X * obj.PrimaryPart.Size.Y * obj.PrimaryPart.Size.Z
                    end

                    -- คัดกรอง: เอาไข่ที่แพงที่สุดก่อน ถ้าแพงเท่ากันเอาใบที่ใหญ่ที่สุด
                    if eggValue > highestValue then
                        highestValue = eggValue
                        maxVolume = eggSize
                        bestEgg = obj
                    elseif eggValue == highestValue and eggSize > maxVolume then
                        maxVolume = eggSize
                        bestEgg = obj
                    end
                end
            end
        end)
    end
    
    return bestEgg, highestValue
end

-- ========================================================
-- ฟังก์ชัน: วาร์ปความเร็วสูง (ป้องกันบัคตกแมพ)
-- ========================================================
local function FastTeleport(targetPart)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and targetPart then
        -- ใช้วิธีเปลี่ยน CFrame โดยตรงเพื่อความไวสูงสุด (ไร้ดีเลย์)
        local targetPos = targetPart:IsA("Model") and targetPart.PrimaryPart.CFrame or targetPart.CFrame
        
        -- ยกตัวละครขึ้นเล็กน้อยป้องกันการติดพื้นหรือบัคจมดิน
        char.HumanoidRootPart.CFrame = targetPos + Vector3.new(0, 3, 0)
        
        -- บังคับให้ความเร็วการตกเป็น 0 ป้องกันตายจากการวาร์ป
        if char.HumanoidRootPart:FindFirstChild("VectorForce") == nil then
            char.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
    end
end

-- ========================================================
-- ระบบลูปการทำงาน (Auto Farm)
-- ========================================================
local function StartAutoSteal()
    task.spawn(function()
        while task.wait(0.1) do -- ดีเลย์ 0.1 วิ ป้องกันเกมค้าง
            if not _G.AutoSteal then break end
            
            pcall(function()
                local bestEgg, val = GetBestEgg()
                if bestEgg then
                    FastTeleport(bestEgg)
                    
                    -- วางโค้ดสำหรับกด E หรือรับของตรงนี้
                    -- fireproximityprompt(bestEgg.ProximityPrompt)
                    
                    task.wait(0.5) -- รอให้ขโมยสำเร็จก่อนหาใบต่อไป
                end
            end)
        end
    end)
end

-- ========================================================
-- สร้างเมนู UI
-- ========================================================
Tab:CreateToggle({
   Name = "🚀 เปิดระบบขโมยไข่ (Auto Steal Best Egg)",
   CurrentValue = false,
   Flag = "Toggle_Steal",
   Callback = function(Value)
        _G.AutoSteal = Value
        if Value then
            Rayfield:Notify({
                Title = "ระบบทำงาน",
                Content = "กำลังสแกนหาไข่ที่แพงที่สุดในแมพ!",
                Duration = 3,
                Image = 4483362458,
            })
            StartAutoSteal()
        else
            Rayfield:Notify({
                Title = "หยุดทำงาน",
                Content = "ปิดระบบขโมยไข่แล้ว",
                Duration = 2,
                Image = 4483362458,
            })
        end
   end,
})

Tab:CreateButton({
   Name = "🔍 ทดสอบสแกนหาไข่ที่แพงที่สุด (เช็คค่าสถานะ)",
   Callback = function()
        local egg, val = GetBestEgg()
        if egg then
            Rayfield:Notify({
                Title = "พบเป้าหมาย!",
                Content = "เจอไข่ราคา: $" .. tostring(val),
                Duration = 5,
                Image = 4483362458,
            })
            FastTeleport(egg)
        else
            Rayfield:Notify({
                Title = "ไม่พบไข่",
                Content = "ไม่มีไข่ในแมพ หรือตั้งชื่ออ้างอิงไม่ตรง",
                Duration = 3,
                Image = 4483362458,
            })
        end
   end,
})

Rayfield:LoadConfiguration()
