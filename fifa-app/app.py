from flask import Flask, render_template_string
from flask_httpauth import HTTPBasicAuth

app = Flask(__name__)
auth = HTTPBasicAuth()

# --- SEGURIDAD ---
USER_DATA = {
    "alumno": "unir2026"
}

@auth.verify_password
def verify_password(username, password):
    if username in USER_DATA and USER_DATA[username] == password:
        return username

# --- DISEÑO FIFA 2026 ---
HTML_TEMPLATE = '''
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>FIFA World Cup 2026</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            background-color: #02052b; /* Azul FIFA */
            font-family: 'Arial Black', sans-serif;
            color: white;
            text-align: center;
        }

        .welcome {
            font-size: 1.2rem;
            letter-spacing: 4px;
            margin-bottom: 10px;
            text-transform: uppercase;
            color: #00ff88; /* Verde Neón */
        }

        h1 {
            font-size: 4.5rem;
            margin: 0;
            line-height: 1;
            background: linear-gradient(to right, #00ff88, #ff0055, #00d4ff);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-transform: uppercase;
        }

        .year {
            font-size: 6rem;
            display: block;
            color: #ffffff;
            margin-top: -10px;
        }
    </style>
</head>
<body>
    <div class="welcome">BIENVENIDO AL TORNEO MÁS GRANDE DEL MUNDO</div>
    <h1>FIFA WORLD CUP</h1>
    <span class="year">2026</span>
</body>
</html>
'''

@app.route('/')
@auth.login_required
def index():
    return render_template_string(HTML_TEMPLATE)

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000)