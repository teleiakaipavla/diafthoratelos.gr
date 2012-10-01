xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "teleiakaipavla incidents"
    xml.description "teleiakaipavla: recent incidents"
    # TODO: use incidents_url when outside WP
    xml.link "http://www.teleiakaipavla.gr/backkick/incidents"
    #xml.link incidents_url

    for incident in @incidents
      title_start = ""
      title_suffix = ""
      if incident.praise?
        title_start = t(:piece_of_good_news)
      else
        title_start = t(:piece_of_bad_news)
        title_suffix += " #{t(:money_asked)} #{incident.money_asked}"
        title_suffix += " #{t(:money_given)} #{incident.money_given}"
      end
      xml.item do
        xml.title "#{title_start}: #{incident.public_entity_name}" +
          "#{title_suffix}"
        xml.description incident.description
        xml.pubDate incident.created_at.to_s(:rfc822)
        target_url =
          "http://www.teleiakaipavla.gr/?cat=22&inc=#{incident.id}"
        xml.link target_url
        xml.guid target_url
        # TODO: use incident_url when outside WP
        # xml.link incident_url(incident)
        # xml.guid incident_url(incident)
      end
    end
  end
end