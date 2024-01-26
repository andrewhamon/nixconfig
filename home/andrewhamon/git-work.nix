{
  condition = "gitdir:~/discord/";
  contents = {
    user.name = "Andy Hamon";
    user.email = "andy.hamon@discordapp.com";
    oh-my-zsh.hide-dirty = 1;

    core.fsmonitor = true;
    core.untrackedcache = true;
  };
}
