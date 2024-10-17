MQTT Over TLS
====

1.	Create root CA private key and certificates 

```
$ mkdir certs 
$ cd certs 
$ mkdir ca 
$ cd ca/ 
$ openssl req -new -x509 -days 365 -extensions v3_ca -keyout ca.key -out ca.crt 
```
2.	Create MQTT broker private key and certificates
```
$ mkdir broker
$ cd broker
$ openssl genrsa -out broker.key 2048
$ openssl req -out broker.csr -key broker.key -new
$ openssl x509 -req -in broker.csr -CA ../ca/ca.crt -CAkey ../ca/ca.key -CAcreateserial -out broker.crt -days 100
```

3.	Create MQTTS clients certificates
```
$ mkdir client
$ cd client
$ openssl genrsa -out client.key 2048
$ openssl req -out client.csr -key client.key -new
$ openssl x509 -req -in client.csr -CA ../ca/ca.crt -CAkey ../ca/ca.key -CAcreateserial -out client.crt -days 100
```
4.	Configure moqsquitto.conf and run MQTT broker
   

  * Add below lines in /etc/mosquitto/mosquitto.conf

  ```
  Port 8883
  cafile /home/openest/certs/ca/ca.crt
  certfile /home/openest/certs/broker/broker.crt
  keyfile /home/openest/certs/broker/broker.key
  require_certificate true
  ```

  * Run 
  /usr/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf
  

mosquitto.conf
----

```
# mosquitto.conf
# Place your local configuration in /etc/mosquitto/conf.d/
#
# A full description of the configuration file is at
# /usr/share/doc/mosquitto/examples/mosquitto.conf.example

listener 1883 0.0.0.0
listener 1884 0.0.0.0
listener 1885 0.0.0.0
listener 1886 0.0.0.0
listener 1887 0.0.0.0
listener 1888 0.0.0.0
listener 1889 0.0.0.0
listener 1890 0.0.0.0

persistence false
allow_anonymous true
set_tcp_nodelay true

# MQTT over TLS over Web Socket
listener 8883
listener 8884
protocol websockets
cafile /etc/certs/ca/ca.crt
certfile /etc/certs/broker/broker.crt
keyfile /etc/certs/broker/broker.key
require_certificate true

persistence false
allow_anonymous true
set_tcp_nodelay true

```

