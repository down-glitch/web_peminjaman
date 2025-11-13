# Gunakan image PHP versi 8.2 dengan FPM
FROM php:8.2-fpm

# Set direktori kerja di dalam container
WORKDIR /var/www/html

# Install dependensi sistem yang dibutuhkan untuk ekstensi PHP
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip

# Install ekstensi PHP yang dibutuhkan oleh Laravel dan dependensi Anda
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd xml zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Salin file composer terlebih dahulu untuk memanfaatkan Docker cache
COPY composer.json composer.lock ./

# Install dependensi PHP (tanpa dev dependencies)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Salin semua file dari proyek ke dalam container
COPY . .

# --- BAGIAN KRUSIAL UNTUK MEMPERBAIKI IZIN ---
# Berikan kepemilikan folder ke user www-data
RUN chown -R www-data:www-data /var/www/html

# Berikan izin write ke folder storage dan cache
RUN chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Pindah ke user www-data untuk menjalankan aplikasi
USER www-data

# --- BARIS INI SUDAH DIHAPUS ---
# RUN php artisan key:generate --force

# Expose port 8000 (port yang akan digunakan Railway)
EXPOSE 8000

# Perintah untuk menjalankan server Laravel
CMD php artisan serve --host=0.0.0.0 --port=8000