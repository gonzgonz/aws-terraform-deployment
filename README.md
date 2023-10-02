# Infrastructure deployment exercise

Using Terraform, automate the build of the following application in AWS. For the purposes of this challenge, use any Linux based AMI id for the two EC2 instances and simply show how they would be provisioned with the connection details for the RDS cluster.

![diagram](./images/diagram.png)

There are a lot of additional resources to create even in this simple setup, you can use the code we have made available that will create some structure and deploy the networking environment to make it possible to plan/apply the full deployment. Feel free to use and/or modify as much or as little of it as you like.

Document any assumptions or additions you make in the README for the code repository. You may also want to consider and make some notes on:

How would a future application obtain the load balancer’s DNS name if it wanted to use this service?

What aspects need to be considered to make the code work in a CD pipeline (how does it successfully and safely get into production)?

# Boilerplate code changes (Most of these can also be seen in commit messages)

1. First I merged the provided boilerplate codebase from `infrastructure-deployment` into my new `aws-terraform-deployment` directory in order to create a new single main terraform module for the purpose of this project.
2. I can see the code uses the legacy `merge` tactic to deal with tags. In my opinion it is a good idea to change these into [default_tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider) as it can provide both a cleaner/ more DRY/intuitive way to deal with them.
3. Decided to add a `region` variable so that the module is not restricted to run in a specific hard coded region (future proof / modularised) - this could mean the module can be later on further enhanced with a wrapper like [Terragrunt](https://github.com/gruntwork-io/terragrunt) where we can add multiple regions using variations of some inputs in each `terragrunt.hcl`, if desired (won't include this particular layout in this project but I'm happy to develop on this on a further call).
4. Decided to bring the terraform version up to the latest minor version, for security, bug fixes, and giving access to all latest features and functions.


