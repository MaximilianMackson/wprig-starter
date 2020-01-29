# WP Rig Starter

A self-contained Docker environment for WordPress theme development with WP Rig.

## Configuration

1. Install Docker.

2. Clone this repo to your host.

3. Run `docker-compose up`. This will build the custom image which powers WP Rig's build process and BrowserSync server, start a container from the image, and run `npm run rig-init` in the `/themes/wprig` directory to initialize the rig. After the rig is initialized, the container will automatically run `npm run dev` to bundle the WP Rig theme for development, watch theme files for changes, and start the BrowserSync server.

4. Browse to (http://localhost:80/)[http://localhost:80/] and complete the traditional WordPress setup procedure.

5. Navigate to _Appearance_ > _Themes_ and click the _Activate_ button on the "_WP Rig_" theme.

6. Continue with (the official WP Rig configuration process)[https://github.com/wprig/wprig].

## Usage

You may access the WordPress installation by browsing to (http://localhost:80/)[http://localhost:80/].

_See my note below for the reason why the installation uses port `80`._

For ease of development (and to maintain parity with WP Rig's feature set), this project includes the BrowserSync server which ships with WP Rig. You may access WordPress through BrowserSync by browsing to (http://localhost:8080/)[http://localhost:8080/], or (http://localhost:3001/)[http://localhost:3001/] to access the BrowserSync settings interface.

## Cleaning Up

When you're done working, press _Ctrl + C_ in the running Docker Compose process to stop all containers, then run `docker-compose down --rmi local` to stop and remove all containers, images, and networks created by the Compose script.

When you're ready to begin working again, run `docker-compose up` to start up where you left off.

If you're fine with losing all data in WordPress (everything except for your WP Rig theme files), you may replace the above command with `docker-compose down --rmi local -v` to stop and remove all containers, images, networks, **and volumes** created from the compose script. It's probably best not to add this option unless you're done with a project, not planning on working on it for a while, or have a lot of patience, as you'll need to re-create any edits you've made within the WordPress admin interface.

## Notes

### Why does WordPress run on port `80`?

**TL;DR:** It's the simplest way to access WordPress both internally (on Docker's virtual network) and from the host without dropping support for BrowserSync.

While binding an alternative port such as `8080` to the WordPress container is completely possible, doing so would only expose and publish port `8080` to the _host_—other containers running on the internal, Docker-generated network would still interface with the WordPress container via Apache's default port of `80`.

This isn't an issue when running the WordPress installation alone, but with the addition of BrowserSync, not running WordPress on port `80` complicates things.

On the host, you'd access WordPress via port `8080`. This is very common. The BrowserSync server, on the other hand (which runs inside of the `wprig` container located on the same virtual Docker network as the WordPress container), would proxy web traffic from the WordPress container via port `80`. This means the WordPress installation would be accessed simultaneously at two URLs: `http://localhost:8080/` and `http://localhost:80/` (or simply `http://localhost/`).

This is fine to the container, but WordPress isn't easily able to serve pages to both URLs, so it creates a situation where you'd have to choose between accessing WordPress normally, or accessing WordPress exclusively through BrowserSync.

There are a couple of potential solutions...

-   Creating a new image based on the WordPress image and changing the default Apache port to a port number other than `80`.

-   Routing traffic from port 80 on the WordPress container to an alternative port on the `wprig` container via a script running in the `wprig` container.

...but to keep things as vanilla as possible (at least for the time being, until I learn of a better solution), this configuration works well.

### Bundling the WP Rig theme for production

As of right now, there's no streamlined method of running `npm run bundle` to bundle a production-ready theme from WP Rig.

Quitting the running `npm run dev` process and using `docker container exec` to execute `npm run bundle` inside of the `wprig` container could work, but this is an untested method for the time being.

### Updating your WP Rig version

In the future, part of the initialization process will involve cloning the latest version of WP Rig from the official WP Rig repository.

This project does not currently include this capability, so the recommended approach in the meantime is to replace `/themes/wprig` with the most up-to-date version of WP Rig from the appropriate repository before initializing the project.

After you do, add the following snippet to `/themes/wprig/config/config.json` to ensure BrowserSync is properly configured:

```json
{
	"dev": {
		"browserSync": {
			"proxyURL": "wprig-starter_wordpress_1",
			"bypassPort": 8080,
			"open": false
		}
	}
}
```

### Renaming the `/themes/wprig` directory

If you want to change the name of the `wprig` directory, make sure you also change the paths where the directory is referenced in `docker-compose.yml`.
