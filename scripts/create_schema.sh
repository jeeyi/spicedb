#!/bin/bash

# set context
zed context set poc localhost:50051 "authzedpoc" --insecure

# write schema
zed schema write <(cat << EOF
definition subscriptions/corporation {}

definition subscriptions/subscription {
	relation view: subscriptions/corporation
}

definition subscriptions/plan {
	relation view: subscriptions/subscription#view
}

definition subscriptions/feature {
	relation view: subscriptions/plan#view
}

definition cds/carta_group {
	relation member: cds/carta_user
}

definition cds/carta_user {
}

definition cds/usergroup {
	relation member: cds/carta_user | cds/carta_group#member | cds/usergroup#member
}

definition cds/content {
    relation parent: cds/content
    relation administrator: cds/carta_user | cds/carta_group#member | cds/usergroup#member
    relation editor: cds/carta_user | cds/carta_group#member | cds/usergroup#member
    relation viewer: cds/carta_user | cds/carta_group#member | cds/usergroup#member

    permission admin = parent->admin + administrator
    permission edit = parent->edit + admin + editor
    permission view = edit + parent->view + viewer
}

EOF
)

# read schema
zed schema read
