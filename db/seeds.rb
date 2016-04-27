# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Board.create([{ description: "To do"}, { description: "In Progress" }, { description: "Done" }])
Task.create([{ description: "Go to work", order: 0, board_id: 1 }, { description: "Eat Breakfast", board_id: 2}, { description: "Get up", order: 1, board_id: 3 }])