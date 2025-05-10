## 创建一个自定义且优化的容器镜像
默认的 keycloak 容器镜像已准备好进行配置和优化。

为了获得最佳的 keycloak 容器启动性能，在容器构建过程中通过执行 `build` 步骤来构建镜像
此步骤将在容器镜像的每个后续启动阶段中节省时间。

### 编写自定义的优化 keycloak 容器文件（`Containerfile）
以下 Containerfile 会创建一个预配置的 keycloak 镜像，该镜像启用了健康检查和指标端点、启用了令牌交换功能，并使用 PostgreSQL 数据库。

.Containerfile:
```
FROM quay.io/keycloak/keycloak:{containerlabel} AS builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:{containerlabel}
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# change these values to point to a running postgres instance
ENV KC_DB=postgres
ENV KC_DB_URL=<DBURL>
ENV KC_DB_USERNAME=<DBUSERNAME>
ENV KC_DB_PASSWORD=<DBPASSWORD>
ENV KC_HOSTNAME=localhost
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
```
构建过程包含多个阶段：

* 运行 `build` 命令以设置服务器构建选项，从而创建一个优化后的镜像。
* `build` 阶段生成的文件会被复制到一个新的镜像中。
* 在最终镜像中，会设置主机名和数据库的额外配置选项，因此在运行容器时无需再次设置它们
* 在入口点（entrypoint）中，`kc.sh` 脚本使你可以访问所有分发版的子命令。

要安装自定义`providers`程序，只需定义一个步骤，将 JAR 文件添加到 `/opt/keycloak/providers` 目录。 此步骤必须放在执行 `build` 命令的行之前，如下所示：

```
# 一个构建步骤示例：从 URL 下载 JAR 文件并将其添加到 providers 目录。
FROM quay.io/keycloak/keycloak:{containerlabel} as builder

...

# 将 provider JAR 文件添加到 providers 目录
ADD --chown=keycloak:keycloak --chmod=644 <MY_PROVIDER_JAR_URL> /opt/keycloak/providers/myprovider.jar

...

# Context: RUN the build command
RUN /opt/keycloak/bin/kc.sh build
```

=== 安装额外的 RPM 包

如果你尝试在一个 `FROM quay.io/keycloak/keycloak` 阶段中安装新软件，你会发现 `microdnf`、`dnf` 甚至 `rpm` 都未被安装。此外，可用的软件包也非常少，仅包含足以运行 `bash` shell 和 keycloak 本身的必要组件。这是由于安全加固措施的实施，旨在减少 keycloak 容器的攻击面。

首先，考虑是否可以通过其他方式实现你的使用场景，从而避免将新的 RPM 软件包安装到最终容器中：

* Containerfile 中的 `RUN curl` 指令可以用 `ADD` 替代，因为后者原生支持远程 URL。
* 一些常用的 CLI 工具可以通过创造性地使用 Linux 文件系统来替代。例如，`ip addr show tap0` 可以替换为 `cat /sys/class/net/tap0/address`。
* 需要 RPM 的任务可以移至镜像构建的早期阶段，并将结果复制到后续阶段中。

以下是一个示例：在前一个构建阶段中运行 update-ca-trust，然后将结果复制到后续阶段中：

```
FROM registry.access.redhat.com/ubi9 AS ubi-micro-build
COPY mycertificate.crt /etc/pki/ca-trust/source/anchors/mycertificate.crt
RUN update-ca-trust

FROM quay.io/keycloak/keycloak
COPY --from=ubi-micro-build /etc/pki /etc/pki
```

如果确实需要安装新的 RPM 软件包，可以按照 ubi-micro 所定义的这种两阶段模式来进行安装：

```
FROM registry.access.redhat.com/ubi9 AS ubi-micro-build
RUN mkdir -p /mnt/rootfs
RUN dnf install --installroot /mnt/rootfs <package names go here> --releasever 9 --setopt install_weak_deps=false --nodocs -y && \
dnf --installroot /mnt/rootfs clean all && \
rpm --root /mnt/rootfs -e --nodeps setup

FROM quay.io/keycloak/keycloak
COPY --from=ubi-micro-build /mnt/rootfs /
```

这种方法使用了一个 chroot 环境 `/mnt/rootfs`，确保仅安装你指定的软件包及其依赖项，从而可以轻松地将它们复制到第二个阶段，而无需进行猜测。

警告：某些软件包具有庞大的依赖树。安装新的 RPM 软件包可能会无意中扩大容器的攻击面，请仔细检查已安装的软件包列表。

### 构建容器镜像
要构建实际的容器镜像，请在包含 Containerfile 的目录中运行以下命令：

```
podman|docker build . -t mykeycloak
```

注意事项：
====
Podman 仅用于创建或定制镜像：如果你使用的是 Red Hat 产品环境（如 OpenShift），需要注意 Podman 不支持在生产环境中运行 keycloak 容器。
====
通过执行此步骤，你将获得一个优化后的、适合快速启动的容器镜像。构建完成后，你可以使用 docker 或 podman 来运行这个镜像。

### 启动优化后的 keycloak 容器镜像
要启动该镜像，请运行以下命令：

```
podman|docker run --name mykeycloak -p 8443:8443 -p 9000:9000 \
-e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=change_me \
mykeycloak \
start --optimized --hostname=localhost
```

keycloak 以生产模式启动，仅使用安全的 HTTPS 通信，并可通过 https://localhost:8443 访问。

健康检查端点可通过以下地址访问：
* https://localhost:9000/health
* https://localhost:9000/health/ready
* https://localhost:9000/health/live
打开 https://localhost:9000/metrics 将显示操作指标页面，这些指标可被你的监控系统使用。

### 与 Docker 相关的已知问题

本节列出了在使用 Docker 运行 keycloak 容器时可能出现的问题及相应的解决方案或缓解措施。

* 如果 RUN dnf install 命令执行时间过长，则很可能是你的 Docker systemd 服务中的文件限制设置 `LimitNOFILE` 配置不正确。 你可以选择以下任一方式解决该问题：
 - 更新 Docker 服务配置，将 `LimitNOFILE` 设置为一个更大的值（例如 1024000）；
 - 或者在 RUN 命令中直接使用 `ulimit`

例如：
```
...
RUN ulimit -n 1024000 && dnf install --installroot ...
...
```

* 如果你在构建中包含了 `provider` 的 JAR 文件，而容器在运行 `start --optimized` 时失败，并提示某个 `provider JAR` 已被修改，这通常是由于 Docker 截断了文件时间戳（mtime）， 或者以其他方式修改了文件的修改时间戳——与 `build` 命令记录的时间不一致。
在这种情况下，你需要在运行 `build` 命令之前，使用 `touch` 命令强制为这些 JAR 文件设置一个统一的已知时间戳。例如：

```
...
# ADD or copy one or more provider jars
ADD --chown=keycloak:keycloak --chmod=644 some-jar.jar /opt/keycloak/providers/
...
RUN touch -m --date=@1743465600 /opt/keycloak/providers/*
RUN /opt/keycloak/bin/kc.sh build
...
```

## 将容器暴露到不同的端口

默认情况下，服务器分别通过 `8080` 端口监听 `http` 请求，通过 `8443` 端口监听 `https` 请求。

如果你想通过不同的端口暴露容器，你需要相应地设置 `hostname` 参数：

. 使用非默认端口暴露容器

```
podman|docker run --name mykeycloak -p 3000:8443 \
-e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=change_me \
mykeycloak \
start --optimized --hostname=https://localhost:3000
```

通过将 `hostname` 选项设置为完整的 URL，你现在可以通过 `https://localhost:3000` 访问服务器。

## 在开发模式下使用 Keycloak
对于开发或测试目的，从容器中尝试 Keycloak 的最简单方法是使用开发模式。 你使用 start-dev 命令：

```
podman|docker run --name mykeycloak -p 8080:8080 \
-e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=change_me \
quay.io/keycloak/keycloak:{containerlabel} \
start-dev
```

执行此命令将在开发模式下启动 Keycloak 服务器。

由于此模式使用不安全的默认设置，绝不应在生产环境中使用。 有关在生产环境中运行 Keycloak 的更多信息，请参见 <@links.server id="configuration-production"/>。

## 运行一个标准的 Keycloak 容器
遵循诸如不可变基础设施（`immutable infrastructure`）等概念，容器需要定期重新配置（`re-provisioned`）。

在这些环境中，你需要能够快速启动的容器，因此你需要按照前一节所述创建一个优化后的镜像。 但是，如果你的环境有不同的需求，你可以直接运行 start 命令来启动一个标准的 Keycloak 镜像。 例如：

```
podman|docker run --name mykeycloak -p 8080:8080 \
-e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=change_me \
quay.io/keycloak/keycloak:{containerlabel} \
start \
--db=postgres --features=token-exchange \
--db-url=<JDBC-URL> --db-username=<DB-USER> --db-password=<DB-PASSWORD> \
--https-key-store-file=<file> --https-key-store-password=<password>
```

运行此命令将启动 Keycloak 服务器，首先检测并应用构建选项。 
在示例中，`--db=postgres --features=token-exchange` 这行代码将数据库供应商设置为 PostgreSQL，并启用了令牌交换功能。

Keycloak 随后启动并应用针对特定环境的配置。 这种方法显著增加了启动时间，并且生成的镜像是可变的，这并非最佳实践。

## 在容器中运行时提供初始管理员凭据

Keycloak 仅允许通过本地网络连接创建初始管理员用户。而在容器中运行时情况不同，因此在运行镜像时，你需要提供以下环境变量：

```
# setting the admin username
-e KC_BOOTSTRAP_ADMIN_USERNAME=<admin-user-name>

# setting the initial password
-e KC_BOOTSTRAP_ADMIN_PASSWORD=change_me
```

## 在启动时导入领域（Realm）

Keycloak 容器中包含一个目录 `/opt/keycloak/data/import`。如果你通过卷挂载或其他方式将一个或多个导入文件放入该目录，并在启动时添加参数 `--import-realm`，那么 Keycloak 容器将在启动时自动导入这些数据！此功能仅建议在开发（Dev）模式下使用。

```
podman|docker run --name keycloak_unoptimized -p 8080:8080 \
-e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=change_me \
-v /path/to/realm/data:/opt/keycloak/data/import \
quay.io/keycloak/keycloak:{containerlabel} \
start-dev --import-realm
```

欢迎加入开放的 https://github.com/keycloak/keycloak/discussions/8549 [ GitHub 讨论] 共同探讨关于管理员引导流程（admin bootstrapping）的改进。

## 指定不同的内存设置

Keycloak 容器并未采用硬编码方式指定初始和最大堆内存值，而是根据容器的总内存大小按比例设置堆内存。 该行为通过 JVM 选项 `-XX:MaxRAMPercentage=70` 和 `-XX:InitialRAMPercentage=50` 实现。

* `-XX:MaxRAMPercentage` 选项表示最大堆内存为容器总内存的 70%。 
* `-XX:InitialRAMPercentage` 选项表示初始堆内存为容器总内存的 50%。
  这些值是通过对 Keycloak 内存管理的深入分析后选定的。

由于堆内存大小是根据容器总内存动态计算的，因此你应始终为容器*设置内存限制*。

过去，最大堆内存被设定为 512 MB，为了接近相同的值，你需要将容器的内存限制至少设置为 750 MB。 对于较小的生产环境部署，推荐的内存限制为 2 GB。

与堆内存相关的 JVM 选项可以通过设置环境变量 `JAVA_OPTS_KC_HEAP` 来覆盖。 你可以在 `kc.sh` 或 `kc.bat` 脚本的源代码中找到 `JAVA_OPTS_KC_HEAP` 的默认值。

例如，你可以按以下方式指定环境变量和内存限制：

```
podman|docker run --name mykeycloak -p 8080:8080 -m 1g \
-e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=change_me \
-e JAVA_OPTS_KC_HEAP="-XX:MaxHeapFreeRatio=30 -XX:MaxRAMPercentage=65" \
quay.io/keycloak/keycloak:{containerlabel} \
start-dev
```

警告：如果未设置内存限制，随着堆内存增长至容器总内存的 70%，内存消耗会迅速增加。 一旦 JVM 分配了内存，在当前 Keycloak 的垃圾回收（GC）设置下，内存将难以及时释放回操作系统。

