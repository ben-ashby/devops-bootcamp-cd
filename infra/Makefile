up:
	terraform apply --auto-approve -var environment=${ENV}

down:
	terraform destroy --auto-approve -var environment=${ENV}

init:
	terraform init --backend-config="key=state/${ENV}.tfstate" --backend-config="dynamodb_table=bootcamp-locktable-tioe3s" --backend-config="bucket=bootcamp-tfstate-tioe3s"
