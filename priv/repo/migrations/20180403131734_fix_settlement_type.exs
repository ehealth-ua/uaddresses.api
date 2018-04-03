defmodule Uaddresses.Repo.Migrations.FixSettlementType do
  use Ecto.Migration

  def change do
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '0510490001';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '0510490003';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '0510690001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '0510690002';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '0510690003';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1210436301';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '1210790001';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1211090001';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1211090003';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1211090005';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '1211090007';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '1211090009';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1211390001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '1213590001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '1221487703';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1410640001';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1410640003';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1411290001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '1411390001';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1411690001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '1411790003';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '1412090001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '1412090003';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1412990001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '1412990003';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '1413390001';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1413390003';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '1413390005';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '1413390007';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1413590001';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1415090005';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1415390001';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1415390003';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1415390005';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1415390007';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '1415390009';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '2110290001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '2110890001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '2110890002';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '2110890003';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '2321883001';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '4412990001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '4412990002';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '4412990003';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '4412990005';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '4424583910';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '5910290001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '5910290003';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '5910290005';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '5910290007';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '5910390001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '5910590001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '5910590002';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '5910590003';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '5910790003';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '5910790005';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '6311090001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '6311090003';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '6311290001';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '6311290003';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '6311290005';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '6311290009';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '6312090001';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '6312090003';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '7110136701';")
    execute("UPDATE settlements SET type = 'VILLAGE' WHERE koatuu = '7110290001';")
    execute("UPDATE settlements SET type = 'SETTLEMENT' WHERE koatuu = '7110590001';")
  end
end
