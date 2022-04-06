# Telestion Project Template

This is a template for Telestion projects.
It provides the boilerplate code so can instantly start to develop your groundstation.

## Setup

For a more in-depth guide on how to start a new project, take a look on our [developer documentation](https://docs.telestion.wuespace.de/application/tutorials/starting-a-new-project/).

### Via GitHub

First, press the `Use this template` button.

![github-use-this-template](https://user-images.githubusercontent.com/52416718/155911275-4b230feb-4fde-4ba3-a302-d552f0e7b9b3.png)

Now, GitHub asks you some required information. Select a suitable user/group and give the repository a meaningful name.

Next, select your repository's visibility. When you're happy with your information, press the Create repository from template button.

![github-create-repo](https://user-images.githubusercontent.com/52416718/155911289-92e4cebe-65db-48b5-be31-0b09a098265d.png)

Now, go to the _Actions_ Tab in the GitHub UI and choose the `Initialize` Action.
Then click `Run workflow` and enter your preferences like so:

![Screenshot_20210427_091359](https://user-images.githubusercontent.com/52416718/116217289-01329a00-a739-11eb-811a-08bee30de8b7.png)

> It is recommended to follow [Maven Central `groupId` naming conventions](https://maven.apache.org/guides/mini/guide-naming-conventions.html),
> e.g. beginning with the company url in reverse.

Let GitHub Actions initialize your project.

### Manually

1. Create a new and empty git repository:

   ```shell
   mkdir my-telestion-project
   cd my-telestion-project
   git init
   ```

2. Fetch the changes from this template:

   ```shell
   git fetch --depth=1 -n "https://github.com/wuespace/telestion-project-template.git"
   ```

3. Create an orphaned commit to start from there:

   ```shell
   git reset --hard "$(git commit-tree FETCH_HEAD^{tree} -m "feat: Initial commit")"
   ```

4. Run the initialize script:

   ```shell
   ./scripts/initialize.sh
   ```

5. Commit your changes as suggested by the script:

   ```shell
   git add .
   git commit -m "feat: Initialize project"
   ```

6. (Optional) Add a remote repository where you can push your project:

   ```shell
   git remote add origin "git@gitlab.com:your-name/my-telestion-project.git"
   git branch -M main
   git push -u origin main
   ```

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

For the documentation on contributing to this repository, please take a look at the [Contributing Guidelines](./CONTRIBUTING.md).

## Contributors

Thank you to all contributors of this repository:

[![Contributors](https://contrib.rocks/image?repo=wuespace/telestion-project-daedalus2)](https://github.com/wuespace/telestion-project-daedalus2/graphs/contributors)

Made with [contributors-img](https://contrib.rocks).

## About

Belongs to [Telestion](https://telestion.wuespace.de/), a project by [WüSpace e.V.](https://www.wuespace.de/).
