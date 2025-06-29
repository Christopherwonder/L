# Filename: CONFIGURATION_VARS.md

# laundr.me Configuration Variables

This document lists all the environment variables required to run the `laundr.me` application stack. After running the generation scripts, a `.env` file will be created in the project root. You must populate this file with the values described below.

---

### **Backend & Database Configuration (for Docker Compose & Flask)**

These variables are used by Docker Compose to set up the services and are also read by the Flask backend application.

-   **`FLASK_APP`**
    -   Description: The entry point of the Flask application.
    -   Required Value: `run.py`

-   **`FLASK_ENV`**
    -   Description: The environment for Flask. Use `development` for debugging features or `production` for optimized settings.
    -   Example Value: `development`

-   **`SECRET_KEY`**
    -   Description: A secret, random string used by Flask for securely signing session cookies and other security-related needs.
    -   How to Generate: Run `python -c 'import secrets; print(secrets.token_hex(24))'` in your terminal.
    -   Example Value: `your_super_secret_random_string_here`

-   **`DATABASE_URL`**
    -   Description: The full connection URI for the PostgreSQL database. The code and Docker Compose are configured to use the variables below to construct this.
    -   Example Value: `postgresql://laundr_user:your_strong_password@db:5432/laundr_db`

-   **`POSTGRES_USER`**
    -   Description: The username for the PostgreSQL database.
    -   Example Value: `laundr_user`

-   **`POSTGRES_PASSWORD`**
    -   Description: The password for the PostgreSQL user. **Use a strong, unique password.**
    -   Example Value: `your_strong_password`

-   **`POSTGRES_DB`**
    -   Description: The name of the PostgreSQL database.
    -   Example Value: `laundr_db`

-   **`REDIS_URL`**
    -   Description: The connection URL for the Redis instance, used for caching and other services.
    -   Example Value: `redis://redis:6379/0`

-   **`JWT_SECRET_KEY`**
    -   Description: A secret, random string used specifically for signing and verifying JSON Web Tokens (JWTs) for API authentication.
    -   How to Generate: Run `python -c 'import secrets; print(secrets.token_hex(24))'` in your terminal.
    -   Example Value: `another_very_secret_jwt_string`

---

### **Third-Party Service Configuration**

-   **`ASTRA_API_KEY`**
    -   Description: Your API Key for the Astra Financial API.
    -   Where to find: From your Astra Developer Dashboard.
    -   Example Value: `astra_api_key_xxxxxxxx`

-   **`ASTRA_API_SECRET`**
    -   Description: Your API Secret for the Astra Financial API.
    -   Where to find: From your Astra Developer Dashboard.
    * Example Value: `astra_api_secret_xxxxxxxx`

-   **`ASTRA_WEBHOOK_SECRET`**
    -   Description: The secret used to verify webhooks coming from Astra.
    -   Where to find: From your Astra Developer Dashboard when configuring webhooks.
    * Example Value: `astra_webhook_secret_xxxxxxxx`

---

### **Frontend Configuration (for React Native)**

These variables are used by the React Native application. The `REACT_NATIVE_` prefix is not required due to the setup in `babel.config.js`.

-   **`API_BASE_URL`**
    -   Description: The base URL for the backend API that the mobile app will connect to. When running in Codespaces with a forwarded port (e.g., 5000), this will be a specific URL.
    -   Example Value (for Codespaces): `https://your-codespace-name-5000.preview.app.github.dev`
