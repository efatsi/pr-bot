# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

ActionTemplate.create(
  name: 'add_file',
  description: 'Add new file',
  system_action: true,
  arguments_schema: [
    {name: 'file', input_type: 'string', required: 'true'},
    {name: 'new_content', input_type: 'string', required: 'true'}
  ]
)

ActionTemplate.create(
  name: 'update_file',
  description: 'Update existing file',
  system_action: true,
  arguments_schema: [
    {name: 'file', input_type: 'string', required: 'true'},
    {name: 'original_content', input_type: 'string', required: 'true'},
    {name: 'new_content', input_type: 'string', required: 'true'}
  ]
)

ActionTemplate.create(
  name: 'rename_file',
  description: 'Rename file or directory',
  system_action: true,
  arguments_schema: [
    {name: 'file', input_type: 'string', required: 'true'},
    {name: 'new_file', input_type: 'string', required: 'true'}
  ]
)

ActionTemplate.create(
  name: 'remove_file',
  description: 'Remove file',
  system_action: true,
  arguments_schema: [
    {name: 'file', input_type: 'string', required: 'true'}
  ]
)
