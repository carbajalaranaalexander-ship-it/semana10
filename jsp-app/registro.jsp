<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.regex.Pattern" %>

<%!
    /**
     * Función utilitaria para sanitizar cadenas contra XSS.
     * Reemplaza caracteres especiales HTML por sus entidades seguras.
     */
    public String escapeHtml(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;")
                    .replace("/", "&#x2F;");
    }

    /**
     * Valida el formato de un correo electrónico mediante una expresión regular estándar.
     */
    public boolean isValidEmail(String email) {
        if (email == null) {
            return false;
        }
        String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
        Pattern pat = Pattern.compile(emailRegex);
        return pat.matcher(email).matches();
    }
%>

<%
    // 1. Controlar el método HTTP de la petición
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED); // 405
        request.setAttribute("errorTitle", "405 - Método No Permitido");
        request.setAttribute("errorMessage", "El recurso solicitado solo puede ser accedido a través de peticiones HTTP POST.");
        request.getRequestDispatcher("error.jsp").forward(request, response);
        return;
    }

    // 2. Obtener y limpiar parámetros de entrada
    String rawNombre = request.getParameter("nombre");
    String rawCorreo = request.getParameter("correo");
    
    String nombreClean = (rawNombre != null) ? rawNombre.trim() : "";
    String correoClean = (rawCorreo != null) ? rawCorreo.trim() : "";

    // 3. Validar los datos de entrada
    if (nombreClean.length() < 2 || !isValidEmail(correoClean)) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 400
        request.setAttribute("errorTitle", "400 - Datos Inválidos");
        request.setAttribute("errorMessage", "El nombre ingresado es muy corto o el correo electrónico no cumple con un formato válido. Inténtelo de nuevo.");
        request.getRequestDispatcher("error.jsp").forward(request, response);
        return;
    }

    // 4. Sanitizar variables antes de almacenarlas/renderizarlas (Prevención de XSS)
    String nombreSanitizado = escapeHtml(nombreClean);
    String correoSanitizado = escapeHtml(correoClean);

    // 5. Inicializar o recuperar la lista de registros guardada en la sesión
    HttpSession sesion = request.getSession(true);
    List<Map<String, String>> registros = (List<Map<String, String>>) sesion.getAttribute("registros");
    
    if (registros == null) {
        registros = new ArrayList<Map<String, String>>();
    }

    // 6. Obtener fecha y hora actual formateada
    SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
    String fechaRegistro = sdf.format(new Date());

    // 7. Crear el nuevo registro y agregarlo a la lista
    Map<String, String> nuevoRegistro = new HashMap<String, String>();
    nuevoRegistro.put("nombre", nombreSanitizado);
    nuevoRegistro.put("correo", correoSanitizado);
    nuevoRegistro.put("fecha", fechaRegistro);
    registros.add(nuevoRegistro);

    // 8. Actualizar la lista en la sesión
    sesion.setAttribute("registros", registros);
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lab 09 | Registro Exitoso (JSP)</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="container">
        <div class="alert alert-success">
            <strong>✓ Registro Completado:</strong> El contacto se ha almacenado exitosamente en la sesión de Java (Tomcat).
        </div>

        <h2>Registros Almacenados</h2>
        <p class="subtitle">Lista actual de registros en HttpSession (JSP)</p>

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
                    <% 
                        int index = 1;
                        for (Map<String, String> reg : registros) {
                    %>
                            <tr>
                                <td><%= index++ %></td>
                                <td><%= reg.get("nombre") %></td>
                                <td><%= reg.get("correo") %></td>
                                <td><%= reg.get("fecha") %></td>
                            </tr>
                    <% 
                        } 
                    %>
                </tbody>
            </table>
        </div>

        <a href="index.jsp" class="btn btn-secondary">← Registrar otro contacto</a>
    </div>
</body>
</html>
