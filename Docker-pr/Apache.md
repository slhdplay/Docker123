# Запуск веб-сервера Apache в Docker

## 1. Скачивание образа
Перед запуском контейнера необходимо скачать официальный образ Apache (httpd).  
Выполняем команду:
```bash
docker pull httpd

![Запуск](https://raw.githubusercontent.com/s1hdplay/Docker123/main/Docker-pr/pull.png)
2. Запуск контейнера

Запускаем контейнер в фоновом режиме, пробрасывая порт 8080 хоста на порт 80 контейнера:
bash

docker run -d -p 8080:80 --name my-apache-app httpd

https://run.png
3. Проверка запущенных контейнеров

Убеждаемся, что контейнер работает:
bash

docker ps

https://ps.png
4. Проверка работы веб-сервера

Открываем браузер и переходим по адресу http://localhost:8080.
Видим стандартную страницу Apache:
https://browser.png
