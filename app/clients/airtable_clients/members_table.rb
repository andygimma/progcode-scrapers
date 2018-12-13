
Airrecord.api_key = ENV['AIRTABLE_KEY']

class AirtableChannelListTable < Airrecord::Table
  self.base_key   = ENV['AIRTABLE_APP']
  self.table_name = ENV['AIRTABLE_BASE']

  def self.add_or_update_channel(channel, channel_details)
    if self.channel_exists?(channel)
      self.new({
        "Channel Name"     => channel[:name],
        "Creation Date"    => Time.at(channel[:created]).strftime("%m/%d/%Y"),
        "Membership"       => channel[:num_members],
        "Status"           => channel[:is_archived] ? "Archived" : "Active",
        "Channel Purpose"  => channel[:purpose][:value],
        "Last Activity"    => Time.at((channel_details&.latest&.ts || channel_details&.last_read).to_f).strftime("%m/%d/%Y"),
        "Channel Topic"    => channel_details.topic.value,
      })
    else
      existing_channel = self.find(matches[0].id)
      existing_channel["Channel Name"]     = channel[:name]
      existing_channel["Creation Date"]    = Time.at(channel[:created]).strftime("%m/%d/%Y")
      existing_channel["Membership"]       = channel[:num_members]
      existing_channel["Channel Purpose"]  = channel[:purpose][:value]
      existing_channel["Status"]           = "Archived" if channel[:is_archived]
      existing_channel["Last Activity"]    = Time.at((channel_details&.latest&.ts || channel_details&.last_read).to_f).strftime("%m/%d/%Y")
      existing_channel["Channel Topic"]    = channel_details.topic.value
      existing_channel.save
    end
  end

  private
  def self.channel_exists?(channel)
    self.all({filter: "{Channel Name} = \"#{channel[:name]}\""}).any?
  end
end