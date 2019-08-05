# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_08_05_105453) do

  create_table "house_holds", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tracking_number", default: 0
    t.string "uuid"
    t.index ["uuid"], name: "index_house_holds_on_uuid"
  end

  create_table "readings", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "thermostat_id"
    t.integer "tracking_number"
    t.float "temperature"
    t.float "humidity"
    t.float "battery_charge"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "household_token"
    t.string "uuid"
  end

  create_table "stats", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "thermostat_id"
    t.string "sensor_type"
    t.float "avg"
    t.float "min"
    t.float "max"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.float "sum"
    t.index ["uuid"], name: "index_stats_on_uuid"
  end

  create_table "thermostats", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.text "household_token"
    t.text "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uuid"
    t.integer "number_of_readings"
    t.integer "house_hold_id"
    t.index ["uuid"], name: "index_thermostats_on_uuid"
  end

end
