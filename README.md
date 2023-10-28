# MUA Union Lobby Entry Server Docker Image
## 准备工作
条件：
- 稳定的网络环境
- Linux
- docker, docker compose

## 部署
1. 创建并编辑`docker-compose.yml`，并修改尖括号中的内容。其中，建议为`FRPS_AUTH_TOKEN`生成随机字符串。**不需要双引号。**
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
        restart: always
        ports:
        - "7001:7001"
        - "7002:7002"
        - "7003:7003"
        - "7050:7050"
        - "25565:25577"
        restart: "no"
    ```

    > 这个项目使用的Docker镜像基于[itzg/bungeecord](https://hub.docker.com/r/itzg/bungeecord)。可以在这里找到进阶配置的说明。

2. 使用该命令启动：`docker-compose run entry`。首次启动时，会自动设置插件和Velocity的配置，配置完成后会自动关闭。这时，你可以安装别的插件或者按需修改你的设置。

3. 配置完成后，联系Union Lobby管理员，并提交`server/union`内的文件，以及你的域名或IP。

## 运行
使用相同的命令`docker-compose run entry`即可启动。每一次启动前，会自动检查更新。