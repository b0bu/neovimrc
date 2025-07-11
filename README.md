## neovim kickstart customization
This is written for me, so not expecting reuse. This is a mechanism I use to sync
changes across multiple machines and in and out of kickstart. By default `Sync` tries from cwd and can be called
with empty args.

```
sudo apt install ansible -y
ansible-playbook -c local -i 'localhost,' main.yaml -u $(whoami)
```


```
NVIM v0.11.2
KICKSTART e947649
```

Once deployed 
`<leader>cfg` syncs any new config from git, `<leader>ctg` syncs new edits into git

### dirs
- lua - plugins that extend capability
- after - custom functions and bindings that alter functionality
- plugin - lua loaded before neovim loads plugins 

### deploy 
```bash
gh repo clone b0bu/neovimrc && cd neovimrc
./deps.sh
#initial sync -  move to keymaps after this
nvim --headless -c "luafile after/plugin/sync.lua" -c "lua Sync({})" -c "qa"
```
### reqs 
- set `vim.g.have_nerd_font = true` in kickstart init.lua
- `'nvim-tree/nvim-web-devicons'` is pre-installed by kickstart
- uncomment `{ import = 'custom.plugin' },` in `~/.config/nvim/init.lua`

### installed lsps
- bash-debug-adapter
- clangd
- cpptools
- go-debug-adapter
- goimports
- gopls
- json-lsp
- jsonls
- jsonlint
- jsonnetfmt
- lua-language-server
- lua-ls
- stylua
- terraform-ls
- terraformls
- tflint
