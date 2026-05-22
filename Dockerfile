# ============================================================
#  Ibiza Mi Vida CMS — Dockerfile
#  Serves the single-file CMS via nginx (ultra-lightweight)
# ============================================================

FROM nginx:1.25-alpine

LABEL maintainer="Viesa Automations <tom@viesa.nl>"
LABEL description="Ibiza Mi Vida CMS"

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy CMS file
COPY ibiza-cms.html /usr/share/nginx/html/index.html

# Copy any static assets if present
COPY assets/ /usr/share/nginx/html/assets/ 2>/dev/null || true

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80 || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
