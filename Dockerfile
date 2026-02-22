    # Etapa 1: Construcción con Maven
    FROM maven:3.9.6-eclipse-temurin-21 AS build

    # Establecer el directorio de trabajo
    WORKDIR /app

    # Copiar el pom.xml y descargar dependencias (aprovecha el cache de Docker)
    COPY pom.xml .
    RUN mvn dependency:go-offline

    # Copiar el resto del código fuente y construir el JAR
    COPY src ./src
    RUN mvn clean package -DskipTests

    # Etapa 2: Ejecución con una imagen JRE ligera y válida
    FROM eclipse-temurin:21-jre-alpine

    # Establecer el directorio de trabajo
    WORKDIR /app

    # Copiar el JAR desde la etapa de construcción
    COPY --from=build /app/target/eureka-*.jar app.jar

    # Exponer el puerto en el que corre la aplicación
    EXPOSE 8085

    # Comando para ejecutar la aplicación
    # Los perfiles y la configuración se pasarán como variables de entorno
    ENTRYPOINT ["java", "-jar", "app.jar"]
