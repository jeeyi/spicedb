#!/bin/bash

# set context
zed context set poc localhost:50051 "authzedpoc" --insecure

# vars
SUB_ID=1
PLAN_ID=1

if [ $1 ]
then
  NUM_CORP=$1
else
  NUM_CORP=10
fi

# create permissions for NUM_CORP corporations with 1-2 subscriptions
for (( i=1; i<=NUM_CORP; i++)) 
  do
    zed relationship create subscriptions/subscription:$SUB_ID view subscriptions/corporation:$i
    echo "Added subscriptions/corporation:$i view subscriptions/subscription:$SUB_ID"

    # every 5th corporation has two subscriptions
    if [ `expr $i % 5` == 0 ]
    then
      ((SUB_ID++))
      zed relationship create subscriptions/subscription:$SUB_ID view subscriptions/corporation:$i
      echo "Added subscriptions/corporation:$i view subscriptions/subscription:$SUB_ID"
    fi
done 

# create relationship between subscriptions and plans
for (( j=1; j<=SUB_ID; j++)) 
  do
    zed relationship create subscriptions/plan:$PLAN_ID view subscriptions/subscription:$j#view
    echo "Added subscriptions/subscription:$j#view view subscriptions/plan:$PLAN_ID"

    # each plan is associated with 100 subscriptions 
    if [ `expr $j % 100` == 0 ]
    then
      ((PLAN_ID++))
    fi
done

# create relationship between plans and features
for (( k=1; k<=PLAN_ID; k++)) 
  do
    # each plan has 10 out of 40 features
    (( FEATURE_OFFSET=(k-1)%40 ))

    for (( f=1; f<=10; f++ ))
    do
      (( FEATURE_ID=f+FEATURE_OFFSET ))
      zed relationship create subscriptions/feature:$FEATURE_ID view subscriptions/plan:$k#view
      echo "Added subscriptions/plan:$k#view view subscriptions/feature:$FEATURE_ID"
    done  
done

echo "$NUM_CORP CORPORATIONS"
echo "$SUB_ID SUBSCRIPTIONS"
echo "$PLAN_ID PLANS"
echo "40 FEATURES"