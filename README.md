# MUA Union Lobby Entry Server Docker Image
## 准备工作
条件：
- 稳定的网络环境
- Linux
- docker, docker compose

## 部署
1. 创建并编辑`docker-compose.yml`，并修改尖括号中的内容。建议为`FRPS_AUTH_TOKEN`生成随机字符串。**不需要双引号。**。`<MUA CODE>`大写。

    ```
    version: "3.8"

    services:
    entry:
        image: mua-union-lobby-entry:latest
        stdin_open: true
        tty: true
        volumes:
        - "./server:/server"
        environment:
        - UNION_SYNC_URL=wss://mc.sjtu.cn:22905
        - UNION_ENTRY_ID=<MUA CODE>
        - UNION_SYNC_AUTH_TOKEN=<UNION API TOKEN>
        - FRPS_AUTH_TOKEN=<RANDOM STRING>
        ports:
        - "7001:7001"
        - "7002:7002/udp"
        - "7003:7003/udp"
        - "7050:7050"
        - "25565:25577"
        restart: "no"
    ```

    > 这个项目使用的Docker镜像基于[itzg/bungeecord](https://hub.docker.com/r/itzg/bungeecord)。可以在这里找到进阶配置的说明。

2. (可选) 启用quic支持。
  - 永久修改：
    - 修改`/etc/sysctl.d/10-network-tcp-buff.conf`：
        ```
        net.core.rmem_max=2500000
        net.core.wmem_max=2500000
        ```
      - 重启服务器。
  - 立即修改：
    ```
    sysctl "net.core.rmem_max=2500000"
    sysctl "net.core.rmem_max=2500000"
    ```

3. 编辑`start.sh`
    ```
    docker compose pull
    docker compose run --service-ports --rm entry
    ```

4. 使用该命令启动：`bash start.sh`。首次启动时，会自动设置插件和Velocity的配置，配置完成后会自动关闭。这时，你可以安装别的插件或者按需修改你的设置。

5. 配置完成后，联系Union Lobby管理员，并提交`server/union`内的文件，以及你的域名或IP。

6. 每一次启动前，会自动更新镜像，包括frp、Velocity本体以及Union系列插件。