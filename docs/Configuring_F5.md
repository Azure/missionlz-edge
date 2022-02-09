# Introduction

The F5 BIG-IP VE and associated resources are deployed via the Bicep/ARM template. Once deployed the F5 needs to be configured to become functional and affect the intended flows. The F5 must be configured via the Windows 2019 management VM.

The sections below will outline the 2 different ways to configure the F5.

## Partial Manual Configuration

The partial configuration method requires the administrator to manually apply the necessary traffic flow configurations manually via the F5 portal and then apply the STIG settings via a script. Use this method when you want to deviate from the default values provided in the Bicep and script files. Follow the steps outline the [Manual Configuration README](./F5_manual_cfg.md).

## Scripted Configuration

The scripted configuration method enables the administrator to apply the necessary traffic flow configurations and the STIG settings via a single script. Use this method when the default values provided in the Bicep and script files are sufficient. Follow the steps outline the [Scripted Configuration README](./F5_scripted_config.md).
