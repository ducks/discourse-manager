{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    ruby_3_4
    nodejs_20
    git
  ];

  shellHook = ''
    echo "discourse-manager dev shell"
    echo "Use 'dv' to manage Discourse containers."
  '';
}
