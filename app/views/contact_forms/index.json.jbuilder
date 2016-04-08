json.array!(@contact_forms) do |contact_form|
  json.extract! contact_form, :id, :message
  json.url contact_form_url(contact_form, format: :json)
end
