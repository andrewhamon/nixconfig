{
  condition = "gitdir:~/flexport/";
  contents = {
    user.name = "Andy Hamon";
    user.email = "andrew.hamon@flexport.com";
    oh-my-zsh.hide-dirty = 1;

    core.fsmonitor = true;
    core.untrackedcache = true;
  };
}
