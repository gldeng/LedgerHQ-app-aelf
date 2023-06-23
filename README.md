[![Code style check](https://github.com/blooo-io/LedgerHQ-app-aelf/actions/workflows/lint-workflow.yml/badge.svg)](https://github.com/blooo-io/LedgerHQ-app-aelf/actions/workflows/lint-workflow.yml)
[![Compilation & tests](https://github.com/blooo-io/LedgerHQ-app-aelf/actions/workflows/ci-workflow.yml/badge.svg)](https://github.com/blooo-io/LedgerHQ-app-aelf/actions/workflows/ci-workflow.yml)
[![Sonarcloud](https://github.com/blooo-io/LedgerHQ-app-aelf/actions/workflows/sonarcloud.yml/badge.svg)](https://github.com/blooo-io/LedgerHQ-app-aelf/actions/workflows/sonarcloud.yml)

# Aelf app for Ledger Wallet

## Overview

This app adds support for the Aelf native token to Ledger Nano S/SP/X hardware wallet.

## Prerequisites
* [Install Docker](https://docs.docker.com/get-docker/)
* [Install VS Code](https://code.visualstudio.com/download)
* For Linux hosts, install the Ledger Nano [udev rules](https://github.com/LedgerHQ/udev-rules)
## Working with the device with VSCode

You can quickly setup a convenient environment to build and test your application by using the vscode integration and the [ledger-app-dev-tools](https://github.com/LedgerHQ/ledger-app-builder/pkgs/container/ledger-app-builder%2Fledger-app-dev-tools) docker image.

It will allow you, whether you are developing on macOS, Windows or Linux to quickly **build** your apps, **test** them on **Speculos** and **load** them on any supported device.

* Run Docker.
* Make sure you have an X11 server running :
    * On Ubuntu Linux, it should be running by default.
    * On macOS, install and launch [XQuartz](https://www.xquartz.org/) (make sure to go to XQuartz > Preferences > Security and check "Allow client connections").
    * On Windows, install and launch [VcXsrv](https://sourceforge.net/projects/vcxsrv/) (make sure to configure it to disable access control).
* Open a terminal and clone `LedgerHQ-app-aelf` with `git clone https://github.com/blooo-io/LedgerHQ-app-aelf.git`.
* Open the `LedgerHQ-app-aelf` folder with VSCode.
* Open the vscode tasks with  `ctrl + shift + b` (`command + shift + b` on a Mac) and run the following actions :
    * Pull and run the [ledger-app-dev-tools](https://github.com/LedgerHQ/ledger-app-builder/pkgs/container/ledger-app-builder%2Fledger-app-dev-tools) docker image by selecting `Run dev-tools image`.
    * Build the for the device model of your choice with `Build app`.
    * Load your binary on a Ledger device with `Load app on device`.

You can find all the available tasks definitions in `.vscode/tasks.json`.
# Test
## Unit
Run C tests:
```bash
make -C lib
```
## Python
### First install the deps
* Open the vscode tasks with  `ctrl + shift + b` (`command + shift + b` on a Mac) and run the following actions :
    * First install the requirements with `Install tests requirements`.
    * Run the tests with `Run functional tests`.
