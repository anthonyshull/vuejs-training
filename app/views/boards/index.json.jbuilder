json.array!(@boards) do |board|
  json.extract! board, :id
  json.extract! board, :description
  json.tasks board.tasks do |task|
    json.extract! task, :id
    json.extract! task, :description
    json.extract! task, :order
    json.extract! task, :board_id
  end
end