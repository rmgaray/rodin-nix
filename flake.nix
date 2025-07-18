{

  description = "FHS wrapper for Rodin";

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
      fhs = pkgs.buildFHSEnv {
        name = "rodin-env";
        targetPkgs = pkgs: (with pkgs; [
          jdk11
          glib
          gtk4
          webkitgtk_4_1
          zlib
          rodin380
          self.outputs.packages.${system}.swt-links
        ]) ++ (with pkgs.xorg; [
          libX11
          libXcursor
          libXrandr
          libXrender
          libXtst
        ]);
        multiPkgs = pkgs: (with pkgs; [
          udev
          alsa-lib
        ]);
        runScript = "${rodin380}/rodin";
        profile =
        ''
        export XDG_DATA_DIRS=$XDG_DATA_DIRS:${pkgs.gtk4}/share/gsettings-schemas/gtk4-4.18.5/glib-2.0/schemas
        '';
      };
    in {
      packages = {
        default = self.outputs.packages.${system}.rodin;

        rodin = fhs;

        # We create a symbolic links for SWT so eclipse can find it.
        swt-links = pkgs.stdenv.mkDerivation {
          name = "swt-links";
          buildCommand = ''
            mkdir -p $out/lib
            ln -s ${pkgs.swt}/lib/libswt-pi3-gtk-4967r8.so $out/lib/libswt-pi3-gtk.so
            ln -s ${pkgs.swt}/lib/libswt-gtk-4967r8.so $out/lib/libswt-pi4-gtk.so
          '';
        };
      };
    });
}
