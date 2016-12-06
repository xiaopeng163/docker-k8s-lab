Customize the docker0 bridge
============================

The default docker0 bridge has some default configuration [#f1]_.

.. code-block:: bash

  ubuntu@docker-node1:~$ docker network list
  NETWORK ID          NAME                DRIVER              SCOPE
  83a58f039549        bridge              bridge              local
  0f93d7177516        host                host                local
  68721ff2f526        none                null                local
  ubuntu@docker-node1:~$
  ubuntu@docker-node1:~$
  ubuntu@docker-node1:~$ docker network inspect bridge
  [
      {
          "Name": "bridge",
          "Id": "83a58f039549470e3374c6631ef721b927e92917af1d21b464dd59551025ac22",
          "Scope": "local",
          "Driver": "bridge",
          "EnableIPv6": false,
          "IPAM": {
              "Driver": "default",
              "Options": null,
              "Config": [
                  {
                      "Subnet": "172.17.0.0/16",
                      "Gateway": "172.17.0.1"
                  }
              ]
          },
          "Internal": false,
          "Containers": {
              "13866c4e5bf2c73385883090ccd0b64ca6ff177d61174f4499210b8a17a7def1": {
                  "Name": "test1",
                  "EndpointID": "99fea9853df1fb5fbed3f927b3d2b00544188aa7913a8c0f4cb9f9a40639d789",
                  "MacAddress": "02:42:ac:11:00:02",
                  "IPv4Address": "172.17.0.2/16",
                  "IPv6Address": ""
              }
          },
          "Options": {
              "com.docker.network.bridge.default_bridge": "true",
              "com.docker.network.bridge.enable_icc": "true",
              "com.docker.network.bridge.enable_ip_masquerade": "true",
              "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
              "com.docker.network.bridge.name": "docker0",
              "com.docker.network.driver.mtu": "1500"
          },
          "Labels": {}
      }
  ]
  ubuntu@docker-node1:~$

What we want to do is to change the default IPAM dirver's configuration, IP address, netmask and IP allocation range.


References
-----------

.. [#f1] https://docs.docker.com/engine/userguide/networking/default_network/custom-docker0/
