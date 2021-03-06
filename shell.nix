{ pkgs ? import <nixpkgs> { } }:
let
  basePackages = with pkgs; [
    gnumake
    gcc
    readline
    openssl
    zlib
    libxml2
    curl
    libiconv
    elixir
    elixir_ls
    glibcLocales
    nodejs
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
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-hex
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH
    export LANG=en_US.UTF-8
    export ERL_AFLAGS="-kernel shell_history enabled"
    if [ ! -d $MIX_HOME ]; then
        echo "Install hex and rebar..."
        mix local.hex --force
        mix local.rebar --force
    fi
    if [ ! -d $HEX_HOME ]; then
        echo "Getting dependencies"
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
