{ pkgs, python, self }:
  with pkgs.lib;

{
  lxml = { buildInputs=[pkgs.libxml2 pkgs.libxslt]; };
  pysqlite = { buildInputs=[pkgs.sqlite]; };
  pylibmc = { propagatedBuildInputs = [pkgs.libmemcached pkgs.cyrus_sasl pkgs.zlib]; };
  psycopg2 = { buildInputs=[pkgs.postgresql]; };
  pyyaml = p: { buildInputs = p.buildInputs ++ [pkgs.libyaml]; };
  cffi = p: { buildInputs = p.buildInputs ++ [pkgs.libffi]; };

  graph-explorer = p: { propagatedBuildInputs = p.propagatedBuildInputs++[python.modules.sqlite3]; doCheck = false; };
  sentry = {
    preCheck = ''
      rm tests/sentry/buffer/redis/tests.py
      rm tests/sentry/quotas/redis/tests.py
    '';
  };
}
