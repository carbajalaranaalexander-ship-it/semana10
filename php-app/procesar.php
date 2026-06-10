<?php
/**
 * Procesamiento del Formulario de Contacto - PHP
 * Semana 09 - Desarrollo de Aplicaciones Web
 * 
 * Este script valida, sanitiza y almacena en sesión los datos enviados 
 * mediante el método POST, devolviendo una vista detallada con el historial.
 */

// 1. Iniciar o reanudar la sesión del usuario
session_start();

// 2. Controlar la seguridad de la petición: solo permitir método POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    render_error_page('405 - Método No Permitido', 'El recurso solicitado solo puede ser accedido a través de peticiones HTTP POST.');
    exit;
}

// 3. Obtener y sanitizar inputs de forma segura
// Usamos filter_input para limpiar/validar
$raw_nombre = isset($_POST['nombre']) ? trim($_POST['nombre']) : '';
$raw_correo = isset($_POST['correo']) ? trim($_POST['correo']) : '';

// Sanitizar nombre para prevenir XSS en base de datos/sesión
$nombre = htmlspecialchars($raw_nombre, ENT_QUOTES, 'UTF-8');

// Validar correo
$correo = filter_var($raw_correo, FILTER_VALIDATE_EMAIL);

// 4. Validar que la información obligatoria sea correcta
if (empty($nombre) || strlen($nombre) < 2 || !$correo) {
    http_response_code(400);
    render_error_page('400 - Datos Inválidos', 'El nombre ingresado es muy corto o el formato del correo electrónico es inválido. Por favor, intente de nuevo.');
    exit;
}

// 5. Inicializar el almacén de registros en la sesión si no existe
if (!isset($_SESSION['registros'])) {
    $_SESSION['registros'] = [];
}

// 6. Almacenar el nuevo registro en la sesión
$_SESSION['registros'][] = [
    'nombre' => $nombre,
    'correo' => $correo,
    'fecha'  => date('d-m-Y H:i:s')
];

// 7. Renderizar la página de éxito y la tabla
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lab 09 | Registro Exitoso</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <div class="alert alert-success">
            <strong>✓ Registro Completado:</strong> El contacto se ha almacenado exitosamente en la sesión.
        </div>

        <h2>Registros Almacenados</h2>
        <p class="subtitle">Lista actual de registros en $_SESSION (PHP)</p>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Nombre</th>
                        <th>Correo Electrónico</th>
                        <th>Fecha Registro</th>
                    </tr>
                </thead>
                <tbody>
                    <?php 
                    $index = 1;
                    foreach ($_SESSION['registros'] as $registro): 
                    ?>
                        <tr>
                            <td><?php echo $index++; ?></td>
                            <td><?php echo htmlspecialchars($registro['nombre'], ENT_QUOTES, 'UTF-8'); ?></td>
                            <td><?php echo htmlspecialchars($registro['correo'], ENT_QUOTES, 'UTF-8'); ?></td>
                            <td><?php echo htmlspecialchars($registro['fecha'], ENT_QUOTES, 'UTF-8'); ?></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>

        <a href="index.html" class="btn btn-secondary">← Registrar otro contacto</a>
    </div>
</body>
</html>

<?php
/**
 * Función auxiliar para renderizar una página elegante de error.
 */
function render_error_page($title, $message) {
    ?>
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Error | <?php echo htmlspecialchars($title); ?></title>
        <link rel="stylesheet" href="css/style.css">
    </head>
    <body>
        <div class="container" style="max-width: 500px;">
            <div class="alert alert-error">
                <strong>⚠ Error:</strong> <?php echo htmlspecialchars($title); ?>
            </div>
            <p style="color: var(--text-secondary); margin-bottom: 1.5rem;"><?php echo htmlspecialchars($message); ?></p>
            <a href="index.html" class="btn btn-secondary">← Volver al Formulario</a>
        </div>
    </body>
    </html>
    <?php
}
?>
