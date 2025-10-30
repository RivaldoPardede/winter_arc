allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(file("../build"))

subprojects {
    project.layout.buildDirectory.set(file("${rootProject.layout.buildDirectory.get()}/${project.name}"))
}

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects.forEach { project ->
      project.tasks.withType(JavaCompile) {
          options.compilerArgs += ['-Xlint:deprecation']
      }
  }

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
