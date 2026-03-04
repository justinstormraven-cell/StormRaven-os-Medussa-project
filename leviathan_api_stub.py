# Use an official, minimal, and secure base image
FROM python:3.11-slim-bullseye AS builder

# Set environment variables for Python security and optimization
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Create a non-root system user and group (Aligning with your 'leviathan' user concept)
RUN addgroup --system leviathan && adduser --system --ingroup leviathan leviathan

WORKDIR /build

# Install dependencies securely
COPY requirements.txt .
RUN pip install --user --requirement requirements.txt

# ----------------------------------------------------------------------
# Final Stage: Keep the runtime environment as small and secure as possible
# ----------------------------------------------------------------------
FROM python:3.11-slim-bullseye

# Re-create the non-root user in the final image
RUN addgroup --system leviathan && adduser --system --ingroup leviathan leviathan

# Copy application files and installed dependencies from builder
COPY --from=builder /root/.local /home/leviathan/.local
COPY . /app

# Ensure correct permissions
RUN chown -R leviathan:leviathan /app /home/leviathan

# Update PATH to include local pip binaries
ENV PATH=/home/leviathan/.local/bin:$PATH
ENV PYTHONPATH=/app

# Switch to the non-root user
USER leviathan

WORKDIR /app

# Run the primary orchestrator (Odin/Leviathan)
CMD ["python", "leviathan.py"]
