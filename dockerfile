# Используем официальный образ Python версии 3.9
FROM python:3.11

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем зависимости проекта
COPY requirements.txt .

# Устанавливаем зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Копируем исходный код проекта в контейнер
COPY . .

# Запускаем приложение
CMD [ "python", "-V" ]