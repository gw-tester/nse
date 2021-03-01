# Network Service Mesh Endpoint
[![Go Report Card](https://goreportcard.com/badge/github.com/gw-tester/nse)](https://goreportcard.com/report/github.com/gw-tester/nse)
[![GoDoc](https://godoc.org/github.com/gw-tester/nse?status.svg)](https://godoc.org/github.com/gw-tester/nse)
[![Docker](https://images.microbadger.com/badges/image/gwtester/nse.svg)](http://microbadger.com/images/gwtester/nse)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Summary

This project provides a generic Network Service Mesh Endpoint which
supports multiple services in one endpoint. It reads the network
configuration values from the [downwardAPI feature][1].

```yaml
apiVersion: v1
kind: Pod 
metadata:
  name: pgw 
  annotations:
    ns.networkservicemesh.io/endpoints: |
      {   
        "name": "lte-network",
        "networkServices": [
          {"link": "s5u", "labels": "app=pgw-s5u", "ipaddress": "172.25.0.0/24"},
          {"link": "s5c", "labels": "app=pgw-s5c", "ipaddress": "172.25.1.0/24"},
          {"link": "sgi", "labels": "app=http-server-sgi", "ipaddress": "10.0.1.0/24", "route": "10.0.3.0/24"}
        ]   
      }   
spec:
  containers:
    - name: sidecar
      image: gwtester/nse:0.0.1
      resources:
        limits:
          networkservicemesh.io/socket: 1
      volumeMounts:
        - name: nsm-endpoints
          mountPath: /etc/nsminfo
    - image: gwtester/pgw:0.0.1
      name: pgw 
      securityContext:
        capabilities:
          add: ["NET_ADMIN"]
  volumes:
    - name: nsm-endpoints
      downwardAPI:
        items:
          - path: endpoints
            fieldRef:
              fieldPath: metadata.annotations['ns.networkservicemesh.io/endpoints']
```

[1]: https://kubernetes.io/docs/tasks/inject-data-application/downward-api-volume-expose-pod-information/
