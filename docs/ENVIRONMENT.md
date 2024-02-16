# Environment Variables

This environment variables can be used to configure released docker container at start time.
Also sample `.env` can be used as payload for `docker run` cli.

## General

| VAR_NAME      | Default Value   | Description                                                                                                                                       |
|---------------|-----------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| RELEASE_COOKIE | `1s8BoxlWXKa`.. | Erlang [distribution cookie](http://erlang.org/doc/reference_manual/distributed.html). **Make sure that default value is changed in production.** |

## Phoenix HTTP Endpoint

| VAR_NAME   | Default Value    | Description                                                                                                                                |
|------------|------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| PORT       | `4000`           | HTTP port for web app to listen on.                                                                                                        |
| HOST       | `localhost`      | HTTP host for web app to listen on.                                                                                                        |
| SECRET_KEY | `KZwncHsdv592`.. | Phoenix [`:secret_key_base`](https://hexdocs.pm/phoenix/Phoenix.Endpoint.html). **Make sure that default value is changed in production.** |

## Database

| VAR_NAME     | Default Value | Description                            |
|--------------|---------------|----------------------------------------|
| DB_NAME      |               | Database name.                         |
| DB_USER      |               | Database user name.                    |
| DB_PASSWORD  |               | Database user password.                |
| DB_HOST      |               | Database host.                         |
| DB_PORT      | `5432`        | Database port.                         |
| DB_POOL_SIZE | `10`          | Number of connections to the database. |
| DB_MIGRATE   | `false`       | Flag to run migration.                 |
