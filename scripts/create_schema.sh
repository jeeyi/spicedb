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
EOF
)

# read schema
zed schema read
