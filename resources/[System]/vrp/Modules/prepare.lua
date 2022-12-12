-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERS
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("characters/allChars","SELECT * FROM characters")
vRP.prepare("characters/getUsers","SELECT * FROM characters WHERE id = @id")
vRP.prepare("characters/getPhone","SELECT id FROM characters WHERE phone = @phone")
vRP.prepare("characters/getSerial","SELECT id FROM characters WHERE serial = @serial")
vRP.prepare("characters/updatePort","UPDATE characters SET port = @port WHERE id = @id")
vRP.prepare("characters/updatePhone","UPDATE characters SET phone = @phone WHERE id = @id")
vRP.prepare("characters/removeCharacters","UPDATE characters SET deleted = 1 WHERE id = @id")
vRP.prepare("characters/updateLocate","UPDATE characters SET locate = @locate WHERE id = @id")
vRP.prepare("characters/addFines","UPDATE characters SET fines = fines + @fines WHERE id = @id")
vRP.prepare("characters/setPrison","UPDATE characters SET prison = @prison WHERE id = @user_id")
vRP.prepare("characters/updateGarages","UPDATE characters SET garage = garage + 1 WHERE id = @id")
vRP.prepare("characters/removeFines","UPDATE characters SET fines = fines - @fines WHERE id = @id")
vRP.prepare("characters/Characters","SELECT * FROM characters WHERE steam = @steam and deleted = 0")
vRP.prepare("characters/removePrison","UPDATE characters SET prison = prison - @prison WHERE id = @user_id")
vRP.prepare("characters/updateName","UPDATE characters SET name = @name, name2 = @name2 WHERE id = @user_id")
vRP.prepare("characters/lastCharacters","SELECT id FROM characters WHERE steam = @steam ORDER BY id DESC LIMIT 1")
vRP.prepare("characters/countPersons","SELECT COUNT(steam) as qtd FROM characters WHERE steam = @steam and deleted = 0")
vRP.prepare("characters/newCharacter","INSERT INTO characters(steam,name,name2,locate,sex,phone,serial,blood) VALUES(@steam,@name,@name2,@locate,@sex,@phone,@serial,@blood)")
-----------------------------------------------------------------------------------------------------------------------------------------
-- BANKs
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("bank/getInfos","SELECT * FROM bank WHERE user_id = @user_id AND mode = @mode AND owner = 1")
vRP.prepare("bank/newAccount","INSERT INTO bank(user_id,value,mode,owner) VALUES(@user_id,@value,@mode,@owner)")
vRP.prepare("bank/addValue","UPDATE bank SET value = value + @value WHERE user_id = @user_id AND mode = @mode AND owner = 1")
vRP.prepare("bank/remValue","UPDATE bank SET value = value - @value WHERE user_id = @user_id AND mode = @mode AND owner = 1")
-----------------------------------------------------------------------------------------------------------------------------------------
-- ACCOUNTS
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("accounts/getInfos","SELECT * FROM accounts WHERE steam = @steam")
vRP.prepare("accounts/newAccount","INSERT INTO accounts(steam) VALUES(@steam)")
vRP.prepare("accounts/updateWhitelist","UPDATE accounts SET whitelist = 0 WHERE steam = @steam")
vRP.prepare("accounts/removeGems","UPDATE accounts SET gems = gems - @gems WHERE steam = @steam")
vRP.prepare("accounts/setPriority","UPDATE accounts SET priority = @priority WHERE steam = @steam")
vRP.prepare("accounts/infosUpdatechars","UPDATE accounts SET chars = chars + 1 WHERE steam = @steam")
vRP.prepare("accounts/infosUpdategems","UPDATE accounts SET gems = gems + @gems WHERE steam = @steam")
vRP.prepare("accounts/updatePremium","UPDATE accounts SET premium = premium + 2592000 WHERE steam = @steam")
vRP.prepare("accounts/setPremium","UPDATE accounts SET premium = @premium, priority = @priority WHERE steam = @steam")
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERDATA
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("playerdata/getUserdata","SELECT dvalue FROM playerdata WHERE user_id = @user_id AND dkey = @key")
vRP.prepare("playerdata/setUserdata","REPLACE INTO playerdata(user_id,dkey,dvalue) VALUES(@user_id,@key,@value)")
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENTITYDATA
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("entitydata/removeData","DELETE FROM entitydata WHERE dkey = @dkey")
vRP.prepare("entitydata/getData","SELECT dvalue FROM entitydata WHERE dkey = @dkey")
vRP.prepare("entitydata/setData","REPLACE INTO entitydata(dkey,dvalue) VALUES(@dkey,@value)")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLES
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("vehicles/plateVehicles","SELECT * FROM vehicles WHERE plate = @plate")
vRP.prepare("vehicles/getVehicles","SELECT * FROM vehicles WHERE user_id = @user_id")
vRP.prepare("vehicles/removeVehicles","DELETE FROM vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("vehicles/selectVehicles","SELECT * FROM vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("vehicles/paymentArrest","UPDATE vehicles SET arrest = 0 WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("vehicles/moveVehicles","UPDATE vehicles SET user_id = @nuser_id WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("vehicles/plateVehiclesUpdate","UPDATE vehicles SET plate = @plate WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("vehicles/rentalVehiclesDays","UPDATE vehicles SET rental = rental + 2592000 WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("vehicles/countVehicles","SELECT COUNT(vehicle) as qtd FROM vehicles WHERE user_id = @user_id AND work = @work AND rental <= 0")
vRP.prepare("vehicles/arrestVehicles","UPDATE vehicles SET arrest = UNIX_TIMESTAMP() + 2592000 WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("vehicles/updateVehiclesTax","UPDATE vehicles SET tax = UNIX_TIMESTAMP() + 2592000 WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("vehicles/rentalVehiclesUpdate","UPDATE vehicles SET rental = UNIX_TIMESTAMP() + 2592000 WHERE user_id = @user_id AND vehicle = @vehicle")
vRP.prepare("vehicles/addVehicles","INSERT IGNORE INTO vehicles(user_id,vehicle,plate,work,tax) VALUES(@user_id,@vehicle,@plate,@work,UNIX_TIMESTAMP() + 604800)")
vRP.prepare("vehicles/rentalVehicles","INSERT IGNORE INTO vehicles(user_id,vehicle,plate,work,rental,tax) VALUES(@user_id,@vehicle,@plate,@work,UNIX_TIMESTAMP() + 2592000,UNIX_TIMESTAMP() + 604800)")
vRP.prepare("vehicles/updateVehicles","UPDATE vehicles SET engine = @engine, body = @body, fuel = @fuel, doors = @doors, windows = @windows, tyres = @tyres, nitro = @nitro WHERE user_id = @user_id AND vehicle = @vehicle")
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPERTYS
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("propertys/selling","DELETE FROM propertys WHERE name = @name")
vRP.prepare("propertys/permissions","SELECT * FROM propertys WHERE name = @name")
vRP.prepare("propertys/totalHomes","SELECT name,tax FROM propertys WHERE owner = 1")
vRP.prepare("propertys/userList","SELECT name FROM propertys WHERE user_id = @user_id")
vRP.prepare("propertys/countUsers","SELECT COUNT(*) as qtd FROM propertys WHERE user_id = @user_id")
vRP.prepare("propertys/countPermissions","SELECT COUNT(*) as qtd FROM propertys WHERE name = @name")
vRP.prepare("propertys/userOwnermissions","SELECT * FROM propertys WHERE name = @name AND owner = 1")
vRP.prepare("propertys/removePermissions","DELETE FROM propertys WHERE name = @name AND user_id = @user_id")
vRP.prepare("propertys/userPermissions","SELECT * FROM propertys WHERE name = @name AND user_id = @user_id")
vRP.prepare("propertys/updateOwner","UPDATE propertys SET user_id = @nuser_id WHERE user_id = @user_id AND name = @name")
vRP.prepare("propertys/updateTax","UPDATE propertys SET tax = UNIX_TIMESTAMP() + 2592000 WHERE name = @name AND owner = 1")
vRP.prepare("propertys/updateVault","UPDATE propertys SET vault = vault + 10, price = price + 10000 WHERE name = @name AND owner = 1")
vRP.prepare("propertys/updateFridge","UPDATE propertys SET fridge = fridge + 10, price = price + 10000 WHERE name = @name AND owner = 1")
vRP.prepare("propertys/newPermissions","INSERT IGNORE INTO propertys(name,interior,user_id,owner) VALUES(@name,@interior,@user_id,@owner)")
vRP.prepare("propertys/buying","INSERT IGNORE INTO propertys(name,interior,price,user_id,tax,residents,vault,fridge,owner) VALUES(@name,@interior,@price,@user_id,UNIX_TIMESTAMP() + 604800,@residents,@vault,@fridge,1)")
-----------------------------------------------------------------------------------------------------------------------------------------
-- PRISON
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("prison/cleanRecords","DELETE FROM prison WHERE nuser_id = @nuser_id")
vRP.prepare("prison/getRecords","SELECT * FROM prison WHERE nuser_id = @nuser_id ORDER BY id DESC")
vRP.prepare("prison/insertPrison","INSERT INTO prison(police,nuser_id,services,fines,text,date) VALUES(@police,@nuser_id,@services,@fines,@text,@date)")
-----------------------------------------------------------------------------------------------------------------------------------------
-- BANNEDS
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("banneds/getBanned","SELECT * FROM banneds WHERE steam = @steam")
vRP.prepare("banneds/removeBanned","DELETE FROM banneds WHERE steam = @steam")
vRP.prepare("banneds/insertBanned","INSERT INTO banneds(steam,time) VALUES(@steam,UNIX_TIMESTAMP() + 86400 * @time)")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHESTS
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("chests/getChests","SELECT * FROM chests WHERE name = @name")
vRP.prepare("chests/upgradeChests","UPDATE chests SET weight = weight + 25 WHERE name = @name")
-----------------------------------------------------------------------------------------------------------------------------------------
-- RACES
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("races/checkResult","SELECT * FROM races WHERE raceid = @raceid AND user_id = @user_id")
vRP.prepare("races/requestRanking","SELECT * FROM races WHERE raceid = @raceid ORDER BY points ASC LIMIT 5")
vRP.prepare("races/updateRecords","UPDATE races SET points = @points, vehicle = @vehicle WHERE raceid = @raceid AND user_id = @user_id")
vRP.prepare("races/insertRecords","INSERT INTO races(raceid,user_id,name,vehicle,points) VALUES(@raceid,@user_id,@name,@vehicle,@points)")
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINDENTITY
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("fidentity/getResults","SELECT * FROM fidentity WHERE id = @id")
vRP.prepare("fidentity/lastIdentity","SELECT id FROM fidentity ORDER BY id DESC LIMIT 1")
vRP.prepare("fidentity/newIdentity","INSERT INTO fidentity(name,name2,locate,blood) VALUES(@name,@name2,@locate,@blood)")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEARTABLES
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("south/playerdata","DELETE FROM playerdata WHERE dvalue = '[]' OR dvalue = '{}'")
vRP.prepare("south/entitydata","DELETE FROM entitydata WHERE dvalue = '[]' OR dvalue = '{}'")
vRP.prepare("south/cleanPremium","UPDATE accounts SET premium = '0', priority = '0' WHERE UNIX_TIMESTAMP() >= premium")
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADCLEANERS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	vRP.execute("south/playerdata")
	vRP.execute("south/entitydata")
	vRP.execute("south/cleanPremium")
end)