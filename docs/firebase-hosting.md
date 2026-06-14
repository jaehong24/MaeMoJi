# MaeMoJi Firebase Hosting 배포 가이드

MaeMoJi 웹앱을 iPhone Safari에서도 접속할 수 있게 배포하는 절차입니다.

## 1. Firebase 프로젝트 확인

- 현재 Android 설정 기준 Firebase 프로젝트 ID는 `maemoji-c4302` 입니다.
- 이 저장소에는 이미 [.firebaserc](C:/Users/icand/Documents/MaeMoJi/.firebaserc) 가 추가되어 있어 기본 프로젝트가 연결되도록 맞춰두었습니다.

## 2. Firebase CLI 설치

PowerShell에서 한 번만 설치합니다.

```powershell
npm install -g firebase-tools
```

설치 후 로그인합니다.

```powershell
firebase login
```

## 3. 운영용 웹 빌드

MaeMoJi 웹은 운영 WAS를 바라보도록 빌드해야 합니다.

```powershell
flutter build web --release --dart-define=API_BASE_URL=https://maemoji-ig16.onrender.com
```

빌드 결과물은 `build/web` 아래에 생성됩니다.

## 4. Firebase Hosting 배포

이 저장소 루트에서 아래 명령을 실행합니다.

```powershell
firebase deploy --only hosting
```

배포가 완료되면 Firebase Hosting URL이 출력됩니다.

## 5. iPhone 테스트

- iPhone Safari에서 배포 URL 접속
- 로그인, 홈, 포트폴리오, 상세 화면 확인
- 필요하면 Safari 공유 메뉴에서 `홈 화면에 추가`

## 6. 중요 체크

- 현재 앱은 웹에서도 `API_BASE_URL` 을 명시하면 운영 WAS `https://maemoji-ig16.onrender.com` 를 호출합니다.
- 웹은 브라우저 CORS 정책이 있으므로, Firebase Hosting 도메인에서 Render WAS 호출이 막히면 백엔드에 CORS 허용 설정이 추가로 필요할 수 있습니다.
- Flutter Web 배포와 Android 앱 배포는 별개입니다. 웹은 Firebase Hosting, Android APK는 기존 방식 그대로 유지됩니다.

## 자주 쓰는 명령

로컬 웹 실행:

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=https://maemoji-ig16.onrender.com
```

운영 배포:

```powershell
flutter build web --release --dart-define=API_BASE_URL=https://maemoji-ig16.onrender.com
firebase deploy --only hosting
```
