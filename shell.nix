{ pkgs ? import <nixpkgs> { } }:
let
  unstable = import (builtins.fetchTarball
    "https://github.com/nixos/nixpkgs/tarball/nixpkgs-unstable") { };
  basePackages = with pkgs; [
    gnumake
    gcc
    readline
    openssl
    zlib
    libxml2
    curl
    libiconv
    unstable.elixir
    unstable.elixir_ls
    glibcLocales
    unstable.nodejs
    yarn
    postgresql
    inotify-tools
    bat
    ffmpeg
  ];

  # define shell startup command
  hooks = ''
    # this allows mix to work on the local directory
    echo 'Setting elixir'
    mkdir -p .nix-mix
    mkdir -p .nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-hex
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH
    export LANG=en_US.UTF-8
    export ERL_AFLAGS="-kernel shell_history enabled"
    if [ ! -d $HEX_HOME ]; then
        mix local.hex --force
        mix local.rebar --force
    fi
    if [ ! -d $MIX_HOME ]; then
        mix deps.get
    fi
    echo 'Setting database'
    export PGDATA=$PWD/postgres_data
    export PGHOST=$PWD/postgres
    export LOG_PATH=$PWD/postgres/LOG
    export PGDATABASE=postgres
    export PGSOCKET=$PWD/sockets
    mkdir $PGSOCKET
    if [ ! -d $PGHOST ]; then
      mkdir -p $PGHOST
    fi
    if [ ! -d $PGDATA ]; then
      echo 'Initializing postgresql database...'
      initdb $PGDATA --auth=trust >/dev/null
    fi
    pg_ctl start -l $LOG_PATH -o "-c listen_addresses= -c unix_socket_directories=$PGSOCKET"
    createuser -d -h $PGSOCKET postgres
    psql -h $PGSOCKET -c "ALTER USER postgres PASSWORD 'postgres';"
    function end {
          echo "Shutting down the database..."
          pg_ctl stop
          echo "Removing directories..."
          rm -rf $PGDATA $PGHOST $PGSOCKET
        }
        trap end EXIT
  '';

in pkgs.mkShell {
  buildInputs = basePackages;
  shellHook = hooks;
}
