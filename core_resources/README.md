# js-controlm-services
JS Control-M Infrastructure for core_resources

Copy of JS AMI's
The AMI's are created from the JS CIS Level 1 for Amazon-Linux2 and RHEL 7.2. Once these AMI's have been created,
the instances they are created from need to be terminated to save IP's and costs.
The AMI's can be re-created by re-running the Terraform stack for 'core_resources' under both environment folders.

The new AMI servers created in tfCode/createInstances.tf must complete and the instances must have completed all installatio
of additional software before we can initiate the tfCode_Post/copyAMI.tf code. Because we can't tell how long this will take,
it's best to comment out the module "post_core_resources" in the main.tf code. Run the terraform to re-create the AMI servers
and manually check their completion from the syslog.
When everthing is completed, re-add the module "post_core_resources" in the main.tf and re-apply.
