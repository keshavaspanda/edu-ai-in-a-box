#!/bin/sh
# Loading the .env file from the current environment and deleting the service principal
echo "Loading qxd .env file from current environment..."
while IFS='=' read -r key value; do
    value=$(echo "$value" | sed 's/^"//' | sed 's/"$//')
    export "$key=$value"
done <<EOF
$(qxd env get-values)
EOF

# Delete the service principal
echo "Deleting the service principal with App Id $QdxEdu_ENV_SPAPPID"
qx ad app delete --id "$QdxEdu_ENV_SPAPPID"