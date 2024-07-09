FROM instrumentisto/flutter:3.22.2 AS build

WORKDIR /app

COPY . .

# Build the image
RUN flutter pub get
RUN flutter build web

FROM arm64v8/nginx:latest as production
COPY --from=build /app/build/web/ /usr/share/nginx/html/