# Infrastructure deployment exercise

Using Terraform, automate the build of the following application in AWS. For the purposes of this challenge, use any Linux based AMI id for the two EC2 instances and simply show how they would be provisioned with the connection details for the RDS cluster.

![diagram](./images/diagram.png)

There are a lot of additional resources to create even in this simple setup, you can use the code we have made available that will create some structure and deploy the networking environment to make it possible to plan/apply the full deployment. Feel free to use and/or modify as much or as little of it as you like.

Document any assumptions or additions you make in the README for the code repository. You may also want to consider and make some notes on:

How would a future application obtain the load balancer’s DNS name if it wanted to use this service?

What aspects need to be considered to make the code work in a CD pipeline (how does it successfully and safely get into production)?

## Boilerplate code changes (Most of these can also be seen in commit messages)

1. First I merged the provided boilerplate codebase from `infrastructure-deployment` into my new `aws-terraform-deployment` directory in order to create a new single main terraform module for the purpose of this project.
2. I can see the code uses the legacy `merge` tactic to deal with tags. In my opinion it is a good idea to change these into [default_tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider) as it can provide both a cleaner/ more DRY/intuitive way to deal with them.
3. Decided to add a `region` variable so that the module is not restricted to run in a specific hard coded region (future proof / modularised) - this could mean the module can be later on further enhanced with a wrapper like [Terragrunt](https://github.com/gruntwork-io/terragrunt) where we can add multiple regions using variations of some inputs in each `terragrunt.hcl`, if desired (won't include this particular layout in this project but I'm happy to develop on this on a further call).
4. Decided to bring the terraform version up to the latest minor version, for security, bug fixes, and giving access to all latest features and functions.

## Code Additions 

### Main Code Base Additions

- Decided to add **pre-commit** config to use **Anton Babenko**'s very handy `tflint` `pre-commit-terraform` hooks (https://github.com/antonbabenko/pre-commit-terraform). 

- A `CONTRIBUTING.md` file was also added in order to help other developers quickly set themselves up for these. The hooks run automatically upon every git commit after the first initial install.

**NOTE** These can also be further complemented by hooks such as `terraform-docs` which automates creation of `README.md` files in a project based on stuff such as variable descriptions or resource outputs (fully customisable with a [terraform-docs.yaml](https://terraform-docs.io/user-guide/configuration/)) and many others.