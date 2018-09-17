# Consul and Vault on AWS ECS

This repository contains the workshop content for our talk on running Consul and Vault on AWS ECS.  We've given the talk on the following occasions:

* [DevOpsDays Boston 2018](https://www.devopsdays.org/events/2018-boston/program/tim-hartmann)

## Requirements

You will need access to the following in order to complete this workshop:

* an AWS account (sign up [here](https://aws.amazon.com/getting-started/)).  The resources required for this lab should all fit within the AWS [Free Tier](https://aws.amazon.com/free/) if you created your AWS account less than 12 months ago.
* a computer with a (more or less) [POSIX-compliant](https://en.wikipedia.org/wiki/POSIX#POSIX-oriented_operating_systems) operating system.  This workshop was developed and tested on a Mac; I'm confident it should work on just about any Linux or BSD.  I'm sorry, Windows-using colleagues; I'd be happy to accept a pull request with changes to support your platform!  [Chocolatey](https://chocolatey.org/) is perhaps a good place to start?
* a [Git](https://git-scm.com/) client.  The most straightforward way to get the command-line Git client on a Mac is to install [XCode](https://developer.apple.com/xcode/); on other systems, use the native package manager to install Git or download an installer from the [Git website](https://git-scm.com/).
* HashiCorp [Terraform](https://www.terraform.io/).  Download Terraform from the [website](https://www.terraform.io/downloads.html) or use your native package manager.
* the AWS [command-line interface](https://aws.amazon.com/cli/).  Follow the instructions in the AWS CLI [User Guide](http://docs.aws.amazon.com/cli/latest/userguide/) to install and configure; you must complete the [Install](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) and [Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) steps.
