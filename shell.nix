{ pkgs ? import <nixpkgs> { } }:
let
  feed-parser-repo = pkgs.fetchFromGitHub {
    owner = "easypodcasts";
    repo = "go-feed-parser";
    rev = "78877f3e16022a47f57c8fe9f37b9abeb2053418";
    sha256 = "USHbk5zJycy3oDmUsPjQQlWrz0yzBOdzyOKH9Rkclc8=";
  };
  feed-parser-pkg = pkgs.callPackage "${feed-parser-repo}" { };
  basePackages = with pkgs; [
    gnumake
    gcc
    readline
    openssl
    feed-parser-pkg
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
    export FEEDPARSER_BIN=${feed-parser-pkg}/bin/go-feed-parser
    if [ ! -d $MIX_HOME ]; then
        echo "Install hex and rebar..."
        mix local.hex --force || true
        mix local.rebar --force || true
    fi
    if [ ! -d $HEX_HOME ]; then
        echo "Getting dependencies"
        mix deps.get || true
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
    echo 'Run migrations'
    mix ecto.setup || true
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
