# Claude code container

This repository provides the container to run opencode in a safe environment. It also introduce a small go binary
to sync the clipboard between the opencode container and the host mac os system (see [README](./tools/clipboard-bridge/README.md)).

In claude its not really working and I rely on tmux to copy text, so I don't know it it will work for your terminal setup.

To build the container itself just run

```bash
./build.sh
```

Which will build the container for your local architecture.


To actually run it, please use following script (just name it `cc` or `claude` and put it to `~/bin/` or `/usr/local/bin`):

```bash
#!/usr/bin/env bash

WORKDIR="${PWD/"${HOME}"//home/user}"

# TERM_PROGRAM and COLORTERM are required to specify the terminal and color to support correct formatting
# mounting of the git config is required to have the correct ssh keys for git repos
# mounting of the ssh config is required to clone private repos
command=(
	docker run --rm -it
	-e TERM=xterm-256color
	-e TERM_PROGRAM=WezTerm
	-e COLORTERM=truecolor
	-v "${HOME}/.config/git":/home/user/.config/git:ro
	-v "${HOME}/.ssh":/home/user/.ssh:ro
	-v "${HOME}/.claude.json":/home/user/.claude.json
	-v "${HOME}/.claude":/home/user/.claude
	-v "${PWD}":"${WORKDIR}"
	-u "$(id -u):$(id -g)"
	-w "${WORKDIR}"
	claudecode
	--permission-mode plan
)

trap 'reset' EXIT
"${command[@]}" "$@"
```
