`IP scanner` is a script that will help you with the process of IP scanning. Feed it with a file containing all IP ranges you discovered. It will use prips to get all the IPs from the ranges, filter for the alive ones with nmap and scan all the 65535 ports on every alive IP.

## Requierements

```sh
sudo apt install prips nmap
```


## Usage

```sh
./ip_scanner.sh -h
```
![imagen](https://github.com/user-attachments/assets/b686ed12-313f-488f-ae04-fe32e9fb2b6f)

```sh
cat ips.txt
```
![imagen](https://github.com/user-attachments/assets/5df70c27-7acd-47b7-8c40-e8f462e29bef)


```sh
bash ip_scanner.sh -f ips.txt
```


Check the files in the output folder to see the results

>[!Note]
If the file contains lots of IP ranges, this whole process can take a while. In this case is preferable to run it on a VPS
