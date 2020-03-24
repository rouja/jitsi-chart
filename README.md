# This charts installs the Jisti on kubernetes

It's based on theses [files](https://github.com/jitsi/docker-jitsi-meet/tree/master/examples/kubernetes)

## Disclaimer

It's a work in progress, it's need improvement.

## Installation

```console
git clone git@github.com:rouja/jitsi-chart.git
cp jitsi-chart/values.yaml customized-values.yaml
```

### Configuration

Adapt the content of  **customized-values.yaml** to your environment.

At least you need to generate the secret

```console
./jitsi-chart/generate-secret.sh
################################################
JICOFO_AUTH_PASSWORD: bGlTY21na1FTRHlXRHpiWgo=
JICOFO_COMPONENT_SECRET: VEE0bE03Q0xQeTlzNmlKWAo=
JVB_AUTH_PASSWORD: WEhIWU9VRGFZdDFTYkNmbAo=
################################################
```

You need to insert the generated block into your **customized-values.yaml**.

By default, the pod is not exposed. If you want to expose jitsi automatically by using this chart you need to have : 

- a working HTTP/HTTPS ingress controller.
- cert-manager installed and configured (including a working cert issuer).

To expose your jitsi, you have to configure the certificate section :

```console
certificate:
  enabled: true
  maindomain: jitsi.$YOUR_DOMAIN
  altnames:
    - jitsi.$YOUR_DOMAIN
    - guest.jitsi.$YOUR_DOMAIN
  issuer: $YOUR_CERT_MANAGER_ISSUER
```

And the ingress section :

```console
ingress:
  enabled: true
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  hosts:
    - host: jitsi.$YOUR_DOMAIN
      paths:
        - "/"
    - host: guest.jitsi.$YOUR_DOMAIN
      paths:
        - "/"
  tls: 
    - hosts:
      - jitsi.$YOUR_DOMAIN
      secretName: jitsi-certificates
    - hosts:
      - guest.jitsi.$YOUR_DOMAIN
      secretName: jitsi-certificates
```

And you need to specify the public IP on which the service should expose the UDP port :

```console
service:
  type: ClusterIP
  port: 80
  publicIp: "$YOUR_PUBLIC_IP"
```

Do not forget to change the domain in all variables. For instance :

```console
    - name: XMPP_GUEST_DOMAIN
      value: guest.jitsi.meet.jitsi
```

### Deployment

```console
kubectl create ns jitsi
helm upgrade -n jitsi -f customized-values.yaml --install jitsi jitsi-chart/
```

Wait a minute and check that the web container is ready :

```console
kubectl -n jitsi logs $(kubectl -n jitsi get po -o go-template --template="{{ range .items}}{{ .metadata.name }}{{end}}") -c jitsi-chart-web
```

If you see **[services.d] starting services** everything should be ok.

### Authentication

If you choose to enable authentication in order to generate a user, you can do :

```console
kubectl -n jitsi exec -it $(kubectl -n jitsi get po -o go-template --template="{{ range .items}}{{ .metadata.name }}{{end}}") -c jitsi-chart-prosody /bin/bash
prosodyctl --config /config/prosody.cfg.lua register USER DOMAIN PASSWORD
```
