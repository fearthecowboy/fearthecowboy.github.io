---
layout: post
title: "Quick and dirty Code-Server in WSL"
description: "Getting Code-Server running in WSL"
category: Tutorial
tags: [wsl,vscode,codeserver]
---

A short tutorial on getting Code-Server (VSCode in browser) running in WSL, and exposing it to the internets.

References: 
  - [Code Server](https://github.com/cdr/code-server)
  - [Code Server Guide](https://github.com/cdr/code-server/blob/v3.5.0/doc/guide.md)
  
This is going to be short and sweet, as I don't have a lot of time to burn with this.

Prep:
- Make sure that you have your DNS pointing to your external IP address (My router supports dyndns, so it can keep the DNS record up to date YMMV.)
- If you are on a NAT, port-forward 80/443 to your Windows machine (specific to your router)

Steps:
### 0. Install WSL support for systemd
Run the script and commands

``` sh
git clone https://github.com/DamionGans/ubuntu-wsl2-systemd-script.git
cd ubuntu-wsl2-systemd-script/
bash ubuntu-wsl2-systemd-script.sh
# Enter your password and wait until the script has finished
```
Then restart the Ubuntu shell and try running systemctl
`systemctl`

### 1. Install Code-Server
In WSL run the command to install code-server:<br>
  `curl -fsSL https://code-server.dev/install.sh | sh`

To enable it in systemd:
  `sudo systemctl enable --now code-server@$USER`
<hr>

### 2. Install Caddy
>__Note__: This will appear to fail to install the daemon as it's built for `systemd` AFAICT. Don't worry about it. 

``` sh
  echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" | sudo tee -a /etc/apt/sources.list.d/caddy-fury.list
  sudo apt update
  sudo apt install caddy
```
<hr>

### 3. Make Windows pass thru the ports. 
<br> I found a powershell script that makes this really easy. Create a `network-forward-to-wsl.ps1` script : 

``` powershell
 
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}

# create the firewall rule to let in 443/80
if( -not ( get-netfirewallrule -displayname web -ea 0 ) {
  new-netfirewallrule -name web -displayname web -enabled true -profile any -action allow -localport 80,443 -protocol tcp 
}

$remoteport = bash.exe -c "ifconfig eth0 | grep 'inet '"
$found = $remoteport -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

if( $found ){
  $remoteport = $matches[0];
} else{
  echo "The Script Exited, the ip address of WSL 2 cannot be found";
  exit;
}

$ports=@(80,443);

iex "netsh interface portproxy reset";
for( $i = 0; $i -lt $ports.length; $i++ ){
  $port = $ports[$i];
  iex "netsh interface portproxy add v4tov4 listenport=$port connectport=$port connectaddress=$remoteport";
}
iex "netsh interface portproxy show v4tov4";
```

> __NOTE:__ You will have to  run that every time you restart WSL (WSL gets a random IP in an internal address)
<hr>

### 4. Unblock ports `443/80` in Windows Firewall
Sorry, didn't automate that. It's a one-time thing.
<hr>

### 5. Using your domain name (ie `code.mydomain.com`), replace `/etc/caddy/Caddyfile` with sudo to look like this:
``` sh
  code.mydomain.com

  reverse_proxy 127.0.0.1:8080
```
> When Caddy runs, it will automatically go and get an HTTPS certificate from Let's Encrypt for that domain. 
> <br>Make sure that you have your DNS pointing to your IP address


### 6. Get the password from your `~/.config/code-server/config.yaml` file (it's randomly generated) <br>
or edit the file and set one

### 7. Browse to your domain name you set up.

  
