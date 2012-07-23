module OmniAuth
  module Strategies
    class SsoStrategy
      include OmniAuth::Strategy

      def initialize(app, options = {}, &block)
        super(app, :sso, options, &block)
        @sso_url = nil
      end

      attr_reader :sso_url

      def call!(env)
        host = env["HTTP_HOST"].split(':').first
        group = Group.where(:domain => host).first
        @sso_url = group.sso_url if group

        super
      end

      def request_phase
        raise ArgumentError, "group.sso_url must be provided" if sso_url.blank?

        redirect sso_url
      end

      def callback_phase
        check_cookies
        call_app!
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid'       => request.cookies['oa_sso_id'],
          'user_info' => user_info,
          'extra'     => {}
        })
      end

      def user_info
        {
          'nickname' => request.cookies['oa_sso_nickname'],
          'first_name' => request.cookies['oa_sso_first_name'],
          'last_name' => request.cookies['oa_sso_last_name'],
          'name' => request.cookies['oa_sso_name'] || "#{request.cookies['oa_sso_first_name']} #{request.cookies['oa_sso_last_name']}",
          'email'=> request.cookies['oa_sso_email']
        }
      end

      protected
      def check_cookies
        %w[oa_sso_id oa_sso_first_name oa_sso_last_name].each do |key|
          if !request.cookies[key]
            raise ArgumentError, "#{key} was not found in cookie" # TODO: replace this with fail!()
          end
        end

        if request.cookies['oa_sso_id'].length < 15
          raise ArgumentError, "oa_sso_id is too short. minimum size is 15"
        end
      end
    end
  end
end
