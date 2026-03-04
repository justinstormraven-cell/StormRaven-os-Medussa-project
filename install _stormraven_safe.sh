install_stormraven_safe
name: StormRaven Leviathan Security Build Pipeline


on:
  push:
    branches: [ "main", "develop" ]
  pull_request:
    branches: [ "main" ]

jobs:
  security-audit:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source Code
        uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      # 1. SAST (Static Application Security Testing) for Python
      - name: Install Bandit
        run: pip install bandit
      - name: Run Bandit Security Linting
        run: bandit -r . -f custom -ll

      # 2. Dependency Vulnerability Scanning
      - name: Install Safety
        run: pip install safety
      - name: Check Python Dependencies for Known CVEs
        run: safety check -r requirements.txt

  container-security:
    needs: security-audit
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Source Code
        uses: actions/checkout@v3

      - name: Build Docker Image
        run: docker build -t stormraven/leviathan:test .

      # 3. Container Vulnerability Scanning via Trivy
      - name: Run Trivy Vulnerability Scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'stormraven/leviathan:test'
          format: 'table'
          exit-code: '1'
          ignore-unfixed: true
          vuln-type: 'os,library'
          severity: 'CRITICAL,HIGH'
