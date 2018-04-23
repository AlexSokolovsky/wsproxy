# WebSocket proxy

## Getting Started

```
thin start -R config.ru -t 1000 -p 3001
```
## In order to initialize websocket connection by:
  - User side

      You must send correct request to the proxy server  :
      ```
      ws://host:port?uid=user_id
      ```
  - Device side

      You must send correct request to the proxy server  :
      ```
      ws://host:port?chip_id=chip_id
      ```
  Connection type is P2P, e.g. one device have connection to one user.

## In order to change logfile, set env variable 'LOGFILE' in .env file

## For auto unbind devices, set env variable 'TIME_LEFT' in .env file
