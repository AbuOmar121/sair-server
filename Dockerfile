FROM dart:stable AS build

WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

COPY . .

RUN dart pub global activate dart_frog_cli
RUN dart_frog build
RUN dart compile exe build/bin/server.dart -o server


FROM debian:stable-slim

WORKDIR /app

COPY --from=build /app/server ./server
COPY --from=build /app/openapi.yaml ./openapi.yaml
COPY --from=build /app/data ./data

EXPOSE 8080

CMD ["./server"]