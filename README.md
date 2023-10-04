# aws-terraform-deployment
This PoC project sets up an EC2 autoscaling group containing nginx webserver instances listening on port 80, behind an ALB. Therefore It is assumed that there will be an application running as well behind the nginx webserver which will need access to the DB.

The instances export the RDS DB DNS endpoint as a system variable in userdata on bootstrap.

The project is based on the following diagram and greatly expands upon it:

![diagram](./images/diagram.png)

## Boilerplate code changes (Most of these can also be seen in commit messages)

1. First I merged the provided boilerplate codebase from `infrastructure-deployment` into my new `aws-terraform-deployment` directory in order to create a new single main terraform module for the purpose of this project.

2. **default tags vs merging with locals** I can see the code uses the legacy `merge` tactic to deal with tags. In my opinion it is a good idea to change these into the AWS builtin [default_tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider) as it can provide both a cleaner/ more DRY/intuitive way to deal with them. Another benefit of doing this is that then all resources will contain default tags, avoiding leaving any without.

3. Decided to add a `region` variable so that the module is not restricted to run in a specific hard coded region (future proof / modularised) - this could mean the module can be later on further enhanced with a wrapper like [Terragrunt](https://github.com/gruntwork-io/terragrunt) where we can add multiple regions using variations of some inputs in each `terragrunt.hcl`, if desired (won't include this particular layout in this project but I'm happy to develop on this on a further call).

4. Decided to bring the `terraform`` version up to the latest minor version, for security and bug fixes reasons as well as giving access to all latest features and functions.

5. Added an S3 state bucket as a best practice (with the option to also use a DDB lock table) - please feel free to comment it out when applying on your end or to replace the bucket name by one of your own (I'm using my own free tier account to test the demo).

## New Stuff

### Terraform Pre Commit Linter Hook

- Decided to add **pre-commit** config to use **Anton Babenko**'s very handy `tflint` `pre-commit-terraform` hooks (https://github.com/antonbabenko/pre-commit-terraform). 

- A `CONTRIBUTING.md` file was also added in order to help other developers quickly set themselves up for these. The hooks run automatically upon every git commit after the first initial install. Please run the commands listed in the file in order to test this on your end. You can manually force run the pre commit hooks with `pre-commit run -a` as well as letting it autorun with every commit.

**NOTE** These can also be further complemented by hooks such as `terraform-docs` which automates creation of `README.md` files in a project based on stuff such as variable descriptions or resource outputs (fully customisable with a [terraform-docs.yaml](https://terraform-docs.io/user-guide/configuration/)) and many others.

### New EC2 Resources

- new file `ec2.tf` containing all new ec2 resources.
- **HTTPS and Security**: For the purpose of this project I won't use an ACM certificate or an **SSL HTTPS listener** on the ALB, mainly because I'm making this so that it runs on my free tier account as well as yours with no issue. However please note that I would set up the ALB to have an **HTTPS listener** which has an **ACM certificate** attached related to the domain of this webserver, and that I would set up automatic redirection of any HTTP requests to the HTTPS listener as well. The instance will only have access to port 80 and SSL will be terminated at the LB.
- **Security Group rules on the instance and LB**: the idea here is going with the usual secure approach of allowing access only from the LB to the instance and giving public access to the ALB HTTP port (as I assume this webserver will be public based on the public subnets provided in boilerplate code)
- based on the above, I created a `handle_sg` security group that will be used to allow traffic to the instances at port 80 **only** from the ALB (to prevent applications or testers trying to use this webserver directly on the instance port - may not be suited to all case scenarios of course and just added here for demo purposes)

### Autoscaling

- I set up autoscaling rules so that there is a desired number of `2` nodes, with a min of `1` and a max of `4`. These will vary according to the `CPUUtilization` native EC2 metric with thresholds of above or below `70%` and two evaluation periods of 5 minutes for both triggers (for production this could maybe be reduced to 5 periods of 60 seconds probably).

- in the beginning I set it with two 2 instances using `count = 2` on an `ec2_instance_resource` but then changed my mind as I couldn't think this would be optimal if this is supposed to be a public facing web server, it would at least require some basic autoscaling to cope with unexpected pressure. Of course if the requirement is to keep it simple at 2 then it can easily be changed.

## Further Questions from Exercise README  


- Q: How would a future application obtain the load balancer’s DNS name if it wanted to use this service?
- A: The main solution that comes to mind is by creating an SSM parameter resource with the `"alb_dns_name"` terraform output (included in this project) as a value, so that the other application can easily obtain the record by polling this parameter.
- Another solution is by using the `terragrunt` wrapper and utilising `dependency` blocks. The output will still be used, but in this case the terraform on the other app module will be the one reading from the dependency and therefore bootstrapping the app by already including the DNS from this module. Example: https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#dependency

- Q: What aspects need to be considered to make the code work in a CD pipeline (how does it successfully and safely get into production)?
- A: For starters we need to make sure the RDS credentials won't be pushed into the project in unencrypted form. We could put them on SSM or Secrets Manager, and then poll those services from somewhere like github Actions or similar to retrieve the password. Alternatively the password field could be removed from the project after initial creation, as it is not a required argument.

- The layout for the CI/CD pipeline would consist on a typical set of steps like what HashiCorp recommends at https://developer.hashicorp.com/terraform/tutorials/automation/automate-terraform#automated-terraform-cli-workflow

Which would be pretty much the core of:

1. `terraform init -input=false`
2. `terraform validate` (or execute the tflint scripts used in my project for consistency)

3. `terraform plan -out=tfplan -input=false` # on all pushes
4. `terraform apply -input=false tfplan` # on merges to `main`

Appropriate security of this CI project should be achieved by restricting the plan to be run only by users members of a certain group (like Administrators only). The Plan shall also use AWS Credentials or IAM Profile Roles in order to securely access the resources and actions in the project.

## What was done to test this/ How to Apply

- Ensure you have `terraorm 1.5.1` installed (I use `tfenv` to easily manage switching between versions).
- Run `terraform apply` from the top

**NOTES:**
- I tried to stay pragmatic here. 
- I added some nice things I thought would improve the project but there's more that can be done in terms of polishing and further enhancing, some of that has been mentioned above. 
- I used my AWS Free Tier account to test the whole apply. My current list of resources is the following:

```shell
gonz@pop-os:~/git/aws-terraform-deployment$ terraform state list
data.aws_ami.amazon_linux_2
data.aws_availability_zones.current
aws_autoscaling_group.cint_infrastructure
aws_autoscaling_policy.scale_in_policy
aws_autoscaling_policy.scale_out_policy
aws_db_instance.rds_instance
aws_db_subnet_group.rds_subnet_group
aws_eip.nat_eip
aws_internet_gateway.main
aws_launch_template.cint_infrastructure
aws_lb.cint_infrastructure
aws_lb_listener.cint_infrastructure_listener
aws_lb_target_group.cint_infrastructure
aws_nat_gateway.nat
aws_route_table.private
aws_route_table.public
aws_route_table_association.private[0]
aws_route_table_association.private[1]
aws_route_table_association.private[2]
aws_route_table_association.public[0]
aws_route_table_association.public[1]
aws_route_table_association.public[2]
aws_security_group.alb_sg
aws_security_group.handle_sg
aws_security_group.rds_sg
aws_subnet.private[0]
aws_subnet.private[1]
aws_subnet.private[2]
aws_subnet.public[0]
aws_subnet.public[1]
aws_subnet.public[2]
aws_vpc.main
```

- This is also proof of a successfull apply on my test account:

```bash
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = "cint-infrastructure-alb-1730441350.us-east-1.elb.amazonaws.com"
application_http_endpoint = "http://cint-infrastructure-alb-1730441350.us-east-1.elb.amazonaws.com"
rds_dns_endpoint = "cint-code-test-db-instance.clsket2a8vwn.us-east-1.rds.amazonaws.com:3306"
```

- I will now destroy all the resources to avoid any possible charges :) but I can recreate it all if needed on a further call. I hope you can also run this well on your end.