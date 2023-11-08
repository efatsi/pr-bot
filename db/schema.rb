# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_11_08_205851) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "robo_changes", force: :cascade do |t|
    t.bigint "robo_job_id", null: false
    t.json "raw_json", null: false
    t.text "summary"
    t.string "file"
    t.string "action"
    t.text "original_content"
    t.text "new_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["robo_job_id"], name: "index_robo_changes_on_robo_job_id"
  end

  create_table "robo_jobs", force: :cascade do |t|
    t.string "filepath", null: false
    t.text "project_context"
    t.text "feature_request", null: false
    t.string "contextual_files", default: [], array: true
    t.text "generated_instructions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "robo_requests", force: :cascade do |t|
    t.bigint "robo_job_id", null: false
    t.string "request_type", null: false
    t.text "prompt", null: false
    t.text "response"
    t.json "raw_response", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["robo_job_id"], name: "index_robo_requests_on_robo_job_id"
  end

  add_foreign_key "robo_changes", "robo_jobs"
  add_foreign_key "robo_requests", "robo_jobs"
end
