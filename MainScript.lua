-- ==========================================
-- 🌶️ Chilli Hub - Ultimate Pro Translation Engine
-- แปลไทยโดย : บาฟัค (God Tier Optimization & Bug Fixed)
-- Version : Max (Anti-Lag, Auto-Cleanup, Placeholder Support)
-- ==========================================

-- 1. เตรียมบริการและ Bypass สำหรับ Executor ทุกประเภท
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = gethui and gethui() or game:GetService("CoreGui")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 2. ระบบเคลียร์การทำงานซ้ำ (Auto-Cleanup ป้องกันเกมแลคเมื่อรันซ้ำ)
if _G.Chilli_Connections then
    for _, conn in pairs(_G.Chilli_Connections) do
        pcall(function() conn:Disconnect() end)
    end
end
_G.Chilli_Connections = {} -- สร้างตารางเก็บ Event ไว้ลบในอนาคต

-- ==========================================
-- 3. DICTIONARY (ตารางคำศัพท์ตายตัว)
-- ==========================================
local dict = {
    ["Chilli Hub"] = "Chilli Hub : แปลโดย บาฟัค",
    ["Farm"] = "🚜 ฟาร์ม",
    ["Player"] = "🏃 ตัวละคร",
    ["Egg Finder"] = "🔎 ค้นหาไข่",
    ["Predictor"] = "🔮 คาดการณ์",
    ["Progress"] = "📈 ความคืบหน้า",
    ["Server"] = "🌐 เซิร์ฟเวอร์",
    ["Misc"] = "⚙️ อื่นๆ",
    ["Webhook"] = "🔗 เว็บฮุค",
    ["Discord"] = "💬 ดิสคอร์ด",
    ["Quick & Keys"] = "⚡ ทางลัดและปุ่มลัด",
    ["Settings"] = "⚙️ ตั้งค่า",
    ["Config"] = "📁 คอนฟิก",
    ["Search"] = "🔎 ค้นหา",
    ["Filter features..."] = "ค้นหาเมนู...",
    ["Auto Buy Scramble Shop"] = "🛒 ซื้อของร้าน Scramble อัตโนมัติ",
    ["Keep Samples"] = "💾 เก็บ Samples สำรอง",
    ["Idle"] = "💤 ว่าง",
    ["IDLE"] = "💤 ว่าง",
    ["ACTIVE"] = "🟢 กำลังทำงาน",
    -- วางคำศัพท์อื่นๆ ของคุณต่อลงมาตรงนี้ได้เลย...
}

-- ==========================================
-- 4. PATTERN DICTIONARY (แปลแบบมีตัวแปร)
-- ==========================================
local patternDict = {
    {"^Ends in (.*)$", "⏳ สิ้นสุดใน %1"},
    {"^1 in (.*)$", "🎲 โอกาส 1 ใน %1"},
    {"^Level (%d+)$", "⭐ เลเวล %1"},
    {"^Found: (.*)$", "🔍 พบแล้ว: %1"},
}

-- ==========================================
-- 5. TRANSLATION ENGINE (ระบบประมวลผล)
-- ==========================================
local translatedCache = {}
for eng, thai in pairs(dict) do translatedCache[thai] = true end
for _, pattern in pairs(patternDict) do translatedCache[pattern[2]] = true end

local function Translate(text)
    if type(text) ~= "string" or text == "" or text == " " then return text end
    if translatedCache[text] then return text end

    if dict[text] then return dict[text] end

    for _, pattern in ipairs(patternDict) do
        if string.match(text, pattern[1]) then
            local translated = string.gsub(text, pattern[1], pattern[2])
            translatedCache[translated] = true
            return translated
        end
    end
    return text
end

-- ==========================================
-- 6. UI PROCESSOR (ฟังก์ชันจัดการหน้าต่าง UI)
-- ==========================================
local goodFonts = {Enum.Font.Gotham, Enum.Font.GothamMedium, Enum.Font.GothamBold, Enum.Font.BuilderSans}

local function ProcessElement(element)
    pcall(function()
        -- จัดการเฉพาะ Text UI
        if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
            
            -- ปรับฟอนต์ไทยให้สวยงาม ไม่ตกขอบ
            if not table.find(goodFonts, element.Font) then
                element.Font = Enum.Font.GothamMedium
            end

            -- 6.1 แปลข้อความหลัก (.Text)
            local currentText = element.Text
            local translatedText = Translate(currentText)
            if currentText ~= translatedText then
                element.Text = translatedText
            end
            
            -- 6.2 แปลข้อความช่องกรอก (.PlaceholderText) สำหรับ TextBox
            if element:IsA("TextBox") then
                local currentPlaceholder = element.PlaceholderText
                local translatedPlaceholder = Translate(currentPlaceholder)
                if currentPlaceholder ~= translatedPlaceholder then
                    element.PlaceholderText = translatedPlaceholder
                end
            end

            -- 6.3 ดักจับการเปลี่ยนแปลงแบบ Real-Time
            if not element:GetAttribute("ChilliTranslated_Max") then
                element:SetAttribute("ChilliTranslated_Max", true)
                
                -- ตรวจจับเวลา Text เปลี่ยน (เช่น สถานะเปลี่ยน, เลขเงินเปลี่ยน)
                local connText = element:GetPropertyChangedSignal("Text"):Connect(function()
                    local newText = element.Text
                    if not translatedCache[newText] then
                        local newTranslated = Translate(newText)
                        if newText ~= newTranslated then
                            element.Text = newTranslated
                        end
                    end
                end)
                table.insert(_G.Chilli_Connections, connText)

                -- ตรวจจับเวลา Placeholder เปลี่ยน
                if element:IsA("TextBox") then
                    local connPlaceholder = element:GetPropertyChangedSignal("PlaceholderText"):Connect(function()
                        local newText = element.PlaceholderText
                        if not translatedCache[newText] then
                            local newTranslated = Translate(newText)
                            if newText ~= newTranslated then
                                element.PlaceholderText = newTranslated
                            end
                        end
                    end)
                    table.insert(_G.Chilli_Connections, connPlaceholder)
                end
            end
        end
    end)
end

-- ==========================================
-- 7. INITIALIZATION (เริ่มระบบสแกน)
-- ==========================================
local function ScanTarget(targetGui)
    task.spawn(function()
        local descendants = targetGui:GetDescendants()
        for i, obj in ipairs(descendants) do
            ProcessElement(obj)
            -- [ANTI-CRASH] พักสคริปต์ 0.01 วินาที ทุกๆ การสแกน UI 100 ชิ้น (กันเกมค้าง)
            if i % 100 == 0 then task.wait() end
        end
    end)
    
    -- เฝ้าระวัง UI ใหม่ที่จะเกิดขึ้น
    local connAdded = targetGui.DescendantAdded:Connect(function(newObj)
        task.defer(ProcessElement, newObj)
    end)
    table.insert(_G.Chilli_Connections, connAdded)
end

local function StartProEngine()
    -- สแกนทั้ง CoreGui (Hub ส่วนใหญ่) และ PlayerGui (บาง Hub ที่ซ่อน UI ไว้ที่นี่)
    ScanTarget(CoreGui)
    ScanTarget(PlayerGui)
end

StartProEngine()
print("🌶️ Chilli Hub Translation [GOD TIER VERSION] Loaded Successfully! All Bugs Fixed.")
