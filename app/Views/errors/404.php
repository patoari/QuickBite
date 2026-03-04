<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Page Not Found | QuickBite</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); height: 100vh; display: flex; align-items: center; justify-content: center; }
        .error-container { text-align: center; color: white; }
        .error-code { font-size: 120px; font-weight: bold; margin-bottom: 20px; }
        .error-message { font-size: 24px; margin-bottom: 30px; }
        .error-description { font-size: 16px; margin-bottom: 40px; opacity: 0.9; }
        .btn-home { display: inline-block; padding: 12px 30px; background: white; color: #667eea; text-decoration: none; border-radius: 5px; font-weight: bold; transition: transform 0.3s; }
        .btn-home:hover { transform: translateY(-2px); }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-code">404</div>
        <div class="error-message">Page Not Found</div>
        <div class="error-description">The page you are looking for doesn't exist or has been moved.</div>
        <a href="<?= BASE_URL ?>" class="btn-home">Go to Homepage</a>
    </div>
</body>
</html>
