# Docker Hetzner DDNS

This small Alpine Linux based Docker image will allow you to use the free [Hetzner DNS Console](https://www.hetzner.com/dns-console) as a Dynamic DNS Provider ([DDNS](https://en.wikipedia.org/wiki/Dynamic_DNS)).

This is a multi-arch image and will run on amd64, aarch64, and armhf devices, including the Raspberry Pi.

## Image Variants

| Architecture  | OS            |
| :-------------| :------------ |
| x64           | Alpine Linux  |
| arm32v6       | Alpine Linux  |
| arm64         | Alpine Linux  |

## Usage

Quick Setup:

```shell
docker run \
  -e API_KEY=xxxxxxx \
  -e ZONE=example.com \
  -e SUBDOMAIN=subdomain \
  ghcr.io/ptpu/docker-hetzner-ddns
```

## Parameters

* `--restart=always` - ensure the container restarts automatically after host reboot.
* `-e API_KEY` - Your Hetzner API token. See the [Creating a Hetzner DNS Console API token](#creating-a-hetzner-dns-console-api-token) below. **Required**
  * `API_KEY_FILE` - Path to load your Hetzner DNS Console API token from (e.g. a Docker secret). *If both `API_KEY_FILE` and `API_KEY` are specified, `API_KEY_FILE` takes precedence.*
* `-e ZONE` - The DNS zone that DDNS updates should be applied to. **Required**
  * `ZONE_FILE` - Path to load your Hetzner DNS Console Zone from (e.g. a Docker secret). *If both `ZONE_FILE` and `ZONE` are specified, `ZONE_FILE` takes precedence.*
* `-e SUBDOMAIN` - A subdomain of the `ZONE` to write DNS changes to. If this is not supplied the root zone will be used.
  * `SUBDOMAIN_FILE` - Path to load your Hetzner DNS Console Subdomain from (e.g. a Docker secret). *If both `SUBDOMAIN_FILE` and `SUBDOMAIN` are specified, `SUBDOMAIN_FILE` takes precedence.*

## Optional Parameters

* `-e TTL=86400` - Set to any Integer (in seconds) to change the Time-To-Live for the created record. Defaults to `86400`.
* `-e RRTYPE=A` - Set to `AAAA` to use set IPv6 records instead of IPv4 records. Defaults to `A` for IPv4 records.
* `-e DELETE_ON_STOP` - Set to `true` to have the dns record deleted when the container is stopped. Defaults to `false`.
* `-e INTERFACE=tun0` - Set to `tun0` to have the IP pulled from a network interface named `tun0`. If this is not supplied the public IP will be used instead. Requires `--network host` run argument.
* `-e CUSTOM_LOOKUP_CMD="echo '1.1.1.1'"` - Set to any shell command to run them and have the IP pulled from the standard output. Leave unset to use default IP address detection methods.
* `-e DNS_SERVER=10.0.0.2` - Set to the IP address of the DNS server you would like to use. Defaults to 1.1.1.1 otherwise. 
* `-e CRON="@daily"` - Set your own custom CRON value before the exec portion. Defaults to every 5 minutes - `*/5 * * * *`.

## Creating a Hetzner DNS Console API token

To create a Hetzner DNS Console API token for your DNS zone go to https://dns.hetzner.com/settings/api-token and follow these steps:

1. Click Create access token
2. Provide the token a name, for example, `hetzner-ddns`
3. Complete the wizard and copy the generated token into the `API_KEY` variable for the container

## Multiple Domains

If you need multiple records pointing to your public IP address you can create CNAME records in Hetzner DNS Console.

## IPv6

If you're wanting to set IPv6 records set the environment variable `RRTYPE=AAAA`. You will also need to run docker with IPv6 support, or run the container with host networking enabled.

## Docker Compose

If you prefer to use [Docker Compose](https://docs.docker.com/compose/):

```yml
version: '3'
services:
  hetzner-ddns:
    image: ghcr.io/ptpu/docker-hetzner-ddns
    restart: always
    environment:
      - API_KEY=xxxxxxx
      - ZONE=example.com
      - SUBDOMAIN=subdomain
```

## License

```
Copyright (C) 2017-2020 oznu
Copyright (C) 2022-2024 ptpu

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
```
