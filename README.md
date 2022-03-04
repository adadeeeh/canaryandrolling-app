# canaryandrolling-app

# Description

This terraform configuration us used to create server on top of [this network](https://github.com/adadeeeh/canaryandrolling) and use remote state of the workspace above as input.

# Configuration

1. Use Therraform Cloud as the backend. Create new workspace and create environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.
2. Create github actions for Terraform.
3. Create github secrets `GITHUB_TOKEN`.
4. For production used, create branch rule to protect main branch and enable require status checks to pass before merging.
5. Configure run trigger by navigating to "Settings" page, under "Run Triggers" tab. Add run trigger by selecting the network worskpace and click "Add workspace". This is done so that whenever the network workspace is running Terraform Apply command, this server workspace is autoamtically running Terraform Apply too.

# References

1. https://learn.hashicorp.com/tutorials/terraform/blue-green-canary-tests-deployments?in=terraform/applications
2. https://learn.hashicorp.com/tutorials/terraform/github-actions
3. https://learn.hashicorp.com/tutorials/terraform/cloud-run-triggers
