# WSL
## Running Ubuntu in wsl
```sh
wsl --install Ubuntu
```
```bash
curl -sSfL https://raw.githubusercontent.com/231tr0n/config/main/wsl/ubuntu/wsl_main_setup.bash | bash -x
```
## Running Arch in wsl
```sh
scoop install archwsl
wsl -d Arch
```
```bash
curl -sSfL https://raw.githubusercontent.com/231tr0n/config/main/wsl/arch/wsl_initial_setup.bash | bash -x
```
Exit the shell and run specified commands in the script.
```bash
curl -sSfL https://raw.githubusercontent.com/231tr0n/config/main/wsl/arch/wsl_main_setup.bash | bash -x
```
