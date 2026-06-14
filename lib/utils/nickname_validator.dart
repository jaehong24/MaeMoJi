class NicknameValidator {
  const NicknameValidator._();

  static final RegExp _allowedCharacters = RegExp(r'^[0-9A-Za-z가-힣_]+$');

  static String? validate(String value) {
    final nickname = value.trim();
    if (nickname.isEmpty) {
      return '닉네임을 입력해주세요.';
    }
    if (nickname.length < 2) {
      return '닉네임이 너무 짧아요. 2자 이상 입력해주세요.';
    }
    if (nickname.length > 12) {
      return '닉네임이 너무 길어요. 12자 이하로 입력해주세요.';
    }
    if (nickname.contains(RegExp(r'\s'))) {
      return '닉네임에는 띄어쓰기를 사용할 수 없어요.';
    }
    if (!_allowedCharacters.hasMatch(nickname)) {
      return '닉네임에는 한글, 영문, 숫자, 밑줄(_)만 사용할 수 있어요.';
    }
    return null;
  }

  static bool isValid(String value) => validate(value) == null;
}
