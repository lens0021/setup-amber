# setup-amber

[![Linter](https://github.com/lens0021/setup-amber/actions/workflows/linter.yaml/badge.svg)](https://github.com/lens0021/setup-amber/actions/workflows/linter.yaml)
[![Test](https://github.com/lens0021/setup-amber/actions/workflows/test.yaml/badge.svg)](https://github.com/lens0021/setup-amber/actions/workflows/test.yaml)

GitHub Actions for setting up [Amber] compiler.

This action downloads and installs the Amber compiler binary, making it available for subsequent steps in your workflow.

> [!NOTE]
> This is a [composite action] because I want less maintaining costs.
> There is a limitation of composite action itself:
>
> - Name of steps are not displayed. ([GitHub discussion](https://github.com/orgs/community/discussions/10985))

## Usage

See [action.yaml](action.yaml)

<!-- start usage -->

### Basic Parameters

```yaml
- uses: lens0021/setup-amber@v1
  with:
    # The Amber version to install.
    # Examples: 0.4.0-alpha, 0.5.0-alpha
    # Default: 0.5.1-alpha
    amber-version: ""

    # Whether to cache Amber binaries
    # Default: true
    enable-cache: ""

    # The path to store Amber binaries.
    # If empty string is given, the used path depends on the runner.
    # Default (Linux): '/home/runner/.setup-amber'
    # Default (Mac): '/Users/runner/.setup-amber'
    cache-path: ""

    # The path where the Amber binary should be installed.
    # Default: /usr/local/bin/amber
    bin-path: ""
```

### Building from Source (Optional)

When building Amber from source instead of using pre-built binaries:

```yaml
- uses: lens0021/setup-amber@v1
  with:
    # Git repository URL to clone Amber from when building from source.
    # Default: https://github.com/amber-lang/amber.git
    amber-repository-url: ""

    # Git ref (commit SHA, branch, or tag) to build Amber from source.
    # If provided, this overrides 'amber-version' and builds from source.
    # Examples: main, v0.5.0-alpha, 3742194594cfdf18e034658d1f58a93b3143bbd7
    # Default: "" (uses pre-built binaries)
    amber-repository-ref: ""
```

<!-- end usage -->

### Outputs

- `amber-path`: The path where the Amber binary was installed.

### Example workflow

**Basic usage:**

```yaml
name: Build with Amber

on: push

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6

      - name: Setup Amber
        uses: lens0021/setup-amber@v1
        with:
          amber-version: 0.4.0-alpha

      - name: Compile Amber script
        run: amber script.ab
```

**With custom cache path:**

```yaml
- uses: lens0021/setup-amber@v1
  with:
    amber-version: 0.4.0-alpha
    cache-path: /tmp/amber-cache
```

**Using outputs:**

```yaml
- name: Setup Amber
  id: setup-amber
  uses: lens0021/setup-amber@v2
  with:
    amber-version: 0.5.1-alpha

- name: Display installed path
  run: echo "Amber installed at ${{ steps.setup-amber.outputs.amber-path }}"
```

**Building from source:**

```yaml
- uses: lens0021/setup-amber@v2
  with:
    # Build from a specific commit
    amber-repository-ref: 3742194594cfdf18e034658d1f58a93b3143bbd7
```

```yaml
- uses: lens0021/setup-amber@v2
  with:
    # Build from a branch
    amber-repository-ref: main
```

```yaml
- uses: lens0021/setup-amber@v2
  with:
    # Build from a custom repository fork
    amber-repository-url: https://github.com/myusername/amber.git
    amber-repository-ref: my-feature-branch
```

> [!NOTE]
> Building from source requires Rust and Cargo to be available in the environment.
> GitHub Actions runners include these by default, but if you're using a custom
> runner, you may need to install the Rust toolchain first.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

[amber]: https://amber-lang.com/
[composite action]: https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-composite-action
