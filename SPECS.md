# Specifications of the Group Messaging Service App

## Entities of the system

Users are records containing optional first and last name and an 11 digit phone number.

Groups are comprised of multiple users which will receive broadcast text messages for the corresponding group.

Admins are user numbers which are allowed to send text messages to group "gateway" numbers. They are promoted to admins and given access to zero or
more groups by the super admin.

Super Admin is the single admin user who has all administrative privileges including promoting users to admin status.

Gateway numbers are Plivo numbers that are purchased for a monthly subscription through Plivo's admin interface.  They are used to broadcast text messages
sent from admin user numbers to all user numbers of a specific group.  Gateway numbers can only be assigned to one group at a time,
but they can all participate in round-robin style broadcasting of messages to members of a group, 5 at a time.

The Stop List is a collection of numbers belonging to users who have texted (case insensitive) 'stop' in response to a group broadcast.  User numbers
can voluntarily initialize or restart a group subscription by texting (case insensitive) 'start' to the gateway number for that group.

The Forbidden List is a collection of numbers belonging to users who have been flagged as unauthorized which effectively excludes them from any
groups or admin status. They must be flagged by admins via the web interface.

## Admin phone number functionality

A user whose 11 digit phone number is listed as an admin in the database is allowed to send text messages to a pre-defined Plivo number which will then
be broadcast to the group to which that predefined Plivo number is assigned.  While the Plivo number receiving a text from an admin user number will
kick off a group broadcast, the broadcast texts may be received from multiple Plivo numbers in order to minimize the risk that phone providers will block
messages coming from the same Plivo number in rapid succession.  The texts will be sent from a cycle of Plivo numbers if multiple Plivo numbers have been
purchased.
This broadcast will be done in a throttled manner by sending at random time intervals (reasonably delayed) between each send request to 5 or fewer group member numbers.

## Super Admin web interface functionality

The sole super user can login to the web interface and manage the group messaging service system through the following actions:
-manually add or remove users
-move users to the stop_numbers or forbidden_numbers
-promote/demote users to/from admins
-add/remove users to/from groups in bulk
-create groups
-add/remove new plivo numbers
