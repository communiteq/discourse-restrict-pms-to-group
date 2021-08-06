# name: discourse-restrict-pms-to-group
# about: restrict pms to group
# version: 1.0
# authors: michael@communiteq.com
# url: https://github.com/communiteq/discourse-restrict-pms-to-group

enabled_site_setting :discourse_restrict_pms_to_group_enabled

after_initialize do
  module ::GuardianOverride
    def can_send_private_message?(target, notify_moderators: false)
      return super unless SiteSetting.discourse_restrict_pms_to_group_enabled

      return false unless super

      if target.is_a?(User)
        restricted_groups = SiteSetting.discourse_restrict_pms_restricted_groups.split('|').map { |s| s.to_i }
        if target.groups.pluck(:id).intersection(restricted_groups).count > 0
          privileged_groups = SiteSetting.discourse_restrict_pms_privileged_groups.split('|').map { |s| s.to_i }
          return @user.groups.pluck(:id).intersection(privileged_groups).count > 0
        end
      end

      return true
    end
  end

  class ::Guardian
    prepend GuardianOverride
  end
end
