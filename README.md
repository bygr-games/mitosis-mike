# Mitosis Mike

Mitosis Mike is a game jam project built with Haxe, Heaps, and HashLink.

## Installation

### Required tools

Install these first:

1. Haxe (includes `haxelib`)
2. HashLink (`hl` runtime)

### Required Haxelib dependencies

Core libraries used by this project:

- `castle`
- `heaps`
- `hscript`
- `deepnightLibs`
- `ldtk-haxe-api`
- `heaps-aseprite`
- `ase`
- `redistHelper`

Target-specific libraries:

- OpenGL/HashLink build (`build.opengl.hxml`): `hlsdl`
- DirectX/HashLink build (`build.directx.hxml`): `hldx`

### Haxelib install commands (exact)

Run these from the repository root.

Core (git-based):

```bash
haxelib --always git castle https://github.com/deepnight/castle.git
haxelib --always git heaps https://github.com/deepnight/heaps.git
haxelib --always git hscript https://github.com/HaxeFoundation/hscript.git
haxelib --always git deepnightLibs https://github.com/deepnight/deepnightLibs.git
haxelib --always git ldtk-haxe-api https://github.com/deepnight/ldtk-haxe-api.git
haxelib --always git heaps-aseprite https://github.com/deepnight/heaps-aseprite.git
```

Core (registry install):

```bash
haxelib --always install ase
haxelib --always install redistHelper
```

Target-specific (git-based):

```bash
haxelib --always git hlsdl https://github.com/HaxeFoundation/hashlink.git master libs/sdl
haxelib --always git hldx https://github.com/HaxeFoundation/hashlink.git master libs/directx
```

From the repository root, install everything with:

```bash
haxe setup.hxml
```

This command installs all dependencies above, including git-based haxelibs.

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
