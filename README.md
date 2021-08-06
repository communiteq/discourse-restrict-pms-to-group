## Discourse Restrict PMs to Group Plugin

Restricts sending personal messages to members of a group to members of another group.

## How to Install this Plugin

To install Discourse Plugin - https://meta.discourse.org/t/install-a-plugin/19157

## Configuration

Go to Admin - Plugins - discourse-restrict-pms-to-group - Settings

`discourse restrict pms to group enabled` : enable the plugin

members of the `discourse restrict pms restricted groups` groups cannot receive personal messages, except when sent by members of one of the groups in `discourse restrict pms privileged groups`.

So in `discourse restrict pms restricted groups` the target groups are defined,
and `discourse restrict pms privileged groups` defines the sender groups.


