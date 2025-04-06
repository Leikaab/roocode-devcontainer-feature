# RooCode Integration (roocode) Devcontainer Feature

This feature integrates the RooCode AI coding assistant (`RooVeterinaryInc.roo-cline` VS Code extension) into your development container. It installs the extension and sets up a default configuration for its operational modes, providing a ready-to-use AI coding environment.

## How it Works

This feature automates the setup process through two main steps:

1.  **Extension Installation (`devcontainer-feature.json`):** The `RooVeterinaryInc.roo-cline` VS Code extension is automatically added to the list of extensions installed within the dev container's VS Code instance when the container is built or reopened.
2.  **Configuration Script (`install.sh`):** During the container build process, this script executes the following:
    *   **Creates Default Modes Configuration:** It generates a default `.roomodes` configuration file at the path specified by the `modesConfigPath` option (defaulting to `/home/node/.config/roocode/.roomodes`). This location is typically outside the project workspace to keep project directories clean. This file includes pre-defined modes such as:
        *   Boomerang Mode (Workflow Orchestrator)
        *   Senior Code Generator
        *   Junior Code Generator
        *   Free Ratelimited Junior Code Generator
        *   Infrastructure Code Generator
        *   Code Reviewer
        *   Code Optimizer
        *   Test Writer
        *   Pseudocode Architect
        *   Specification Writer
        *   Documentation Writer
        *   Debugger
    *   **Updates VS Code Settings:** It modifies the container's VS Code `settings.json` file, setting the `roocode.modesConfigPath` property to point the RooCode extension to the generated `.roomodes` file. This ensures the extension loads the default modes correctly.

## Example Usage

To include this feature in your project, add it to your `devcontainer.json` file:

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/RooVeterinaryInc/roocode-devcontainer-feature/roocode:latest": {}
  }
}
```

**Important:** Replace `ghcr.io/RooVeterinaryInc/roocode-devcontainer-feature/roocode:latest` with the correct OCI registry path where this feature is published. Using `latest` is shown for simplicity; pinning to a specific version (e.g., `:1`) is recommended for stable builds.

## Options

| Option            | Type   | Default                             | Description                                                                                                                               |
| ----------------- | ------ | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `modesConfigPath` | string | `/home/node/.config/roocode/.roomodes` | Specifies the absolute path within the container where the default `.roomodes` configuration file will be created and referenced by VS Code settings. |

## Testing

This feature includes automated tests executed using the standard `devcontainer features test` command. You can find the test scripts and scenarios within the `test/roocode` directory.