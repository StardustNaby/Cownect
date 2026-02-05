allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Fix para isar_flutter_libs: especificar namespace requerido por AGP 8.0+
// El namespace debe coincidir con el package del AndroidManifest.xml
// Forzar que todos los subproyectos usen la misma versión de Gradle
subprojects {
    afterEvaluate {
        // Actualizar gradle-wrapper.properties si existe
        val wrapperProps = file("${project.projectDir}/gradle/wrapper/gradle-wrapper.properties")
        if (wrapperProps.exists()) {
            var content = wrapperProps.readText()
            // Reemplazar cualquier versión de Gradle con 8.13
            content = content.replace(
                Regex("distributionUrl=.*gradle-.*\\.zip"),
                "distributionUrl=https\\://services.gradle.org/distributions/gradle-8.13-bin.zip"
            )
            wrapperProps.writeText(content)
        }
    }
}

subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            compileSdk = 36  // Forzar compileSdk 36 para todos los subproyectos
        }
        
        if (project.name == "isar_flutter_libs") {
            extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                namespace = "dev.isar.isar_flutter_libs"
            }
            
            // Eliminar el atributo package del AndroidManifest.xml (requerido por AGP 8.0+)
            // El AndroidManifest está en el cache de pub
            tasks.matching { it.name.startsWith("process") && it.name.contains("Manifest") }.configureEach {
                doFirst {
                    val manifestFile = file("${project.projectDir}/src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        var content = manifestFile.readText()
                        // Eliminar el atributo package del tag manifest
                        // Buscar y eliminar package="..." o package='...'
                        content = content.replace(
                            Regex("\\s+package\\s*=\\s*[\"'][^\"']*[\"']"),
                            ""
                        )
                        manifestFile.writeText(content)
                    }
                }
            }
        }
    }
}

// Forzar resolución de dependencias de androidx.core para compatibilidad
subprojects {
    project.configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.core") {
                useVersion("1.12.0")
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
