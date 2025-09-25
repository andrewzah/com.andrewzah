{pkgs, ...}:
pkgs.marmite.overrideAttrs (finalAttrs: prevAttrs: {
  pname = "marmite";
  version = "0.2.6";

  src = pkgs.fetchFromGitHub {
    owner = "rochacbruno";
    repo = "marmite";
    tag = "${finalAttrs.version}";
    hash = "sha256-4FH9WEVTvnu0gp006tBg511bn8LE6AyHOML4tHoqXeM=";
  };
  cargoHash = "sha256-wl2/feheYOYPzVElwt3WDZuaQrmoi3OoThYF4PINWd4=";

  cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname src version;
    hash = finalAttrs.cargoHash;
  };
})
