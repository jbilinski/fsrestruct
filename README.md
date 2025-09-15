# expfsstruct.sh

## Description

A bash script to export the structure of a Linux filesystem, including directories, (empty)files, ownerships, permissions, and symbolic links, into a script that can recreate the same structure elsewhere.

## Usage

```shell
bash expfsstruct.sh <source_directory> [--with-files]
```

## Purpose

This script is used to parse an existing linux filesystem and build restructuring commands. It generates a script that can recreate the directory structure, file ownerships, permissions, and symbolic links in a new location. It is useful for automating the setup of docker compose environments.

## Requirements
- Bash shell
- Standard Unix utilities (e.g., mkdir, mv, cp, rm)

