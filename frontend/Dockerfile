FROM caddy:latest

WORKDIR /frontend

COPY Caddyfile /etc/caddy/Caddyfile

COPY build/web .

EXPOSE 80

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
