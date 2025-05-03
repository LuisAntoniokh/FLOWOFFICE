import processing.video.*;
import java.io.BufferedReader;
import java.io.InputStreamReader;

Button[] botones;
Button btnTomarFoto, btnSubirFoto, btnRegresar, btnCapturar, btnSubir, btnRegresarTomarFoto, btnRegresarSubirFoto;
Button btnRegresarWorkspace, btnRegresarEstadoOficina, btnRegresarUsoWorkspace; // Botones de regresar
int pantalla = 0; // 0 = menú, 1 = reconocimiento facial, 2 = cámara, 3 = vista previa, 4 = workspace tiempo real, 5 = estado oficina, 6 = uso workspace
Capture cam;
PImage ultimaFoto, imagenSeleccionada;
String ultimaRuta, rutaSeleccionada;

boolean computadoraRenéOcupada = false;
boolean computadoraPabloOcupada = true;

// Variables para el estado de los dispositivos
boolean ventilacionOn = false;
boolean iluminacionOn = false;
boolean workspacePabloOn = true;
boolean workspaceReneOn = false;

float animacionVentilacion = 0;
float animacionIluminacion = 0;
float animacionWorkspacePablo = 0;
float animacionWorkspaceRene = 0;

// Imágenes para los iconos
PImage iconoVentilacion, iconoIluminacion, iconoWorkspace;

// Variables para datos de uso del workspace
String periodoUso = "Mayo 1 - Mayo 2, 2025";
int horasRene = 14;
int minutosRene = 35;
int horasPablo = 12;
int minutosPablo = 50;
float porcentajeRene = 0.65; // 65% de uso
float porcentajePablo = 0.78; // 78% de uso
color colorRene = color(100, 150, 255);
color colorPablo = color(255, 100, 150);
float anguloAnimacion = 0;

void setup() {
  size(800, 600);
  textFont(createFont("Arial", 20));

  // Cargar iconos (asegúrate de tener estos archivos en la carpeta "data" de tu sketch)
  iconoVentilacion = loadImage("ventilacion.png");
  iconoIluminacion = loadImage("iluminacion.png");
  iconoWorkspace = loadImage("workspace.png");
  
  // Si no tienes los iconos, crea placeholders para que el código funcione
  if (iconoVentilacion == null) iconoVentilacion = createIconPlaceholder(color(100, 200, 255));
  if (iconoIluminacion == null) iconoIluminacion = createIconPlaceholder(color(255, 255, 100));
  if (iconoWorkspace == null) iconoWorkspace = createIconPlaceholder(color(100, 255, 150));

  // Menú principal
  botones = new Button[4]; // Eliminado el botón adicional
  botones[0] = new Button("Ocupación Computadoras", 250, 150, 300, 50, color(100, 150, 255));
  botones[1] = new Button("Entrada a Oficina", 250, 230, 300, 50, color(100, 255, 150));
  botones[2] = new Button("Estado Oficina", 250, 310, 300, 50, color(255, 200, 100));
  botones[3] = new Button("Uso Workspace", 250, 390, 300, 50, color(255, 100, 150));

  // Reconocimiento facial
  btnTomarFoto = new Button("Tomar Foto", 250, 200, 300, 50, color(150, 150, 255));
  btnSubirFoto = new Button("Subir Foto", 250, 280, 300, 50, color(150, 255, 200));
  btnRegresar  = new Button("Regresar", 250, 360, 300, 50, color(200, 200, 200));

  // Botones cámara y vista previa
  btnCapturar = new Button("Capturar", 400, 520, 200, 40, color(255, 100, 100));
  btnSubir    = new Button("Subir", 400, 520, 200, 40, color(100, 200, 255));

  // Nuevos botones de regresar
  btnRegresarTomarFoto = new Button("Regresar", 100, 520, 200, 40, color(200, 200, 200));
  btnRegresarSubirFoto = new Button("Regresar", 100, 520, 200, 40, color(200, 200, 200));
  
  // Botones de regresar desde Workspace y Estado Oficina
  btnRegresarWorkspace = new Button("Regresar al Menú", 300, 500, 200, 50, color(200, 200, 200));
  btnRegresarEstadoOficina = new Button("Regresar al Menú", 300, 520, 200, 50, color(200, 200, 200));
  btnRegresarUsoWorkspace = new Button("Regresar al Menú", 300, 520, 200, 50, color(200, 200, 200));
}

void draw() {
  background(240);

  if (pantalla == 0) {
    fill(0);
    textSize(32);
    textAlign(CENTER);
    text("Menú Principal", width / 2, 60);

    for (Button b : botones) {
      b.display();
    }
  } 
  else if (pantalla == 1) {
    fill(0);
    textSize(32);
    textAlign(CENTER);
    text("Reconocimiento Facial", width / 2, 100);

    btnTomarFoto.display();
    btnSubirFoto.display();
    btnRegresar.display();
  } 
  else if (pantalla == 2) {
    if (cam != null && cam.available()) {
      cam.read();
    }
    if (cam != null) {
      image(cam, 0, 0, width, height - 80);
    }

    fill(0);
    textSize(24);
    textAlign(CENTER);
    text("Vista de Cámara", width / 2, 30);

    btnCapturar.display();
    btnRegresarTomarFoto.display();  // Botón para regresar a la vista de tomar foto
  }
  else if (pantalla == 3) {
    if (ultimaFoto != null) {
      image(ultimaFoto, 0, 0, width, height - 80);
    } else if (imagenSeleccionada != null) {
      image(imagenSeleccionada, 0, 0, width, height - 80);
    }

    fill(0);
    textSize(24);
    textAlign(CENTER);
    text("Vista Previa de Captura", width / 2, 30);

    btnSubir.display();
    btnRegresarSubirFoto.display();  // Botón para regresar a la vista de subir foto
  }
  else if (pantalla == 4) { // Nueva pantalla "Workspace tiempo real"
    background(50, 100, 150);  // Color de fondo azul

    fill(255);
    textSize(32);
    textAlign(CENTER);
    text("Workspace tiempo real", width / 2, 50);

    // Computadora de René
    drawComputer(150, 150, "Computadora de René", computadoraRenéOcupada);
    // Computadora de Pablo
    drawComputer(450, 150, "Computadora de Pablo", computadoraPabloOcupada);

    btnRegresarWorkspace.display();  // Botón de regresar al menú
  }
  else if (pantalla == 5) { // Nueva pantalla "Estado Oficina"
    background(60, 80, 120);  // Color de fondo para estado oficina
    
    fill(255);
    textSize(32);
    textAlign(CENTER);
    text("Estado de la Oficina", width / 2, 60);
    
    // Actualizar valores de animación
    actualizarAnimaciones();
    
    // Mostrar los 4 estados con sus animaciones
    // Ventilación
    mostrarEstadoDispositivo(150, 150, "Ventilación", ventilacionOn, animacionVentilacion, iconoVentilacion);
    
    // Iluminación
    mostrarEstadoDispositivo(450, 150, "Iluminación", iluminacionOn, animacionIluminacion, iconoIluminacion);
    
    // Workspace Pablo
    mostrarEstadoDispositivo(150, 300, "Workspace Pablo", workspacePabloOn, animacionWorkspacePablo, iconoWorkspace);
    
    // Workspace René
    mostrarEstadoDispositivo(450, 300, "Workspace René", workspaceReneOn, animacionWorkspaceRene, iconoWorkspace);
    
    // Agregar controles para cambiar estados (opcional)
    textSize(16);
    fill(200, 200, 200);
    text("Haz clic en los paneles para cambiar el estado", width/2, 460);
    
    // Botón para regresar al menú principal
    btnRegresarEstadoOficina.display();
  }
  else if (pantalla == 6) { // Nueva pantalla "Uso Workspace"
    drawUsoWorkspace();
    
    // Botón para regresar al menú principal
    btnRegresarUsoWorkspace.display();
  }
}

void drawUsoWorkspace() {
  anguloAnimacion += 0.01; // Incrementar ángulo para animación
  if (anguloAnimacion > TWO_PI) anguloAnimacion -= TWO_PI;
  
  // Fondo con gradiente
  for (int y = 0; y < height; y++) {
    float inter = map(y, 0, height, 0, 1);
    color c = lerpColor(color(30, 40, 60), color(60, 70, 100), inter);
    stroke(c);
    line(0, y, width, y);
  }
  
  // Título principal con animación suave
  textAlign(CENTER);
  fill(255);
  textSize(36);
  float offsetY = sin(anguloAnimacion) * 5;
  text("Uso Workspace", width/2, 60 + offsetY);
  
  // Periodo de uso
  fill(200, 200, 200);
  textSize(18);
  text("(" + periodoUso + ")", width/2, 90);
  
  // Dibujar paneles de visualización
  drawWorkspacePanel("René", horasRene, minutosRene, porcentajeRene, colorRene, width/2 - 220, 150);
  drawWorkspacePanel("Pablo", horasPablo, minutosPablo, porcentajePablo, colorPablo, width/2 + 220, 150);
  
  // Línea de tiempo comparativa
  drawTimelineComparison(width/2, 380, 700);
}

void drawWorkspacePanel(String nombre, int horas, int minutos, float porcentaje, color c, float x, float y) {
  // Panel principal con efecto de profundidad
  noStroke();
  fill(20, 30, 50, 200);
  rect(x - 150, y, 300, 200, 20);
  
  // Borde brillante animado
  stroke(red(c), green(c), blue(c), 128 + 127 * sin(anguloAnimacion * 2));
  strokeWeight(3);
  noFill();
  rect(x - 150, y, 300, 200, 20);
  strokeWeight(1);
  
  // Título del workspace
  fill(255);
  textSize(24);
  textAlign(CENTER);
  text("Workspace " + nombre, x, y + 30);
  
  // Tiempo de uso
  textSize(18);
  fill(200, 200, 200);
  text("Tiempo total:", x, y + 65);
  
  // Mostrar tiempo con efecto de número digital
  fill(c);
  textSize(36);
  String tiempoTexto = nf(horas, 2) + ":" + nf(minutos, 2);
  text(tiempoTexto, x, y + 110);
  
  // Visualización del porcentaje como círculo animado
  float radio = 40;
  float grosor = 10;
  float angulo = TWO_PI * porcentaje;
  
  // Círculo de fondo
  noFill();
  stroke(100, 100, 100, 150);
  strokeWeight(grosor);
  arc(x, y + 160, radio*2, radio*2, 0, TWO_PI);
  
  // Arco de porcentaje con efecto pulsante
  float pulso = 1 + sin(anguloAnimacion * 3) * 0.1;
  stroke(c);
  strokeWeight(grosor * pulso);
  arc(x, y + 160, radio*2, radio*2, -HALF_PI, -HALF_PI + angulo);
  strokeWeight(1);
  
  // Texto del porcentaje
  fill(255);
  textSize(18);
  textAlign(CENTER, CENTER);
  text(int(porcentaje * 100) + "%", x, y + 160);
}

void drawTimelineComparison(float x, float y, float width) {
  // Título de la línea de tiempo
  fill(255);
  textSize(24);
  textAlign(CENTER);
  text("Comparativa de Uso", x, y - 20);
  
  // Línea base de tiempo (24 horas)
  stroke(150);
  strokeWeight(2);
  line(x - width/2, y, x + width/2, y);
  
  // Marcas de hora
  for (int i = 0; i <= 24; i += 4) {
    float posX = map(i, 0, 24, x - width/2, x + width/2);
    line(posX, y - 5, posX, y + 5);
    
    // Etiquetas de hora
    fill(200);
    textSize(14);
    textAlign(CENTER);
    text(i + ":00", posX, y + 20);
  }
  
  // Visualización de uso con barras animadas
  float alturaBarraRene = 30 + sin(anguloAnimacion * 2) * 5;
  float alturaBarraPablo = 30 + sin(anguloAnimacion * 2 + PI) * 5;
  
  // Barra de René
  noStroke();
  fill(colorRene, 180);
  float inicioRene = x - width/2 + width * 0.1; // Inicio en hora 2.4
  float finRene = inicioRene + width * (horasRene + minutosRene/60.0) / 24.0;
  rect(inicioRene, y - alturaBarraRene/2 - 15, finRene - inicioRene, alturaBarraRene, 10);
  
  // Barra de Pablo
  fill(colorPablo, 180);
  float inicioPablo = x - width/2 + width * 0.3; // Inicio en hora 7.2
  float finPablo = inicioPablo + width * (horasPablo + minutosPablo/60.0) / 24.0;
  rect(inicioPablo, y + 15, finPablo - inicioPablo, alturaBarraPablo, 10);
  
  // Etiquetas para cada barra
  fill(255);
  textSize(16);
  textAlign(LEFT, CENTER);
  text("René", inicioRene + 10, y - alturaBarraRene/2 - 15 + alturaBarraRene/2);
  text("Pablo", inicioPablo + 10, y + 15 + alturaBarraPablo/2);
}

void actualizarAnimaciones() {
  // Actualizar animación de ventilación
  if (ventilacionOn) {
    animacionVentilacion += 0.05;
    if (animacionVentilacion > 1) animacionVentilacion = 0;
  } else {
    animacionVentilacion = 0;
  }
  
  // Actualizar animación de iluminación
  if (iluminacionOn) {
    animacionIluminacion += 0.03;
    if (animacionIluminacion > 1) animacionIluminacion = 0;
  } else {
    animacionIluminacion = 0;
  }
  
  // Actualizar animación de workspace Pablo
  if (workspacePabloOn) {
    animacionWorkspacePablo += 0.04;
    if (animacionWorkspacePablo > 1) animacionWorkspacePablo = 0;
  } else {
    animacionWorkspacePablo = 0;
  }
  
  // Actualizar animación de workspace René
  if (workspaceReneOn) {
    animacionWorkspaceRene += 0.04;
    if (animacionWorkspaceRene > 1) animacionWorkspaceRene = 0;
  } else {
    animacionWorkspaceRene = 0;
  }
}

void mostrarEstadoDispositivo(float x, float y, String nombre, boolean encendido, float animacion, PImage icono) {
  // Dibujar panel principal
  stroke(200);
  if (encendido) {
    fill(70, 150, 70, 200);  // Verde semi-transparente para ON
  } else {
    fill(150, 70, 70, 200);  // Rojo semi-transparente para OFF
  }
  rect(x - 100, y - 60, 200, 120, 15);  // Panel redondeado
  
  // Nombre del dispositivo
  fill(255);
  textSize(18);
  textAlign(CENTER);
  text(nombre, x, y - 35);
  
  // Mostrar icono
  tint(255, encendido ? 255 : 100);  // Atenuar icono si está apagado
  image(icono, x - 30, y - 20, 60, 60);
  noTint();
  
  // Indicador de estado con animación
  String estado = encendido ? "ON" : "OFF";
  fill(encendido ? color(100, 255, 100) : color(255, 100, 100));
  textSize(20);
  text(estado, x + 60, y + 10);
  
  // Animación visual (círculos pulsantes para ON)
  if (encendido) {
    float pulso = sin(animacion * TWO_PI) * 0.5 + 0.5;  // Valor entre 0 y 1
    
    // Diferentes animaciones según el tipo de dispositivo
    if (nombre.contains("Ventilación")) {
      // Animación de ventilador girando
      pushMatrix();
      translate(x + 60, y + 35);
      rotate(animacion * TWO_PI * 2);  // Rotación del ventilador
      fill(100, 200, 255, 150 + int(pulso * 100));
      for (int i = 0; i < 4; i++) {
        pushMatrix();
        rotate(i * PI/2);
        ellipse(0, -10, 5, 15);
        popMatrix();
      }
      fill(200, 200, 255);
      ellipse(0, 0, 10, 10);  // Centro del ventilador
      popMatrix();
    } 
    else if (nombre.contains("Iluminación")) {
      // Animación de luz brillante
      float tamanio = 15 + pulso * 10;
      
      // Rayos de luz
      stroke(255, 255, 100, 150 + int(pulso * 100));
      strokeWeight(2);
      for (int i = 0; i < 8; i++) {
        float ang = i * PI/4;
        float longRayo = 10 + pulso * 15;
        line(x + 60, y + 35, 
             x + 60 + cos(ang) * longRayo, 
             y + 35 + sin(ang) * longRayo);
      }
      
      // Centro brillante
      noStroke();
      fill(255, 255, 100, 150 + int(pulso * 100));
      ellipse(x + 60, y + 35, tamanio, tamanio);
      
      strokeWeight(1);
    } 
    else if (nombre.contains("Workspace")) {
      // Animación de computadora/workspace
      float tamanio = 6 + pulso * 4;
      
      // Monitor con señal pulsante
      fill(150, 255, 150, 100 + int(pulso * 150));
      rect(x + 50, y + 25, 20, 15, 2);
      
      // Luz indicadora
      fill(100, 255, 100, 150 + int(pulso * 100));
      ellipse(x + 60, y + 35, tamanio, tamanio);
    }
  }
}

PImage createIconPlaceholder(color c) {
  // Crea un ícono placeholder si no existen las imágenes
  PImage img = createImage(100, 100, ARGB);
  img.loadPixels();
  for (int i = 0; i < img.pixels.length; i++) {
    float x = i % 100;
    float y = i / 100;
    float d = dist(x, y, 50, 50);
    if (d < 40) {
      img.pixels[i] = c;
    } else {
      img.pixels[i] = color(0, 0); // Transparente
    }
  }
  img.updatePixels();
  return img;
}

void mousePressed() {
  if (pantalla == 0) {
    for (Button b : botones) {
      if (b.isHovered()) {
        if (b.label.equals("Ocupación Computadoras")) {
          pantalla = 4; // Redirige a "Workspace tiempo real"
        } else if (b.label.equals("Estado Oficina")) {
          pantalla = 5; // Redirige a "Estado Oficina"
        } else if (b.label.equals("Entrada a Oficina")) {
          pantalla = 1;
        } else if (b.label.equals("Uso Workspace")) {
          pantalla = 6; // Redirige a "Uso Workspace"
        }
      }
    }
  } 
  else if (pantalla == 1) {
    if (btnTomarFoto.isHovered()) {
      if (cam == null) {
        String[] cameras = Capture.list();
        if (cameras.length == 0) {
          println("No se detectaron cámaras.");
        } else {
          cam = new Capture(this, cameras[0]);
          cam.start();
          pantalla = 2;
        }
      } else {
        cam.start();
        pantalla = 2;
      }
    }
    if (btnSubirFoto.isHovered()) {
      selectInput("Selecciona una foto:", "fileSelected"); // Abre el explorador de archivos
    }
    if (btnRegresar.isHovered()) {
      pantalla = 0;
    }
  } 
  else if (pantalla == 2) {
    if (btnCapturar.isHovered()) {
      println("Capturando foto...");
      ultimaFoto = cam.get();
      String nombreArchivo = "captura_" + year() + month() + day() + "_" + hour() + minute() + second() + ".jpg";
      ultimaRuta = sketchPath("img/" + nombreArchivo);
      ultimaFoto.save(ultimaRuta);
      println("Foto guardada como: " + ultimaRuta);
      pantalla = 3; // Ir a vista previa
    }
    if (btnRegresarTomarFoto.isHovered()) {  // Regresar a la vista de reconocimiento facial
      pantalla = 1;
    }
  } 
  else if (pantalla == 3) {
    if (btnSubir.isHovered()) {
      String archivoSubir = (rutaSeleccionada != null) ? rutaSeleccionada : ultimaRuta;
      println("Subiendo foto a S3: " + archivoSubir);
    
      String pythonPath = "\"C:\\Users\\nyavi\\AppData\\Local\\Programs\\Python\\Python311\\python.exe\"";
      String scriptPath = "\"" + sketchPath("subir_a_s3.py") + "\"";
      String filePath = "\"" + archivoSubir + "\"";
      String comando = pythonPath + " " + scriptPath + " " + filePath;
    
      try {
        Process p = Runtime.getRuntime().exec(comando);
    
        BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
        BufferedReader stdError = new BufferedReader(new InputStreamReader(p.getErrorStream()));
    
        String s;
        while ((s = stdInput.readLine()) != null) {
          println("[PYTHON] " + s);
        }
        while ((s = stdError.readLine()) != null) {
          println("[PYTHON ERROR] " + s);
        }
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    if (btnRegresarSubirFoto.isHovered()) {  // Regresar a la vista de reconocimiento facial
      pantalla = 1;
    }
  }
  // Regresar al menú desde Workspace
  else if (pantalla == 4 && btnRegresarWorkspace.isHovered()) {
    pantalla = 0;
  }
  // Regresar al menú desde Estado Oficina
  else if (pantalla == 5) {
    if (btnRegresarEstadoOficina.isHovered()) {
      pantalla = 0;
    }
    
    // Toggle estados al hacer clic en los paneles
    // Ventilación
    if (mouseX > 50 && mouseX < 250 && mouseY > 90 && mouseY < 210) {
      ventilacionOn = !ventilacionOn;
    }
    // Iluminación
    if (mouseX > 350 && mouseX < 550 && mouseY > 90 && mouseY < 210) {
      iluminacionOn = !iluminacionOn;
    }
    // Workspace Pablo
    if (mouseX > 50 && mouseX < 250 && mouseY > 240 && mouseY < 360) {
      workspacePabloOn = !workspacePabloOn;
    }
    // Workspace René
    if (mouseX > 350 && mouseX < 550 && mouseY > 240 && mouseY < 360) {
      workspaceReneOn = !workspaceReneOn;
    }
  }
  // Regresar al menú desde Uso Workspace
  else if (pantalla == 6 && btnRegresarUsoWorkspace.isHovered()) {
    pantalla = 0;
  }
}

void drawComputer(float x, float y, String nombre, boolean ocupada) {
  fill(255);
  rect(x, y, 200, 100, 20); // Caja para la computadora con bordes redondeados
  fill(0);
  textSize(20);
  textAlign(CENTER);
  text(nombre, x + 100, y + 30); // Título de la computadora

  // Indicador de ocupación
  if (ocupada) {
    fill(255, 0, 0); // Rojo para "Ocupada"
    rect(x + 50, y + 60, 100, 30); // Rectángulo de ocupación
    fill(255);
    textSize(16);
    text("Ocupado", x + 100, y + 80);
  } else {
    fill(0, 255, 0); // Verde para "Desocupado"
    rect(x + 50, y + 60, 100, 30); // Rectángulo de ocupación
    fill(255);
    textSize(16);
    text("Desocupado", x + 100, y + 80);
  }
}

void fileSelected(File selection) {
  if (selection != null) {
    rutaSeleccionada = selection.getAbsolutePath();  // Guardamos la ruta del archivo seleccionado
    imagenSeleccionada = loadImage(rutaSeleccionada);  // Cargamos la imagen
    pantalla = 3; // Cambiar a la pantalla de vista previa
  } else {
    println("No se seleccionó ninguna foto.");
  }
}

class Button {
  String label;
  float x, y, w, h;
  color c;

  Button(String label, float x, float y, float w, float h, color c) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.c = c;
  }

  void display() {
    if (isHovered()) {
      fill(lerpColor(c, color(255), 0.3));
    } else {
      fill(c);
    }
    noStroke();
    rect(x, y, w, h, 10);

    fill(255);
    textSize(20);
    textAlign(CENTER, CENTER);
    text(label, x + w / 2, y + h / 2);
  }

  boolean isHovered() {
    return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
  }
}
