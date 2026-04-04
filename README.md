# Mitosis Mike

Mitosis Mike is a game jam project built with Haxe, Heaps, and HashLink.

## Installation

1. Install Haxe and HashLink.
2. From the repository root, install project dependencies:

```bash
haxe setup.hxml
```

## Startup

Build and run from the repository root.

HashLink build:

```bash
haxe build.opengl.hxml
hl bin/client.hl
```

Alternative builds:

- DirectX: `haxe build.directx.hxml`
- JavaScript/WebGL: `haxe build.js.hxml`

To run the JavaScript build, open `run_js.html` after compiling.

## Debugging

For a debug-enabled build from the command line:

```bash
haxe build.dev.hxml
hl bin/client.hl
```

In VS Code, the workspace already includes launch configurations:

- `HL debug` launches the HashLink target.
- `Chrome JS debug` launches `run_js.html` in Chrome.

Both launch configs use the `HaxeActiveConf` pre-launch task.

## Docs

- [Docs overview](docs/README.md)
- [Story](docs/story.md)
- [Mechanics](docs/mechanics.md)
- [Level flow](docs/level-flow.md)
