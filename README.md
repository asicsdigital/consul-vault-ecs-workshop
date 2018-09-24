# Consul and Vault on AWS ECS

This repository contains the workshop content for our talk on running Consul and Vault on AWS ECS.  We've given the talk on the following occasions:

* [DevOpsDays Boston 2018](https://www.devopsdays.org/events/2018-boston/program/tim-hartmann)

## Requirements

You will need access to the following in order to complete this workshop:

* an AWS account (sign up [here](https://aws.amazon.com/getting-started/)).  The resources required for this lab should all fit within the AWS [Free Tier](https://aws.amazon.com/free/) if you created your AWS account less than 12 months ago.
* a computer with a (more or less) [POSIX-compliant](https://en.wikipedia.org/wiki/POSIX#POSIX-oriented_operating_systems) operating system.  This workshop was developed and tested on a Mac; I'm confident it should work on just about any Linux or BSD.  I'm sorry, Windows-using colleagues; I'd be happy to accept a pull request with changes to support your platform!  [Chocolatey](https://chocolatey.org/) is perhaps a good place to start?
* a [Git](https://git-scm.com/) client.  The most straightforward way to get the command-line Git client on a Mac is to install [XCode](https://developer.apple.com/xcode/); on other systems, use the native package manager to install Git or download an installer from the [Git website](https://git-scm.com/).  Sample code in this repository will assume you're using the command-line Git client; if you're using a different client, you'll need to translate the commands appropriately.
* HashiCorp [Terraform](https://www.terraform.io/).  Download Terraform from the [website](https://www.terraform.io/downloads.html) or use your native package manager.
* the AWS [command-line interface](https://aws.amazon.com/cli/).  Follow the instructions in the AWS CLI [User Guide](http://docs.aws.amazon.com/cli/latest/userguide/) to install and configure; you must complete the [Install](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) and [Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) steps.

Text formatted like this

```sh
$ this_is_a_command
this_is_output
...
this_is_more_output
$ this_is_another_command
```

represents a command-line session.  Lines beginning with `$` indicate commands that you enter at the shell prompt; other lines are examples of output you should expect to see after you enter the commands.  On a Mac, launch Terminal.app to get a shell; on a Linux system, use GNOME Terminal or Konsole (or xterm for the traditionalists among us).  None of the commands you enter during this workshop should require root access or the `sudo` command.

## Step 1

1. Check out this repository.
```sh
$ git clone https://github.com/asicsdigital/consul-vault-ecs-workshop
Cloning into 'consul-vault-ecs-workshop'...
...
$ cd consul-vault-ecs-workshop
```

2. Switch to the `step1` branch.
```sh
$ git checkout step1
Branch 'step1' set up to track remote branch 'step1' from 'origin'.
Switched to a new branch 'step1'
$
```

3. Run `terraform init` to download the required Terraform plugins.
```sh
$ terraform init
Initializing modules...
- module.infra_1
  Getting source "github.com/terraform-community-modules/tf_aws_ecs?ref=v5.4.0"
- module.infra_2
  Getting source "github.com/terraform-community-modules/tf_aws_ecs?ref=v5.4.0"
- module.vpc
  Found version 1.43.2 of terraform-aws-modules/vpc/aws on registry.terraform.io
  Getting source "terraform-aws-modules/vpc/aws"

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "template" (1.0.0)...
- Downloading plugin for provider "aws" (1.36.0)...

Terraform has been successfully initialized!
...
$
```

4. You'll need to set one Terraform variable in order to proceed; that's `vpc_name`, which will identify the [Amazon VPC](https://aws.amazon.com/vpc/) in which you'll provision resources.  VPC names have some limitations; for this workshop, we ask that you choose a name that's a valid [DNS label](https://en.wikipedia.org/wiki/Domain_name#Domain_name_syntax).  You can run the script `init_tfvars.sh` to generate a `_terraform.auto.tfvars` file; this will try to generate a valid value for `vpc_name`.
```sh
$ ./init_tfvars.sh
vpc_name = "shuff-63899"
$
```

5. Now you're ready for a Terraform run!  This first step will provision a VPC (with associated subnets, Internet gateway, NAT gateways, route tables, etc.) and two ECS clusters.  No services will be deployed to those clusters yet; that's for the next steps in this workshop.
```sh
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.aws_region.current: Refreshing state...
...
------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
...
------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```
Once the `terraform plan` completes, it'll show you a bunch of resources to be created.  Create them with a `terraform apply`.
```sh
$ terraform apply
data.aws_region.current: Refreshing state...
...
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
...
Apply complete! Resources: 86 added, 0 changed, 0 destroyed.
```

Log into the [ECS console](https://console.aws.amazon.com/ecs) (make sure you've selected the correct region) and you should see your two ECS clusters, `infra-<REGION>_1` and `infra-<REGION>_2`.  Each should have 0 services and tasks, and 2 container instances.

## Step 2

1. Switch to the `step2` branch.
```sh
$ git checkout step2
Branch 'step2' set up to track remote branch 'step2' from 'origin'.
Switched to a new branch 'step2'
$
```

2. Generate a HTTP Basic Auth password to enable access to your Consul cluster.  This deployment also supports OAuth2, but we're not going to configure that right now in the interest of time.  This branch has an updated version of the `init_tfvars.sh` script; run this to add some new Terraform variables to `_terraform.auto.tfvars`.
```sh
$ ./init_tfvars.sh
vpc_name = "shuff-63899"
# password: 21661
consul_sha_htpasswd_hash = "consul:{SHA}6WZ72ox3d/sTju9YbIpGtEuOPgQ="
$
```
Make note of the password!  You'll need that later on to connect to the Consul REST API.

3. Run another `terraform init` to download new dependencies.
```sh
$ terraform init
Initializing modules...
- module.infra_1
  Getting source "github.com/terraform-community-modules/tf_aws_ecs?ref=v5.4.0"
- module.infra_2
  Getting source "github.com/terraform-community-modules/tf_aws_ecs?ref=v5.4.0"
...
$
```

4. Run another `terraform apply` to create your Consul cluster.
```sh
$ terraform apply
data.aws_region.current: Refreshing state...
...
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
...
Apply complete! Resources: 17 added, 0 changed, 0 destroyed.

Outputs:

consul_url = http://consul20180923153406741500000005-1418999670.us-east-1.elb.amazonaws.com
```
See that `consul_url` output?  That's the public-facing endpoint of your new Consul cluster.  Make note of that as well.  If you forget it, run `terraform output` in your current directory.

5. Wait a minute or two for your Consul nodes to start up and complete their cluster election.  You can watch the logs via the ECS console; look at either of the two ECS clusters you created, select the `consul-workshop-primary` or `consul-workshop-secondary` service, and then look at the logs for the `consul_cluster-workshop` containers.

6.  Send a basic healthcheck to the proxy server in front of the Consul REST API to make sure it's healthy.  You'll need to construct your own HTTP request based on the password and the URI you made note of earlier.
```sh
$ curl -s --user consul:21661 http://consul20180923153406741500000005-1418999670.us-east-1.elb.amazonaws.com/ping
OK
$
```
Now use the Consul status API to confirm that the leader election has completed.
```sh
$ curl -s --user consul:21661 http://consul20180923153406741500000005-1418999670.us-east-1.elb.amazonaws.com/v1/status/leader
"10.0.20.248:8300
$
```
Finally, use the Consul catalog API to get some information about the nodes in the cluster.  I've piped this output through [jq](https://stedolan.github.io/jq/) to make it easier to read.
```sh
$ curl -s --user consul:21661 http://consul20180923153406741500000005-1418999670.us-east-1.elb.amazonaws.com/v1/catalog/nodes | jq .
[
  {
    "ID": "e985c15e-edf1-2022-101b-42435909b77b",
    "Node": "ip-10-0-10-247",
    "Address": "10.0.10.247",
    "Datacenter": "shuff-63899-us-east-1",
    "TaggedAddresses": {
      "lan": "10.0.10.247",
      "wan": "10.0.10.247"
    },
    "Meta": {
      "consul-network-segment": ""
    },
    "CreateIndex": 7,
    "ModifyIndex": 11
  },
...
$
```
Or, if you have the `consul` binary installed locally, you can use that.
```sh
$ CONSUL_HTTP_ADDR=http://consul20180923153406741500000005-1418999670.us-east-1.elb.amazonaws.com CONSUL_HTTP_AUTH=consul:21661 consul catalog nodes
```

## Step 3

1. Switch to the `step3` branch.
```sh
$ git checkout step3
Branch 'step3' set up to track remote branch 'step3' from 'origin'.
Switched to a new branch 'step3'
$
```

2. This branch has an updated `init_tfvars.sh` script to add a new Terraform variable for this next step.
```sh
$./init_tfvars.sh
vpc_name = "shuff-63899"
# password: 21661
consul_sha_htpasswd_hash = "consul:{SHA}6WZ72ox3d/sTju9YbIpGtEuOPgQ="

initialize_vault = true
```

3. Run another `terraform init` to download new dependencies.
```sh
$ terraform init
Initializing modules...
- module.infra_1
  Getting source "github.com/terraform-community-modules/tf_aws_ecs?ref=v5.4.0"
- module.infra_2
  Getting source "github.com/terraform-community-modules/tf_aws_ecs?ref=v5.4.0"
...
$
```

4. Run another `terraform apply` to initialize your Vault storage backend.
```sh
# terraform apply
aws_kms_key.vault: Refreshing state... (ID: 9ed01a78-c4dd-4b04-ba0c-a31b86afb39e)
data.aws_availability_zones.available: Refreshing state...
...
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
...
Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

consul_url = http://consul20180923153406741500000005-1418999670.us-east-1.elb.amazonaws.com
kms_key_alias = arn:aws:kms:us-east-1:332913666507:alias/vault-20180923190839497600000001
vault_url = http://vault-20180923200817732700000005-403418657.us-east-1.elb.amazonaws.com
$
```

5. You'll now need to retrieve the three unseal keys, which have been written to the `vault-init` task's log.  In the ECS console, find your first ECS cluster, browse to the `vault-init-workshop` service, and look at the task logs.  You want the logs for the `vault-init` task; the log messages should display three unseal keys and a root token.  These unseal keys are crucial to accessing your Vault cluster; save them and the root token somewhere secure!  They'll be purged from this log after a day.

6. Use [AWS KMS](https://aws.amazon.com/kms/) to encrypt your Vault unseal keys.  There's an `encrypt_unseal_keys.sh` script that takes the three keys as arguments; it'll encrypt them and update your Terraform variables appropriately.  Be sure to enclose the keys in single quotes to avoid shell interpolation of metacharacters!
```sh
$ ./encrypt_unseal_keys.sh 'KEY1' 'KEY2' 'KEY3'
vpc_name = "shuff-63899"
# password: 21661
consul_sha_htpasswd_hash = "consul:{SHA}6WZ72ox3d/sTju9YbIpGtEuOPgQ="

kms_payload = "AQICAHh48hy2SYp5yAT0HDpBwKIMm236E3nD6UVUdash6yDq6gHXRquC1z3spR78+5X6VCZeAAAA6TCB5gYJKoZIhvcNAQcGoIHYMIHVAgEAMIHPBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDCTF5jxy7hiGxTYHzQIBEICBobiE2mJ0lcsYq0CjD1M9n365cGscjHZu2XIboHeujsRzYL/ZLO35GRN/ndpe/Csj9DqWerFaLqfEDM+zqEBNB/HJwrKT5uFfBDyZjmDrAbk6cRtJiHcB3R9UWVbrTKGMipaogmvwI63lU8u3j4eGJiNj2Iox3nNvidFe7e0tAjhGG2CW4trjQFwB4N9Cwh53GNPFY1hQg3nb2RKpRTjfs6F8"
$
```

7. Now, run one more `terraform apply` to get rid of the one-off initialization task and deploy your complete Vault cluster.
```sh
$ terraform apply
aws_kms_key.vault: Refreshing state... (ID: 9ed01a78-c4dd-4b04-ba0c-a31b86afb39e)
aws_iam_role.ecsServiceRole: Refreshing state... (ID: terraform-20180923200815340300000002)
...
Plan: 3 to add, 0 to change, 4 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
...
Apply complete! Resources: 3 added, 0 changed, 4 destroyed.

Outputs:

consul_url = http://consul20180923153406741500000005-1418999670.us-east-1.elb.amazonaws.com
kms_key_alias = arn:aws:kms:us-east-1:332913666507:alias/vault-20180923190839497600000001
vault_url = http://vault-20180923200817732700000005-403418657.us-east-1.elb.amazonaws.com
```

8. At this point you'll have a working Vault deployment, but you won't be able to do anything with it, because Vault access policies deny all by default.  Configuring your new Vault deployment is outside the scope of this lab; use the root token you saved earlier to perform the initial configuration, then revoke it once you've set up another way to get in.

You can confirm vault is up and running with by running :

*  `VAULT_TOKEN=<root token here> VAULT_ADDR="vault addr" vault status`
*  `VAULT_TOKEN=<root token here> VAULT_ADDR="vault addr" vault write secret/foo value=bar`
*  `VAULT_TOKEN=<root token here> VAULT_ADDR="vault addr vault read secret/foo`
