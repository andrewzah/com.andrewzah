---
title: "MonoGame: Shader Compilation on Linux"
date: "2025-07-30"
lastmod: "2025-08-04"
tags: ["dotnet", "game-dev", "linux", "nix"]
description: "This is how I set up Monogame shader compilation for Linux."
toc: true
---

Recently I started learning how to make games, and I decided to follow
MonoGame's
[phenomenal guide to making 2D games](https://docs.monogame.net/articles/tutorials/building_2d_games/index.html),
on linux, as my daily driver is a thinkpad running NixOS.

After I set up .NET 8/9 and neovim / Visual Studio Code, it was smooth sailing
until
[Chapter 24: Shaders](https://docs.monogame.net/articles/tutorials/building_2d_games/24_shaders/index.html).
Currently, building shaders with the
[MGCB (MonoGame Content Builder)](https://docs.monogame.net/articles/getting_started/tools/mgcb.html)
tool and loading them with `Content.Load<Effect>()` requires emulation via wine.

There is another way to build shaders without MGCB, so I'll list both methods
below.

## Building manually with MGFXC

You can use the
[`dotnet-mgfxc`](https://docs.monogame.net/articles/getting_started/tools/mgfxc.html)
tool to compile shaders:

```shell {title = "shell"}
$ dotnet tool install dotnet-mgfxc
$ dotnet mgfxc grayscaleEffect.fx grayscaleEffect.fxc
```

Then, you can load them directly:

```csharp {title = "C#"}
byte[] bytecode = File.ReadAllBytes("mycompiled.mgfx");
var effect = new Effect(graphicsDevice, bytecode);
```

However, we lose the benefits of using the
[ContentManager](https://docs.monogame.net/api/Microsoft.Xna.Framework.Content.ContentManager.html),
namely [caching](https://www.youtube.com/watch?v=RumjGqpw6Zk).

## Building with MGCB and Wine

> [!important]
>
> This method is a temporary workaround. The MonoGame developers have let me
> know they want to have native shader compilation on linux and mac as well.

In Chapter 2 of the tutorial, they do provide a script and commands to set up
wine for you, shown below. But I'm not on debian/ubuntu, and I'm not a fan of
piping unknown scripts directly to bash. I appreciate the effort put into that
script, though.

```shell {title = "shell"}
$ sudo apt-get update
$ sudo apt-get install -y curl p7zip-full wine64 
$ wget -qO- https://monogame.net/downloads/net8_mgfxc_wine_setup.sh | bash
```

The following is my understanding of that script and what I did to get things
working.

### Requirements

- wine64 -
  [see wine's documentation for installation methods (search by distro)](https://gitlab.winehq.org/wine/wine/-/wikis/home) -
  version 8.0+
- winetricks
- dotnet8+
- dotnet-mgfxc
- a shader: [see below](#example-shader)

To install `mgfxc`: (add `-g` for a global install)

```shell { title="shell" }
$ dotnet tool install dotnet-mgfxc
```

### Set up wine and dependencies

Set up your environment variables. I'll assume your username is `user`.

```shell { title="shell" }
$ export WINEARCH="win64";
$ export WINEPREFIX="/home/user/.winemonogame";
$ export MGFXC_WINE_PATH="$WINEPREFIX";
$ export PATH="$WINEPREFIX:$PATH";

$ export DOTNET_CLI_TELEMETRY_OPTOUT=1;
$ export DOTNET_ROOT="/path/to/your/dotnet/installation";
```

If `wine64` doesn't exist, create a wrapper around `wine` and symlink that:

```shell {title = "shell"}
$ echo -e "#\!/bin/bash\nwine \"\$@\"" \
  > "$WINEPREFIX/wine_wrapper.sh"
$ chmod +x "$WINEPREFIX/wine_wrapper.sh"
$ ln -s "$WINEPREFIX/wine_wrapper.sh" "$WINEPREFIX/wine64"
```

Initialize your wine prefix and install the required dependencies with
`winetricks`. Dotnet 8 and 9 use a GUI installer, so I'm not sure how to
automate installing it with wine in a display-less docker container yet. (If you
know how, please [contact](./about) me!)

```shell  { title="shell" }
$ wine64 wineboot
$ winetricks d3dcompiler_47 dotnet8
```

### Build the Shader with MGCB

I'm assuming you're using
[a monogame template](https://docs.monogame.net/articles/tutorials/building_2d_games/02_getting_started/index.html?tabs=linux#creating-your-first-monogame-application).
In your game's directory, make sure to restore your dotnet tools:

```shell { title="shell" }
$ cd "$your_game_directory"
$ dotnet restore .
```

Lastly,
[add your shader to the pipeline with MGCB](https://docs.monogame.net/articles/tutorials/building_2d_games/24_shaders/index.html#creating-the-shader-file),
reference it in your game, and you should be good to go.

```csharp {title = "C#"}
public override void LoadContent()
{
    Effect grayscaleEffect = Content.Load<Effect>("grayscaleEffect");
}
```

## For NixOS users

You can install dotnet/wine/winetricks through nixpkgs and follow this post as
usual:

```nix {title = "nix"}
dotnetPkg = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnet-sdk_9
    pkgs.dotnet-sdk_8
];
paths = [
    dotnetPkg
    pkgs.wineWowPackages.stable
    pkgs.winetricks
    pkgs.netcoredbg
    pkgs.dotnetPackages.Nuget
];
```

Once you build the game though, NixOS will complain about the built executable
being dynamic. There are a few workarounds, but either way, you'll likely want
to set `LD_LIBRARY_PATH`.

A quick workaround is using `pkgs.steam-run`:

```shell {title = "shell"}
$ steam-run ./bin/Debug/net9.0/MyGame
```

I settled on using [`nix-ld`](https://github.com/nix-community/nix-ld) in my
flake.

Since a flake is worth a thousand words, here is what my dev shell flake looks
like, including vscode:

```nix { title="flake.nix" }
{
  description = "monogame dev env";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg:
          builtins.elem (pkgs.lib.getName pkg) [
            "code"
            "vscode"
            "vscode-with-extensions"
            "vscode-extension-ms-dotnettools-csharp"
            "vscode-extension-ms-dotnettools-csdevkit"
          ];
      };

      customExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "monogame";
          publisher = "r88";
          version = "0.0.3";
          sha256 = "sha256-8kMwK51yy0/pPRBcvDa0vHtPccYdfo6uHTcXrt5QZl4=";
        }
        {
          name = "mgcb-editor";
          publisher = "mangrimen";
          version = "0.0.6";
          sha256 = "sha256-b4Vp2hIHMDxD5FSywYi5fCjdW5hvpAo6LV5YAqcqxC0=";
        }
      ];

      dotnetPkg = pkgs.dotnetCorePackages.combinePackages [
        pkgs.dotnet-sdk_9
        pkgs.dotnet-sdk_8
      ];
      requiredPaths = [
        dotnetPkg
        pkgs.wineWowPackages.stable
        pkgs.winetricks
        pkgs.netcoredbg
        pkgs.dotnetPackages.Nuget
        #tiled -- currently globally installed
      ];
      runtimeDeps = [
        pkgs.gtk3
        pkgs.libGL
        pkgs.freetype
        pkgs.stdenv.cc.cc.lib
        pkgs.vulkan-loader
        dotnetPkg

        pkgs.SDL2
        pkgs.openal
        pkgs.xorg.libX11
        pkgs.xorg.libXrandr
        pkgs.xorg.libXi
        pkgs.xorg.libXcursor
        pkgs.xorg.libXinerama
        pkgs.fontconfig
        pkgs.libpulseaudio
        pkgs.pipewire.dev
        pkgs.stdenv.cc.cc
      ];
    in {
      devShells.default = pkgs.mkShell rec {
        nativeBuildInputs = [pkgs.autoPatchelfHook];

        buildInputs =
          requiredPaths
          ++ [
            (pkgs.vscode-with-extensions.override (old: {
              vscodeExtensions =
                (with pkgs.vscode-extensions; [
                  bbenoist.nix
                  christian-kohler.path-intellisense
                  vscodevim.vim
                  ms-dotnettools.csharp
                  ms-dotnettools.csdevkit
                  ms-dotnettools.vscode-dotnet-runtime
                  skellock.just
                  vadimcn.vscode-lldb
                  github.github-vscode-theme
                ])
                ++ customExtensions;
            }))
          ];

        NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath runtimeDeps;
        NIX_LD = "${pkgs.stdenv.cc.libc_bin}/bin/ld.so";
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath runtimeDeps;
        DOTNET_CLI_TELEMETRY_OPTOUT = 1;
        DOTNET_ROOT = "${dotnetPkg}/share/dotnet";

        WINEARCH = "win64";
        WINEPREFIX = "/home/dragon/.winemonogame";
        MGFXC_WINE_PATH = "/home/dragon/.winemonogame";
      };
    });

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix2container.url = "github:nlewo/nix2container";
    flake-utils.url = "github:numtide/flake-utils";
  };
}
```

## Example Shader

This is taken from the MonoGame 2D tutorial.

```wgsl { title="grayscaleEffect.fx" }
#if OPENGL
    #define SV_POSITION POSITION
    #define VS_SHADERMODEL vs_3_0
    #define PS_SHADERMODEL ps_3_0
#else
    #define VS_SHADERMODEL vs_4_0_level_9_1
    #define PS_SHADERMODEL ps_4_0_level_9_1
#endif

Texture2D SpriteTexture;

// A value between 0 and 1 that controls the intensity of the grayscale effect.
// 0 = full color, 1 = full grayscale.
float Saturation = 1.0;

sampler2D SpriteTextureSampler = sampler_state
{
    Texture = <SpriteTexture>;
};

struct VertexShaderOutput
{
    float4 Position : SV_POSITION;
    float4 Color : COLOR0;
    float2 TextureCoordinates : TEXCOORD0;
};

float4 MainPS(VertexShaderOutput input) : COLOR
{
    // Sample the texture
    float4 color = tex2D(SpriteTextureSampler, input.TextureCoordinates) * input.Color;

    // Calculate the grayscale value based on human perception of colors
    float grayscale = dot(color.rgb, float3(0.3, 0.59, 0.11));

    // create a grayscale color vector (same value for R, G, and B)
    float3 grayscaleColor = float3(grayscale, grayscale, grayscale);

    // Linear interpolation between he grayscale color and the original color's
    // rgb values based on the saturation parameter.
    float3 finalColor = lerp(grayscale, color.rgb, Saturation);

    // Return the final color with the original alpha value
    return float4(finalColor, color.a);
}

technique SpriteDrawing
{
    pass P0
    {
        PixelShader = compile PS_SHADERMODEL MainPS();
    }
};
```

## References

- [MonoGame 2D Tutorial | Ch 02: Getting Started](https://docs.monogame.net/articles/tutorials/building_2d_games/02_getting_started/index.html?tabs=linux)
- [MonoGame Forums | [SOLVED] Effect compilation on Linux](https://community.monogame.net/t/solved-effect-compilation-on-linux/13416)
- [MonoGame Docs | MonoGame Effects Compiler (MGFXC)](https://docs.monogame.net/articles/getting_started/tools/mgfxc.html)
