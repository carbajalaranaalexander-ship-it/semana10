<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Obtener los atributos oficiales de Tomcat en caso de redirección automática por error 4xx/5xx
    Integer statusCode = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
    if (statusCode == null) {
        statusCode = (Integer) request.getAttribute("javax.servlet.error.status_code");
    }
    
    // Obtener atributos manuales pasados por request.setAttribute()
    String errorTitle = (String) request.getAttribute("errorTitle");
    String errorMessage = (String) request.getAttribute("errorMessage");

    // Lógica dinámica para rellenar campos en caso de captura automática por Tomcat
    if (errorTitle == null) {
        if (statusCode != null) {
            errorTitle = "Error " + statusCode;
        } else {
            errorTitle = "Error Desconocido";
        }
    }
    
    if (errorMessage == null) {
        if (statusCode != null) {
            switch (statusCode) {
                case 400:
                    errorMessage = "La petición enviada contiene datos inválidos o mal estructurados.";
                    break;
                case 404:
                    errorMessage = "El recurso solicitado no existe en esta aplicación web (Tomcat).";
                    break;
                case 405:
                    errorMessage = "El método HTTP utilizado no está permitido para este recurso (se requiere POST).";
                    break;
                case 500:
                    errorMessage = "Se produjo un error interno (500) en el servidor al procesar el código Java.";
                    break;
                default:
                    errorMessage = "Ocurrió una anomalía de red o de configuración del servidor. Código de estado: " + statusCode;
                    break;
            }
        } else {
            errorMessage = "Ocurrió un error inesperado al procesar su solicitud.";
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error | <%= errorTitle %></title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container" style="max-width: 500px;">
        <div class="alert alert-error">
            <strong>⚠ Error:</strong> <%= errorTitle %>
        </div>
        <p style="color: var(--text-secondary); margin-bottom: 1.5rem;"><%= errorMessage %></p>
        <a href="index.jsp" class="btn btn-secondary">← Volver al Formulario</a>
    </div>
</body>
</html>
