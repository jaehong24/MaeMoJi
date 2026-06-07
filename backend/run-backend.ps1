# MaeMoJi 백엔드를 로컬에서 쉽게 실행하기 위한 스크립트입니다.
# JDK 경로를 먼저 고정하고, 필요한 경우 JAR를 다시 빌드한 뒤 실행합니다.

param(
    [switch]$BuildFirst
)

$ErrorActionPreference = "Stop"

# 현재 개발 환경에서 확인된 JDK 17 경로를 기본값으로 사용합니다.
$javaHome = "C:\jdk-17.0.0.1"
$jarPath = Join-Path $PSScriptRoot "build\libs\maemoji-backend-0.0.1-SNAPSHOT.jar"

if (-not (Test-Path $javaHome)) {
    throw "JDK 경로를 찾을 수 없습니다: $javaHome"
}

$env:JAVA_HOME = $javaHome
$env:Path = "$javaHome\bin;$env:Path"

if ($BuildFirst -or -not (Test-Path $jarPath)) {
    # 최초 실행이거나 코드가 바뀐 경우 JAR를 다시 생성합니다.
    & (Join-Path $PSScriptRoot "gradlew.bat") bootJar --console=plain --no-daemon

    if ($LASTEXITCODE -ne 0) {
        throw "Spring Boot JAR 빌드에 실패했습니다."
    }
}

# 생성된 JAR를 실행하면 bootRun보다 환경 차이가 적고 재현성이 좋습니다.
& "$javaHome\bin\java.exe" -jar $jarPath
