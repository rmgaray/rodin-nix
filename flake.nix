{

  description = "Wrapper for Rodin 3.8";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rodin380 = {
      flake = false;
      url = "https://master.dl.sourceforge.net/project/rodin-b-sharp/Core_Rodin_Platform/3.8/rodin-3.8.0.202304051545-af2f57e1e-linux.gtk.x86_64.tar.gz?viasf=1";
    };
  };

  outputs = {
    self,
    nixpkgs,
    rodin380,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
    in {
      packages = {
        default = self.outputs.packages.${system}.rodin;

        # Mostly stolen from eclipse/default.nix in nixpkgs.
        rodin = pkgs.stdenv.mkDerivation {
          name = "rodin";
          version = "3.8.0";

          desktopItem = pkgs.makeDesktopItem {
            name = "Rodin";
            exec = "rodin";
            icon = "rodin";
            comment = "Integrated Development Environment for Event-B";
            desktopName = "Rodin 3.8.0";
            genericName = "Integrated Development Environment";
            categories = [ "Development" ];
          };

          nativeBuildInputs = [
            pkgs.makeWrapper
          ];

          buildInputs = with pkgs; [
            fontconfig
            freetype
            glib
            gsettings-desktop-schemas
            gtk3
            jdk
            xorg.libX11
            xorg.libXrender
            xorg.libXtst
            libsecret
            zlib
            webkitgtk_4_0
          ];

          buildCommand = with pkgs;
          ''
            mkdir -p $out
            cp -r ${rodin380} $out/rodin
            chmod -R u+w $out/rodin

            # Patch binaries.
            interpreter="$(cat $NIX_BINTOOLS/nix-support/dynamic-linker)"
            patchelf --set-interpreter $interpreter $out/rodin/rodin

            makeWrapper $out/rodin/rodin $out/bin/rodin \
              --prefix PATH : ${jdk23}/bin \
              --prefix LD_LIBRARY_PATH : ${
                lib.makeLibraryPath
                  [
                    glib
                    gtk3
                    xorg.libXtst
                    libsecret
                    webkitgtk_4_0
                  ]
              } \
              --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules" \
              --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
          '';
        };
      };
    });
}
