print("Script Loaded!")

local function main(key)
    print("Key received:", key)  
    if key ~= "ligma balls" then
        error("Appreciate the ligma balls club! GRR!!") 
    end
    print("Key is correct!")
end

local key = ... -- adhesivo
if key then
    main(key)
else
    print("No key provided!")
end
