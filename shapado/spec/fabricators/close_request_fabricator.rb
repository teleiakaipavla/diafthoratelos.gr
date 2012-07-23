Fabricator(:close_request) do
  reason { CloseRequest::REASONS[rand()*CloseRequest::REASONS.size]}
  closeable(:fabricator => :question)
  user
  after_build do |request|
    if request.closeable && !request.user.member_of?(request.closeable.group)
      request.user.join!(request.closeable.group)
      request.user.update_reputation(30000, request.closeable.group)
    end
  end
end
