json.array!(@records) do |record|
  json.extract! record, :id, :cas_user_id, :title, :metadata
  json.url record_url(record, format: :json)
end
