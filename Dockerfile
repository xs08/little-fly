FROM centos:latest

# 安装基础系统依赖
RUN yum update -y && \
    yum install -y wget git && \
    # v2ray 依赖
    yum install -y lrzsz git zip unzip curl wget qrencode libcap && \
    # Nginx 依赖
    yum install -y zlib zlib-devel pcre-devel openssl openssl-devel automake autoconf libtool make gcc gcc-c++

# 端口透出
EXPOSE 1320
EXPOSE 4320

# 添加系统变量。避免 COPY 阶段使用构建缓存
ENV REFRESH_DATE=2021-09-23,16:59:54

# 安装 v2ray
COPY scripts /var/v2ray-install
WORKDIR /var/v2ray-install
RUN chmod +x install.sh && ./install.sh

ENTRYPOINT ["start.sh"]

# FROM base_image:tag    # 引用基础镜像 *必要*

# ARG arg_key[=default_value1]     # 声明变量
# ENV env_key=value2     # 声明环境变量

# # 构建几乎不变的部分，例如整体的目录结构，build 时依赖的文件和工具包等
# COPY src dst
# RUN command1 && command2 ...

# WORKDIR /path/to/work/dir   # 设置工作目录 

# # 构建较少变动的部分，例如应用的依赖的文件、依赖的包等
# COPY src dst
# RUN command3 && command4 ...

# # 构建经常变动的部分，例如应用的编译生成
# COPY src dst
# RUN command5 && command6 ...

# # 容器入口  *必要*
# ENTRYPOINT ["/entry.app"]  # 指定容器启动时默认执行的命令
# CMD ["--options"] # 指定容器启动时默认命令的默认参数