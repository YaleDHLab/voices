json.array!(@records) do |record|
  json.extract! record, :id, :cas_user_name, :title, :metadata
  json.url record_url(record, format: :json)
end
