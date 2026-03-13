FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Apache, güncel PHP 8.3, Python 3 ve Veritabanı istemcilerini kuruyoruz
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php -y && \
    apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    nano \
    python3 \
    python3-pip \
    python3-venv \
    apache2 \
    libapache2-mod-php8.3 \
    php8.3 \
    php8.3-cli \
    php8.3-mysql \
    php8.3-pgsql \
    php8.3-pdo \
    php8.3-curl \
    php8.3-xml \
    postgresql-client \
    mysql-client \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# SFTP ve Kullanıcı Ayarları
RUN mkdir /var/run/sshd
RUN useradd -rm -d /home/mahmut -s /bin/bash -g root -G sudo mahmut
RUN echo 'mahmut:openclaw2026' | chpasswd

# Apache ayarları: Varsayılan klasörü /var/www/html yerine /app yapıyoruz
RUN sed -i 's|/var/www/html|/app|g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's|<Directory /var/www/>|<Directory /app/>|g' /etc/apache2/apache2.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Apache ayarları: ServerName ekleyerek AH00558 uyarısını susturuyoruz
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN sed -i 's|/var/www/html|/app|g' /etc/apache2/sites-available/000-default.conf
RUN sed -i 's|<Directory /var/www/>|<Directory /app/>|g' /etc/apache2/apache2.conf

# Çalışma dizini
WORKDIR /app

# Supervisord ayar dosyasını kopyalıyoruz
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 22(SFTP), 80(Apache Web), 8000(OpenClaw)
EXPOSE 22 80 8000

CMD ["/usr/bin/supervisord", "-n"]
