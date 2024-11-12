{ pkgs,
findutils,
gnused,
quartoMinimal,
texliveTeTeX,
python3,
pandoc,
which
}:
pkgs.stdenv.mkDerivation {
  pname = "personal-site-quarto";
  version = "0.1.0";

  src = ./src;

  nativeBuildInputs = [
    (texliveTeTeX.withPackages (ps: [ ps.framed ]))
    (python3.withPackages (ps: with ps; [ jupyter matplotlib plotly ]))
    pandoc
    which
  ];

  buildPhase = ''
    XDG_CACHE_HOME=/tmp/deno ${quartoMinimal}/bin/quarto render

    # TODO: do this w/ quarto
    # wrap <img> tags with <a>
    # ${findutils}/bin/find ./public/ -type f -exec \
    #   ${gnused}/bin/sed -E -i 's^(<img src="([a-zA-Z0-9.\/:_]+)" alt="([a-zA-Z0-9 ]+)"\/{0,1}>)^<a href="\2">\1</a>^g' {} \;
    ## make images load lazily
    # ${findutils}/bin/find ./public/ -type f -exec sed -i 's#<img src#<img decoding="async" loading="lazy" src#g' {} \;
  '';

  installPhase = ''
    mkdir -p $out/var/www/com.andrewzah
    mv ./_site/* $out/var/www/com.andrewzah
  '';
}
