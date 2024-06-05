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

ActiveRecord::Schema[7.0].define(version: 2024_06_05_011135) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.string "status", default: "pending", null: false
    t.json "arguments", default: {}
    t.json "history", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "summary"
    t.text "error"
    t.string "type"
    t.bigint "robo_request_id"
    t.index ["robo_request_id"], name: "index_actions_on_robo_request_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "contextual_files", force: :cascade do |t|
    t.bigint "robo_job_id", null: false
    t.string "filepath"
    t.string "status", default: "pending"
    t.json "robo_analysis"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "robo_event_id", null: false
    t.index ["robo_event_id"], name: "index_contextual_files_on_robo_event_id"
    t.index ["robo_job_id"], name: "index_contextual_files_on_robo_job_id"
  end

  create_table "git_commits", force: :cascade do |t|
    t.string "commit_hash"
    t.text "message"
    t.bigint "robo_job_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "pending"
    t.string "error"
    t.string "branch"
    t.text "response"
    t.index ["commit_hash"], name: "index_git_commits_on_commit_hash", unique: true
    t.index ["robo_job_id"], name: "index_git_commits_on_robo_job_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "image_uploads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "robo_job_id"
    t.index ["robo_job_id"], name: "index_image_uploads_on_robo_job_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "repo_path", null: false
    t.text "project_context", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ignored_files", default: [], array: true
  end

  create_table "robo_events", force: :cascade do |t|
    t.bigint "parent_robo_event_id"
    t.string "subject_type", null: false
    t.bigint "subject_id", null: false
    t.string "event_type", null: false
    t.string "status", default: "active", null: false
    t.json "event_data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "robots", default: [], array: true
    t.index ["parent_robo_event_id"], name: "index_robo_events_on_parent_robo_event_id"
    t.index ["subject_type", "subject_id"], name: "index_robo_events_on_subject"
  end

  create_table "robo_jobs", force: :cascade do |t|
    t.text "feature_request", null: false
    t.string "seed_contextual_files", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_id"
    t.bigint "parent_job_id"
    t.boolean "include_last_convo", default: false
    t.boolean "include_all_convos", default: false
    t.index ["parent_job_id"], name: "index_robo_jobs_on_parent_job_id"
    t.index ["project_id"], name: "index_robo_jobs_on_project_id"
  end

  create_table "robo_requests", force: :cascade do |t|
    t.string "request_type", null: false
    t.text "response"
    t.json "raw_response", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "prompt_token_count"
    t.integer "response_token_count"
    t.decimal "cost", precision: 8, scale: 2
    t.string "parent_type", null: false
    t.bigint "parent_id", null: false
    t.json "prompt_messages", default: []
    t.bigint "robo_event_id"
    t.string "robot"
    t.string "status", default: "active"
    t.text "error"
    t.index ["parent_type", "parent_id"], name: "index_robo_requests_on_parent"
    t.index ["robo_event_id"], name: "index_robo_requests_on_robo_event_id"
  end

  add_foreign_key "actions", "robo_requests"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "contextual_files", "robo_events"
  add_foreign_key "contextual_files", "robo_jobs"
  add_foreign_key "git_commits", "robo_jobs"
  add_foreign_key "image_uploads", "robo_jobs"
  add_foreign_key "robo_events", "robo_events", column: "parent_robo_event_id"
  add_foreign_key "robo_jobs", "projects"
  add_foreign_key "robo_jobs", "robo_jobs", column: "parent_job_id"
  add_foreign_key "robo_requests", "robo_events"
end
