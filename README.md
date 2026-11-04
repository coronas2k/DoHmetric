# DoHmetric

Compare common public DNS resolvers from your network, then pick two from different providers.

Port 53 answers and DNS-over-HTTPS answers are not the same measurement. DoHmetric keeps them separate so a fast handshake is not mistaken for a fast lookup.

## Contents

- [Requirements](#requirements)
  - [How to install](#how-to-install)
    - [Debian and Ubuntu](#debian-and-ubuntu)
    - [RHEL, Fedora, Alma, and Rocky](#rhel-fedora-alma-and-rocky)
    - [macOS](#macos)
- [Usage](#usage)
  - [Docker](#docker)
  - [Options](#options)
- [Resolvers](#resolvers)
- [Results](#results)
  - [Traditional DNS](#traditional-dns)
  - [DNS over HTTPS](#dns-over-https)
- [License](#license)

## Requirements

Bash, `dig`, and `awk`. DNS-over-HTTPS mode also needs `python3` and a `curl` built with HTTP/2.

### How to install

#### Debian and Ubuntu

```bash
sudo apt install bind9-dnsutils python3 curl
```

#### RHEL, Fedora, Alma, and Rocky

```bash
sudo dnf install bind-utils python3 curl
```

#### macOS

```bash
brew install bind python
```

## Usage

```bash
chmod +x dohmetric
./dohmetric
```

```bash
./dohmetric -m doh
./dohmetric -m both -d cloudflare.com -n 5
```

### Docker

```bash
docker build -t dohmetric .
docker run --rm dohmetric
```

### Options

```text
dohmetric [-m traditional|doh|both] [-d domain] [-n samples] [-t timeout]
```

| Option | Default | Description |
| --- | --- | --- |
| `-m` | `traditional` | `traditional` uses port 53. `doh` uses DNS over HTTPS. `both` runs traditional, then DoH. |
| `-d` | `example.com` | Name to query. |
| `-n` | `5` | Timed queries per resolver, from 1 to 20. One warmup query is discarded. |
| `-t` | 2s, or 5s for DoH | Per-query timeout in seconds, from 1 to 15. |
| `-h` | | Show the same details in the terminal. |

`DOMAIN`, `SAMPLES`, `TIMEOUT`, and `MODE` set the same defaults from the environment. Passing `-t` applies that timeout to whichever modes you run.

## Resolvers

| Provider | Port 53 | DNS over HTTPS |
| --- | --- | --- |
| Google | yes | yes |
| Cloudflare | yes | yes |
| Quad9 | yes | yes |
| OpenDNS | yes | yes |
| AdGuard | yes | yes |
| CleanBrowsing | yes | yes |
| Control D | yes | yes |
| NextDNS | yes | yes |
| DNSPod | yes | yes |
| AliDNS | yes | yes |
| 360 | yes | yes |
| DNS.SB | yes | yes |
| Canadian Shield | yes | yes |
| DNS for Family | yes | yes |
| DNS4EU | yes | yes |
| Restena | | yes |
| UncensoredDNS | | yes |
| LibreDNS | | yes |
| Digitale Gesellschaft | | yes |
| Switch | | yes |
| Comcast Xfinity | | yes |
| OpenBLD | | yes |
| IIJ | | yes |
| Foundation for Applied Privacy | | yes |
| RethinkDNS | | yes |

## Results

### Traditional DNS

`./dohmetric` asks each address with `dig` and ranks the query time of `NOERROR` answers.

```text
Provider                       Address               Avg      Min      Max       OK
------------------------------ ---------------- -------- -------- -------- --------
Quad9                          149.112.112.112     20 ms    18 ms    22 ms      5/5
Cloudflare                     1.1.1.1             22 ms    20 ms    25 ms      5/5
```

The suggestion is the fastest address, then the fastest address from a different provider. On macOS the script prints a `networksetup` command for your first active network service. Elsewhere it prints `resolvectl` and an `/etc/resolv.conf` snippet.

### DNS over HTTPS

`./dohmetric -m doh` sends an RFC 8484 POST (`application/dns-message`) over HTTP/2. Each sample is a new `curl` process, so each sample includes a new connection.

```text
Provider                       Endpoint                                              HTTP   TCP ms   TLS ms  Total ms    OK
------------------------------ ---------------------------------------------------- ----- -------- -------- --------- -----
Quad9                          https://149.112.112.112/dns-query                      200    25.53    51.48     71.29   5/5
Cloudflare                     https://1.1.1.1/dns-query                              200    23.49    57.25     86.06   5/5
```

| Column | Meaning |
| --- | --- |
| TCP | `curl` `time_connect` |
| TLS | `curl` `time_appconnect`. This already includes TCP. It is the time until the handshake has finished. |
| Total | `curl` `time_total`: TCP, TLS, and the DNS answer. The table is sorted by this. |
| OK | Successful samples out of `-n`. |

The DNS portion of a sample is about Total minus TLS. A browser that keeps the connection open pays the handshake once, then sees times closer to that lookup figure. With more than one sample, TCP, TLS, and Total are averages.

Browsers take one custom DoH URL. Use the first suggestion, and keep the second as a fallback.

- Chrome: Settings → Privacy and security → Security → Use secure DNS → With → custom
- Firefox: Settings → Privacy & Security → DNS over HTTPS → custom provider

## License

Apache License 2.0. See [LICENSE](LICENSE).
