{
  enable = true;

  extraConfig = ''
    Host *
        UseKeychain yes
        AddKeysToAgent yes
        IdentityFile ~/.ssh/id_rsa
  '';
}
