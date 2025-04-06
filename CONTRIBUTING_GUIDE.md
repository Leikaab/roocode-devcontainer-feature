# Contributing Guide

Thank you for your interest in contributing to the RooCode Dev Container Feature!

## Development Workflow

1.  **Branch:** Create a new branch from `main` for your feature or bug fix (e.g., `git checkout -b feature/my-new-feature`).
2.  **Develop:** Make your changes to the feature source code (`src/roocode/`), tests (`test/roocode/`), or documentation.
    *   If adding new functionality or options, update `src/roocode/devcontainer-feature.json` accordingly.
    *   Ensure you add or update tests in `test/roocode/test.sh` to cover your changes.
3.  **Commit:** Commit your changes with clear messages.
4.  **Push:** Push your branch to the repository (`git push origin feature/my-new-feature`).
5.  **Pull Request:** Create a Pull Request (PR) targeting the `main` branch.

## Continuous Integration (CI)

When you create a Pull Request or push changes to `main`, the `.github/workflows/test.yaml` workflow automatically runs. This workflow performs the following checks:

1.  **Testing:** Runs various tests using `devcontainer features test`:
    *   Auto-generated tests based on different base images.
    *   Scenario-based tests defined in `test/roocode/scenarios.json`.
    *   Global tests defined in `test/_global/scenarios.json`.
2.  **Validation:** If all tests pass, it validates the `devcontainer-feature.json` file and associated scripts using `devcontainer features validate`.

All checks must pass for a PR to be considered mergeable. If any checks fail, please review the logs in the "Actions" tab of the PR, fix the issues in your branch, and push the changes. The checks will re-run automatically.

## Versioning

The version of the feature is defined in `src/roocode/devcontainer-feature.json` using semantic versioning (e.g., `1.0.0`). Increment the version number according to the changes made (MAJOR for breaking changes, MINOR for new features, PATCH for bug fixes) before creating a release.

## Release Process

Releases are performed manually by maintainers using the `.github/workflows/release.yaml` workflow.

1.  **Ensure `main` is Ready:** Verify that the `main` branch contains the code and the correct version number in `src/roocode/devcontainer-feature.json` for the intended release.
2.  **Trigger Release Workflow:**
    *   Navigate to the "Actions" tab of the repository.
    *   Select the "Release dev container features & Generate Documentation" workflow from the list.
    *   Click the "Run workflow" dropdown.
    *   Ensure the "Use workflow from" branch is set to `main`.
    *   Click the "Run workflow" button.
3.  **Process:** The workflow will:
    *   Publish the feature(s) located in the `src/` directory to the GitHub Container Registry (GHCR) based on the content in the `main` branch at the time of triggering.
    *   Generate documentation based on the feature definition.
    *   Create a new Pull Request containing the updated documentation (e.g., README updates).
4.  **Merge Documentation PR:** Review the automatically created documentation PR and merge it into `main`.