# SocioBoard with Docker Compose

#### Table of Contents

1. [Description](#description)
2. [Setup](#setup)
3. [Usage](#usage)
4. [Reference](#reference)
5. [Development](#development)
6. [Contributors](#contributors)

## Description

Docker-compose setup for starting [SocioBoard](https://www.socioboard.com/).

## Setup

```sh
cd /opt
git clone https://github.com/solution-libre/docker-socioboard.git socioboard
cd socioboard
```

Declare environment variables or copy the `.env.dist` to `.env`, the `.env.maria.dist` to `.env.maria` and the `.env.mongo.dist` to `.env.mongo` and adjust its values.

Register a domain like 'socioboard.domain.tld' and theese subdomains 'api-00.socioboard.domain.tld', 'api-01.socioboard.domain.tld', 'api-02.socioboard.domain.tld', 'api-03.socioboard.domain.tld'.

## Usage

```sh
cd /opt/socioboard
docker-compose up -d
```

## Reference

### Environment variables

#### `HOSTNAME`

The SocioBoard hostname. Default value: 'socioboard.domain.tld'

## Development

[Solution Libre](https://www.solution-libre.fr)'s repositories are open projects, and community contributions are essential for keeping them great.


[Fork this repo on GitHub](https://github.com/solution-libre/docker-socioboard/fork)

## Contributors

The list of contributors can be found at: https://github.com/solution-libre/docker-socioboard/graphs/contributors
