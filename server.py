# Hotel Hermes - External Backend Entrypoint
# File: server.py
# Description: Root entrypoint bridging execution to server/server.py.

import os
import sys

# Add server directory to path
server_dir = os.path.join(os.path.dirname(__file__), "server")
if server_dir not in sys.path:
    sys.path.insert(0, server_dir)

from server import app, API_SECRET, mock_db

if __name__ == '__main__':
    print("Hotel Hermes Server running on port 5000...")
    app.run(host='0.0.0.0', port=5000, debug=False)