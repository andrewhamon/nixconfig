# Usage: `source ./fixup-ssh-auth-sock.sh` in zshrc or similar

# Some notes about my testing:
#
# If I disconnect/reconnect repeatedly in a short period of time, there will be multiple 
# sockets found using `find /tmp/auth-agent*/listener.sock`
#
# All of these appear to be real files/unix sockets, however only one is still
# good.
#
# For simplicity as well as speed, I assume the most recently created one is the good
# one. In my testing, this seems to be a reliable heuristic.

fixup-ssh-auth-sock(){
  # Do nothing unless running in coder
  if [[ -z "${CODER// }" ]]; then
    return
  fi

  # Only modify SSH_AUTH_SOCK if it is set to a socket in /tmp
  # Otherwise, assume that the user has already set it to a valid socket

  if [[ -z "${SSH_AUTH_SOCK// }" ]]; then
    # SSH_AUTH_SOCK is empty, do nothing. This means agent forwarding is not enabled.
    return
  fi

  if ! [[ "$SSH_AUTH_SOCK" =~ '/tmp/auth-agent.*' ]]; then
    # SSH_AUTH_SOCK does not point to a socket matching /tmp/auth-agent.*, do nothing
    # Don't want to interfere with user's explicit setting of SSH_AUTH_SOCK
    # /tmp/auth-agent.* seems to be what ssh uses when agent forwarding is enabled
    return
  fi

  socket_candidates=($(find /tmp/auth-agent*/listener.sock))

  # Grab the first socket as the initial candidate
  # weird syntax to be compatible with bash and zsh
  newest_socket="${socket_candidates[@]:0:1}"

  # Search for the newest socket
  for socket in ${socket_candidates[@]}; do
    if [ $socket -nt $newest_socket ]; then
      newest_socket=$socket
    fi
  done

  # Set SSH_AUTH_SOCK to the newest socket
  export SSH_AUTH_SOCK=$newest_socket
}

fixup-ssh-auth-sock
