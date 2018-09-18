# Consul and Vault on AWS ECS

This repository contains the workshop content for our talk on running Consul and Vault on AWS ECS.  We've given the talk on the following occasions:

* [DevOpsDays Boston 2018](https://www.devopsdays.org/events/2018-boston/program/tim-hartmann)

## Requirements

You will need access to the following in order to complete this workshop:

* an AWS account (sign up [here](https://aws.amazon.com/getting-started/)).  The resources required for this lab should all fit within the AWS [Free Tier](https://aws.amazon.com/free/) if you created your AWS account less than 12 months ago.
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
- module.infra
  Getting source "github.com/terraform-community-modules/tf_aws_ecs?ref=v5.2.0"
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


