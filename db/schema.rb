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

ActiveRecord::Schema[7.0].define(version: 2023_12_10_235135) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "git_commits", force: :cascade do |t|
    t.string "commit_hash"
    t.text "message"
    t.bigint "project_id", null: false
    t.bigint "robo_job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "message_options", default: {}
    t.string "status", default: "pending"
    t.string "error"
    t.string "branch"
    t.text "response"
    t.index ["commit_hash"], name: "index_git_commits_on_commit_hash", unique: true
    t.index ["project_id"], name: "index_git_commits_on_project_id"
    t.index ["robo_job_id"], name: "index_git_commits_on_robo_job_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "filepath", null: false
    t.text "project_context", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ignored_files", default: [], array: true
  end

  create_table "robo_changes", force: :cascade do |t|
    t.bigint "robo_job_id", null: false
    t.json "raw_json", null: false
    t.text "summary"
    t.string "file", null: false
    t.string "action", null: false
    t.text "original_content"
    t.text "new_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "pending", null: false
    t.string "error"
    t.string "new_file"
    t.index ["robo_job_id"], name: "index_robo_changes_on_robo_job_id"
  end

  create_table "robo_jobs", force: :cascade do |t|
    t.text "feature_request", null: false
    t.string "contextual_files", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_id"
    t.bigint "parent_job_id"
    t.json "generated_instructions", default: {}
    t.boolean "include_last_convo", default: false
    t.boolean "include_all_convos", default: false
    t.index ["parent_job_id"], name: "index_robo_jobs_on_parent_job_id"
    t.index ["project_id"], name: "index_robo_jobs_on_project_id"
  end

  create_table "robo_requests", force: :cascade do |t|
    t.string "request_type", null: false
    t.text "prompt", null: false
    t.text "response"
    t.json "raw_response", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "prompt_token_count"
    t.integer "response_token_count"
    t.decimal "cost", precision: 8, scale: 2
    t.string "parent_type", null: false
    t.bigint "parent_id", null: false
    t.index ["parent_type", "parent_id"], name: "index_robo_requests_on_parent"
  end

  add_foreign_key "git_commits", "projects"
  add_foreign_key "git_commits", "robo_jobs"
  add_foreign_key "robo_changes", "robo_jobs"
  add_foreign_key "robo_jobs", "projects"
  add_foreign_key "robo_jobs", "robo_jobs", column: "parent_job_id"
end
