# name: discourse-restrict-pms-to-group
# about: restrict pms to group
# version: 1.0
# authors: michael@communiteq.com
# url: https://github.com/communiteq/discourse-restrict-pms-to-group

enabled_site_setting :discourse_restrict_pms_to_group_enabled

after_initialize do
  NewPostManager.add_handler do |manager|
    next unless SiteSetting.discourse_restrict_pms_to_group_enabled

    privileged_groups = SiteSetting.discourse_restrict_pms_privileged_groups.split('|').map { |s| s.to_i }
    restricted_groups = SiteSetting.discourse_restrict_pms_restricted_groups.split('|').map { |s| s.to_i }

    # we can bail out if we are in the privileged or restricted groups ourself
    next if manager.user.groups.pluck(:id).intersection(restricted_groups.union(privileged_groups)).count > 0

    user_ids = []
    # the first post of a PM has archetype 'private_message'
    # in that case we have target_usernames as a comma separated array
    if manager.args[:archetype] == 'private_message'
      user_ids = User.where(username_lower: manager.args[:target_usernames].downcase.split(',')).pluck(:id) - [ manager.user.id ]
    end

    # later posts have archetype regular, we need to check the topic in that case
    # in this case we have topic.allowed_users
    if manager.args[:topic_id]
      topic = Topic.find(manager.args[:topic_id])
      if topic && topic.archetype == 'private_message'
        user_ids = topic.allowed_users.pluck(:id) - [ manager.user.id ]
      end
    end

    # bail out if there are no users that are in restricted groups
    next unless user_ids.count > 0
    next unless GroupUser.where(group_id: restricted_groups).where(user_id: user_ids).exists?

    # but if there are then we need to fail this action
    result = NewPostResult.new(:created_post, false)
    result.errors.add(:base, 'You are not allowed to message that user.')
    result
  end

end
