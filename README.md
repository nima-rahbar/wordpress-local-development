<div align="center">
  <h1>🚀 WordPress Local Development Environment 🚀</h1>
  <p>
    A flexible and powerful local development environment for managing multiple WordPress sites using Docker, Nginx Proxy Manager, and Adminer.
  </p>
  <p>
    <a href="https://github.com/nima-rahbar/wordpress-local-development/stargazers"><img src="https://img.shields.io/github/stars/nima-rahbar/wordpress-local-development?style=for-the-badge" alt="Stars Badge"/></a>
    <a href="https://github.com/nima-rahbar/wordpress-local-development/network/members"><img src="https://img.shields.io/github/forks/nima-rahbar/wordpress-local-development?style=for-the-badge" alt="Forks Badge"/></a>
    <a href="https://github.com/nima-rahbar/wordpress-local-development/issues"><img src="https://img.shields.io/github/issues/nima-rahbar/wordpress-local-development?style=for-the-badge" alt="Issues Badge"/></a>
    <a href="https://github.com/nima-rahbar/wordpress-local-development/blob/main/LICENSE"><img src="https://img.shields.io/github/license/nima-rahbar/wordpress-local-development?style=for-the-badge" alt="License Badge"/></a>
  </p>
</div>

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [First-Time Setup](#1-first-time-setup-nginx-proxy-manager--global-adminer)
- [Creating a New Site](#2-creating-a-new-site)
- [Starting the Site](#3-starting-the-site)
- [Configuring Nginx Proxy Manager](#4-configuring-nginx-proxy-manager)
- [Running WP-CLI Commands](#5-running-wp-cli-commands)
- [Managing Sites](#6-managing-sites)
- [Managing Memcached](#7-managing-memcached)

---

## How to Use This Environment

This document will guide you through the process of adding and managing new WordPress sites in this environment.

## Prerequisites

Before you begin, make sure you have the following software installed on your machine:

- Docker
- Docker Compose
- WordPress core folder (inside `wp-template` folder)

## 1. First-Time Setup: Nginx Proxy Manager & Global Adminer

If you are setting up this environment for the first time, you need to start the Nginx Proxy Manager and the Global Adminer.

1.  **Create the required Docker networks**:

    ```bash
    docker network create proxy-network
    docker network create data-network
    ```

2.  **Start the Nginx Proxy Manager**:

    ```bash
    cd nginx-proxy-manager
    docker-compose up -d
    ```

3.  **Access the Nginx Proxy Manager UI**:

    Open your web browser and navigate to `http://localhost:81`.

    The default credentials are:

    - **Email**: `admin@example.com`
    - **Password**: `changeme`

    You will be prompted to change these credentials after your first login.

4.  **Start the Global Adminer**:

    ```bash
    cd adminer
    docker-compose up -d
    ```

5.  **Access the Global Adminer UI**:

    Open your web browser and navigate to `http://localhost:8080`.

    To connect to a site's database, you need to provide the correct credentials in the Adminer login form.

    ### Login Details

    - **System**: `MySQL` (or `MariaDB`)
    - **Server**: The unique container name of the database. For a site named `my-awesome-site`, this would be `db_my-awesome-site`.
    - **Username**: The database username you chose during site creation (e.g., `wordpress`).
    - **Password**: The database password you chose during site creation.
    - **Database**: The name of the database you want to manage (e.g., `wordpress`).

    Here is an example for a site named `my-awesome-site`:

    ```
    +-------------------------------------------------+
    | System      | MySQL                           |
    | Server      | db_my-awesome-site              |
    | Username    | wordpress                       |
    | Password    | •••••••••                       |
    | Database    | wordpress                       |
    +-------------------------------------------------+
    | [ Login ]                                       |
    +-------------------------------------------------+
    ```

## 2. Creating a New Site

To create a new WordPress site, use the `create-site.sh` script. This script will guide you through the process, including setting up the host entry automatically.

```bash
./create-site.sh
```

The script will prompt you for:

- Site Name
- Domain TLD (default: `local`)
- Database Prefix (default: `wp_`)
- Plugins (space-separated list, e.g., `woocommerce elementor`)
- Memcached (y/n, default: `n`)
- PHP Memory Limit (default: `256M`)
- PHP Max Upload Filesize (default: `64M`)
- WordPress Debug Mode (y/n, default: `n`)
- Adminer Port (default: `8080` - _Note: This is for individual site Adminer, which is no longer used. You can keep the default._)
- Database User (default: `wordpress`)
- Database Password (default: `wordpress`)
- Database Name (default: `wordpress`)

This command will create a new directory named `my-awesome-site` with a full WordPress installation in a `wordpress` subdirectory.

## 3. Starting the Site

Once the setup script has generated the configuration files, you can start your site using `docker-compose`.

### Standard Start

For a standard site without any optional services (like Memcached), run the following command:

```bash
cd <site-name>
docker-compose up -d
```

This will start the default WordPress and database containers.

### Starting with Memcached

If you enabled Memcached during the site creation process, the `memcached` service was added to your `docker-compose.yml` file under a special "profile". Profiles allow for optional services that don't run by default.

To start your site *and* the Memcached container, you must activate the `memcached` profile using the `--profile` flag:

```bash
cd <site-name>
docker-compose --profile memcached up -d
```

This command starts the default services plus any services matching the `memcached` profile. If you don't use this flag on a Memcached-enabled site, the site may not work correctly as the Memcached container will not be running.

## 4. Configuring Nginx Proxy Manager

The final step is to configure the Nginx Proxy Manager to route traffic to your new site.

1.  **Log in to the Nginx Proxy Manager UI** at `http://localhost:81`.

2.  **Go to `Hosts` > `Proxy Hosts`** and click `Add Proxy Host`..

3.  **Fill in the form**:

    - **Domain Names**: The full domain of your site (e.g., `my-awesome-site.local`).
    - **Scheme**: `http`
    - **Forward Hostname / IP**: The name of your WordPress container. By default, it is `wp_<site-name>` (e.g., `wp_my-awesome-site`).
    - **Forward Port**: `80`

4.  **Click `Save`**.

You should now be able to access your new WordPress site in your browser at the domain you configured (e.g., `http://my-awesome-site.local`).

## 5. Running WP-CLI Commands

To run `wp-cli` commands for your site (e.g., to install plugins, manage users, etc.), you can execute them directly inside the running WordPress container.

1.  **Find your WordPress container name**:

    ```bash
    docker ps
    ```

    Look for the container with the `NAMES` like `wp_your-site-name`.

2.  **Execute `wp-cli` commands**:
    ```bash
    docker exec -it wp_your-site-name wp <command>
    ````
    Replace `wp_your-site-name` with your actual WordPress container name and `<command>` with the `wp-cli` command you want to run or using it directly
    ```bash
    docker-compose run --rm --entrypoint wp wp-cli <command>
    ```

### Example: Install and Activate a Plugin

```bash
docker exec -it wp_my-awesome-site wp plugin install updraftplus --activate
```

## 6. Managing Sites

Once your site is created and running, you can manage its lifecycle using `docker-compose` commands.

### Restarting a Site

To restart all services for a specific site:

```bash
cd <site-name>
docker-compose restart
```

### Stopping a Site

To stop all services for a specific site without removing them:

```bash
cd <site-name>
docker-compose stop
```

### Deleting a Site (Containers Only)

To stop and remove only the containers and networks associated with a specific site (keeping the database data and site files):

```bash
cd <site-name>
docker-compose down
```

### Fully Deleting a Site (Containers, Volumes, and Files)

To completely remove a site, including its containers, Docker volumes (which store database data), and all site files:

1.  **Stop and remove containers and volumes**:

    ```bash
    cd <site-name>
    docker-compose down --volumes
    ```

2.  **Delete the site directory**:

    ```bash
    cd ..
    rm -rf <site-name>
    ```

    **Warning**: This action is irreversible and will permanently delete all your site's files and database data.

## 7. Managing Memcached

If you have a site running with Memcached, here’s how you can manage its cache.

### Flushing Cache from a Plugin

Once you have configured a caching plugin (like W3 Total Cache, LiteSpeed Cache, etc.) to use Memcached as its object cache, the plugin's own "Purge All Caches" or "Flush Cache" button in the WordPress admin dashboard will correctly flush the Memcached object cache.

### Flushing Cache from the Command Line

For a more direct approach, you can flush the entire Memcached server from the command line. The simplest and most effective way to do this in a development environment is to restart the Memcached container. Since Memcached is an in-memory cache, restarting it completely clears all cached data.

1.  Navigate to your site's directory:
    ```bash
    cd <site-name>
    ```

2.  Restart the `memcached` service:
    ```bash
    docker-compose restart memcached
    ```
This command will quickly restart the container, giving you a fresh, empty cache.
