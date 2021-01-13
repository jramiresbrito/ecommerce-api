json.system_requirements do
  json.array! @loading_service.records, :id, :name, :operational_system, :storage, :processor, :memory, :video_board
end
