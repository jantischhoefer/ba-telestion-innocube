# ##REPO_NAME##

[![Running Telestion](https://img.shields.io/static/v1?label=Running&message=Telestion&labelColor=2B2E3A&color=452897)](https://telestion.wuespace.de/)
[![CI Application](https://github.com/##REPO_USER##/##REPO_NAME##/actions/workflows/ci-app.yml/badge.svg)](https://github.com/##REPO_USER##/##REPO_NAME##/actions/workflows/ci-app.yml)

This is a Telestion Project based on the [Telestion Project Template](https://github.com/wuespace/telestion-project-template).

## Installation

### The Application

To run the application on your production system, you need [docker](https://www.docker.com/) and [docker-compose](https://docs.docker.com/compose/install/) installed and ready-to-go.

Go to the [latest release](https://github.com/##REPO_USER##/##REPO_NAME##/releases/latest) of the project and download the application archive named `##REPO_NAME##-vX.X.X.zip`.

Extract it on your production system and go into the folder which contains the `docker-compose.yml`.

Start the application with the following command:

```shell
docker-compose up -d
```

This downloads and starts the required components to run Telestion.

If you want to stop Telestion, call:

```shell
docker-compose down
```

### The Client

Client builds are also available via the [latest release](https://github.com/##REPO_USER##/##REPO_NAME##/releases/latest) of the project.

OS coverage depends on the used Client system.

## Building

To build the projects from source, please take a look into the part specific descriptions:

- [Application](./application/README.md)
- [Client](./client/README.md)

## Releasing

When you use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) during development, automation tools can release a new version based on [Semantic Versioning] and automatically create changelogs based on the commit messages.

For more information, take a look at the release tutorial on our developer documentation.

### Via GitHub

The `release` action creates and updates a pull request that tracks the changes to the next release. Once you're happy with your result, merge this branch. This triggers the release pipeline which creates a new release archive and publishes the code to the GitHub Container Registry.

### Manually

If you're not hosting your code on GitHub, we provide some convenience scripts to release a new version.

First, bump your project version.

Update the project version in the version.txt file which resides in the project root.

Next, open the console and commit the version bump:

```shell
git add version.txt
git commit -m "chore(main): release $(<version.txt)"
git tag -a "v$(<version.txt)" -m "release $(<version.txt)"
git push --follow-tags
```

> Attention: The deployment scripts and tools require that you use the Semantic Versioning release style in your project.

Now, build the Application.

Open your IDE and select the assembleDist task in the distribution section of Gradle.
Or run the Gradle task in your console:

```shell
cd application
JAVA_HOME="<path-to-jdk16>" ./gradlew assembleDist
cd ..
```cd application
JAVA_HOME="<path-to-jdk16>" ./gradlew assembleDist
cd ..

To build, tag and publish the docker containers, call the following script:

```shell
./scripts/push-docker-images.sh
```

To create a setup archive, call the following script:

```shell
./scripts/create-setup.sh
```

Both scripts depend on the version number in the `version.txt` file.

## This repository

The overall file structure of this monorepo looks like this:

```plain
.
├── .github
│   ├── workflows (CI configuration)
│   └── dependabot.yml (Dependabot config)
├── application
|   ├── conf (the verticle configuration for the Application)
|   ├── src (the source files of the Telestion Application)
|   ├── Dockerfile (the definition to successfully build a Docker image from the compiled Application sources)
|   ├── build.gradle (manages dependencies and the build process via Gradle)
|   ├── gradle.properties (contains the required tokens to access required dependencies)
|   ├── gradlew (the current gradle executable for UNIX-based systems)
|   └── gradlew.bat (the current gradle executable for Windows systems)
├── client
|   ├── public (template webpage folder where React will engage)
|   ├── src (the source files of the Telestion Client)
|   └── package.json (manages dependencies and the build process via npm)
├── CHANGELOG.md (DON'T TOUCH! Automatically generated Changelog)
├── README.md (you're here :P)
├── project.json (contains the current project information like the current version etc.)
└── telestion-application (DON'T TOUCH! Used as an indicator for our automation tools)
```

**The [Application](./application/README.md) and the [Client](./client/README.md) folders contain their own `README.md` that describe the different parts more specific.**

### Contributing

For the documentation on contributing to this repository, please take look at the [Contributing Guidelines](./CONTRIBUTING.md) and the official [Telestion Developer Documentation](https://docs.telestion.wuespace.de/).

## About

Running [Telestion](https://telestion.wuespace.de/), a project by [WüSpace e.V.](https://www.wuespace.de/).
