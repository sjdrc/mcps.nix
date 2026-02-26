{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  python3,
  makeWrapper,
}:

buildNpmPackage {
  pname = "context-mode";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "mksglu";
    repo = "claude-context-mode";
    rev = "v0.7.3";
    hash = "sha256-949Hkk9RveoA/0wxW31MjnIgL7BhJ2xYwvIXkkACtSs=";
  };

  # Upstream lockfile is missing resolved/integrity for 92 packages,
  # causing prefetch-npm-deps to skip them. Replace with a regenerated lockfile.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  nodejs = nodejs_22;

  npmDepsHash = "sha256-OQ9TU7JIH4tSLy48zubr0h/rMyfQJjsYimK/79/SAfY=";
  npmFlags = [ "--legacy-peer-deps" ];

  # better-sqlite3 requires node-gyp which needs python
  nativeBuildInputs = [ python3 makeWrapper ];
  buildInputs = [ nodejs_22 ];

  # Use the pre-built bundle
  dontNpmBuild = true;

  postFixup = ''
    rm -f $out/bin/context-mode
    makeWrapper ${nodejs_22}/bin/node $out/bin/context-mode \
      --add-flags "$out/lib/node_modules/context-mode/server.bundle.mjs"
  '';

  meta = {
    description = "Claude Code MCP plugin that compresses tool outputs to save context window";
    homepage = "https://github.com/mksglu/claude-context-mode";
    license = lib.licenses.mit;
    mainProgram = "context-mode";
  };
}
