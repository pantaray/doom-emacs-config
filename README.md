# doom-emacs-config
Customized setup of Doom Emacs for both Emacs v29 and v26

## Setup 

Clone this repository to a convenient location on your system:

``` shell
git clone https://github.com/pantaray/doom-emacs-config.git
```

The provided shell script installs/updates/removes [Doom Emacs](https://github.com/doomemacs/doomemacs)
from a system. To use it, first ensure the script is executable 

``` shell
cd doom-emacs-config/
chmod +x setup.sh
```

**Note** This Doom setup is configured to use the 
[Python LSP server for Emacs](https://emacs-lsp.github.io/lsp-mode/page/lsp-pylsp/) 
to enable auto-completion etc. in Python. The language server must be installed 
on the system outside of Emacs (e.g., `pip install 'python-lsp-server[all]'` or 
`apt install python3-pylsp` on modern Debian systems) to use its functionality. 

## Usage 

To install the provided Doom Emacs configuration use 

``` shell
./setup.sh --install
```

and follow the instructions. 

Similarly, 

``` shell
./setup.sh --uninstall
```

removes Doom Emacs from your system. 

To update an existing Doom Emacs setup, use 

``` shell
./setup.sh --update
```

### Remote Editing 

By default, the provided configuration enables
[ssh-deploy](https://github.com/cjohansson/emacs-ssh-deploy/tree/master) in Doom Emacs. 
To use it in a project, create a file called `.dir-locals.el` at the project root with 
appropriate settings. Note that `ssh-deploy` itself uses 
[TRAMP](https://www.gnu.org/software/tramp/) for remote connections 
and thus supports SSH, SFTP, FTP (among others). To use `ssh-deploy` with an 
ssh remote host use the following settings:

``` shell
((nil . (
  (ssh-deploy-root-local . "/path/to/project/")
  (ssh-deploy-root-remote . "/ssh:user@remote:/remote/path/to/project/")
  (ssh-deploy-on-explicit-save . t)
  (ssh-deploy-force-on-explicit-save . 1)
)))
```

Internally, TRAMP relies on the local machine's `ssh` client to establish the 
connection. Thus, any ssh-specific options (proxies, keys, port forwards etc.) 
can be specified in your local `~/.ssh/config`. 

### AI-Assisted Coding

By default, the provided configuration also enables [gpt.el](https://github.com/karthink/gptel) 
in Doom Emacs. To use it, you have to first have to set up the model you want to 
use in Emacs. The included example shows how to do this for Google's Gemini 
(free tier). Once you've obtained your API key, include it in your `~/doom.d/config.el`
and start interacting with Gemini via the keybinding `[ALT] + ,`, `[o]`, `[l]`. 

## Support

For general questions related to Emacs or Doom, please consult, e.g., the 
[Emacs Wiki](https://www.emacswiki.org/) and [Doom's Discourse](https://discourse.doomemacs.org/)
respectively. 

If you have questions/suggestions particular to this configuration, please use 
its [GitHub Issue Tracker](https://github.com/pantaray/doom-emacs-config/issues). 

## Contributing

If you want to extend/modify this configuration, feel free to fork this GitHub repository. 

Please ensure to set up the accompanying git filter to not accidentally push any LLM API 
key(s):

```shell
git config --local include.path ../.gitconfig
```

Check if the filter has been set up correctly:

```shell
git config --list --show-origin 
# the last line should show 
# file:.git/../.gitconfig filter.apikey.clean=sed 's/:key "[^"]*"/:key "api-key"/g'
```

Upon committing your changes, ensure any actual API key(s) have been replaced by the 
configured place-holder:

```shell
git commit ...
git cat-file -p HEAD:config/.doom.d/config.el
```

Once you're done, please open a [pull request](https://github.com/pantaray/doom-emacs-config/pulls).

## Project Status

This project is actively maintained and (sometimes) updated.
