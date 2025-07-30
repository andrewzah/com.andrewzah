---
title: "MonoGame: Shader Compilation on Linux"
date: "2025-07-30"
tags: ["dotnet", "game-dev", "linux", "nix"]
description: "This is how I set up Monogame shader compilation for Linux."
---

> [!important]
>
> This post is a temporary workaround. The MonoGame developers have let me know
> they want to have native shader compilation on linux and mac as well.

Recently I started learning how to make games, and I decided to follow
MonoGame's
[phenomenal guide to making 2D games](https://docs.monogame.net/articles/tutorials/building_2d_games/index.html),
on linux. My daily driver is a thinkpad running NixOS.

After I set up .NET 8/9 and Visual Studio Code, it was smooth sailing until
[Chapter 24: Shaders](https://docs.monogame.net/articles/tutorials/building_2d_games/24_shaders/index.html).
This is a workaround using wine, which most linux distros should support.

> [!note]
>
> In Chapter 2 of the tutorial, they do provide a script to set up wine for you,
> shown below. But I'm not on debian/ubuntu, and I'm not a fan of piping unknown
> scripts directly to bash. I read that script to figure out what I needed to
> install.
>
> ```shell {title = "shell"}
> $ sudo apt-get update
> $ sudo apt-get install -y curl p7zip-full wine64 
> $ wget -qO- https://monogame.net/downloads/net8_mgfxc_wine_setup.sh | bash
> ```

## requirements

- wine64 -
  [see wine's documentation for installation methods (search by distro)](https://gitlab.winehq.org/wine/wine/-/wikis/home) -
  version 8.0+
- winetricks
- dotnet8+
- a shader: I'll use the example from the tutorial:

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

## Setup

Set up your environment variables. I'll assume your username is `user`.

```shell { title="shell" }
$ export WINEARCH = "win64";
$ export WINEPREFIX = "/home/user/.winemonogame";
$ export MGFXC_WINE_PATH = "/home/user/.winemonogame";

$ export DOTNET_CLI_TELEMETRY_OPTOUT = 1;
$ export DOTNET_ROOT = "/path/to/your/dotnet/installation";
```

Initialize your wine prefix and install the required dependencies with
`winetricks`.

```shell  { title="shell" }
$ wine64 wineboot
$ winetricks d3dcompiler_47 dotnet8
```

> [!note]
>
> Dotnet 8 and 9 use a GUI installer, so I'm not sure how to automate installing
> it with wine in a docker container yet.

I'm assuming you're using
[a monogame template](https://docs.monogame.net/articles/tutorials/building_2d_games/02_getting_started/index.html?tabs=linux#creating-your-first-monogame-application).
In your game's directory, make sure to restore your dotnet tools:

```shell { title="shell" }
$ dotnet restore .

Determining projects to restore...
Restoring dotnet tools (this might take a while depending on your internet speed and should only happen upon building your project for the first time, or after upgrading MonoGame, or clearing your nuget cache)
Tool 'dotnet-mgcb' (version '3.8.4') was restored. Available commands: mgcb
Tool 'dotnet-mgcb-editor-linux' (version '3.8.4') was restored. Available commands: mgcb-editor-linux
Tool 'dotnet-mgcb-editor-windows' (version '3.8.4') was restored. Available commands: mgcb-editor-windows
Tool 'dotnet-mgcb-editor-mac' (version '3.8.4') was restored. Available commands: mgcb-editor-mac
Tool 'dotnet-mgcb-editor' (version '3.8.4') was restored. Available commands: mgcb-editor
```

Then, install `mgfxc`:

```shell { title="shell" }
$ dotnet tool install dotnet-mgfxc
```

Add your shader to the pipeline with MGCB, and you should be good to go.

## for NixOS users

Nix will complain about the built executable being dynamic. There are a few
workarounds, but either way, you'll want to set `LD_LIBRARY_PATH`.

A really quick workaround is using `pkgs.steam-run`:

```shell {title = "shell"}
$ steam-run ./bin/Debug/net9.0/MyGame
```

I settled on using [`nix-ld`](https://github.com/nix-community/nix-ld) in my
flake.

Since a flake is worth a thousand words, here is what my dev shell flake looks
like, including vscode:

```nix{ title="flake.nix" }
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

## References

- [MonoGame 2D Tutorial | Ch 02: Getting Started](https://docs.monogame.net/articles/tutorials/building_2d_games/02_getting_started/index.html?tabs=linux)
- [MonoGame Forums | [SOLVED] Effect compilation on Linux](https://community.monogame.net/t/solved-effect-compilation-on-linux/13416)
- [MonoGame Docs | MonoGame Effects Compiler (MGFXC)](https://docs.monogame.net/articles/getting_started/tools/mgfxc.html)
