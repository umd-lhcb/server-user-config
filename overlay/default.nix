final: prev:
{
  # put new packages/package overrides here
  home-build = prev.writeScriptBin "home-build" ''
    nix build ".#homeConfiguration.physicist.activationPackage"
  '';
  home-switch = prev.writeScriptBin "home-switch" ''
    ${final.home-build}/bin/home-build && ./result/activate
  '';

  colortest = prev.writeScriptBin "colortest" ''
    ${prev.gawk}/bin/awk -v term_cols="''${width:-''$(tput cols || echo 80)}" 'BEGIN{
        s="/\\";
        for (colnum = 0; colnum<term_cols; colnum++) {
            r = 255-(colnum*255/term_cols);
            g = (colnum*510/term_cols);
            b = (colnum*255/term_cols);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum%2+1,1);
        }
        printf "\n";
    }'
  '';
}
