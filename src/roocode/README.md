# RooCode Integration (roocode)

Installs the `RooVeterinaryInc.roo-cline` VS Code extension and configures its default operational modes within the dev container for a seamless setup.

## How it Works

This feature performs the following actions:

1.  **Extension Installation:** Adds the `RooVeterinaryInc.roo-cline` extension to the list of extensions to be installed in the dev container's VS Code instance.
2.  **Configuration Script (`install.sh`):**
    *   Creates a default `.roomodes` configuration file at a specified path (default: `/home/node/.config/roocode/.roomodes`). This location is intentionally outside the project workspace to avoid cluttering user projects.
    *   Updates the container's VS Code `settings.json` file to point the `roo-cline` extension to this centrally located `.roomodes` configuration file using the `roocode.modesConfigPath` setting.

## Example Usage

Include the feature in your `devcontainer.json`:

```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/your-repo/roocode-devcontainer-feature/roocode:1": {}
  }
}
```

*(Note: Replace `ghcr.io/your-repo/roocode-devcontainer-feature/roocode:1` with the actual registry path once published.)*

## Options

| Option            | Type   | Default                             | Description                                                                                                                               |
| ----------------- | ------ | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `modesConfigPath` | string | `/home/node/.config/roocode/.roomodes` | Specifies the path within the container where the default `.roomodes` configuration file will be created and referenced by VS Code settings. |